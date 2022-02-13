module GF (  
 // input signals
    clk,
    rst_n,
    in_valid,
    in_x,
    in_y,
 // output signals
    out_valid,
    out_x,
    out_y,
    out_area);
	
input             clk,rst_n,in_valid;
input      [9:0]  in_x,in_y;
output reg [9:0]  out_x,out_y;
output reg [24:0] out_area;
output reg        out_valid;

parameter	INPUT	=	2'd0;
parameter	SORT	=	2'd1;
parameter	AREA	=	2'd2;
parameter	OUTPUT	=	2'd3;

reg			[9:0]	in_pos_reg		[0:5][0:1];
reg			[9:0]	in_pos_reg_ns	[0:5][0:1];
reg			[9:0]	out_pos_reg		[0:5][0:1];
reg			[9:0]	out_pos_reg_ns	[0:5][0:1];
reg	signed	[10:0]	vector			[0:4][0:1];
reg	signed	[10:0]	vector_ns		[0:4][0:1];
reg	signed	[20:0]	out_product   	[0:3];
reg	signed	[20:0]	out_product_ns	[0:3];
reg			[1:0]	state;
reg			[1:0]	state_ns;
reg			[2:0]	counter;
reg			[2:0]	counter_ns;
reg			[24:0]	area;
reg			[24:0]	area_ns;


integer i, j;

wire			[2:0]	det_rank [0:4];
wire	signed	[20:0]	det_res	 [0:5];

SIGN_DET sign_det0 (vector[0][0], vector[0][1], vector[counter][0], vector[counter][1], 3'd0, det_rank[0]);
SIGN_DET sign_det1 (vector[1][0], vector[1][1], vector[counter][0], vector[counter][1], det_rank[0], det_rank[1]);
SIGN_DET sign_det2 (vector[2][0], vector[2][1], vector[counter][0], vector[counter][1], det_rank[1], det_rank[2]);
SIGN_DET sign_det3 (vector[3][0], vector[3][1], vector[counter][0], vector[counter][1], det_rank[2], det_rank[3]);
SIGN_DET sign_det4 (vector[4][0], vector[4][1], vector[counter][0], vector[counter][1], det_rank[3], det_rank[4]);
// SORTER sorter (out_product[0], out_product[1], out_product[2], out_product[3], det_rank[0], det_rank[1], det_rank[2], det_rank[3], det_rank[4]);

UNSIGN_DET det1 (out_pos_reg[0][0], out_pos_reg[0][1], out_pos_reg[1][0], out_pos_reg[1][1], det_res[0]);
UNSIGN_DET det2 (out_pos_reg[1][0], out_pos_reg[1][1], out_pos_reg[2][0], out_pos_reg[2][1], det_res[1]);
UNSIGN_DET det3 (out_pos_reg[2][0], out_pos_reg[2][1], out_pos_reg[3][0], out_pos_reg[3][1], det_res[2]);
UNSIGN_DET det4 (out_pos_reg[3][0], out_pos_reg[3][1], out_pos_reg[4][0], out_pos_reg[4][1], det_res[3]);
UNSIGN_DET det5 (out_pos_reg[4][0], out_pos_reg[4][1], out_pos_reg[5][0], out_pos_reg[5][1], det_res[4]);
UNSIGN_DET det6 (out_pos_reg[5][0], out_pos_reg[5][1], out_pos_reg[0][0], out_pos_reg[0][1], det_res[5]);


always @ (*)
begin
	state_ns = state;
	counter_ns = counter;
	area_ns = area;
	out_valid = 0;
	out_x = 0;
	out_y = 0;
	out_area = 0;
	for (i = 0; i < 6; i = i + 1)
		for (j = 0; j < 2; j = j + 1)
		begin
			in_pos_reg_ns[i][j] = in_pos_reg[i][j];
			out_pos_reg_ns[i][j] = out_pos_reg[i][j];
		end
	for (i = 0; i < 5; i = i + 1)
		for (j = 0; j < 2; j = j + 1)
			vector_ns[i][j] = vector[i][j];
	for (i = 0; i < 4; i = i + 1)
		out_product_ns[i] = out_product[i];

	case (state)
		INPUT:
		begin
			if (in_valid)
			begin
				counter_ns = counter + 1;
				in_pos_reg_ns[counter][0] = in_x;
				in_pos_reg_ns[counter][1] = in_y;
				if (counter != 0)
				begin
					vector_ns[counter - 1][0] = in_x - in_pos_reg[0][0];
					vector_ns[counter - 1][1] = in_y - in_pos_reg[0][1];
				end
				if (counter == 5)
				begin
					counter_ns = 0;
					state_ns = SORT;
				end
			end
		end
		SORT:
		begin
			out_pos_reg_ns[0][0] = in_pos_reg[0][0];
			out_pos_reg_ns[0][1] = in_pos_reg[0][1];
			if (counter != 4)
			begin
				counter_ns = counter + 1;
			end
			else
			begin
				state_ns = AREA;
				counter_ns = 0;
			end
			out_pos_reg_ns[det_rank[4]][0] = in_pos_reg[counter+1][0];
			out_pos_reg_ns[det_rank[4]][1] = in_pos_reg[counter+1][1];
		end
		AREA:
		begin
			area_ns = (det_res[0] + det_res[1] + det_res[2] + det_res[3] + det_res[4] + det_res[5]) / 2;
			state_ns = OUTPUT;
		end
		OUTPUT:
		begin
			counter_ns = counter + 1;
			out_valid = 1;
			out_area = area;
			out_x = out_pos_reg[counter][0];
			out_y = out_pos_reg[counter][1];
			if (counter == 5)
			begin
				state_ns = INPUT;
				state_ns = 0;
				counter_ns = 0;
				area_ns = 0;
				for (i = 0; i < 6; i = i + 1)
					for (j = 0; j < 2; j = j + 1)
					begin
						in_pos_reg_ns[i][j] = 0;
						out_pos_reg_ns[i][j] = 0;
					end
				for (i = 0; i < 5; i = i + 1)
					for (j = 0; j < 2; j = j + 1)
						vector_ns[i][j] = 0;
				for (i = 0; i < 4; i = i + 1)
					out_product_ns[i] = 0;
			end
		end
	endcase
end

always @ (posedge clk or negedge rst_n)
begin
	if (!rst_n)
	begin
		state <= 0;
		counter <= 0;
		area <= 0;
		for (i = 0; i < 6; i = i + 1)
			for (j = 0; j < 2; j = j + 1)
			begin
				in_pos_reg[i][j] <= 0;
				out_pos_reg[i][j] <= 0;
			end
		for (i = 0; i < 5; i = i + 1)
			for (j = 0; j < 2; j = j + 1)
				vector[i][j] <= 0;
		for (i = 0; i < 4; i = i + 1)
		begin
			out_product[i] <= 0;
		end
	end
	else
	begin
		state <= state_ns;
		counter <= counter_ns;
		area <= area_ns;
		for (i = 0; i < 6; i = i + 1)
			for (j = 0; j < 2; j = j + 1)
			begin
				in_pos_reg[i][j] <= in_pos_reg_ns[i][j];
				out_pos_reg[i][j] <= out_pos_reg_ns[i][j];
			end
		for (i = 0; i < 5; i = i + 1)
			for (j = 0; j < 2; j = j + 1)
				vector[i][j] <= vector_ns[i][j];
		for (i = 0; i < 4; i = i + 1)
		begin
			out_product[i] <= out_product_ns[i];
		end
	end
end

endmodule

module SIGN_DET
(
	ax, ay,
	bx, by,
	old_rank,
	new_rank
);
input signed [10:0] ax;
input signed [10:0] ay;
input signed [10:0] bx;
input signed [10:0] by;
input		 [2:0]	old_rank;
output		 [2:0]	new_rank;

wire signed [20:0] s_res;

assign s_res = ax*by - bx*ay;

assign new_rank = (s_res >= 0) ? old_rank + 1 : old_rank;

endmodule

module UNSIGN_DET
(
	x0, y0,
	x1, y1,
	result
);
input [9:0] x0;
input [9:0] y0;
input [9:0] x1;
input [9:0] y1;
output signed [20:0] result;

assign result = x0*y1 - x1*y0;

endmodule

module SORTER
(
	det0,
	det1,
	det2,
	det3,
	out0,
	out1,
	out2,
	out3,
	out4
);
input [20:0]	det0;
input [20:0]	det1;
input [20:0]	det2;
input [20:0]	det3;
output reg	 [2:0]	out0;
output reg	 [2:0]	out1;
output reg	 [2:0]	out2;
output reg	 [2:0]	out3;
output reg	 [2:0]	out4;

wire signed [20:0]	in	[0:3];
reg [1:0] level1[0:3];
reg [1:0] level2[0:3];
reg [1:0] level3[0:3];
reg [1:0] level4[0:3];
reg [1:0] level5[0:3];
reg		  zero_flag;

assign in[0] = det0;
assign in[1] = det1;
assign in[2] = det2;
assign in[3] = det3;

always @ (*)
begin
	zero_flag = 0;
	
	if (in[0] > in[1])
	begin
		level1[0] = 0;
		level1[1] = 1;
	end
	else
	begin
		level1[0] = 1;
		level1[1] = 0;
	end
	if (in[2] > in[3])
	begin
		level1[2] = 2;
		level1[3] = 3;
	end
	else
	begin
		level1[2] = 3;
		level1[3] = 2;
	end

	
	if (in[level1[1]] > in[level1[2]])
	begin
		level2[0] = level1[0];
		level2[1] = level1[1];
		level2[2] = level1[2];
		level2[3] = level1[3];
	end
	else
	begin
		level2[0] = level1[0];
		level2[1] = level1[2];
		level2[2] = level1[1];
		level2[3] = level1[3];
	end

	
	if (in[level2[0]] > in[level2[1]])
	begin
		level3[0] = level2[0];
		level3[1] = level2[1];
	end
	else
	begin
		level3[0] = level2[1];
		level3[1] = level2[0];
	end
	if (in[level2[2]] > in[level2[3]])
	begin
		level3[2] = level2[2];
		level3[3] = level2[3];
	end
	else
	begin
		level3[2] = level2[3];
		level3[3] = level2[2];
	end

	
	if (in[level3[1]] > in[level3[2]])
	begin
		level4[0] = level3[0];
		level4[1] = level3[1];
		level4[2] = level3[2];
		level4[3] = level3[3];
	end
	else
	begin
		level4[0] = level3[0];
		level4[1] = level3[2];
		level4[2] = level3[1];
		level4[3] = level3[3];
	end

	
	if (in[level4[0]] > in[level4[1]])
	begin
		level5[0] = level4[0];
		level5[1] = level4[1];
	end
	else
	begin
		level5[0] = level4[1];
		level5[1] = level4[0];
	end
	if (in[level4[2]] > in[level4[3]])
	begin
		level5[2] = level4[2];
		level5[3] = level4[3];
	end
	else
	begin
		level5[2] = level4[3];
		level5[3] = level4[2];
	end
	
	if (in[level5[0]] > 0)
		out0 = level5[0] + 2;
	else
	begin
		out0 = 1;
		zero_flag = 1;
	end
	if (zero_flag == 1)
		out1 = level5[0] + 2;
	else if (in[level5[1]] > 0)
		out1 = level5[1] + 2;
	else
	begin
		out1 = 1;
		zero_flag = 1;
	end
	if (zero_flag == 1)
		out2 = level5[1] + 2;
	else if (in[level5[2]] > 0)
		out2 = level5[2] + 2;
	else
	begin
		out2 = 1;
		zero_flag = 1;
	end
	if (zero_flag == 1)
		out3 = level5[2] + 2;
	else if (in[level5[3]] > 0)
		out3 = level5[3] + 2;
	else
	begin
		out3 = 1;
		zero_flag = 1;
	end
	if (zero_flag == 1)
		out4 = level5[3] + 2;
	else
	begin
		out4 = 1;
		zero_flag = 1;
	end
end
endmodule
