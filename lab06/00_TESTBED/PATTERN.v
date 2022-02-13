//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   2020 ICLAB Fall Course
//   Lab06       : GF inverse array
//   Author      : Tien-Hui Lee (bnfw623@gmail.com)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : PATTERN.v
//   Module Name : PATTERN
//   Release version : v1.0
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
`ifdef RTL
    `define CYCLE_TIME 10
`endif

`ifdef GATE
    `define CYCLE_TIME 10
`endif

module PATTERN(
    // Output signals
    in_valid, in_data,
	deg, poly,
	rst_n, clk,
    // Input signals
    out_data,
    out_valid
);

output reg clk, rst_n, in_valid;
output reg [4:0] in_data;
output reg [2:0] deg;
output reg [5:0] poly;
input out_valid;
input [4:0] out_data;

//================================================================
// wires & registers
//================================================================

reg [4:0] gold_out_data;

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
always	#(`CYCLE_TIME/2.0) clk = ~clk;
initial	clk = 0;
//================================================================
// initial
//================================================================
initial begin
	rst_n    = 1'b1;
	in_valid = 1'b0;
	
	force clk = 0;
	total_cycles = 0;
	reset_task;
	
	input_file=$fopen("../00_TESTBED/input.txt","r");
	output_file=$fopen("../00_TESTBED/output.txt","r");
    @(negedge clk);

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
	if((out_data !== 0) || (out_valid !== 0)) begin
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

task input_data ; 
	begin
		gap = $urandom_range(1,3);
		repeat(gap)@(negedge clk);
		in_valid = 'b1;
		a = $fscanf(input_file,"%d",deg);
		a = $fscanf(input_file,"%d",poly);
		for(i = 0; i < 4; i = i + 1)
		begin
			a = $fscanf(input_file,"%d",in_data);
			@(negedge clk);
			if (out_valid === 1)
			begin
				$display("SPEC 5 IS FAIL!");
				$display("out_valid should not be hight when in_valid is high");
				repeat(2)@(negedge clk);
				$finish;
			end
			deg = 'bx;
			poly = 'bx;
		end
		in_valid     = 'b0;
		in_data      = 'bx;
		deg 		 = 'bx;
		poly 		 = 'bx;
	end 
endtask

task wait_out_valid ; 
begin
	cycles = 0;
	while(out_valid === 0)begin
		cycles = cycles + 1;
		if(cycles == 3000) begin
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
    while(out_valid === 1) begin
		a = $fscanf(output_file,"%d",gold_out_data);
		if(out_data !== gold_out_data) begin
			$display ("\033[0;31mSPEC 7 IS FAIL!\033[m");
			$display ("Pattern NO.%03d", patcount);
			$display ("\033[0;31mout_data: %d,  ans: %d\033[m", out_data, gold_out_data);
			$display ("Your out step: %d", golden_step);
			@(negedge clk);
			$finish;
		end
		
		@(negedge clk);
		golden_step=golden_step+1;
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
	$display ("                                           Your clock period = %.1f ns        					                ", `CYCLE_TIME);
	$display ("                                           Your total latency = %.1f ns         						            ", total_cycles*`CYCLE_TIME);
	$display ("----------------------------------------------------------------------------------------------------------------------");
	$finish;

	end
endtask


endmodule
