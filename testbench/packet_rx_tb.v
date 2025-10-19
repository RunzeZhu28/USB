`include "define.v"
`timescale  1ns/100ps
module packet_rx_tb;

reg         clk;
reg         rst_n;
reg         rx_start;
reg         rx_finish;
reg  		    rx_status;  
reg         rx_bit;
wire [3:0] rx_packet_pid; 
wire rx_packet_pid_valid; 
wire [10:0] rx_packet_addr;
wire [7:0] rx_packet_byte;
wire rx_packet_byte_en;
wire rx_packet_valid;
wire rx_packet_fin;         

packet_rx u_packet_rx(
    .clk       (clk),        
    .rst_n     (rst_n),  
    .rx_start  (rx_start), //1: start RX
    .rx_finish (rx_finish), //1: RX finsh
    .rx_status (rx_status), //1: have rx_bit
    .rx_bit    (rx_bit),
    .rx_packet_pid (rx_packet_pid),
    .rx_packet_pid_valid (rx_packet_pid_valid),              //check if pid is valid
    .rx_packet_addr (rx_packet_addr),
    .rx_packet_byte (rx_packet_byte),  // for data packet
    .rx_packet_byte_en (rx_packet_byte_en),     //when data packet data is valid
    .rx_packet_valid (rx_packet_valid),	// check crc, if no crc, it is same as pid valid
    .rx_packet_fin   (rx_packet_fin)        //when one packet is complete
);


//real clk_period = 16.666;  // nanoseconds
parameter FREQ = 60e6;

initial begin
  clk = 0;
  forever begin
    //#(clk_period/2) clk = ~clk;
	 #(1e9/(2.0 * FREQ)) clk = ~clk;
  end
end

initial begin
   rst_n = 1'b0;
	rx_start = 1'b0;
	rx_finish = 1'b0;
	rx_status = 1'b0;
	rx_bit    = 1'b0;
   #200 rst_n = 1'b1;
end

initial begin
  @(posedge rst_n); //wait for reset finished

  rx_start = 1'b1;  //start the packet
  repeat(5) @(posedge clk);
  // status = 1 for every five clk cycle
  //Token packet,OUT PID: 4'b0001, PID:11100001, address: 10101100111, crc should be 00110
  rx_start = 1'b0;
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk); //pid finished
  
  
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);

  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);   // addr finished
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_finish = 1'b1;
  @(posedge clk);
  rx_finish = 1'b0;
  repeat(14) @(posedge clk);  //IDLE for 15 cycles
  
  
  //ACK packet,ACK PID: 4'b0010, PID:11010010
  rx_finish = 1'b0;
  rx_start = 1'b1;  //start the packet
  repeat(5) @(posedge clk);
  rx_start = 1'b0;
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);  //pid finished
  
  rx_finish = 1'b1;
  @(posedge clk);
  rx_finish = 1'b0;
  repeat(14) @(posedge clk); //finish, IDLE for 15 cycles
  
  //Data packet,MDATA_PID 4'b1111 PID:00001111, data: 100010100110010101100111, crc should be 0001011110010101
  rx_start = 1'b1;  //start the packet
  repeat(5) @(posedge clk);
  
  rx_start = 1'b0;
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk); //PID finished
  
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);

  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk); //data finished
  
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b1;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_status = 1'b1;
  rx_bit = 1'b0;
  @(posedge clk);
  rx_status = 1'b0;
  repeat(4) @(posedge clk);
  
  rx_finish = 1'b1;
  @(posedge clk);
  rx_finish = 1'b0;
  repeat(14) @(posedge clk);  //IDLE for 15 cycles
  $stop;
end

endmodule