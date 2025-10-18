module packet_rx(
input clk,
input rst_n,
input rx_start, //1: start RX
input rx_finish, //1: RX finsh
input rx_status, //1: have rx_bit
input rx_bit,
output reg [3:0] rx_packet_pid,
output reg [10:0] rx_packet_addr,
output reg [7:0] rx_packet_byte,
output reg rx_crc_passing
);



reg [23:0] rx_packet_data;  //  PID:8 + FrameNumber: 11 + CRC5 = 24
reg [ 2:0] rx_cnt; // count to 8

always@(posedge clk or negedge rst_n)
	if (!rst_n) begin
		rx_packet_data <= 24'b0;
		rx_cnt <= 1'b0;
	end
	else begin
		if (rx_start) begin
			rx_cnt <= 1'b0;
		end
		else if (rx_status) begin
			rx_cnt <= rx_cnt + 1;
			rx_packet_data <= {rx_bit, rx_packet_data[23:1]}; //LSB comes in first
		end
	end
 

endmodule