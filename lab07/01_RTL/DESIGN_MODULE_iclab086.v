module CLK_1_MODULE(// Input signals
			clk_1,
			clk_2,
			in_valid,
			rst_n,
			message,
			mode,
			CRC,
			// Output signals
			clk1_0_message,
			clk1_1_message,
			clk1_CRC,
			clk1_mode,
			clk1_control_signal,
			clk1_flag_0,
			clk1_flag_1,
			clk1_flag_2,
			clk1_flag_3,
			clk1_flag_4,
			clk1_flag_5,
			clk1_flag_6,
			clk1_flag_7,
			clk1_flag_8,
			clk1_flag_9
			);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------			
input clk_1; 
input clk_2;	
input rst_n;
input in_valid;
input[59:0]message;
input CRC;
input mode;

output reg [59:0] clk1_0_message;
output reg [59:0] clk1_1_message;
output reg clk1_CRC;
output reg clk1_mode;
output reg [9 :0] clk1_control_signal;
output clk1_flag_0;
output clk1_flag_1;
output clk1_flag_2;
output clk1_flag_3;
output clk1_flag_4;
output clk1_flag_5;
output clk1_flag_6;
output clk1_flag_7;
output clk1_flag_8;
output clk1_flag_9;

//---------------------------------------------------------------------
// PARAMETER DECLARATION
//---------------------------------------------------------------------

reg [59:0] clk1_0_message_ns;
reg clk1_CRC_ns;
reg clk1_mode_ns;

always @ (*)
begin
	if (in_valid)
	begin
		if (mode == 0 && CRC == 0)
			clk1_0_message_ns = message << 8;
		else if (mode == 0 && CRC == 1)
			clk1_0_message_ns = message << 5;
		else
			clk1_0_message_ns = message;
		clk1_CRC_ns = CRC;
		clk1_mode_ns = mode;
	end
	else
	begin
		clk1_0_message_ns = clk1_0_message;
		clk1_CRC_ns = clk1_CRC;
		clk1_mode_ns = clk1_mode;
	end
end

always @ (posedge clk_1 or negedge rst_n)
begin
	if (!rst_n)
	begin
		clk1_0_message <= 0;
		clk1_CRC <= 0;
		clk1_mode <= 0;
	end
	else
	begin
		clk1_0_message <= clk1_0_message_ns;
		clk1_CRC <= clk1_CRC_ns;
		clk1_mode <= clk1_mode_ns;
	end
end

syn_XOR SYN1 (.IN(in_valid), .OUT(clk1_flag_0), .TX_CLK(clk_1), .RX_CLK(clk_2), .RST_N(rst_n));

	
endmodule







module CLK_2_MODULE(// Input signals
			clk_2,
			clk_3,
			rst_n,
			clk1_0_message,
			clk1_1_message,
			clk1_CRC,
			clk1_mode,
			clk1_control_signal,
			clk1_flag_0,
			clk1_flag_1,
			clk1_flag_2,
			clk1_flag_3,
			clk1_flag_4,
			clk1_flag_5,
			clk1_flag_6,
			clk1_flag_7,
			clk1_flag_8,
			clk1_flag_9,
			
			// Output signals
			clk2_0_out,
			clk2_1_out,
			clk2_CRC,
			clk2_mode,
			clk2_control_signal,
			clk2_flag_0,
			clk2_flag_1,
			clk2_flag_2,
			clk2_flag_3,
			clk2_flag_4,
			clk2_flag_5,
			clk2_flag_6,
			clk2_flag_7,
			clk2_flag_8,
			clk2_flag_9
		  
			);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------			
input clk_2;	
input clk_3;	
input rst_n;

input [59:0] clk1_0_message;
input [59:0] clk1_1_message;
input clk1_CRC;
input clk1_mode;
input [9  :0] clk1_control_signal;
input clk1_flag_0;
input clk1_flag_1;
input clk1_flag_2;
input clk1_flag_3;
input clk1_flag_4;
input clk1_flag_5;
input clk1_flag_6;
input clk1_flag_7;
input clk1_flag_8;
input clk1_flag_9;


output reg [59:0] clk2_0_out;
output reg [59:0] clk2_1_out;
output reg clk2_CRC;
output reg clk2_mode;
output reg [9  :0] clk2_control_signal;
output clk2_flag_0;
output clk2_flag_1;
output clk2_flag_2;
output clk2_flag_3;
output clk2_flag_4;
output clk2_flag_5;
output clk2_flag_6;
output clk2_flag_7;
output clk2_flag_8;
output clk2_flag_9;


//---------------------------------------------------------------------
// PARAMETER DECLARATION
//---------------------------------------------------------------------

reg		[5:0]	bit_counter;
reg		[5:0]	bit_counter_ns;
reg		[59:0]	curr_poly;
reg		[59:0]	curr_poly_ns;
reg		[59:0]	curr_CRC;
reg		[59:0]	curr_CRC_ns;
reg		[1:0]	state;
reg		[1:0]	state_ns;
wire	[5:0]	CRC5;
wire	[8:0]	CRC8;

reg 	[59:0]	clk2_0_out_ns;
reg 			clk2_CRC_ns;
reg 			clk2_mode_ns;
reg 	[9:0]	clk2_control_signal_ns;
reg				out_flag;

integer i;

parameter IN = 2'd0;
parameter CALC = 2'd2;
parameter OUT = 2'd3;

assign CRC5 = 6'b101011;
assign CRC8 = 9'b100110001;

always @ (*)
begin
	curr_poly_ns = curr_poly;
	curr_CRC_ns = curr_CRC;
	clk2_CRC_ns = clk2_CRC;
	clk2_mode_ns = clk2_mode;
	state_ns = state;
	bit_counter_ns = bit_counter;
	out_flag = 0;
	clk2_0_out = curr_poly;
	// clk2_0_out_ns = clk2_0_out;
	case (state)
		IN:
		begin
			if (clk1_flag_0)
			begin
				curr_poly_ns = clk1_0_message;
				clk2_CRC_ns = clk1_CRC;
				clk2_mode_ns = clk1_mode;
				state_ns = CALC;
				bit_counter_ns = 59;
				if (clk1_CRC == 0)
					curr_CRC_ns = CRC8 << 51;
				else
					curr_CRC_ns = CRC5 << 54;
			end
		end
		CALC:
		begin
			case (clk2_CRC)
				1'b0:
				begin
					if(curr_poly[bit_counter] != 0)
					begin
						if (bit_counter != 8)
						begin
							curr_poly_ns = curr_poly ^ curr_CRC;
							bit_counter_ns = bit_counter - 1;
							curr_CRC_ns = curr_CRC >> 1;
						end
						else
						begin
							curr_poly_ns = curr_poly ^ curr_CRC;
							bit_counter_ns = 59;
							state_ns = OUT;
						end
					end
					else
					begin
						if (bit_counter != 8)
						begin
							bit_counter_ns = bit_counter - 1;
							curr_CRC_ns = curr_CRC >> 1;
						end
						else
						begin
							bit_counter_ns = 59;
							state_ns = OUT;
						end
					end
				end
				default:
				begin
					if(curr_poly[bit_counter] != 0)
					begin
						if (bit_counter != 5)
						begin
							curr_poly_ns = curr_poly ^ curr_CRC;
							bit_counter_ns = bit_counter - 1;
							curr_CRC_ns = curr_CRC >> 1;
						end
						else
						begin
							curr_poly_ns = curr_poly ^ curr_CRC;
							bit_counter_ns = 59;
							state_ns = OUT;
						end
					end
					else
					begin
						if (bit_counter != 5)
						begin
							bit_counter_ns = bit_counter - 1;
							curr_CRC_ns = curr_CRC >> 1;
						end
						else
						begin
							bit_counter_ns = 59;
							state_ns = OUT;
						end
					end
				end
			endcase
		end
		OUT:
		begin
			out_flag = 1;
			state_ns = IN;
			
			if (clk2_mode == 0 && clk2_CRC == 0)
				curr_poly_ns = {clk1_0_message[59:8], curr_poly[7:0]};
			else if (clk2_mode == 0)
				curr_poly_ns = {{clk1_0_message[59:5]}, {curr_poly[4:0]}};
			else if (curr_poly == 0)
				curr_poly_ns = 0;
			else
			begin
				for (i = 0; i < 60; i = i + 1)
					curr_poly_ns[i] = 1'b1;
			end
		end
	endcase
end

always @ (posedge clk_2 or negedge rst_n)
begin
	if (!rst_n)
	begin
		curr_poly <= 0;
		clk2_CRC <= 0;
		clk2_mode <= 0;
		state <= 0;
		bit_counter <= 59;
		curr_CRC <= 0;
		// clk2_0_out <= 0;
	end
	else
	begin
		curr_poly <= curr_poly_ns;
		clk2_CRC <= clk2_CRC_ns;
		clk2_mode <= clk2_mode_ns;
		state <= state_ns;
		bit_counter <= bit_counter_ns;
		curr_CRC <= curr_CRC_ns;
		// clk2_0_out <= clk2_0_out_ns;
	end
end

syn_XOR SYN2 (.IN(out_flag), .OUT(clk2_flag_0), .TX_CLK(clk_2), .RX_CLK(clk_3), .RST_N(rst_n));

endmodule



module CLK_3_MODULE(// Input signals
			clk_3,
			rst_n,
			clk2_0_out,
			clk2_1_out,
			clk2_CRC,
			clk2_mode,
			clk2_control_signal,
			clk2_flag_0,
			clk2_flag_1,
			clk2_flag_2,
			clk2_flag_3,
			clk2_flag_4,
			clk2_flag_5,
			clk2_flag_6,
			clk2_flag_7,
			clk2_flag_8,
			clk2_flag_9,
			
			// Output signals
			out_valid,
			out
		  
			);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------			
input clk_3;	
input rst_n;

input [59:0] clk2_0_out;
input [59:0] clk2_1_out;
input clk2_CRC;
input clk2_mode;
input [9  :0] clk2_control_signal;
input clk2_flag_0;
input clk2_flag_1;
input clk2_flag_2;
input clk2_flag_3;
input clk2_flag_4;
input clk2_flag_5;
input clk2_flag_6;
input clk2_flag_7;
input clk2_flag_8;
input clk2_flag_9;

output reg out_valid;
output reg [59:0]out; 		

reg out_valid_ns;

//---------------------------------------------------------------------
// PARAMETER DECLARATION
//---------------------------------------------------------------------

always @ (*)
begin
	if (out_valid)
	begin
		out = clk2_0_out;
		out_valid_ns = 0;
	end
	else if (clk2_flag_0)
	begin
		out = 0;
		out_valid_ns = 1;
	end
	else
	begin
		out_valid_ns = 0;
		out = 0;
	end
end

always @ (posedge clk_3 or negedge rst_n)
begin
	if (!rst_n)
	begin
		out_valid <= 0;
	end
	else
	begin
		out_valid <= out_valid_ns;
	end
end


endmodule


