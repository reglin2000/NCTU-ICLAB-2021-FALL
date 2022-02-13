// synopsys translate_off 
`ifdef RTL
`include "GATED_OR.v"
`else
`include "Netlist/GATED_OR_SYN.v"
`endif
// synopsys translate_on

module SP(
	// Input signals
	clk,
	rst_n,
	cg_en,
	in_valid,
	in_data,
	in_mode,
	// Output signals
	out_valid,
	out_data
);

// INPUT AND OUTPUT DECLARATION  
input		clk;
input		rst_n;
input		in_valid;
input		cg_en;
input [8:0] in_data;
input [2:0] in_mode;

output reg 		  out_valid;
output reg signed[9:0] out_data;

reg		signed	[9:0]	in_data_reg[0:8];
reg		signed	[9:0]	in_data_reg_ns[0:8];
reg		signed	[8:0]	in_data_min;
reg		signed	[8:0]	in_data_min_ns;
reg		signed	[8:0]	in_data_min_1;
reg		signed	[8:0]	in_data_min_1_ns;
reg		signed	[8:0]	in_data_max;
reg		signed	[8:0]	in_data_max_ns;
reg		signed	[8:0]	in_data_max_1;
reg		signed	[8:0]	in_data_max_1_ns;
reg				[2:0]	in_mode_reg;
reg				[2:0]	in_mode_reg_ns;
reg				[1:0]	state;
reg				[1:0]	state_ns;
reg				[3:0]	counter_in_data;
reg				[3:0]	counter_in_data_ns;
reg		signed	[11:0]	max_sequence;
reg		signed	[11:0]	max_sequence_ns;
reg				[3:0]	max_position;
reg				[3:0]	max_position_ns;

wire	signed	[11:0]	cur_sequence;
wire	signed	[9:0]	cur_average;
reg		signed	[9:0]	sequence_op;

wire					clks0, clks0os2, clk_state, clks3, clks0os2os1, clks1;

parameter	INPUT		=	2'd0;
parameter	MODE1		=	2'd1;
parameter	MODE2		=	2'd2;
parameter	OUTPUT		=	2'd3;

integer i;

// Clock Gating
GATED_OR GATED_0 (.CLOCK(clk), .SLEEP_CTRL(cg_en && (state!=0)), .RST_N(rst_n), .CLOCK_GATED(clks0));
GATED_OR GATED_1 (.CLOCK(clk), .SLEEP_CTRL(cg_en && (state!=0 && state!=2)), .RST_N(rst_n), .CLOCK_GATED(clks0os2));
GATED_OR GATED_2 (.CLOCK(clk), .SLEEP_CTRL(cg_en && (state!=1 && counter_in_data != 2 && counter_in_data != 8)), .RST_N(rst_n), .CLOCK_GATED(clk_state));
GATED_OR GATED_3 (.CLOCK(clk), .SLEEP_CTRL(cg_en && (state!=3)), .RST_N(rst_n), .CLOCK_GATED(clks3));
GATED_OR GATED_4 (.CLOCK(clk), .SLEEP_CTRL(cg_en && (state!=0 && state!=2 && state!=1)), .RST_N(rst_n), .CLOCK_GATED(clks0os2os1));
GATED_OR GATED_5 (.CLOCK(clk), .SLEEP_CTRL(cg_en), .RST_N(rst_n), .CLOCK_GATED(clks1));

// assign	cur_sequence	=	in_data_reg_ns[counter_in_data] + in_data_reg[counter_in_data - 1] + in_data_reg[counter_in_data - 2];
assign	cur_sequence	=	sequence_op + in_data_reg[counter_in_data - 1] + in_data_reg[counter_in_data - 2];
assign	cur_average		=	(in_data_reg[counter_in_data] + in_data_reg[counter_in_data-1]*2)/3;

always @ (*)
begin
	out_valid = 0;
	out_data = 0;

	sequence_op = 0;
	
	in_data_min_ns = in_data_min;
	in_data_max_ns = in_data_max;
	if (state != MODE1)
	begin
		in_data_min_1_ns = ~in_data_min_1;
		in_data_max_1_ns = ~in_data_max_1;
	end
	else
	begin
		in_data_min_1_ns = in_data_min;
		in_data_max_1_ns = in_data_max;
	end
	in_mode_reg_ns = in_mode_reg;
	state_ns = state;
	counter_in_data_ns = counter_in_data;
	max_sequence_ns = max_sequence;
	max_position_ns = max_position;
	for (i = 0; i < 9; i = i + 1)
	begin
		in_data_reg_ns[i] = in_data_reg[i];
	end
	
	case (state)
		INPUT:
		begin
			if (in_valid)
			begin
				if ((in_mode[0] == 0 && counter_in_data == 0 || in_mode_reg[0] == 0 && counter_in_data != 0))
				begin
					sequence_op[8:0] = in_data;
					sequence_op[9] = in_data[8];
					in_data_reg_ns[counter_in_data] = sequence_op;
				end
				else
				begin
					sequence_op = (1-2*in_data[8]) * (10*(in_data[7:4]-3) + (in_data[3:0]-3));
					in_data_reg_ns[counter_in_data] = sequence_op;
				end

				if (counter_in_data == 0)
				begin
					in_mode_reg_ns = in_mode;
					in_data_min_ns = sequence_op;
					in_data_max_ns = sequence_op;
				end
				else
				begin
					if (sequence_op < in_data_min)
						in_data_min_ns = sequence_op;
					else if (sequence_op > in_data_max)
						in_data_max_ns = sequence_op;
					if (counter_in_data == 2)
					begin
						max_sequence_ns = cur_sequence;
						max_position_ns = counter_in_data;
					end
					else if (counter_in_data != 1 && max_sequence < cur_sequence)
					begin
						max_sequence_ns = cur_sequence;
						max_position_ns = counter_in_data;
					end
				end

				if (counter_in_data != 8)
					counter_in_data_ns = counter_in_data + 1;
				else
				begin
					counter_in_data_ns = 0;
					if (in_mode_reg[1] == 1 || in_mode_reg[2] == 0)
						state_ns = MODE1;
					else
						state_ns = MODE2;
				end
			end
		end
		MODE1:
		begin
			if (in_mode_reg[1] == 1)
			begin
				for (i = 0; i < 9; i = i + 1)
				begin
					in_data_reg_ns[i] = in_data_reg[i] - (in_data_max_1_ns + in_data_min_1_ns) / 2;
				end
				
				if (in_mode_reg[2] == 1)
					state_ns = MODE2;
				else
					state_ns = OUTPUT;
			end
			else
			begin
				state_ns = OUTPUT;
			end
		end
		MODE2:
		begin
			case (counter_in_data)
				4'd0:
					counter_in_data_ns = counter_in_data + 1;
				4'd1:
				begin
					counter_in_data_ns = counter_in_data + 1;
					in_data_reg_ns[1] = cur_average;
				end
				4'd2:
				begin
					counter_in_data_ns = counter_in_data + 1;
					in_data_reg_ns[2] = cur_average;
					sequence_op = cur_average;
					max_sequence_ns = cur_sequence;
					max_position_ns = counter_in_data;
				end
				4'd8:
				begin
					counter_in_data_ns = 0;
					state_ns = OUTPUT;
					in_data_reg_ns[8] = cur_average;
					sequence_op = cur_average;
					if (max_sequence < cur_sequence)
					begin
						max_sequence_ns = cur_sequence;
						max_position_ns = counter_in_data;
					end
				end
				default:
				begin
					counter_in_data_ns = counter_in_data + 1;
					in_data_reg_ns[counter_in_data] = cur_average;
					sequence_op = cur_average;
					if (max_sequence < cur_sequence)
					begin
						max_sequence_ns = cur_sequence;
						max_position_ns = counter_in_data;
					end
				end
			endcase
		end
		OUTPUT:
		begin
			out_valid = 1;
			out_data = in_data_reg[max_position - 2 + counter_in_data];
			if (counter_in_data != 2)
				counter_in_data_ns = counter_in_data + 1;
			else
			begin
				state_ns = INPUT;
				counter_in_data_ns = 0;
			end
		end
	endcase
end

always @ (posedge clks1 or negedge rst_n)
begin
	if (!rst_n)
	begin
		in_data_max_1 <= 0;
		in_data_min_1 <= 0;
	end
	else
	begin
		in_data_min_1 <= in_data_min_1_ns;
		in_data_max_1 <= in_data_max_1_ns;
	end
end

always @ (posedge clks0 or negedge rst_n)
begin
	if (!rst_n)
	begin
		in_data_min <= 0;
		in_data_max <= 0;
		in_mode_reg <= 0;
	end
	else
	begin
		in_data_min <= in_data_min_ns;
		in_data_max <= in_data_max_ns;
		in_mode_reg <= in_mode_reg_ns;
	end
end

always @ (posedge clks0os2 or negedge rst_n)
begin
	if (!rst_n)
	begin
		max_sequence <= 0;
		max_position <= 0;
	end
	else
	begin
		max_sequence <= max_sequence_ns;
		max_position <= max_position_ns;
	end
end

always @ (posedge clk_state or negedge rst_n)
begin
	if (!rst_n)
	begin
		state <= 0;
	end
	else
	begin
		state <= state_ns;
	end
end

always @ (posedge clks0os2os1 or negedge rst_n)
begin
	if (!rst_n)
	begin
		for (i = 0; i < 9; i = i + 1)
		begin
			in_data_reg[i] <= 0;
		end
	end
	else
	begin
		for (i = 0; i < 9; i = i + 1)
		begin
			in_data_reg[i] <= in_data_reg_ns[i];
		end
	end
end

always @ (posedge clk or negedge rst_n)
begin
	if (!rst_n)
	begin
		counter_in_data <= 0;
	end
	else
	begin
		counter_in_data <= counter_in_data_ns;
	end
end

endmodule
