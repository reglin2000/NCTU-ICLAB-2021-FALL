//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//      (C) Copyright NCTU OASIS Lab      
//            All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   2021 ICLAB fall Course
//   Lab05		: SRAM, Template Matching with Image Processing
//   Author     : Shaowen-Cheng (shaowen0213@gmail.com)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : TESTBED.v
//   Module Name : TESTBED
//   Release version : v1.0
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
`ifdef RTL
	`timescale 1ns/10ps
	`include "TMIP.v"
	`define CYCLE_TIME 16.0
`endif
`ifdef GATE
	`timescale 1ns/10ps
	`include "TMIP_SYN.v"
	`define CYCLE_TIME 16.0
`endif

module PATTERN(
// output signals
    clk,
    rst_n,
    in_valid,
	in_valid_2,
    image,
    img_size,
    template, 
    action,
// input signals
    out_valid,
    out_x,
    out_y,
    out_img_pos,
    out_value
);
output reg        clk, rst_n, in_valid, in_valid_2;
output reg [15:0] image, template;
output reg [4:0]  img_size;
output reg [1:0]  action;

input         out_valid;
input [3:0]   out_x, out_y; 
input [7:0]   out_img_pos;
input signed[39:0]  out_value;

reg         gold_out_valid;
reg [3:0]   gold_out_x, gold_out_y; 
reg [7:0]   gold_out_img_pos[0:9];
reg signed[39:0]  gold_out_value;

integer size, output_file;
integer rec_image[0:15][0:15];
integer rec_templete[0:8];

integer total_cycles;
integer patcount;
integer cycles;
integer a, b, c, i, j, k, input_file;
integer gap;
integer golden_step;
integer gold_size;
integer gold_pos_size;

integer PATNUM=100;

//================================================================
// clock
//================================================================
always	#(`CYCLE_TIME/2.0) clk = ~clk;
initial	clk = 0;
//================================================================
// initial
//================================================================
initial begin
	rst_n    = 1'b1;
	in_valid = 1'b0;
	in_valid_2 = 1'b0;
	
	force clk = 0;
	total_cycles = 0;
	reset_task;
	
	input_file=$fopen("../00_TESTBED/input.txt","r");
	output_file=$fopen("../00_TESTBED/output.txt","r");
    @(negedge clk);

	for (patcount=0;patcount<PATNUM;patcount=patcount+1) begin
		input_image;
		input_action;
		wait_out_valid;
		check_ans;
		$display("\033[0;34mPASS PATTERN NO.%4d,\033[m \033[0;32m Cycles: %3d\033[m, ans_length:%3d", patcount ,cycles, golden_step);
	end
	#(1000);
	YOU_PASS_task;
	$finish;
end

task reset_task ; begin
	#(10); rst_n = 0;

	#(10);
	if((out_x !== 0) || (out_valid !== 0)) begin
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display ("                                                                    SPEC 3 FAIL!                                                            ");
		$display ("                                                  Output signal should be 0 after initial RESET at %8t                                      ",$time);
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		
		#(100);
	    $finish ;
	end
	
	#(10); rst_n = 1 ;
	#(3.0); release clk;
end endtask

task input_image ; 
	begin
		gap = $urandom_range(2,4);
		repeat(gap)@(negedge clk);
		in_valid = 'b1;
		a = $fscanf(input_file,"%d",size);
		for (i = 0; i < size; i = i + 1)
		begin
			for (j = 0; j < size; j = j + 1)
			begin
				a = $fscanf(input_file,"%d",rec_image[i][j]);
			end
		end
		for (i = 0; i < 9; i = i + 1)
		begin
			a = $fscanf(input_file,"%d",rec_templete[i]);
		end
		for(i = 0; i < size; i = i + 1)
		begin
			for(j = 0; j < size; j = j + 1)
			begin
				if (i == 0 && j == 0)
					img_size = size;
				else
					img_size = 5'bxxxxx;
				image = rec_image[i][j];
				if (i * size + j < 9)
					template = rec_templete[i * size + j];
				else
					template = 16'dx;
				@(negedge clk);
				if (out_valid === 1)
				begin
					$display("SPEC 5 IS FAIL!");
					$display("out_valid should not be hight when in_valid is high");
					repeat(2)@(negedge clk);
					$finish;
				end
			end
		end
		in_valid     = 'b0;
		image	 = 16'dx;
		template = 16'dx;
	end 
endtask

task input_action ; 
	begin
		@(negedge clk);
		in_valid_2 = 'b1;
		a = $fscanf(input_file,"%d",action);
		@(negedge clk);
		if (out_valid === 1)
		begin
			$display("SPEC 5 IS FAIL!");
			$display("out_valid should not be hight when in_valid is high");
			repeat(2)@(negedge clk);
			$finish;
		end
		while (action !== 0)
		begin
			a = $fscanf(input_file,"%d",action);
			@(negedge clk);
			if (out_valid === 1)
			begin
				$display("SPEC 5 IS FAIL!");
				$display("out_valid should not be hight when in_valid is high");
				repeat(2)@(negedge clk);
				$finish;
			end
		end
		in_valid_2    = 'b0;
		action	 = 2'dx;
	end 
endtask

task wait_out_valid ; 
begin
	cycles = 0;
	while(out_valid === 0)begin
		cycles = cycles + 1;
		if(cycles == 4000) begin
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			$display ("                                                                   SPEC 6 IS FAIL!                                                          ");
			$display ("                                                                   Pattern NO.%03d                                                          ", patcount);
			$display ("                                                     The execution latency are over 3000 cycles                                            ");
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			repeat(2)@(negedge clk);
			$finish;
		end
	@(negedge clk);
	end
	total_cycles = total_cycles + cycles;
end 
endtask

task check_ans ; 
begin
	golden_step = 0;
	b = $fscanf(output_file,"%d", gold_out_x);
	b = $fscanf(output_file,"%d", gold_out_y);
	b = $fscanf(output_file,"%d", gold_size);
	b = $fscanf(output_file,"%d", gold_pos_size);
	for (i = 0; i < gold_pos_size; i = i + 1)
	begin
		b = $fscanf(output_file,"%d", gold_out_img_pos[i]);
	end
	
    while(out_valid === 1) begin

		b = $fscanf(output_file,"%d", gold_out_value);
		
		if(out_value !== gold_out_value) begin
			$display ("\033[0;31mSPEC 7 IS FAIL!\033[m");
			$display ("Pattern NO.%03d", patcount);
			$display ("\033[0;31m out_value: %d,  gold_out_value: %d \033[m", out_value, gold_out_value);
			$display ("Your out step: %d", golden_step);
			@(negedge clk);
			$finish;
		end
		if(golden_step < gold_pos_size && out_img_pos !== gold_out_img_pos[golden_step]) begin
			$display ("\033[0;31mSPEC 7 IS FAIL!\033[m");
			$display ("Pattern NO.%03d", patcount);
			$display ("\033[0;31m out_img_pos: %d,  gold_out_img_pos: %d \033[m", out_img_pos, gold_out_img_pos[golden_step]);
			$display ("Your out step: %d", golden_step);
			@(negedge clk);
			$finish;
		end
		else if(golden_step >= gold_pos_size && out_img_pos !== 0) begin
			$display ("\033[0;31mSPEC 7 IS FAIL!\033[m");
			$display ("Pattern NO.%03d", patcount);
			$display ("\033[0;31m out_img_pos: %d,  gold_out_img_pos: 0 \033[m", out_img_pos);
			$display ("Your out step: %d", golden_step);
			@(negedge clk);
			$finish;
		end
		
		@(negedge clk);
		golden_step=golden_step+1;
    end
	
	if(golden_step !== gold_size * gold_size) begin
		$display ("SPEC 7 IS FAIL!");
		$display ("Pattern NO.%03d", patcount);
		$display ("size error");
		@(negedge clk);
		$finish;
	end
	if(out_x !== 0)
	begin
		$display ("SPEC 4 IS FAIL!");
		$display ("out should be set to 0 after out_valid pulled down");
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
