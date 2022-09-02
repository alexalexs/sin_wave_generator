vsim sin_osc_tb_file
add wave -position end  sim:/sin_osc_tb_file/reset
add wave -position end  sim:/sin_osc_tb_file/clk
add wave -position end  sim:/sin_osc_tb_file/complete_tick
add wave -position end  sim:/sin_osc_tb_file/count_uut0_s_uut3
add wave -position end  sim:/sin_osc_tb_file/count_uut1_i0_uut3
add wave -position end  sim:/sin_osc_tb_file/count_rev_uut1_i1_uut3
add wave -position end  sim:/sin_osc_tb_file/count_uut2_s_uut5
add wave -position end  sim:/sin_osc_tb_file/y_uut3_addr_uut4 
add wave -position end  sim:/sin_osc_tb_file/data_uut4_i0_uut5 
add wave -position end  sim:/sin_osc_tb_file/data_sig_uut4_i1_uut5 
add wave -position end  sim:/sin_osc_tb_file/count_rev
add wave -position end -format analog-step -min -100 -max 100 -height 300 sim:/sin_osc_tb_file/y 
add wave -position end  sim:/sin_osc_tb_file/period
add wave -position end  sim:/sin_osc_tb_file/M
add wave -position end  sim:/sin_osc_tb_file/N
run 10240 ps