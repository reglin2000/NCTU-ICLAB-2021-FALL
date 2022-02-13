###################################################################

# Created by write_sdc on Fri Nov 5 01:37:19 2021

###################################################################
set sdc_version 2.0

set_units -time ns -resistance kOhm -capacitance pF -power mW -voltage V -current mA
set_wire_load_mode top
create_clock [get_ports clk]  -period 8.8  -waveform {0 4.4}
set_input_delay -clock clk   0  [get_ports clk]
set_input_delay -clock clk   0  [get_ports rst_n]
set_input_delay -clock clk   4.4  [get_ports in_valid]
set_input_delay -clock clk   4.4  [get_ports in_valid_2]
set_input_delay -clock clk   4.4  [get_ports {image[15]}]
set_input_delay -clock clk   4.4  [get_ports {image[14]}]
set_input_delay -clock clk   4.4  [get_ports {image[13]}]
set_input_delay -clock clk   4.4  [get_ports {image[12]}]
set_input_delay -clock clk   4.4  [get_ports {image[11]}]
set_input_delay -clock clk   4.4  [get_ports {image[10]}]
set_input_delay -clock clk   4.4  [get_ports {image[9]}]
set_input_delay -clock clk   4.4  [get_ports {image[8]}]
set_input_delay -clock clk   4.4  [get_ports {image[7]}]
set_input_delay -clock clk   4.4  [get_ports {image[6]}]
set_input_delay -clock clk   4.4  [get_ports {image[5]}]
set_input_delay -clock clk   4.4  [get_ports {image[4]}]
set_input_delay -clock clk   4.4  [get_ports {image[3]}]
set_input_delay -clock clk   4.4  [get_ports {image[2]}]
set_input_delay -clock clk   4.4  [get_ports {image[1]}]
set_input_delay -clock clk   4.4  [get_ports {image[0]}]
set_input_delay -clock clk   4.4  [get_ports {img_size[4]}]
set_input_delay -clock clk   4.4  [get_ports {img_size[3]}]
set_input_delay -clock clk   4.4  [get_ports {img_size[2]}]
set_input_delay -clock clk   4.4  [get_ports {img_size[1]}]
set_input_delay -clock clk   4.4  [get_ports {img_size[0]}]
set_input_delay -clock clk   4.4  [get_ports {template[15]}]
set_input_delay -clock clk   4.4  [get_ports {template[14]}]
set_input_delay -clock clk   4.4  [get_ports {template[13]}]
set_input_delay -clock clk   4.4  [get_ports {template[12]}]
set_input_delay -clock clk   4.4  [get_ports {template[11]}]
set_input_delay -clock clk   4.4  [get_ports {template[10]}]
set_input_delay -clock clk   4.4  [get_ports {template[9]}]
set_input_delay -clock clk   4.4  [get_ports {template[8]}]
set_input_delay -clock clk   4.4  [get_ports {template[7]}]
set_input_delay -clock clk   4.4  [get_ports {template[6]}]
set_input_delay -clock clk   4.4  [get_ports {template[5]}]
set_input_delay -clock clk   4.4  [get_ports {template[4]}]
set_input_delay -clock clk   4.4  [get_ports {template[3]}]
set_input_delay -clock clk   4.4  [get_ports {template[2]}]
set_input_delay -clock clk   4.4  [get_ports {template[1]}]
set_input_delay -clock clk   4.4  [get_ports {template[0]}]
set_input_delay -clock clk   4.4  [get_ports {action[1]}]
set_input_delay -clock clk   4.4  [get_ports {action[0]}]
set_output_delay -clock clk  4.4  [get_ports out_valid]
set_output_delay -clock clk  4.4  [get_ports {out_x[3]}]
set_output_delay -clock clk  4.4  [get_ports {out_x[2]}]
set_output_delay -clock clk  4.4  [get_ports {out_x[1]}]
set_output_delay -clock clk  4.4  [get_ports {out_x[0]}]
set_output_delay -clock clk  4.4  [get_ports {out_y[3]}]
set_output_delay -clock clk  4.4  [get_ports {out_y[2]}]
set_output_delay -clock clk  4.4  [get_ports {out_y[1]}]
set_output_delay -clock clk  4.4  [get_ports {out_y[0]}]
set_output_delay -clock clk  4.4  [get_ports {out_img_pos[7]}]
set_output_delay -clock clk  4.4  [get_ports {out_img_pos[6]}]
set_output_delay -clock clk  4.4  [get_ports {out_img_pos[5]}]
set_output_delay -clock clk  4.4  [get_ports {out_img_pos[4]}]
set_output_delay -clock clk  4.4  [get_ports {out_img_pos[3]}]
set_output_delay -clock clk  4.4  [get_ports {out_img_pos[2]}]
set_output_delay -clock clk  4.4  [get_ports {out_img_pos[1]}]
set_output_delay -clock clk  4.4  [get_ports {out_img_pos[0]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[39]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[38]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[37]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[36]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[35]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[34]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[33]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[32]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[31]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[30]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[29]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[28]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[27]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[26]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[25]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[24]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[23]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[22]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[21]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[20]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[19]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[18]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[17]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[16]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[15]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[14]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[13]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[12]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[11]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[10]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[9]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[8]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[7]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[6]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[5]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[4]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[3]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[2]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[1]}]
set_output_delay -clock clk  4.4  [get_ports {out_value[0]}]
