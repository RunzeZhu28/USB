module packet_rx(
input clk,
input rst_n,
input rx_start, //1: start RX
input rx_finish, //1: RX finsh
input rx_status, //1: have rx_bit
input rx_bit,
output reg [3:0] rx_packet_pid,
output reg rx_packet_pid_valid,              //check if pid is valid
output reg [10:0] rx_packet_addr,
output reg [7:0] rx_packet_byte,  // for data packet
output reg rx_packet_byte_en,     //when data packet data is valid
output reg rx_packet_valid,	// check crc, if no crc, it is same as pid valid
output reg rx_packet_fin          //when one packet is complete
);


function  [4:0] CRC5; //G=100101
    input [4:0] crc;
    input       inbit;
    reg         xorbit;
begin
    xorbit = crc[4] ^ inbit;
    CRC5   = {crc[3:0],1'b0} ^ {2'b0,xorbit,1'b0,xorbit};
end
endfunction


function  [15:0] CRC16;  //G=11000000000000101
    input [15:0] crc;
    input        inbit;
    reg          xorbit;
begin
    xorbit = crc[15] ^ inbit;
    CRC16  = {crc[14:0],1'b0} ^ {xorbit,12'b0,xorbit,1'b0,xorbit};
end
endfunction


reg [23:0] rx_packet_data;  // For token: PID:8 + FrameNumber: 11 + CRC5 = 24 ， 3 bytes
reg [1:0]  rx_packet_byte_cnt;  //  Need 3 byte
reg [2:0] rx_cnt; // count to 8
reg [4:0]  rx_crc_delay; // Need to delay some periods for comparison
reg [4:0] rx_crc5;
reg [15:0] rx_crc16;   

always@(posedge clk or negedge rst_n)
	if (!rst_n) begin
		rx_packet_pid  <= 4'b0;
		rx_packet_pid_valid <= 1'b0;
		rx_packet_addr <= 11'b0;
		rx_packet_byte <= 8'b0;
		rx_packet_byte_en <= 1'b0;
		rx_packet_valid  <= 1'b0;
		rx_packet_data <= 24'b0;
		rx_packet_byte_cnt <= 2'b0;
		rx_crc_delay <= 5'b0;
		rx_cnt <= 1'b0;
		rx_crc5    <= 5'h1F;
		rx_crc16   <= 16'hFFFF;
	end
	else begin
		rx_packet_byte_en <= 1'b0;
		if (rx_start) begin
			rx_packet_pid  <= 4'b0;
			rx_packet_pid_valid <= 1'b0;
			rx_packet_addr <= 11'b0; // May remove this as we are using rx_packet_valid as the enable
			rx_packet_byte <= 8'b0;  // May remove this as we are using rx_packet_valid as the enable
			rx_packet_valid  <= 1'b0;
			rx_packet_data <= 24'b0;
			rx_packet_byte_cnt <= 2'b0;
			rx_crc_delay <= 5'b0;
			rx_cnt <= 1'b0;
			rx_crc5    <= 5'h1F;
			rx_crc16   <= 16'hFFFF;
		end
		else if (rx_status) begin
			rx_cnt <= rx_cnt + 1;
			rx_packet_data <= {rx_bit, rx_packet_data[23:1]}; //LSB comes in first
			if(rx_packet_byte_cnt != 2'b0) begin  //Finish pid, will need to check CRC now
				if (rx_crc_delay >= 5'd5)   //Last 5 bits are CRC so not needed in calculation, delay 5 bits so that they are not included in calculating CRC.
					rx_crc5  <= CRC5(rx_crc5, rx_packet_data[19]);
            if (rx_crc_delay >= 5'd16)
               rx_crc16 <= CRC16(rx_crc16, rx_packet_data[8]);
            if (rx_crc_delay != 5'd31)
               rx_crc_delay <= rx_crc_delay + 5'd1;
			end
			
			if(rx_cnt == 7) begin  // 111 + 1 is 000, so no need to reset to 0 manually here, already 7 bits, this new bit is the 8th, and now makes one byte
				if(rx_packet_byte_cnt == 2'b0) begin  //pid
					if({rx_bit,rx_packet_data[23:21]} == ~rx_packet_data[20:17]) begin  //LSB is the original value, MSB to the inverse
						rx_packet_pid_valid <= 1'b1;
						rx_packet_pid <= rx_packet_data[20:17];
					end
				end
				else if (rx_packet_byte_cnt == 2'd2 && rx_packet_pid_valid && rx_packet_pid[1:0] == 2'b01) begin //in token packet,11 bits addr, need 2 bytes(include some crc bits)
						rx_packet_addr <= rx_packet_data[19:9];
				end
				else if (rx_packet_byte_cnt == 2'd3 && rx_packet_pid_valid && rx_packet_pid[1:0] == 2'b11) begin // in data packet, Delay 2 bytes from getting data because last 2 bytes are CRC16 which is not needed to send out.
					rx_packet_byte <= rx_packet_data[8:1];
					rx_packet_byte_en <= 1'b1;
				end
				else if (rx_packet_byte_cnt != 2'd3) begin
					rx_packet_byte_cnt <= rx_packet_byte_cnt + 1; // 2'd3 stays at 2'd3 for data
				end
			end 
		end
	end
 
always@(posedge clk or negedge rst_n)
	if(!rst_n) begin
		rx_packet_valid <= 1'b0;
		rx_packet_fin <= 1'b0;
	end
	else begin
		rx_packet_fin <= rx_finish; // finish goes high need some time due to checking EOF
		case(rx_packet_pid[1:0])
			2'b00: rx_packet_valid <= 1'b0; // special packet
			2'b01: rx_packet_valid <= rx_packet_pid_valid && (~{rx_crc5[0],rx_crc5[1],rx_crc5[2],rx_crc5[3],rx_crc5[4]} == rx_packet_data[23:19]); // token packet
			2'b10: rx_packet_valid <= rx_packet_pid_valid; //handshake packet
			2'b11: rx_packet_valid <= rx_packet_pid_valid && (~{rx_crc16[0],rx_crc16[1],rx_crc16[2],rx_crc16[3],rx_crc16[4],rx_crc16[5],rx_crc16[6],rx_crc16[7],rx_crc16[8],rx_crc16[9],rx_crc16[10],rx_crc16[11],rx_crc16[12],rx_crc16[13],rx_crc16[14],rx_crc16[15]} == rx_packet_data[23:8]);//data packet
			default: rx_packet_valid <= 1'b0; 
		endcase
	end

endmodule