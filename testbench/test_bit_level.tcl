vlib work
vlog -sv +acc E:\\USB\\define.v E:\\USB\\bit_level.v E:\\USB\\testbench\\bit_level_tb.v 
vsim -voptargs=+acc work.bit_level_tb           
add wave -r sim:/bit_level_tb/*
add wave -r sim:/bit_level_tb/u_bit_level/*
run -all
