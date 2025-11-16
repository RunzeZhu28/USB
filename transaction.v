// ep00_setup structure:
// |  wLength  |  wIndex   |  wValue   |  bRequest  |  bmRequestType                      |
// |  wLength  |  wIndex   |  wValue   |  bRequest  |  Direction  |  Type   |  Recipient  |
// |  [63:48]  |  [47:32]  |  [31:16]  |  [15:8]    |  [7]        |  [6:5]  |  [4:0]      |
//--------------------------------------------------------------------------------------------------------
`include "define.v"
module transaction(
input clk,
input rst_n,
input [3:0] rx_packet_pid,
input rx_packet_pid_valid,              
input [10:0] rx_packet_addr,  // we may only need 4 MSB, as we only need rx_packet_endpointoint
input [7:0] rx_packet_byte,
input rx_packet_byte_en,    
input rx_packet_valid,	
input rx_packet_fin,
output reg sot,            // start of USB-transfer
output reg sof,            // start of USB-frame
// rx_packet_endpointoint 0 is the special control rx_packet_endpointoint, bidirectional 
output reg  [63:0] ep00_setup_cmd,
//Support up to 15 rx_packet_endpointoints in full speed. Use 4 here.
//One direction out EP
// rx_packet_endpointoint 0x01 data output
output reg  [ 7:0] ep01_data,
output reg         ep01_valid,
// rx_packet_endpointoint 0x02 data output
output reg  [ 7:0] ep02_data,
output reg         ep02_valid,
// rx_packet_endpointoint 0x03 data output
output reg  [ 7:0] ep03_data,
output reg         ep03_valid,
// rx_packet_endpointoint 0x04 data output
output reg  [ 7:0] ep04_data,
output reg         ep04_valid  
);
wire [3:0] rx_packet_endpoint;
assign rx_packet_endpoint = rx_packet_addr[10:7];
reg [3:0] endpoint; 
reg ep00_setup;
reg ep00_data1;  //DATA0/1
//main control
always@(posedge clk or negedge rst_n)
	if(~rst_n) begin
		endpoint <= 0;
		ep00_setup <= 0;
	end
	else begin
		if(rx_packet_fin && rx_packet_valid)  begin
			if (rx_packet_pid == `SETUP_PID) begin // control transfer
				endpoint   <= rx_packet_endpoint;
				if (rx_packet_endpoint == 0) begin
					ep00_setup <= 1'b1;
					ep00_data1 <= 1'b1; //defined in spec, first data in data stage should be DATA1
				end
			end
			else if (rx_packet_pid == `OUT_PID) begin
				endpoint   <= rx_packet_endpoint;
				if (rx_packet_endpoint == 0) begin
					ep00_setup <= 1'b0; // We know this is control transfer and setup finished
				end
			end
			else begin  //not finished tx
			
			end
		end
	end

//RX out
always @ (posedge clk or negedge rst_n)
    if (~rst_n) begin
		  ep00_setup_cmd <=64'h0;
        ep01_data  <= 8'h0;
        ep01_valid <= 1'b0;
        ep02_data  <= 8'h0;
        ep02_valid <= 1'b0;
        ep03_data  <= 8'h0;
        ep03_valid <= 1'b0;
        ep04_data  <= 8'h0;
        ep04_valid <= 1'b0;
    end else begin
        ep01_data  <= 8'h0;
        ep01_valid <= 1'b0;
        ep02_data  <= 8'h0;
        ep02_valid <= 1'b0;
        ep03_data  <= 8'h0;
        ep03_valid <= 1'b0;
        ep04_data  <= 8'h0;
        ep04_valid <= 1'b0;
        if (rx_packet_byte_en) begin
            if (rx_packet_endpoint == 4'd0) begin                                        // rx_packet_endpoint 00 OUT
                if(ep00_setup) begin
						ep00_setup_cmd <= {rx_packet_byte,ep00_setup_cmd[63:8]};               // get the setup command
					 end
            end else if (rx_packet_endpoint == 4'd1) begin                               // rx_packet_endpoint 01 OUT
                ep01_data  <= rx_packet_byte;
                ep01_valid <= 1'b1;
            end else if (rx_packet_endpoint == 4'd2) begin                               // rx_packet_endpoint 02 OUT
                ep02_data  <= rx_packet_byte;
                ep02_valid <= 1'b1;
            end else if (rx_packet_endpoint == 4'd3) begin                               // rx_packet_endpoint 03 OUT
                ep03_data  <= rx_packet_byte;
                ep03_valid <= 1'b1;
            end else if (rx_packet_endpoint == 4'd4) begin                               // rx_packet_endpoint 04 OUT
                ep04_data  <= rx_packet_byte;
                ep04_valid <= 1'b1;
            end
        end
    end
	 

always@(posedge clk or negedge rst_n)
	if (!rst_n) begin
		sot <= 1'b0;
		sof <= 1'b0;
	end 
	else begin
		sot <= 1'b0;
		sof <= 1'b0;
		if(rx_packet_fin && rx_packet_valid)  begin// They are finished and valid, the frame/transfer may start
			sot <= (rx_packet_endpoint == 0) ? (rx_packet_pid == `SETUP_PID) : (rx_packet_pid == `IN_PID || rx_packet_pid == `OUT_PID ) ; //for EP0, only setup
			sof <= rx_packet_pid == `SOF_PID;
		end
	end
	

endmodule