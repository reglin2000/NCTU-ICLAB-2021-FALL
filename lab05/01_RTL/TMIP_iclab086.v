module TMIP(
// input signals
    clk,
    rst_n,
    in_valid,
	in_valid_2,
    image,
	img_size,
    template, 
    action,
	
// output signals
    out_valid,
    out_x,
    out_y,
    out_img_pos,
    out_value
);

input        clk, rst_n, in_valid, in_valid_2;
input [15:0] image, template;
input [4:0]  img_size;
input [1:0]  action;

parameter INPUT		=	2'd0;
parameter WAITMEM	=	2'd1;
parameter CALC		=	2'd2;
parameter OUTPUT	=	2'd3;

output reg        out_valid;
output reg [3:0]  out_x, out_y; 
output reg [7:0]  out_img_pos;
output reg signed[39:0] out_value;

reg			      	out_valid_ns;
reg			[3:0] 	out_x_ns, out_y_ns; 
reg			[7:0] 	out_img_pos_ns;
reg	signed	[39:0]	out_value_ns;

reg					in_valid_rec;
reg					in_valid_2_rec;
reg			[15:0] 	image_rec, template_rec;
reg			[4:0]  	img_size_rec;
reg			[1:0]  	action_rec;
reg			[1:0]	state;
reg			[1:0]	state_ns;
reg			[1:0]	rec_action		[0:7];
reg			[1:0]	rec_action_ns	[0:7];
reg			[2:0]	count_action;
reg			[2:0]	count_action_ns;
reg			[3:0]	count_sub_step;
reg			[3:0]	count_sub_step_ns;
reg			[3:0]	count_row;
reg			[3:0]	count_row_ns;
reg			[2:0]	count_adjust_brightness;
reg			[2:0]	count_adjust_brightness_ns;
reg	signed	[15:0]	rec_template		[0:2][0:2];
reg	signed	[15:0]	rec_template_ns	[0:2][0:2];
reg			[1:0]	rec_size;
reg			[1:0]	rec_size_ns;
reg			[7:0]	rec_mem_A;
reg					flip_flag;
reg					flip_flag_ns;
reg	signed	[35:0]	max_num;
reg	signed	[35:0]	max_num_ns;
reg			[3:0]	max_x;
reg			[3:0]	max_x_ns;
reg			[3:0]	max_y;
reg			[3:0]	max_y_ns;
reg	signed	[15:0]	cur_brightness;
reg	signed	[15:0]	cur_brightness_ns;
reg					done_flip;
reg					done_flip_ns;
reg			[7:0]	cur_pixel;
reg			[7:0]	cur_pixel_ns;

reg						mem_WEN;
reg				[7:0]	mem_A;
reg		signed	[15:0]	mem_D;
wire	signed	[15:0]	mem_Q;
reg		signed	[15:0]	rec_mem_Q;

reg						cor_mem_WEN;
reg				[7:0]	cor_mem_A;
reg		signed	[35:0]	cor_mem_D;
wire	signed	[35:0]	cor_mem_Q;

reg		[3:0]	actual_size;
reg		[7:0]	actual_pixel;

reg		signed	[33:0]	product_sum_col[0:2];
reg		signed	[33:0]	product_sum_col_ns[0:2];

reg		signed	[31:0]	product;
reg		signed	[15:0]	sel_template;

wire	[7:0]	addr_a_1;

integer i, j;

RA1SH1 MEM1 (.Q(mem_Q), .CLK(~clk), .CEN(1'b0), .WEN(mem_WEN), .A(mem_A), .D(mem_D), .OEN(1'b0));
RA1SH2 MEM2 (.Q(cor_mem_Q), .CLK(~clk), .CEN(1'b0), .WEN(cor_mem_WEN), .A(cor_mem_A), .D(cor_mem_D), .OEN(1'b0));


assign addr_a_1 = rec_mem_A + 1; // shift 1

always @ (*)
begin
	state_ns			=	state;
	rec_size_ns			=	rec_size;
	count_action_ns		=	count_action;
	flip_flag_ns		=	flip_flag;
	max_num_ns			=	max_num;
	max_x_ns			=	max_x;
	max_y_ns			=	max_y;
	count_sub_step_ns	=	count_sub_step;
	count_row_ns		=	count_row;
	cur_brightness_ns	=	cur_brightness;
	done_flip_ns		=	done_flip;
	count_adjust_brightness_ns	=	count_adjust_brightness;
	cur_pixel_ns		=	cur_pixel;
	
	for (i = 0; i < 8; i = i + 1)
	begin
		rec_action_ns[i]	=	rec_action[i];
	end
	for (i = 0; i < 3; i = i + 1)
		for (j = 0; j < 3; j = j + 1)
		begin
			rec_template_ns[i][j]	=	rec_template[i][j];
		end
	for (i = 0; i < 3; i = i + 1)
		product_sum_col_ns[i] = product_sum_col[i];

	mem_WEN	=	1;
	mem_D	=	0;
	mem_A	=	rec_mem_A;
	
	cor_mem_WEN	=	1;
	cor_mem_D	=	0;
	cor_mem_A	=	cur_pixel;
	
	out_valid_ns = 0;
	out_x_ns = 0;
	out_y_ns = 0;
	out_img_pos_ns = 0;
	out_value_ns = 0;

	case (rec_size)
		2'd2:
		begin
			actual_size = 15;
			actual_pixel = 255;
		end
		2'd1:
		begin
			actual_size = 7;
			actual_pixel = 63;
		end
		default:
		begin
			actual_size = 3;
			actual_pixel = 15;
		end
	endcase
	
	case (count_sub_step)
		4'd1:
			sel_template = rec_template[0][0];
		4'd2:
			sel_template = rec_template[1][0];
		4'd3:
			sel_template = rec_template[2][0];
		4'd4:
			sel_template = rec_template[0][1];
		4'd5:
			sel_template = rec_template[1][1];
		4'd6:
			sel_template = rec_template[2][1];
		4'd7:
			sel_template = rec_template[0][2];
		4'd8:
			sel_template = rec_template[1][2];
		default:
			sel_template = rec_template[2][2];
	endcase
	product = sel_template * rec_mem_Q;

	case (state)
		INPUT:
		begin
			if (in_valid_rec)
			begin
				mem_WEN = 0;
				mem_D = image_rec;
				mem_A = cur_pixel;
				if (cur_pixel == 0)
				begin
					case (img_size_rec)
						5'd16:
							rec_size_ns = 2;
						5'd8:
							rec_size_ns = 1;
						default:
							rec_size_ns = 0;
					endcase
				end
				if (cur_pixel < 9)
				begin
					case (cur_pixel)
						9'd0:
							rec_template_ns[0][0] = template_rec;
						9'd1:
							rec_template_ns[0][1] = template_rec;
						9'd2:
							rec_template_ns[0][2] = template_rec;
						9'd3:
							rec_template_ns[1][0] = template_rec;
						9'd4:
							rec_template_ns[1][1] = template_rec;
						9'd5:
							rec_template_ns[1][2] = template_rec;
						9'd6:
							rec_template_ns[2][0] = template_rec;
						9'd7:
							rec_template_ns[2][1] = template_rec;
						9'd8:
							rec_template_ns[2][2] = template_rec;
					endcase
				end
				
				if (cur_pixel != actual_pixel)
					cur_pixel_ns = cur_pixel + 1;
				else
					cur_pixel_ns = 0;
			end
			else if (in_valid_2_rec)
			begin
				rec_action_ns[cur_pixel] = action_rec;
				mem_A = 0;
				
				if (action_rec != 0)
					cur_pixel_ns = cur_pixel + 1;
				else
				begin
					cur_pixel_ns = 0;
					state_ns = CALC;
				end
			end
		end
		CALC:
		begin
			case (rec_action[count_action])
				2'd1:
				begin
					if (actual_size == 15 || actual_size == 7)
					begin
						if (count_sub_step == 0)
						begin
							if (cur_pixel == 64 && rec_size == 2 || cur_pixel == 16 && rec_size == 1)
							begin
								count_sub_step_ns = 0;
								count_row_ns = 0;
								count_action_ns = count_action + 1;
								mem_A = 0;
								rec_size_ns = rec_size - 1;
								cur_pixel_ns = 0;
							end
							else
							begin
								mem_A = (count_row * 2) * (actual_size + 1) + ((cur_pixel) % (actual_size/2 + 1)) * 2;
								count_sub_step_ns = count_sub_step + 1;
								max_num_ns = mem_Q;
							end
						end
						else if (count_sub_step == 1)
						begin
							count_sub_step_ns = count_sub_step + 1;
							mem_A = addr_a_1;
							if (mem_Q > max_num)
								max_num_ns = mem_Q;
						end
						else if (count_sub_step == 2)
						begin
							count_sub_step_ns = count_sub_step + 1;
							mem_A = rec_mem_A + actual_size;
							if (mem_Q > max_num)
								max_num_ns = mem_Q;
						end
						else if (count_sub_step == 3)
						begin
							count_sub_step_ns = count_sub_step + 1;
							// rec_mem_A_ns = count_row * (actual_size/2 + 1) + (rec_mem_A % (actual_size+1)) / 2;
							mem_A = addr_a_1;
							if (mem_Q > max_num)
								max_num_ns = mem_Q;
						end
						else if (count_sub_step == 4)
						begin
							count_sub_step_ns = 0;
							mem_WEN = 0;
							mem_A = cur_pixel;
							mem_D = max_num_ns;
							if (rec_mem_A % (actual_size + 1) == actual_size)
							begin
								count_row_ns = count_row + 1;
								cur_pixel_ns = cur_pixel + 1;
							end
							else
							begin
								cur_pixel_ns = cur_pixel + 1;
							end
						end
					end
					else
						count_action_ns = count_action + 1;
				end
				2'd2:
				begin
					flip_flag_ns = !(flip_flag);
					count_action_ns = count_action + 1;
				end
				2'd3:
				begin
					count_adjust_brightness_ns = count_adjust_brightness + 1;
					count_action_ns = count_action + 1;
				end
				default:
				begin
					if (!done_flip && flip_flag)
					begin
						for (i = 0; i < 3; i = i + 1)
							rec_template_ns[i][0] = rec_template[i][2];
						for (i = 0; i < 3; i = i + 1)
							rec_template_ns[i][2] = rec_template[i][0];
						done_flip_ns = 1;
					end
					else if(count_adjust_brightness != 0)
					begin
						if (count_sub_step == 0)
						begin
							cur_brightness_ns = mem_Q;
							count_sub_step_ns = count_sub_step + 1;
						end
						else if (count_sub_step < count_adjust_brightness)
						begin
							// cur_brightness_ns = (cur_brightness - cur_brightness%2) / 2 + 50;
							cur_brightness_ns = (cur_brightness - (cur_brightness % 2 + 2) % 2) / 2 + 50;
							count_sub_step_ns = count_sub_step + 1;
							if (count_sub_step_ns != count_adjust_brightness)
							begin
								cur_brightness_ns = (cur_brightness_ns - (cur_brightness_ns % 2 + 2) % 2) / 2 + 50;
								count_sub_step_ns = count_sub_step_ns + 1;
							end
							if (count_sub_step_ns != count_adjust_brightness)
							begin
								cur_brightness_ns = (cur_brightness_ns - (cur_brightness_ns % 2 + 2) % 2) / 2 + 50;
								count_sub_step_ns = count_sub_step_ns + 1;
							end
						end
						else if (count_sub_step == count_adjust_brightness)
						begin
							mem_D = (cur_brightness - (cur_brightness % 2 + 2) % 2) / 2 + 50;
							// mem_D = (cur_brightness - cur_brightness%2) / 2 + 50;
							// mem_D = cur_brightness / 2 + 50;
							mem_WEN = 0;
							count_sub_step_ns = count_sub_step + 1;
						end
						else
						begin
							if (rec_mem_A != actual_pixel)
								mem_A = rec_mem_A + 1;
							else
							begin
								mem_A = 0;
								count_adjust_brightness_ns = 0;
							end
							count_sub_step_ns = 0;
						end
					end
					else
					begin
						case (count_sub_step)
							4'd0:
							begin
								if (cur_pixel == 0)
								begin
									count_sub_step_ns = 5;
									mem_A = cur_pixel;
									product_sum_col_ns[0] = 0;
									product_sum_col_ns[1] = 0;
									product_sum_col_ns[2] = 0;
								end
								else if (count_row == 0)
								begin
									count_sub_step_ns = 2;
									mem_A = cur_pixel - 1;
									product_sum_col_ns[0] = 0;
									product_sum_col_ns[1] = 0;
									product_sum_col_ns[2] = 0;
								end
								else if (cur_pixel % (actual_size + 1) == 0)
								begin
									count_sub_step_ns = 4;
									mem_A = cur_pixel - actual_size - 1;
									product_sum_col_ns[0] = 0;
									product_sum_col_ns[1] = 0;
									product_sum_col_ns[2] = 0;
								end
								else
								begin
									count_sub_step_ns = 1;
									mem_A = cur_pixel - actual_size - 2;
									product_sum_col_ns[0] = 0;
									product_sum_col_ns[1] = 0;
									product_sum_col_ns[2] = 0;
								end
							end
							4'd1:
							begin
								mem_A = cur_pixel - 1;
								product_sum_col_ns[0] = product_sum_col[0] + product;
								count_sub_step_ns = 2;
							end
							4'd2:
							begin
								if (count_row == actual_size)
								begin
									mem_A = cur_pixel - actual_size - 1;
									product_sum_col_ns[0] = product_sum_col[0] + product;
									count_sub_step_ns = 4;
								end
								else
								begin
									mem_A = cur_pixel + actual_size;
									product_sum_col_ns[0] = product_sum_col[0] + product;
									count_sub_step_ns = 3;
								end
							end
							4'd3:
							begin
								if (count_row == 0)
								begin
									mem_A = cur_pixel;
									product_sum_col_ns[0] = product_sum_col[0] + product;
									count_sub_step_ns = 5;
								end
								else
								begin
									mem_A = cur_pixel - actual_size - 1;
									product_sum_col_ns[0] = product_sum_col[0] + product;
									count_sub_step_ns = 4;
								end
							end
							4'd4:
							begin
								mem_A = cur_pixel;
								product_sum_col_ns[1] = product_sum_col[1] + product;
								count_sub_step_ns = 5;
							end
							4'd5:
							begin
								if (cur_pixel == actual_pixel)
								begin
									mem_A = 0;
									product_sum_col_ns[1] = product_sum_col[1] + product;
									count_sub_step_ns = 10;
								end
								else if (count_row == actual_size)
								begin
									mem_A = cur_pixel - actual_size;
									product_sum_col_ns[1] = product_sum_col[1] + product;
									count_sub_step_ns = 7;
								end
								else
								begin
									mem_A = cur_pixel + actual_size + 1;
									product_sum_col_ns[1] = product_sum_col[1] + product;
									count_sub_step_ns = 6;
								end
							end
							4'd6:
							begin
								if (cur_pixel % (actual_size + 1) == actual_size)
								begin
									mem_A = 0;
									product_sum_col_ns[1] = product_sum_col[1] + product;
									count_sub_step_ns = 10;
								end
								else if (count_row == 0)
								begin
									mem_A = cur_pixel + 1;
									product_sum_col_ns[1] = product_sum_col[1] + product;
									count_sub_step_ns = 8;
								end
								else
								begin
									mem_A = cur_pixel - actual_size;
									product_sum_col_ns[1] = product_sum_col[1] + product;
									count_sub_step_ns = 7;
								end
							end
							4'd7:
							begin
								mem_A = cur_pixel + 1;
								product_sum_col_ns[2] = product_sum_col[2] + product;
								count_sub_step_ns = 8;
							end
							4'd8:
							begin
								if (count_row == actual_size)
								begin
									mem_A = 0;
									product_sum_col_ns[2] = product_sum_col[2] + product;
									count_sub_step_ns = 10;
								end
								else
								begin
									mem_A = cur_pixel + actual_size + 2;
									product_sum_col_ns[2] = product_sum_col[2] + product;
									count_sub_step_ns = 9;
								end
							end
							4'd9:
							begin
								mem_A = 0;
								product_sum_col_ns[2] = product_sum_col[2] + product;
								cor_mem_WEN = 0;
								cor_mem_A = cur_pixel;
								cor_mem_D = product_sum_col[0] + product_sum_col[1] + product_sum_col_ns[2];
								count_sub_step_ns = 0;
								if ((cor_mem_D > max_num || cur_pixel == 0) && !flip_flag || (cor_mem_D > max_num || cur_pixel == 0 || (cor_mem_D == max_num && max_x == count_row) && flip_flag))
								begin
									max_num_ns = cor_mem_D;
									max_x_ns = count_row;
									max_y_ns = cur_pixel % (actual_size + 1);
								end
								cur_pixel_ns = cur_pixel + 1;
								if (cur_pixel_ns % (actual_size + 1) == 0)
									count_row_ns = count_row + 1;
							end
							4'd10:
							begin
								mem_A = 0;
								cor_mem_WEN = 0;
								cor_mem_A = cur_pixel;
								cor_mem_D = product_sum_col[0] + product_sum_col[1] + product_sum_col[2];
								count_sub_step_ns = 0;
								if ((cor_mem_D > max_num || cur_pixel == 0) && !flip_flag || (cor_mem_D > max_num || cur_pixel == 0 || (cor_mem_D == max_num && max_x == count_row) && flip_flag))
								begin
									max_num_ns = cor_mem_D;
									max_x_ns = count_row;
									max_y_ns = cur_pixel % (actual_size + 1);
								end
								if (cur_pixel == actual_pixel)
								begin
									if (!flip_flag)
										cur_pixel_ns = 0;
									else
										cur_pixel_ns = actual_size;
									state_ns = OUTPUT;
									count_row_ns = 0;
									if (max_x_ns == 0 && max_y_ns == 0 && !flip_flag || max_x_ns == 0 && max_y_ns == actual_size && flip_flag)
										count_sub_step_ns = 5;
									else if (max_x_ns == 0)
										count_sub_step_ns = 4;
									else if (max_y_ns == 0 && !flip_flag || max_y_ns == actual_size && flip_flag)
										count_sub_step_ns = 2;
									else
										count_sub_step_ns = 1;
								end
								else
								begin
									cur_pixel_ns = cur_pixel + 1;
									if (cur_pixel_ns % (actual_size + 1) == 0)
										count_row_ns = count_row + 1;
								end
							end
						endcase
					end
				end
			endcase
		end
		OUTPUT:
		begin
			if (!flip_flag)
			begin
				out_valid_ns = 1;
				out_x_ns = max_x;
				out_y_ns = max_y;
				case(count_sub_step)
					4'b1:
					begin
						out_img_pos_ns = (max_x-1) * (actual_size+1) + (max_y - 1);
						count_sub_step_ns = 2;
					end
					4'd2:
					begin
						out_img_pos_ns = (max_x-1) * (actual_size+1) + max_y;
						if (max_y == actual_size)
							count_sub_step_ns = 4;
						else
							count_sub_step_ns = 3;
					end
					4'd3:
					begin
						out_img_pos_ns = (max_x-1) * (actual_size+1) + (max_y + 1);
						if (max_y == 0)
							count_sub_step_ns = 5;
						else
							count_sub_step_ns = 4;
					end
					4'd4:
					begin
						out_img_pos_ns = (max_x) * (actual_size+1) + (max_y - 1);
						count_sub_step_ns = 5;
					end
					4'd5:
					begin
						out_img_pos_ns = (max_x) * (actual_size+1) + (max_y);
						if (max_y == actual_size && max_x == actual_size)
							count_sub_step_ns = 0;
						else if (max_y == actual_size)
							count_sub_step_ns = 7;
						else
							count_sub_step_ns = 6;
					end
					4'd6:
					begin
						out_img_pos_ns = (max_x) * (actual_size+1) + (max_y + 1);
						if (max_x == actual_size)
							count_sub_step_ns = 0;
						else if (max_y == 0)
							count_sub_step_ns = 8;
						else
							count_sub_step_ns = 7;
					end
					4'd7:
					begin
						out_img_pos_ns = (max_x+1) * (actual_size+1) + (max_y - 1);
						count_sub_step_ns = 8;
					end
					4'd8:
					begin
						out_img_pos_ns = (max_x+1) * (actual_size+1) + (max_y);
						if (max_y == actual_size)
							count_sub_step_ns = 0;
						else
							count_sub_step_ns = 9;
					end
					4'd9:
					begin
						out_img_pos_ns = (max_x+1) * (actual_size+1) + (max_y + 1);
						count_sub_step_ns = 0;
					end
					default:
					begin
						out_img_pos_ns = 0;
					end
				endcase
				out_value_ns = cor_mem_Q;
				if (cur_pixel != actual_pixel)
				begin
					cur_pixel_ns = cur_pixel + 1;
					cor_mem_A = cur_pixel;
				end
				else
				begin
					state_ns = INPUT;
					count_action_ns		=	0;
					mem_A		=	0;
					flip_flag_ns		=	0;
					count_sub_step_ns	=	0;
					count_row_ns		=	0;
					cur_brightness_ns	=	0;
					done_flip_ns		=	0;
					count_adjust_brightness_ns	=	0;
					cur_pixel_ns		=	0;
					
					for (i = 0; i < 8; i = i + 1)
					begin
						rec_action_ns[i]=	0;
					end
					for (i = 0; i < 3; i = i + 1)
						for (j = 0; j < 3; j = j + 1)
						begin
							rec_template_ns[i][j]	=	0;
						end
					for (i = 0; i < 3; i = i + 1)
						product_sum_col_ns[i] = 0;
				end
			end
			else
			begin
				out_valid_ns = 1;
				out_x_ns = max_x;
				out_y_ns = actual_size - max_y;
				case(count_sub_step)
					4'b1:
					begin
						out_img_pos_ns = (max_x-1) * (actual_size+1) + (actual_size - max_y - 1);
						count_sub_step_ns = 2;
					end
					4'd2:
					begin
						out_img_pos_ns = (max_x-1) * (actual_size+1) + actual_size - max_y;
						if (max_y == 0)
							count_sub_step_ns = 4;
						else
							count_sub_step_ns = 3;
					end
					4'd3:
					begin
						out_img_pos_ns = (max_x-1) * (actual_size+1) + (actual_size - max_y + 1);
						if (max_y == actual_size)
							count_sub_step_ns = 5;
						else
							count_sub_step_ns = 4;
					end
					4'd4:
					begin
						out_img_pos_ns = (max_x) * (actual_size+1) + (actual_size - max_y - 1);
						count_sub_step_ns = 5;
					end
					4'd5:
					begin
						out_img_pos_ns = (max_x) * (actual_size+1) + (actual_size - max_y);
						if (max_y == 0 && max_x == actual_size)
							count_sub_step_ns = 0;
						else if (max_y == 0)
							count_sub_step_ns = 7;
						else
							count_sub_step_ns = 6;
					end
					4'd6:
					begin
						out_img_pos_ns = (max_x) * (actual_size+1) + (actual_size - max_y + 1);
						if (max_x == actual_size)
							count_sub_step_ns = 0;
						else if (max_y == actual_size)
							count_sub_step_ns = 8;
						else
							count_sub_step_ns = 7;
					end
					4'd7:
					begin
						out_img_pos_ns = (max_x+1) * (actual_size+1) + (actual_size - max_y - 1);
						count_sub_step_ns = 8;
					end
					4'd8:
					begin
						out_img_pos_ns = (max_x+1) * (actual_size+1) + (actual_size - max_y);
						if (max_y == 0)
							count_sub_step_ns = 0;
						else
							count_sub_step_ns = 9;
					end
					4'd9:
					begin
						out_img_pos_ns = (max_x+1) * (actual_size+1) + (actual_size - max_y + 1);
						count_sub_step_ns = 0;
					end
					default:
					begin
						out_img_pos_ns = 0;
					end
				endcase
				out_value_ns = cor_mem_Q;
				if (cur_pixel != actual_pixel - actual_size)
				begin
					if (cur_pixel % (actual_size + 1) == 0)
						cur_pixel_ns = cur_pixel + actual_size * 2 + 1;
					else 
						cur_pixel_ns = cur_pixel - 1;
					cor_mem_A = cur_pixel;
				end
				else
				begin
					state_ns = INPUT;
					count_action_ns		=	0;
					mem_A		=	0;
					flip_flag_ns		=	0;
					count_sub_step_ns	=	0;
					count_row_ns		=	0;
					cur_brightness_ns	=	0;
					done_flip_ns		=	0;
					count_adjust_brightness_ns	=	0;
					cur_pixel_ns		=	0;
					
					for (i = 0; i < 8; i = i + 1)
					begin
						rec_action_ns[i]=	0;
					end
					for (i = 0; i < 3; i = i + 1)
						for (j = 0; j < 3; j = j + 1)
						begin
							rec_template_ns[i][j]	=	0;
						end
					for (i = 0; i < 3; i = i + 1)
						product_sum_col_ns[i] = 0;
				end
			end
		end
	endcase
end

always @ (posedge clk or negedge rst_n)
begin
	if (!rst_n)
	begin
		in_valid_rec	<=	0;
		in_valid_2_rec	<=	0;
		image_rec		<=	0;
		template_rec	<=	0;
		img_size_rec	<=	0;
		action_rec		<=	0;
		state			<=	0;
		rec_size		<=	0;
		count_action	<=	0;
		rec_mem_A		<=	0;
		flip_flag		<=	0;
		max_num			<=	0;
		max_x			<=	0;
		max_y			<=	0;
		count_sub_step	<=	0;
		count_row		<=	0;
		cur_brightness	<=	0;
		done_flip		<=	0;
		count_adjust_brightness	<=	0;
		cur_pixel		<=	0;

		for (i = 0; i < 8; i = i + 1)
		begin
			rec_action[i]<=	0;
		end
		for (i = 0; i < 3; i = i + 1)
			for (j = 0; j < 3; j = j + 1)
			begin
				rec_template[i][j]	<=	0;
			end
		for (i = 0; i < 3; i = i + 1)
			product_sum_col[i] <= 0;
		out_valid <= 0;
		out_x <= 0;
		out_y <= 0;
		out_img_pos <= 0;
		out_value <= 0;
		rec_mem_Q <= 0;
	end
	else
	begin
		in_valid_rec	<=	in_valid;
		in_valid_2_rec	<=	in_valid_2;
		image_rec		<=	image;
		template_rec	<=	template;
		img_size_rec	<=	img_size;
		action_rec		<=	action;
		state			<=	state_ns;
		rec_size		<=	rec_size_ns;
		count_action	<=	count_action_ns;
		rec_mem_A		<=	mem_A;
		flip_flag		<=	flip_flag_ns;
		max_num			<=	max_num_ns;
		max_x			<=	max_x_ns;
		max_y			<=	max_y_ns;
		count_sub_step	<=	count_sub_step_ns;
		count_row		<=	count_row_ns;
		cur_brightness	<=	cur_brightness_ns;
		done_flip		<=	done_flip_ns;
		count_adjust_brightness	<=	count_adjust_brightness_ns;
		cur_pixel		<=	cur_pixel_ns;

		for (i = 0; i < 8; i = i + 1)
		begin
			rec_action[i]<=	rec_action_ns[i];
		end
		for (i = 0; i < 3; i = i + 1)
			for (j = 0; j < 3; j = j + 1)
			begin
				rec_template[i][j]	<=	rec_template_ns[i][j];
			end
		for (i = 0; i < 3; i = i + 1)
			product_sum_col[i] <= product_sum_col_ns[i];

		out_valid <= out_valid_ns;
		out_x <= out_x_ns;
		out_y <= out_y_ns;
		out_img_pos <= out_img_pos_ns;
		out_value <= out_value_ns;
		rec_mem_Q <= mem_Q;
	end
end

endmodule

