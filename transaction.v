module transaction(
input clk,
input rst_n,
input [3:0] rx_packet_pid,
input rx_packet_pid_valid,              
input [10:0] rx_packet_addr,  // we may only need 4 MSB, as we only need Endpoint
input [7:0] rx_packet_byte,
input rx_packet_byte_en,    
input rx_packet_valid,	
input rx_packet_fin,
// endpoint is the special control endpoint

//Support up to 15 endpoints in full speed. Use 4 here.
// endpoint 0x01 data output
output reg  [ 7:0] ep01_data,
output reg         ep01_valid,
// endpoint 0x02 data output
output reg  [ 7:0] ep02_data,
output reg         ep02_valid,
// endpoint 0x03 data output
output reg  [ 7:0] ep03_data,
output reg         ep03_valid,
// endpoint 0x04 data output
output reg  [ 7:0] ep04_data,
output reg         ep04_valid  
);


endmodule