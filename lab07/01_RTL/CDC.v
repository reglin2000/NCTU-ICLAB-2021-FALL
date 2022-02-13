`include "synchronizer.v"
`include "syn_XOR.v"
`include "DESIGN_MODULE.v"

module CDC(// Input signals
			clk_1,
			clk_2,
			clk_3,
			in_valid,
			rst_n,
			message,
			mode,
			CRC,
		  //  Output signals
			out_valid,
			out
			);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------			
input clk_1; 
input clk_2;
input clk_3;			
input rst_n;
input in_valid;
input[59:0]message;
input CRC;
input mode;
output out_valid;
output [59:0]out; 			


//---------------------------------------------------------------------
//   Wire connection                   
//---------------------------------------------------------------------		

wire [59:0] clk1_0_message;
wire [59:0] clk1_1_message;
wire clk1_CRC;
wire clk1_mode;
wire [9  :0] clk1_control_signal;
wire clk1_flag_0;
wire clk1_flag_1;
wire clk1_flag_2;
wire clk1_flag_3;
wire clk1_flag_4;
wire clk1_flag_5;
wire clk1_flag_6;
wire clk1_flag_7;
wire clk1_flag_8;
wire clk1_flag_9;
wire [59:0]clk2_0_out;
wire [59:0]clk2_1_out;
wire clk2_CRC;
wire clk2_mode;
wire [9  :0]clk2_control_signal;
wire clk2_flag_0;
wire clk2_flag_1;
wire clk2_flag_2;
wire clk2_flag_3;
wire clk2_flag_4;
wire clk2_flag_5;
wire clk2_flag_6;
wire clk2_flag_7;
wire clk2_flag_8;
wire clk2_flag_9;

//---------------------------------------------------------------------
// Module connection
//---------------------------------------------------------------------

CLK_1_MODULE M1 (// Input signals
			.clk_1(clk_1),
			.clk_2(clk_2),
			.in_valid(in_valid),
			.rst_n(rst_n),
			.message(message),
			.mode(mode),
			.CRC(CRC),
			// Output signals
			.clk1_0_message(clk1_0_message),
			.clk1_1_message(clk1_1_message),
			.clk1_CRC(clk1_CRC),
			.clk1_mode(clk1_mode),
			.clk1_control_signal(clk1_control_signal),
			.clk1_flag_0(clk1_flag_0),
			.clk1_flag_1(clk1_flag_1),
			.clk1_flag_2(clk1_flag_2),
			.clk1_flag_3(clk1_flag_3),
			.clk1_flag_4(clk1_flag_4),
			.clk1_flag_5(clk1_flag_5),
			.clk1_flag_6(clk1_flag_6),
			.clk1_flag_7(clk1_flag_7),
			.clk1_flag_8(clk1_flag_8),
			.clk1_flag_9(clk1_flag_9)
			);


			
CLK_2_MODULE M2 (// Input signals
			.clk_2(clk_2),
			.clk_3(clk_3),
			.rst_n(rst_n),
			.clk1_0_message(clk1_0_message),
			.clk1_1_message(clk1_1_message),
			.clk1_CRC(clk1_CRC),
			.clk1_mode(clk1_mode),
			.clk1_control_signal(clk1_control_signal),
			.clk1_flag_0(clk1_flag_0),
			.clk1_flag_1(clk1_flag_1),
			.clk1_flag_2(clk1_flag_2),
			.clk1_flag_3(clk1_flag_3),
			.clk1_flag_4(clk1_flag_4),
			.clk1_flag_5(clk1_flag_5),
			.clk1_flag_6(clk1_flag_6),
			.clk1_flag_7(clk1_flag_7),
			.clk1_flag_8(clk1_flag_8),
			.clk1_flag_9(clk1_flag_9),
			// Output signals
			.clk2_0_out(clk2_0_out),
			.clk2_1_out(clk2_1_out),
			.clk2_CRC(clk2_CRC),
			.clk2_mode(clk2_mode),
			.clk2_control_signal(clk2_control_signal),
			.clk2_flag_0(clk2_flag_0),
			.clk2_flag_1(clk2_flag_1),
			.clk2_flag_2(clk2_flag_2),
			.clk2_flag_3(clk2_flag_3),
			.clk2_flag_4(clk2_flag_4),
			.clk2_flag_5(clk2_flag_5),
			.clk2_flag_6(clk2_flag_6),
			.clk2_flag_7(clk2_flag_7),
			.clk2_flag_8(clk2_flag_8),
			.clk2_flag_9(clk2_flag_9)
			);



CLK_3_MODULE M3 (// Input signals
			.clk_3(clk_3),
			.rst_n(rst_n),			
			.clk2_0_out(clk2_0_out),
			.clk2_1_out(clk2_1_out),
			.clk2_CRC(clk2_CRC),
			.clk2_mode(clk2_mode),
			.clk2_control_signal(clk2_control_signal),
			.clk2_flag_0(clk2_flag_0),
			.clk2_flag_1(clk2_flag_1),
			.clk2_flag_2(clk2_flag_2),
			.clk2_flag_3(clk2_flag_3),
			.clk2_flag_4(clk2_flag_4),
			.clk2_flag_5(clk2_flag_5),
			.clk2_flag_6(clk2_flag_6),
			.clk2_flag_7(clk2_flag_7),
			.clk2_flag_8(clk2_flag_8),
			.clk2_flag_9(clk2_flag_9),			
			// Output signals
			.out_valid(out_valid),
			.out(out)
			);


//---------------------------------------------------------------------
//   Finite-State Mechine                                          
//---------------------------------------------------------------------


		
endmodule