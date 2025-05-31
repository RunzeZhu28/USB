`include "define.v"
module bit_level(   //full-speed 12Mb/s     83.3us
input wire clk, //60MHz, 5 times per bit
input wire rst_n,
input wire rx_dp,
input wire rx_dn,
output reg tx_dp,
output reg tx_dn,
output wire oe,  //1:TX, 0:RX
output reg rx_status //1: start RX
);

reg [4:0] dp = 5'b0;
reg [4:0] dn = 5'b0;
wire dpv;
wire dnv;
wire is_j;
assign dpv = (dp[3] & dp[2]) | (dp[1] & dp[2]) | (dp[1] & dp[3]);
assign dnv = (dn[3] & dn[2]) | (dn[1] & dn[2]) | (dn[1] & dn[3]);
assign is_j = dp[0] & (!dn[0]);

localparam [`SYNC_WIDTH-1:0] SYNC_PATTERN = `SYNC_PATTERN;

localparam [3:0] J_WAIT = 4'd0;
localparam [3:0] IDLE = 4'd1;
localparam [3:0] SYNC = 4'd2;
localparam [3:0] DATA = 4'd3;
reg [3:0] state;
reg [5:0] wait_cnt = 6'b0;
reg [2:0] clk_cnt = 3'd0;
reg [3:0] sync_bit = 4'd0;

always@(posedge clk or negedge rst_n) begin//five bits because 60M/12M

	if(!rst_n) begin
		dp <= 5'b0;
		dn <= 5'b0;
	end
	
	else begin
		dp <= {dp[3:0],rx_dp};
		dn <= {dn[3:0],rx_dn};
	end
end


always@(posedge clk or negedge rst_n) begin

	if(!rst_n) begin
		wait_cnt <= 6'b0;
		clk_cnt <= 3'd4;
		sync_bit <= 4'd0;
		rx_status <= 1'b0;
		state <= J_WAIT;
	end
	
	else begin
		case(state)
		
			J_WAIT: begin
			
				if(!is_j) 
					wait_cnt <= 6'b0;
				
				else if (wait_cnt < `CNT_RX)
					wait_cnt <= wait_cnt + 1'b1;
				
				else begin
					wait_cnt <= 6'b0;
					state <= IDLE;
				end			
			end
			
			IDLE: begin
				
				if(is_j) 
					state <= IDLE;
					
				else if (dn[0] & (!dp[0])) begin
					clk_cnt <= 3'd3;  //already taken one here, so 3
					state <= SYNC;
				end
				
				else
					state <= J_WAIT; //go back to wait
			end
			
			SYNC: begin
			
				if(clk_cnt != 0)
					clk_cnt <= clk_cnt - 1;
					
				else if (sync_bit < 8) begin
					if(dpv == SYNC_PATTERN[sync_bit] && dnv != SYNC_PATTERN[sync_bit]) begin
						sync_bit <= sync_bit + 1;
						clk_cnt <= clk_cnt + 1;
					end
					
					else begin
						sync_bit <= 4'd0;
						clk_cnt <= 3'd4;
					end
				end
				
				else begin
					state <= DATA;
					rx_status <= 1'b0;
				end
			end
			
			DATA: begin
				
			end
			
			default: begin
				state <= J_WAIT;
			end
		endcase
	end
end


endmodule