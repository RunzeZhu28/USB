vlib work
vlog -sv +acc E:\\USB\\define.v E:\\USB\\packet_rx.v E:\\USB\\testbench\\packet_rx_tb.v 
vsim -voptargs=+acc work.packet_rx_tb           
add wave -r sim:/packet_rx_tb/*
run -all
