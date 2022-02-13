
`ifdef RTL
    `define CYCLE_TIME 10.0
`endif
`ifdef GATE
    `define CYCLE_TIME 10.0
`endif

module PATTERN(
    // Output signals
	clk,
    rst_n,
	in_valid,
	in,
    // Input signals
    out_valid,
    out
);

output reg clk, rst_n, in_valid, in;
input out_valid;
input [1:0] out;

//================================================================
// wires & registers
//================================================================

reg		  map_temp[0:16][0:16];
reg	[4:0] cur_x;
reg	[4:0] cur_y;

//================================================================
// parameters & integer
//================================================================

integer total_cycles;
integer patcount;
integer cycles;
integer a, b, c, i, j, k, input_file;
integer gap;
integer golden_step;

parameter PATNUM=300;//104;
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
	if((out !== 0) || (out_valid !== 0)) begin
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
		gap = $urandom_range(2,4);
		repeat(gap)@(negedge clk);
		in_valid = 'b1;
		for(i = 0; i < 17; i = i + 1)
		begin
			for(j = 0; j < 17; j = j + 1)
			begin
				a = $fscanf(input_file,"%d",in);
				map_temp[i][j] = in;
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
		in           = 'bx;
		in           = 'bx;
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
	cur_x = 0;
	cur_y = 0;
    while(out_valid === 1) begin
		
		if (out == 2'd0)
			cur_y = cur_y + 1;
		if (out == 2'd1)
			cur_x = cur_x + 1;
		if (out == 2'd2)
			cur_y = cur_y - 1;
		if (out == 2'd3)
			cur_x = cur_x - 1;
		
		if(cur_x > 16 || cur_y > 16 || map_temp[cur_x][cur_y] === 0) begin
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			$display ("                                                         \033[0;31mSPEC 7 IS FAIL! \033[m                                       ");
			$display ("                                                                   Pattern NO.%03d                                                     ", patcount);
			$display ("                                                     \033[0;31mcurrent_x: %d,  current_y: %d \033[m                                    ", cur_x, cur_y);
			$display ("                                                                      Touch Wall!!!!!!!                                                ");
			$display ("                                                                      Your out step: %d                                                ", golden_step);
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			@(negedge clk);
			$finish;
		end
		
		@(negedge clk);
		golden_step=golden_step+1;
    end
	
	if(cycles + golden_step >= 3000) begin
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display ("                                                                   SPEC 6 IS FAIL!                                                          ");
		$display ("                                                                   Pattern NO.%03d                                                          ", patcount);
		$display ("                                                     The execution latency are over 3000 cycles                                            ");
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		repeat(2)@(negedge clk);
		$finish;
	end
	
	if(cur_x !== 16 && cur_y !== 16) begin
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display ("                                                                    SPEC 7 IS FAIL!                                                          ");
		$display ("                                                                   Pattern NO.%03d                                                     ", patcount);
		$display ("	                                                   CANNOT REACH TO GOAL                                              ");
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		@(negedge clk);
		$finish;
	end
	if(out !== 0)
	begin
		$display ("SPEC 4 IS FAIL!");
		$display ("out should be set to 0 after out_valid pulled down");
		@(negedge clk);
		$finish;
	end
	total_cycles = total_cycles + golden_step;
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
