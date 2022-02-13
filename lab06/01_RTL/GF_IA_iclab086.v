//synopsys translate_off
`include "GF2k.v"
//synopsys translate_on

module GF_IA (
input in_valid,
input [4:0] in_data,
input [2:0] deg,
input [5:0] poly,
input rst_n,
input clk,
output reg [4:0] out_data,
output reg out_valid
);

parameter INPUT	=	2'd0;
parameter DIV	=	2'd1;
parameter OUT	=	2'd2;

reg		[1:0]	state;
reg		[1:0]	state_ns;
reg		[4:0]	rec_in_data		[0:3];
reg		[4:0]	rec_in_data_ns	[0:3];
reg		[4:0]	rec_d1_m_d2;
reg		[4:0]	rec_d1_m_d2_ns;
reg		[4:0]	rec_det;
reg		[4:0]	rec_det_ns;
reg		[4:0]	rec_det_inv;
reg		[4:0]	rec_det_inv_ns;
reg		[2:0]	rec_deg;
reg		[2:0]	rec_deg_ns;
reg		[5:0]	rec_poly;
reg		[5:0]	rec_poly_ns;
reg		[1:0]	counter_state;
reg		[1:0]	counter_state_ns;

reg		[4:0]	mult_IN1;
reg		[4:0]	mult_IN2;
reg		[4:0]	mult_IN1_out;
reg		[4:0]	mult_IN2_out;
reg		[4:0]	rec_d0_m_d3_ns;

wire	[1:0]	mult_RES_deg2;
wire	[2:0]	mult_RES_deg3;
wire	[3:0]	mult_RES_deg4;
wire	[4:0]	mult_RES_deg5;
wire	[1:0]	mult_RES_deg2_out;
wire	[2:0]	mult_RES_deg3_out;
wire	[3:0]	mult_RES_deg4_out;
wire	[4:0]	mult_RES_deg5_out;
wire	[1:0]	det_inv_deg2;
wire	[2:0]	det_inv_deg3;
wire	[3:0]	det_inv_deg4;
wire	[4:0]	det_inv_deg5;
wire	[4:0]	div_IN2;
integer i;

assign div_IN2 = rec_det;

GF2k #(2, 2) mult2bit (.IN1(mult_IN1[1:0]), .IN2(mult_IN2[1:0]), .POLY(rec_poly[2:0]), .RESULT(mult_RES_deg2));
GF2k #(3, 2) mult3bit (.IN1(mult_IN1[2:0]), .IN2(mult_IN2[2:0]), .POLY(rec_poly[3:0]), .RESULT(mult_RES_deg3));
GF2k #(4, 2) mult4bit (.IN1(mult_IN1[3:0]), .IN2(mult_IN2[3:0]), .POLY(rec_poly[4:0]), .RESULT(mult_RES_deg4));
GF2k #(5, 2) mult5bit (.IN1(mult_IN1[4:0]), .IN2(mult_IN2[4:0]), .POLY(rec_poly[5:0]), .RESULT(mult_RES_deg5));

GF2k #(2, 2) mult2bit_out (.IN1(mult_IN1_out[1:0]), .IN2(mult_IN2_out[1:0]), .POLY(rec_poly[2:0]), .RESULT(mult_RES_deg2_out));
GF2k #(3, 2) mult3bit_out (.IN1(mult_IN1_out[2:0]), .IN2(mult_IN2_out[2:0]), .POLY(rec_poly[3:0]), .RESULT(mult_RES_deg3_out));
GF2k #(4, 2) mult4bit_out (.IN1(mult_IN1_out[3:0]), .IN2(mult_IN2_out[3:0]), .POLY(rec_poly[4:0]), .RESULT(mult_RES_deg4_out));
GF2k #(5, 2) mult5bit_out (.IN1(mult_IN1_out[4:0]), .IN2(mult_IN2_out[4:0]), .POLY(rec_poly[5:0]), .RESULT(mult_RES_deg5_out));

GF2k #(2, 3) div2bit (.IN1(2'd1), .IN2(div_IN2[1:0]), .POLY(rec_poly[2:0]), .RESULT(det_inv_deg2));
GF2k #(3, 3) div3bit (.IN1(3'd1), .IN2(div_IN2[2:0]), .POLY(rec_poly[3:0]), .RESULT(det_inv_deg3));
GF2k #(4, 3) div4bit (.IN1(4'd1), .IN2(div_IN2[3:0]), .POLY(rec_poly[4:0]), .RESULT(det_inv_deg4));
GF2k #(5, 3) div5bit (.IN1(5'd1), .IN2(div_IN2[4:0]), .POLY(rec_poly[5:0]), .RESULT(det_inv_deg5));

// =========================================
// Finite State Machine
// =========================================

always @ (*)
begin
	state_ns			=	state;
	rec_det_inv_ns		=	rec_det_inv;
	rec_deg_ns			=	rec_deg;
	rec_poly_ns			=	rec_poly;
	rec_d1_m_d2_ns		=	rec_d1_m_d2;
	rec_det_ns			=	rec_det;
	rec_det_inv_ns		=	rec_det_inv;
	counter_state_ns	=	counter_state;
	
	for (i = 0; i < 4; i = i + 1)
		rec_in_data_ns[i] = rec_in_data[i];

	mult_IN1 = 0;
	mult_IN2 = 0;
	mult_IN1_out = 0;
	mult_IN2_out = 0;
	rec_d0_m_d3_ns = 0;
	
	out_valid = 0;
	out_data = 0;

	case (state)
		INPUT:
		begin
			if (in_valid)
			begin
				rec_in_data_ns[counter_state] = in_data;
				counter_state_ns = counter_state + 1;
				
				if (counter_state == 0)
				begin
					rec_deg_ns = deg;
					rec_poly_ns = poly;
				end
				else if (counter_state == 2)
				begin
					mult_IN1 = rec_in_data[1];
					mult_IN2 = in_data;
					case (rec_deg)
						3'd2:
							rec_d1_m_d2_ns = mult_RES_deg2;
						3'd3:
							rec_d1_m_d2_ns = mult_RES_deg3;
						3'd4:
							rec_d1_m_d2_ns = mult_RES_deg4;
						default:
							rec_d1_m_d2_ns = mult_RES_deg5;
					endcase
				end
				else if (counter_state == 3)
				begin
					mult_IN1 = rec_in_data[0];
					mult_IN2 = in_data;
					case (rec_deg)
						3'd2:
							rec_d0_m_d3_ns = mult_RES_deg2;
						3'd3:
							rec_d0_m_d3_ns = mult_RES_deg3;
						3'd4:
							rec_d0_m_d3_ns = mult_RES_deg4;
						default:
							rec_d0_m_d3_ns = mult_RES_deg5;
					endcase
					rec_det_ns = rec_d0_m_d3_ns ^ rec_d1_m_d2;
					state_ns = DIV;
				end
			end
		end
		DIV:
		begin
			if (rec_det != 0)
			begin
				case (rec_deg)
					3'd2:
						rec_det_inv_ns = det_inv_deg2;
					3'd3:
						rec_det_inv_ns = det_inv_deg3;
					3'd4:
						rec_det_inv_ns = det_inv_deg4;
					default:
						rec_det_inv_ns = det_inv_deg5;
				endcase
				state_ns = OUT;
			end
			else
			begin
				rec_det_inv_ns = 0;
				state_ns = OUT;
			end
		end
		default:
		begin
			out_valid = 1;
			counter_state_ns = counter_state + 1;
			case (counter_state)
				2'd0:
				begin
					mult_IN1_out = rec_in_data[3];
					mult_IN2_out = rec_det_inv;
					case (rec_deg)
						3'd2:
							out_data = mult_RES_deg2_out;
						3'd3:
							out_data = mult_RES_deg3_out;
						3'd4:
							out_data = mult_RES_deg4_out;
						default:
							out_data = mult_RES_deg5_out;
					endcase
				end
				2'd1:
				begin
					mult_IN1_out = rec_in_data[1];
					mult_IN2_out = rec_det_inv;
					case (rec_deg)
						3'd2:
							out_data = mult_RES_deg2_out;
						3'd3:
							out_data = mult_RES_deg3_out;
						3'd4:
							out_data = mult_RES_deg4_out;
						default:
							out_data = mult_RES_deg5_out;
					endcase
				end
				2'd2:
				begin
					mult_IN1_out = rec_in_data[2];
					mult_IN2_out = rec_det_inv;
					case (rec_deg)
						3'd2:
							out_data = mult_RES_deg2_out;
						3'd3:
							out_data = mult_RES_deg3_out;
						3'd4:
							out_data = mult_RES_deg4_out;
						default:
							out_data = mult_RES_deg5_out;
					endcase
				end
				2'd3:
				begin
					mult_IN1_out = rec_in_data[0];
					mult_IN2_out = rec_det_inv;
					case (rec_deg)
						3'd2:
							out_data = mult_RES_deg2_out;
						3'd3:
							out_data = mult_RES_deg3_out;
						3'd4:
							out_data = mult_RES_deg4_out;
						default:
							out_data = mult_RES_deg5_out;
					endcase
					
					state_ns			=	INPUT;
					rec_det_inv_ns		=	0;
					rec_deg_ns			=	0;
					rec_poly_ns			=	0;
					rec_d1_m_d2_ns		=	0;
					rec_det_ns			=	0;
					rec_det_inv_ns		=	0;
				end
			endcase
		end
	endcase
end

// =========================================
// Output Data
// =========================================
//
always @(posedge clk or negedge rst_n)
begin
	if (!rst_n)
	begin
		state			<=	0;
		rec_det_inv		<=	0;
		rec_deg			<=	0;
		rec_poly		<=	0;
		rec_d1_m_d2		<=	0;
		rec_det			<=	0;
		rec_det_inv		<=	0;
		counter_state	<=	0;

		for (i = 0; i < 4; i = i + 1)
			rec_in_data[i] <= 0;
	end
	else
	begin
		state			<=	state_ns;
		rec_det_inv		<=	rec_det_inv_ns;
		rec_deg			<=	rec_deg_ns;
		rec_poly		<=	rec_poly_ns;
		rec_d1_m_d2		<=	rec_d1_m_d2_ns;
		rec_det			<=	rec_det_ns;
		rec_det_inv		<=	rec_det_inv_ns;
		counter_state	<=	counter_state_ns;

		for (i = 0; i < 4; i = i + 1)
			rec_in_data[i] <= rec_in_data_ns[i];
	end
end

endmodule
