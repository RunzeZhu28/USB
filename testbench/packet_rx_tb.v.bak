`include "define.v"
`timescale  1ns/100ps
module bit_level_tb;

reg         clk;
reg         rst_n;
reg         rx_dp;
reg         rx_dn;
wire        tx_dp;
wire        tx_dn;
wire        oe;
wire        rx_start;
wire        rx_finish;
wire 		   rx_status;  
wire        rx_bit;
wire        rx_error;

bit_level u_bit_level (
    .clk       (clk),        
    .rst_n     (rst_n),     
    .rx_dp     (rx_dp),      
    .rx_dn     (rx_dn),      
    .tx_dp     (tx_dp),      
    .tx_dn     (tx_dn),      
    .oe        (oe),         
    .rx_start  (rx_start),   
    .rx_finish (rx_finish),  
    .rx_status (rx_status),  
    .rx_bit    (rx_bit),     
    .rx_error  (rx_error)    
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
   rx_dp = 1'b0;
   rx_dn = 1'b0;
   #200 rst_n = 1'b1;
end

initial begin
  @(posedge rst_n); //wait for reset finished

  // J for 5 cycles switch to K, meaning not stable
  rx_dp <= 1'b1;
  rx_dn <= 1'b0;
  repeat(5) @(posedge clk);

  // K for another cycle, wait_cnt should return 0
  rx_dp <= 1'b0;
  rx_dn <= 1'b1;
  repeat(2) @(posedge clk);
		
  //stable J goto IDLE state 
  rx_dp <= 1'b1;
  rx_dn <= 1'b0;
  repeat(`CNT_RX+2) @(posedge clk);
    
  rx_dp <= 1'b0;  
  rx_dn <= 1'b1;  // K state -> SOP? No, too much, go back to wait state
  repeat(50) @(posedge clk);
	
  //stable J goto IDLE state 
  rx_dp <= 1'b1;
  rx_dn <= 1'b0;
  repeat(`CNT_RX+1) @(posedge clk);	
  
  rx_dp <= 1'b0;
  rx_dn <= 1'b1;
  repeat(5) @(posedge clk);  //K
  
  rx_dp <= 1'b1;
  rx_dn <= 1'b0;
  repeat(3) @(posedge clk);  //J, check if unstable transmission will cause bit error
  
  rx_dp <= 1'b0;
  rx_dn <= 1'b1;
  repeat(2) @(posedge clk);  //J, check if unstable transmission will cause bit error
  
  rx_dp <= 1'b0;
  rx_dn <= 1'b1;
  repeat(5) @(posedge clk);  //K
  
  rx_dp <= 1'b1;
  rx_dn <= 1'b0;
  repeat(5) @(posedge clk);   //J
  
  rx_dp <= 1'b0;
  rx_dn <= 1'b1;
  repeat(5) @(posedge clk);  //K
  
  rx_dp <= 1'b1;
  rx_dn <= 1'b0;
  repeat(5) @(posedge clk);   //J
  
  rx_dp <= 1'b1;
  rx_dn <= 1'b0;
  repeat(1) @(posedge clk);  //K, check if unstable transmission will cause bit error
  
  rx_dp <= 1'b0;
  rx_dn <= 1'b1;
  repeat(4) @(posedge clk);  //K, check if unstable transmission will cause bit error
  
  rx_dp <= 1'b0;
  rx_dn <= 1'b1;
  repeat(5) @(posedge clk);  //k   later seems not correct for now. Should I still have clock fast and low??

  
  //rx_dp <= 1'b1;
  //rx_dn <= 1'b1;
  //repeat(5) @(posedge clk);  //check error
  
  rx_dp <= 1'b1;
  rx_dn <= 1'b0;
  repeat(35) @(posedge clk);  // 6 same bit, next should be stuff bit  0111111 
  
  rx_dp <= 1'b1;
  rx_dn <= 1'b0;
  repeat(5) @(posedge clk);    //should be error
  
  rx_dp <= 1'b0;
  rx_dn <= 1'b1;
  repeat(5) @(posedge clk);   //stuff bit 0, rx_status should be 0
  
  rx_dp <= 1'b0;
  rx_dn <= 1'b1;
  repeat(15) @(posedge clk);   //same as stuff bit so 111
  
  rx_dp <= 1'b1;
  rx_dn <= 1'b0;
  repeat(5) @(posedge clk);    //0
  
  rx_dp <= 1'b0;
  rx_dn <= 1'b1;
  repeat(5) @(posedge clk);     //0
  
  
  rx_dp <= 1'b0;
  rx_dn <= 1'b0;
  repeat(5) @(posedge clk);     //SE0
  
  //rx_dp <= 1'b0;
  //rx_dn <= 1'b1;
  //repeat(5) @(posedge clk);     //should be error
  
  rx_dp <= 1'b0;
  rx_dn <= 1'b0;
  repeat(5) @(posedge clk);      //SE0
  
  rx_dp <= 1'b1;
  rx_dn <= 1'b0;
  repeat(5) @(posedge clk);     //J,EOP
  
  rx_dp <= 1'b1;
  rx_dn <= 1'b0;
  repeat(5) @(posedge clk);     //go back to idle
  $stop;
end

endmodule