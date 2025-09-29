`include "define.v"
module bit_level(   //full-speed 12Mb/s     83.3us  // voltage <--NRZI--> bit
input wire clk, //60MHz, 5 times per bit
input wire rst_n,
input wire rx_dp,
input wire rx_dn,
output reg tx_dp,
output reg tx_dn,
output wire oe,  //1:TX, 0:RX
output reg rx_start, //1: start RX
output reg rx_finish, //1: RX finsh
output reg rx_status, //1: have rx_bit
output reg rx_bit, //only valid when rx_status == 1
output reg rx_error //error in transaction
);

reg [4:0] dp = 5'b0;
reg [4:0] dn = 5'b0;
wire dpv;
wire dnv;
wire is_j;
wire is_k;
wire clk_fast;
wire clk_slow;
assign dpv = (dp[3] & dp[2]) | (dp[1] & dp[2]) | (dp[1] & dp[3]); //most stable three bits
assign dnv = (dn[3] & dn[2]) | (dn[1] & dn[2]) | (dn[1] & dn[3]);
assign is_j = dp[0] & (!dn[0]);
assign is_k = dn[0] & (!dp[0]);
assign clk_fast = ((dp[4] != dp[3])&&(dp[3] == dp[2])&&(dp[2] == dp[1])&&(dp[1] == dp[0]))||((dp[3] != dp[2])&&(dp[2] == dp[1])&&(dp[1] == dp[0]));
assign clk_slow = ((dp[4] == dp[3])&&(dp[3] == dp[2])&&(dp[2] == dp[1])&&(dp[1] != dp[0]))||((dp[4] == dp[3])&&(dp[3] == dp[2])&&(dp[2] == dp[1]));

localparam [`SYNC_WIDTH-1:0] SYNC_PATTERN = `SYNC_PATTERN;

localparam [3:0] J_WAIT = 4'd0;
localparam [3:0] IDLE = 4'd1;
localparam [3:0] SYNC = 4'd2;
localparam [3:0] DATA = 4'd3;
localparam [3:0] STUFF = 4'd4;
localparam [3:0] RX_DONE_1 = 4'd5;
localparam [3:0] RX_DONE_2 = 4'd6;
reg [3:0] state;
reg [5:0] wait_cnt = 6'b0;
reg [2:0] clk_cnt = 3'b0;
reg [3:0] sync_bit = 4'b0;
reg lastdpv = 1'b0;
reg [3:0] stuff_cnt = 4'b0;

always@(posedge clk or negedge rst_n) begin//five bits because 60M/12M, five clk cycles get one bit

	if(!rst_n) begin
		dp <= 5'b0;
		dn <= 5'b0;
		lastdpv <= 1'b0;
	end
	
	else begin
		dp <= {dp[3:0],rx_dp};
		dn <= {dn[3:0],rx_dn};
		if (clk_cnt == 3'b0)
			lastdpv <= dpv;
	end
end


always@(posedge clk or negedge rst_n) begin

	if(!rst_n) begin
		wait_cnt <= 6'b0;
		clk_cnt <= 3'd4;
		sync_bit <= 4'd0;
		rx_start <= 1'b0;
		state <= J_WAIT;
		rx_finish <= 1'b0;
		rx_status <= 1'b0;
		rx_bit <= 1'b0;
		rx_error <= 1'b0;
		stuff_cnt <= 4'b0;
	end
	
	else begin
		rx_start <= 1'b0;
		rx_finish <=1'b0;
		rx_status <= 1'b0;
		clk_cnt   <=  (clk_cnt == 0) ? 3'd4 : (clk_cnt - 1);
		case(state)
		
			J_WAIT: begin
				rx_error <= 1'b0;
				if(!is_j) 
					wait_cnt <= 6'b0;
				
				else if (wait_cnt < `CNT_RX)  //need to be stable for some time
					wait_cnt <= wait_cnt + 1'b1;
				
				else begin
					wait_cnt <= 6'b0;
					state <= IDLE;
				end			
			end
			
			IDLE: begin
				
				if(is_j) 
					state <= IDLE;
					
				else if (is_k) begin
					clk_cnt <= 3'd3;  //already taken one here for this K, so only need to cnt 3,2,1,0 for first bit
					state <= SYNC;
				end
				
				else
					state <= J_WAIT; //go back to wait
			end
			
			SYNC: begin
				
				if (clk_cnt == 0) begin
					if (sync_bit <= 7) begin //clk cnt is 0 and should get a complete bit
						if(dpv == SYNC_PATTERN[sync_bit] && dnv != SYNC_PATTERN[sync_bit]) begin
							if(sync_bit == 7) begin
								state <= DATA;
								clk_cnt <= 3'd4;
								sync_bit <= 4'b0;
								rx_start <= 1'b1;
								stuff_cnt <= 4'b0;
							end
							else begin
								sync_bit <= sync_bit + 1;
								clk_cnt <= 3'd4;
							end
						end
					
						else begin
							sync_bit <= 4'd0;
							clk_cnt <= 3'd4;
							state   <= J_WAIT;
						end
					end
				end

			end
			
			DATA: begin	
			
				if(clk_cnt == 0) begin
				
					if(clk_fast) clk_cnt <= 3'd5;
					
					else if(clk_slow) clk_cnt <= 3'd3;
					
					else clk_cnt <= 3'd4;	
					
					if (dpv == 1 && dnv == 1) begin //SE1 error
						state <= J_WAIT;
						rx_error <= 1'b1;
					end
					
					else if (dpv == 0 && dnv == 0 ) begin //SE0,SE0,J IS EOP
						state <= RX_DONE_1;
						stuff_cnt <= 4'b0;
					end
					else if(dpv == lastdpv) begin
						stuff_cnt <= stuff_cnt + 1;
						if(stuff_cnt == `STUFF_BIT_WIDTH) //next bit is stuff bit, 6 consecutive 1 stuff a 0.
							state <= STUFF;
						else begin  //this bit is 1
							rx_bit <= 1'b1;
							rx_status <= 1'b1;
						end
					end
					
					else begin // this bit is 0
						rx_bit <= 1'b0;
						rx_status <= 1'b1;
					end
				end	
			end
			
			STUFF: begin
				if(clk_cnt == 0) begin
					if (dpv == lastdpv) begin //error
						state <= J_WAIT;
						rx_error <= 1'b1;
					end
					else begin // don't read this stuff bit
						state <= DATA;
						stuff_cnt <= 4'b0;
						rx_status <= 1'b0;
					end
				end
			end
			
			RX_DONE_1: begin
				if(clk_cnt == 0) begin
					if(dpv == 0 && dnv == 0)
						state <= RX_DONE_2;
					else begin
						state <= J_WAIT;
						rx_error <= 1'b1;
					end
				end
			end
			
			RX_DONE_2: begin
				if(clk_cnt == 0) begin
					if(dpv == 1 && dnv == 0) begin
						state <= J_WAIT;
						rx_finish <= 1'b1;
					end
					else begin
						state <= J_WAIT;
						rx_error <= 1'b1;
					end
				end
			end
			
			default: begin
				state <= J_WAIT;
			end
		endcase
	end
end


endmodule