`ifdef RTL
	`timescale 1ns/1ps
	`include "CDC.v"
	`define CYCLE_TIME_clk1 14.1
	`define CYCLE_TIME_clk2 2.5
	`define CYCLE_TIME_clk3 2.7
`endif
`ifdef GATE
	`timescale 1ns/1ps
	`include "CDC_SYN.v"
	`define CYCLE_TIME_clk1 14.1
	`define CYCLE_TIME_clk2 2.5
	`define CYCLE_TIME_clk3 2.7
`endif

module PATTERN(clk_1,clk_2,clk_3,rst_n,in_valid,mode,CRC,message,out_valid,out
	
);

output reg clk_1,clk_2,clk_3;
output reg rst_n;
output reg in_valid;
output reg mode;
output reg [59:0] message;
output reg CRC;


input out_valid;
input[59:0] out;


//================================================================
// wires & registers
//================================================================

reg [59:0] gold_out_data;

//================================================================
// parameters & integer
//================================================================

integer total_cycles;
integer patcount;
integer cycles;
integer a, b, c, i, j, k, input_file, output_file;
integer gap;
integer golden_step;

parameter PATNUM=1000;//104;
//================================================================
// clock
//================================================================
always	#(`CYCLE_TIME_clk1/2.0) clk_1 = ~clk_1;
initial	clk_1 = 0;
always	#(`CYCLE_TIME_clk2/2.0) clk_2 = ~clk_2;
initial	clk_2 = 0;
always	#(`CYCLE_TIME_clk3/2.0) clk_3 = ~clk_3;
initial	clk_3 = 0;
//================================================================
// initial
//================================================================
initial begin
	rst_n    = 1'b1;
	in_valid = 1'b0;
	
	force clk_1 = 0;
	force clk_2 = 0;
	force clk_3 = 0;
	total_cycles = 0;
	reset_task;
	
	input_file=$fopen("../00_TESTBED/input.txt","r");
	output_file=$fopen("../00_TESTBED/output.txt","r");
    @(negedge clk_1);

	for (patcount=0;patcount<PATNUM;patcount=patcount+1) begin
		input_data;
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
	if((out !== 0) || (out_valid !== 0)) begin
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display ("                                                                    SPEC 3 FAIL!                                                            ");
		$display ("                                                  Output signal should be 0 after initial RESET at %8t                                      ",$time);
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		
		#(100);
	    $finish ;
	end
	
	#(10); rst_n = 1 ;
	#(3.0); release clk_1;
	#(3.0); release clk_2;
	#(3.0); release clk_3;
end endtask

task input_data ; 
	begin
		gap = $urandom_range(1,3);
		repeat(gap)@(negedge clk_1);
		#(5.0)
		in_valid = 'b1;
		a = $fscanf(input_file,"%d",mode);
		a = $fscanf(input_file,"%d",CRC);
		a = $fscanf(input_file,"%d",message);
		if (out_valid === 1)
		begin
			$display("SPEC 5 IS FAIL!");
			$display("out_valid should not be hight when in_valid is high");
			repeat(2)@(negedge clk_1);
			$finish;
		end
		@(negedge clk_1);
		in_valid     = 'b0;
		message      = 'bx;
		mode 		 = 'bx;
		CRC 		 = 'bx;
	end 
endtask

task wait_out_valid ; 
begin
	cycles = 0;
	while(out_valid === 0)begin
		cycles = cycles + 1;
		if(cycles == 400) begin
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			$display ("                                                                   SPEC 6 IS FAIL!                                                          ");
			$display ("                                                                   Pattern NO.%03d                                                          ", patcount);
			$display ("                                                     The execution latency are over 3000 cycles                                            ");
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			repeat(2)@(negedge clk_3);
			$finish;
		end
	@(negedge clk_3);
	end
	total_cycles = total_cycles + cycles;
end 
endtask

task check_ans ; 
begin
	golden_step = 0;
	a = $fscanf(output_file,"%d",gold_out_data);
	if(out !== gold_out_data) begin
		$display ("\033[0;31mSPEC 7 IS FAIL!\033[m");
		$display ("Pattern NO.%03d", patcount);
		$display ("\033[0;31mout_data: %d,  ans: %d\033[m", out, gold_out_data);
		$display ("Your out step: %d", golden_step);
		@(negedge clk_3);
		$finish;
	end
		
	
	// total_cycles = total_cycles + golden_step;
end 
endtask

task YOU_PASS_task;
	begin
	$display ("----------------------------------------------------------------------------------------------------------------------");
	$display ("                                                  Congratulations!                						            ");
	$display ("                                           You have passed all patterns!          						            ");
	$display ("                                           Your execution cycles = %5d cycles   						            ", total_cycles);
	$display ("                                           Your clock period = %.1f ns        					                ", `CYCLE_TIME_clk3);
	$display ("                                           Your total latency = %.1f ns         						            ", total_cycles*`CYCLE_TIME_clk3);
	$display ("----------------------------------------------------------------------------------------------------------------------");
	$finish;

	end
endtask

endmodule
