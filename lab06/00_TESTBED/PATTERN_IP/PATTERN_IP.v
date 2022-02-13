//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   2020 ICLAB Fall Course
//   Lab06       : GF 2k Arithmetic Soft IP
//   Author      : Tien-Hui Lee (bnfw623@gmail.com)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : PATTERN_IP.v
//   Module Name : PATTERN_IP
//   Release version : v2.0
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
`ifdef RTL
    `define CYCLE_TIME 50.0
`endif

`ifdef GATE
    `define CYCLE_TIME 50.0
`endif

module PATTERN_IP #(parameter DEG = 8, parameter OP = 3) (
    // Output signals
    output reg[DEG:0] POLY,
	output reg[DEG-1:0] IN1,
	output reg[DEG-1:0] IN2,
    // Input signals
    input [DEG-1:0] RESULT
);

reg			clk;
reg         gold_out_valid;
reg [3:0]   gold_out_x, gold_out_y; 
reg [7:0]   gold_out_img_pos[0:9];
reg signed[39:0]  gold_out_value;

integer operation;
integer degree;

integer total_cycles;
integer patcount;
integer cycles;
integer a, b, c, i, j, k, input_file, output_file;
integer gap;
integer golden_step;
integer gold_size;
integer gold_pos_size;

integer PATNUM=1000;

//================================================================
// clock
//================================================================
always	#(`CYCLE_TIME/2.0) clk = ~clk;
initial	clk = 0;
//================================================================
// initial
//================================================================
initial begin
	POLY = 'dx;
	IN1 = 'dx;
	IN2 = 'dx;
	
	force clk = 0;
	total_cycles = 0;
	#(3.0); release clk;
	
	input_file=$fopen("../00_TESTBED/input_IP.txt","r");
	output_file=$fopen("../00_TESTBED/output_IP.txt","r");
    @(negedge clk);

	for (patcount=0;patcount<PATNUM;patcount=patcount+1) begin
		input_action;
        repeat(1) @(negedge clk);
		check_ans;
		$display("\033[0;34mPASS PATTERN NO.%4d,\033[m \033[0;32m Cycles: %3d\033[m, ans_length:%3d", patcount ,cycles, golden_step);
        repeat(3) @(negedge clk);
	end
	#(1000);
	YOU_PASS_task;
	$finish;
end

task input_action ; 
	begin
		a = $fscanf(input_file,"%d",operation);
		a = $fscanf(input_file,"%d",degree);
		a = $fscanf(input_file,"%d",IN1);
		a = $fscanf(input_file,"%d",IN2);
		a = $fscanf(input_file,"%d",POLY);
	end 
endtask

task check_ans ; 
begin
	b = $fscanf(output_file,"%d", gold_out_value);
	
	if(RESULT !== gold_out_value) begin
		$display ("\033[0;31mSPEC 7 IS FAIL!\033[m");
		$display ("Pattern NO.%03d", patcount);
		$display ("\033[0;31m out_value: %d,  gold_out_value: %d \033[m", RESULT, gold_out_value);
		@(negedge clk);
		$finish;
	end
end 
endtask

task YOU_PASS_task;
	begin
	$display ("----------------------------------------------------------------------------------------------------------------------");
	$display ("                                                  Congratulations!                						            ");
	$display ("                                           You have passed all patterns!          						            ");
	$display ("                                           Your execution cycles = %5d cycles   						            ", total_cycles);
	$display ("                                           Your clock period = %.1f ns        					                ", `CYCLE_TIME);
	$display ("                                           Your total latency = %.1f ns         						            ", total_cycles*`CYCLE_TIME);
	$display ("----------------------------------------------------------------------------------------------------------------------");
	$finish;

	end
endtask






endmodule
