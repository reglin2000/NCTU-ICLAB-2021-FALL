//synopsys translate_off
`include "/usr/synthesis/dw/sim_ver/DW_fp_cmp.v"
`include "/usr/synthesis/dw/sim_ver/DW_fp_sub.v"
`include "/usr/synthesis/dw/sim_ver/DW_fp_div.v"
`include "/usr/synthesis/dw/sim_ver/DW_fp_mult.v"
`include "/usr/synthesis/dw/sim_ver/DW_ifp_mult.v"
`include "/usr/synthesis/dw/sim_ver/DW_fp_sum3.v"
`include "/usr/synthesis/dw/sim_ver/DW_fp_sum4.v"
`include "/usr/synthesis/dw/sim_ver/DW_fp_dp2.v"
`include "/usr/synthesis/dw/sim_ver/DW_fp_ifp_conv.v"
`include "/usr/synthesis/dw/sim_ver/DW_ifp_fp_conv.v"
`include "/usr/synthesis/dw/sim_ver/DW_ifp_addsub.v"
`include "/usr/synthesis/dw/sim_ver/DW_fp_addsub.v"
//synopsys translate_on

module NN(
	// Input signals
	clk,
	rst_n,
	in_valid_d,
	in_valid_t,
	in_valid_w1,
	in_valid_w2,
	data_point,
	target,
	weight1,
	weight2,
	// Output signals
	out_valid,
	out
);

//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------

// IEEE floating point paramenters
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch = 0;

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION
//---------------------------------------------------------------------
input  clk, rst_n, in_valid_d, in_valid_t, in_valid_w1, in_valid_w2;
input [inst_sig_width+inst_exp_width:0] data_point, target;
input [inst_sig_width+inst_exp_width:0] weight1, weight2;
output reg	out_valid;
output reg [inst_sig_width+inst_exp_width:0] out;

//---------------------------------------------------------------------
//   WIRE AND REG DECLARATION
//---------------------------------------------------------------------
reg		[8:0]	counter_epoch;
reg		[10:0]	counter_epoch_ns;
reg		[1:0]	counter_indata1;
reg		[1:0]	counter_indata1_ns;
reg		[1:0]	counter_indata2;
reg		[1:0]	counter_indata2_ns;

reg		[31:0]	rec_weight1[0:2][0:3];
reg		[31:0]	rec_weight1_ns[0:2][0:3];
reg		[31:0]	rec_weight2[0:2];
reg		[31:0]	rec_weight2_ns[0:2];
reg		[31:0]	rec_data[0:3];
reg		[31:0]	rec_data_ns[0:3];
reg		[31:0]	rec_target;
reg		[31:0]	rec_target_ns;

reg		[31:0]	h1[0:2];
reg		[31:0]	h1_ns[0:2];
reg		[31:0]	delta2;
reg		[31:0]	delta2_ns;
reg				in_flag1;
reg				in_flag1_ns;
reg		[31:0]	delta1[0:2];
reg		[31:0]	delta1_ns[0:2];
reg		[31:0]	learning_rate;
reg		[31:0]	learning_rate_ns;
reg				in_flag15;
reg				in_flag17;
reg				in_flag2;
reg				in_flag3;
reg		[31:0]	y2_reg;
reg		[31:0]	y2_reg_ns;
reg		[31:0]	y2_op[0:2];
reg		[31:0]	y2_op_ns[0:2];

wire	[31:0]	h1_0;
wire	[31:0]	h1_1;
wire	[31:0]	h1_2;
wire	[7:0]	s_h1_0;
wire	[7:0]	s_h1_1;
wire	[7:0]	s_h1_2;
wire			y1_0_cmp;
wire			y1_1_cmp;
wire			y1_2_cmp;
wire	[31:0]	y1_0;
wire	[31:0]	y1_1;
wire	[31:0]	y1_2;
wire	[31:0]	w2_y10;
wire	[31:0]	w2_y11;
wire	[31:0]	w2_y12;
wire	[31:0]	y2;
wire	[31:0]	delta2_wire;
wire	[31:0]	delta1_wire[0:2];
wire	[31:0]	delh0;
wire	[31:0]	delh1;
wire	[31:0]	delh2;
wire	[31:0]	learn_delh0;
wire	[31:0]	learn_delh1;
wire	[31:0]	learn_delh2;
wire	[31:0]	w20_temp;
wire	[31:0]	w21_temp;
wire	[31:0]	w22_temp;
wire	[31:0]	del1_0data0;
wire	[31:0]	del1_0data1;
wire	[31:0]	del1_0data2;
wire	[31:0]	del1_0data3;
wire	[31:0]	del1_1data0;
wire	[31:0]	del1_1data1;
wire	[31:0]	del1_1data2;
wire	[31:0]	del1_1data3;
wire	[31:0]	del1_2data0;
wire	[31:0]	del1_2data1;
wire	[31:0]	del1_2data2;
wire	[31:0]	del1_2data3;
wire	[31:0]	learn_del1_0data0;
wire	[31:0]	learn_del1_0data1;
wire	[31:0]	learn_del1_0data2;
wire	[31:0]	learn_del1_0data3;
wire	[31:0]	learn_del1_1data0;
wire	[31:0]	learn_del1_1data1;
wire	[31:0]	learn_del1_1data2;
wire	[31:0]	learn_del1_1data3;
wire	[31:0]	learn_del1_2data0;
wire	[31:0]	learn_del1_2data1;
wire	[31:0]	learn_del1_2data2;
wire	[31:0]	learn_del1_2data3;
wire	[31:0]	w1_temp[0:2][0:3];
wire	[31:0]	learning_rate_divide_2;
wire			h1_0_cmp;
wire			h1_1_cmp;
wire			h1_2_cmp;
wire	[31:0]	w10_d[0:3];
wire	[31:0]	w11_d[0:3];
wire	[31:0]	w12_d[0:3];


integer i, j;
//---------------------------------------------------------------------
//   DesignWare
//---------------------------------------------------------------------

fp_mult L1_W100D0 (.a(rec_weight1[0][0]), .b(rec_data[0]), .rnd(3'b0), .z(w10_d[0]));
fp_mult L1_W101D1 (.a(rec_weight1[0][1]), .b(rec_data[1]), .rnd(3'b0), .z(w10_d[1]));
fp_mult L1_W102D2 (.a(rec_weight1[0][2]), .b(rec_data[2]), .rnd(3'b0), .z(w10_d[2]));
fp_mult L1_W103D3 (.a(rec_weight1[0][3]), .b(rec_data[3]), .rnd(3'b0), .z(w10_d[3]));
fp_sum4 L1_H10 (.a(w10_d[0]), .b(w10_d[1]), .c(w10_d[2]), .d(w10_d[3]), .rnd(3'd0), .z(h1_0));

fp_mult L1_W110D0 (.a(rec_weight1[1][0]), .b(rec_data[0]), .rnd(3'b0), .z(w11_d[0]));
fp_mult L1_W111D1 (.a(rec_weight1[1][1]), .b(rec_data[1]), .rnd(3'b0), .z(w11_d[1]));
fp_mult L1_W112D2 (.a(rec_weight1[1][2]), .b(rec_data[2]), .rnd(3'b0), .z(w11_d[2]));
fp_mult L1_W113D3 (.a(rec_weight1[1][3]), .b(rec_data[3]), .rnd(3'b0), .z(w11_d[3]));
fp_sum4 L1_H11 (.a(w11_d[0]), .b(w11_d[1]), .c(w11_d[2]), .d(w11_d[3]), .rnd(3'd0), .z(h1_1));

fp_mult L1_W120D0 (.a(rec_weight1[2][0]), .b(rec_data[0]), .rnd(3'b0), .z(w12_d[0]));
fp_mult L1_W121D1 (.a(rec_weight1[2][1]), .b(rec_data[1]), .rnd(3'b0), .z(w12_d[1]));
fp_mult L1_W122D2 (.a(rec_weight1[2][2]), .b(rec_data[2]), .rnd(3'b0), .z(w12_d[2]));
fp_mult L1_W123D3 (.a(rec_weight1[2][3]), .b(rec_data[3]), .rnd(3'b0), .z(w12_d[3]));
fp_sum4 L1_H12 (.a(w12_d[0]), .b(w12_d[1]), .c(w12_d[2]), .d(w12_d[3]), .rnd(3'd0), .z(h1_2));

fp_cmp L1_Y1 (.a(h1[0]), .b(32'd0), .zctr(1'b0), .agtb(y1_0_cmp));
fp_cmp L1_Y2 (.a(h1[1]), .b(32'd0), .zctr(1'b0), .agtb(y1_1_cmp));
fp_cmp L1_Y3 (.a(h1[2]), .b(32'd0), .zctr(1'b0), .agtb(y1_2_cmp));

assign y1_0 = (y1_0_cmp) ? h1[0] : 0;
assign y1_1 = (y1_1_cmp) ? h1[1] : 0;
assign y1_2 = (y1_2_cmp) ? h1[2] : 0;

fp_mult L2_W2Y10 (.a(rec_weight2[0]), .b(y1_0), .rnd(3'b0), .z(w2_y10));
fp_mult L2_W2Y11 (.a(rec_weight2[1]), .b(y1_1), .rnd(3'b0), .z(w2_y11));
fp_mult L2_W2Y12 (.a(rec_weight2[2]), .b(y1_2), .rnd(3'b0), .z(w2_y12));
fp_sum3 L2_Y2 (.a(y2_op[0]), .b(y2_op[1]), .c(y2_op[2]), .rnd(3'd0), .z(y2));

fp_sub B_L2DEL2 (.a(y2), .b(rec_target), .rnd(3'd0), .z(delta2_wire));

fp_div LEARN_DIV_2 (.a(learning_rate), .b(32'h40000000), .rnd(3'd0), .z(learning_rate_divide_2));

always @(*)
begin
	for (i = 0; i < 3; i = i + 1)
		for (j = 0; j < 4; j = j + 1)
			rec_weight1_ns[i][j] = rec_weight1[i][j];
	for (i = 0; i < 3; i = i + 1)
	begin
		rec_weight2_ns[i]	=	rec_weight2[i];
		h1_ns[i]			=	h1[i];
		y2_op_ns[i]			=	y2_op[i];
	end
	for (i = 0; i < 4; i = i + 1)
		rec_data_ns[i]		=	rec_data[i];
	rec_target_ns		=	rec_target;
	counter_epoch_ns	=	counter_epoch;
	counter_indata1_ns	=	counter_indata1;
	counter_indata2_ns	=	counter_indata2;
	delta2_ns			=	delta2;
	in_flag1_ns			=	0;
	learning_rate_ns	=	learning_rate;
	y2_reg_ns			=	y2_reg;
	
	if (in_valid_w1)
	begin
		rec_weight1_ns[counter_indata2][counter_indata1] = weight1;
		learning_rate_ns = 32'h358637BD;
		counter_epoch_ns = 0;
		
		if (in_valid_w2)
			rec_weight2_ns[counter_indata1] = weight2;
		
		if (counter_indata2 == 2 && counter_indata1 == 3)
		begin
			counter_indata2_ns = 0;
			counter_indata1_ns = 0;
		end
		else if (counter_indata1 == 3)
		begin
			counter_indata1_ns = 0;
			counter_indata2_ns = counter_indata2 + 1;
		end
		else
			counter_indata1_ns = counter_indata1 + 1;
	end
	else if (in_valid_d)
	begin
		rec_data_ns[counter_indata1] = data_point;
		
		if (in_valid_t)
			rec_target_ns = target;
		
		if (counter_indata1 == 3)
		begin
			counter_indata1_ns = 0;
			in_flag1_ns = 1;

		end
		else
			counter_indata1_ns = counter_indata1 + 1;
	end
	else if (in_flag1)
	begin
		h1_ns[0] = h1_0;
		h1_ns[1] = h1_1;
		h1_ns[2] = h1_2;

	end
	else if (in_flag15)
	begin
		y2_op_ns[0] = w2_y10;
		y2_op_ns[1] = w2_y11;
		y2_op_ns[2] = w2_y12;
	end
	else if (in_flag17)
	begin
		y2_reg_ns = y2;
		delta2_ns = delta2_wire;
	end
	else if (in_flag2)
	begin
		rec_weight2_ns[0] = w20_temp;
		rec_weight2_ns[1] = w21_temp;
		rec_weight2_ns[2] = w22_temp;
	end
	else if (in_flag3)
	begin
		for (i = 0; i < 3; i = i + 1)
			for (j = 0; j < 4; j = j + 1)
				rec_weight1_ns[i][j] = w1_temp[i][j];
		for (i = 0; i < 3; i = i + 1)
			h1_ns[i] = 0;
		if (counter_epoch == 399)
		begin
			learning_rate_ns = learning_rate_divide_2;
			counter_epoch_ns = 0;
		end
		else
			counter_epoch_ns = counter_epoch + 1;
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (!rst_n)
	begin
		for (i = 0; i < 3; i = i + 1)
			for (j = 0; j < 4; j = j + 1)
				rec_weight1[i][j] <=	0;
		for (i = 0; i < 3; i = i + 1)
		begin
			rec_weight2[i]	<=	0;
			h1[i]			<=	0;
			y2_op[i]		<=	0;
		end
		for (i = 0; i < 4; i = i + 1)
			rec_data[i]		<=	0;
		rec_target		<=	0;
		counter_epoch	<=	0;
		counter_indata1	<=	0;
		counter_indata2	<=	0;
		delta2			<=	0;
		in_flag1		<=	0;
		learning_rate	<=	0;
		y2_reg			<=	0;
	end
	else
	begin
		for (i = 0; i < 3; i = i + 1)
			for (j = 0; j < 4; j = j + 1)
				rec_weight1[i][j] <= rec_weight1_ns[i][j];
		for (i = 0; i < 3; i = i + 1)
		begin
			rec_weight2[i]	<=	rec_weight2_ns[i];
			h1[i]			<=	h1_ns[i];
			y2_op[i]		<=	y2_op_ns[i];
		end
		for (i = 0; i < 4; i = i + 1)
			rec_data[i]		<=	rec_data_ns[i];
		rec_target		<=	rec_target_ns;
		counter_epoch	<=	counter_epoch_ns;
		counter_indata1	<=	counter_indata1_ns;
		counter_indata2	<=	counter_indata2_ns;
		delta2			<=	delta2_ns;
		in_flag1		<=	in_flag1_ns;
		learning_rate	<=	learning_rate_ns;
		y2_reg			<=	y2_reg_ns;
	end
end

fp_mult B_L1_D0 (.a(rec_weight2[0]), .b(delta2), .rnd(3'b0), .z(delta1_wire[0]));
fp_mult B_L1_D1 (.a(rec_weight2[1]), .b(delta2), .rnd(3'b0), .z(delta1_wire[1]));
fp_mult B_L1_D2 (.a(rec_weight2[2]), .b(delta2), .rnd(3'b0), .z(delta1_wire[2]));

fp_cmp L1_H1C0 (.a(h1[0]), .b(32'd0), .zctr(1'b0), .agtb(h1_0_cmp));
fp_cmp L1_H1C1 (.a(h1[1]), .b(32'd0), .zctr(1'b0), .agtb(h1_1_cmp));
fp_cmp L1_H1C2 (.a(h1[2]), .b(32'd0), .zctr(1'b0), .agtb(h1_2_cmp));

fp_mult U_L2_DELH0 (.a(delta2), .b(h1[0]), .rnd(3'b0), .z(delh0));
fp_mult U_L2_DELH1 (.a(delta2), .b(h1[1]), .rnd(3'b0), .z(delh1));
fp_mult U_L2_DELH2 (.a(delta2), .b(h1[2]), .rnd(3'b0), .z(delh2));

fp_mult U_L2_LEARN_DELH0 (.a(learning_rate), .b(delh0), .rnd(3'b0), .z(learn_delh0));
fp_mult U_L2_LEARN_DELH1 (.a(learning_rate), .b(delh1), .rnd(3'b0), .z(learn_delh1));
fp_mult U_L2_LEARN_DELH2 (.a(learning_rate), .b(delh2), .rnd(3'b0), .z(learn_delh2));

fp_sub U_L2_W20 (.a(rec_weight2[0]), .b(learn_delh0), .rnd(3'd0), .z(w20_temp));
fp_sub U_L2_W21 (.a(rec_weight2[1]), .b(learn_delh1), .rnd(3'd0), .z(w21_temp));
fp_sub U_L2_W22 (.a(rec_weight2[2]), .b(learn_delh2), .rnd(3'd0), .z(w22_temp));

fp_mult U_L1_DEL0H0 (.a(delta1[0]), .b(rec_data[0]), .rnd(3'b0), .z(del1_0data0));
fp_mult U_L1_DEL0H1 (.a(delta1[0]), .b(rec_data[1]), .rnd(3'b0), .z(del1_0data1));
fp_mult U_L1_DEL0H2 (.a(delta1[0]), .b(rec_data[2]), .rnd(3'b0), .z(del1_0data2));
fp_mult U_L1_DEL0H3 (.a(delta1[0]), .b(rec_data[3]), .rnd(3'b0), .z(del1_0data3));
fp_mult U_L1_DEL1H0 (.a(delta1[1]), .b(rec_data[0]), .rnd(3'b0), .z(del1_1data0));
fp_mult U_L1_DEL1H1 (.a(delta1[1]), .b(rec_data[1]), .rnd(3'b0), .z(del1_1data1));
fp_mult U_L1_DEL1H2 (.a(delta1[1]), .b(rec_data[2]), .rnd(3'b0), .z(del1_1data2));
fp_mult U_L1_DEL1H3 (.a(delta1[1]), .b(rec_data[3]), .rnd(3'b0), .z(del1_1data3));
fp_mult U_L1_DEL2H0 (.a(delta1[2]), .b(rec_data[0]), .rnd(3'b0), .z(del1_2data0));
fp_mult U_L1_DEL2H1 (.a(delta1[2]), .b(rec_data[1]), .rnd(3'b0), .z(del1_2data1));
fp_mult U_L1_DEL2H2 (.a(delta1[2]), .b(rec_data[2]), .rnd(3'b0), .z(del1_2data2));
fp_mult U_L1_DEL2H3 (.a(delta1[2]), .b(rec_data[3]), .rnd(3'b0), .z(del1_2data3));

fp_mult U_L1_LEARN_DEL0H0 (.a(learning_rate), .b(del1_0data0), .rnd(3'b0), .z(learn_del1_0data0));
fp_mult U_L1_LEARN_DEL0H1 (.a(learning_rate), .b(del1_0data1), .rnd(3'b0), .z(learn_del1_0data1));
fp_mult U_L1_LEARN_DEL0H2 (.a(learning_rate), .b(del1_0data2), .rnd(3'b0), .z(learn_del1_0data2));
fp_mult U_L1_LEARN_DEL0H3 (.a(learning_rate), .b(del1_0data3), .rnd(3'b0), .z(learn_del1_0data3));
fp_mult U_L1_LEARN_DEL1H0 (.a(learning_rate), .b(del1_1data0), .rnd(3'b0), .z(learn_del1_1data0));
fp_mult U_L1_LEARN_DEL1H1 (.a(learning_rate), .b(del1_1data1), .rnd(3'b0), .z(learn_del1_1data1));
fp_mult U_L1_LEARN_DEL1H2 (.a(learning_rate), .b(del1_1data2), .rnd(3'b0), .z(learn_del1_1data2));
fp_mult U_L1_LEARN_DEL1H3 (.a(learning_rate), .b(del1_1data3), .rnd(3'b0), .z(learn_del1_1data3));
fp_mult U_L1_LEARN_DEL2H0 (.a(learning_rate), .b(del1_2data0), .rnd(3'b0), .z(learn_del1_2data0));
fp_mult U_L1_LEARN_DEL2H1 (.a(learning_rate), .b(del1_2data1), .rnd(3'b0), .z(learn_del1_2data1));
fp_mult U_L1_LEARN_DEL2H2 (.a(learning_rate), .b(del1_2data2), .rnd(3'b0), .z(learn_del1_2data2));
fp_mult U_L1_LEARN_DEL2H3 (.a(learning_rate), .b(del1_2data3), .rnd(3'b0), .z(learn_del1_2data3));

fp_sub U_L1_W100 (.a(rec_weight1[0][0]), .b(learn_del1_0data0), .rnd(3'd0), .z(w1_temp[0][0]));
fp_sub U_L1_W101 (.a(rec_weight1[0][1]), .b(learn_del1_0data1), .rnd(3'd0), .z(w1_temp[0][1]));
fp_sub U_L1_W102 (.a(rec_weight1[0][2]), .b(learn_del1_0data2), .rnd(3'd0), .z(w1_temp[0][2]));
fp_sub U_L1_W103 (.a(rec_weight1[0][3]), .b(learn_del1_0data3), .rnd(3'd0), .z(w1_temp[0][3]));
fp_sub U_L1_W110 (.a(rec_weight1[1][0]), .b(learn_del1_1data0), .rnd(3'd0), .z(w1_temp[1][0]));
fp_sub U_L1_W111 (.a(rec_weight1[1][1]), .b(learn_del1_1data1), .rnd(3'd0), .z(w1_temp[1][1]));
fp_sub U_L1_W112 (.a(rec_weight1[1][2]), .b(learn_del1_1data2), .rnd(3'd0), .z(w1_temp[1][2]));
fp_sub U_L1_W113 (.a(rec_weight1[1][3]), .b(learn_del1_1data3), .rnd(3'd0), .z(w1_temp[1][3]));
fp_sub U_L1_W120 (.a(rec_weight1[2][0]), .b(learn_del1_2data0), .rnd(3'd0), .z(w1_temp[2][0]));
fp_sub U_L1_W121 (.a(rec_weight1[2][1]), .b(learn_del1_2data1), .rnd(3'd0), .z(w1_temp[2][1]));
fp_sub U_L1_W122 (.a(rec_weight1[2][2]), .b(learn_del1_2data2), .rnd(3'd0), .z(w1_temp[2][2]));
fp_sub U_L1_W123 (.a(rec_weight1[2][3]), .b(learn_del1_2data3), .rnd(3'd0), .z(w1_temp[2][3]));

always @ (*)
begin
	for (i = 0; i < 3; i = i + 1)
		delta1_ns[i]	=	delta1[i];

	out					=	0;
	out_valid			=	in_flag2;
	
	if (in_flag2)
	begin
		out = y2_reg;
		if (h1_0_cmp)
			delta1_ns[0] = delta1_wire[0];
		else
			delta1_ns[0] = 0;
		if (h1_1_cmp)
			delta1_ns[1] = delta1_wire[1];
		else
			delta1_ns[1] = 0;
		if (h1_2_cmp)
			delta1_ns[2] = delta1_wire[2];
		else
			delta1_ns[2] = 0;
	end
end

always @ (posedge clk or negedge rst_n)
begin
	if (!rst_n)
	begin
		in_flag15 <= 0;
		in_flag2 <= 0;
		in_flag3 <= 0;
	end
	else
	begin
		in_flag15 <= in_flag1;
		in_flag17 <= in_flag15;
		in_flag2 <= in_flag17;
		in_flag3 <= in_flag2;
		for (i = 0; i < 3; i = i + 1)
			delta1[i]	<=	delta1_ns[i];
	end
end

endmodule

module fp_sub
(
	a,
	b,
	rnd,
	z
);
// IEEE floating point paramenters
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch = 0;
input	[31:0]	a;
input	[31:0]	b;
input	[2:0]	rnd;
output	[31:0]	z;

DW_fp_sub # (inst_sig_width, inst_exp_width, inst_ieee_compliance) U1 (.a(a), .b(b), .rnd(rnd), .z(z));

//synopsys dc_script_begin
//set_implementation rtl U1
//synopsys dc_script_end
endmodule

module fp_cmp
(
	a,
	b,
	zctr,
	agtb
);
// IEEE floating point paramenters
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch = 0;
input	[31:0]	a;
input	[31:0]	b;
input			zctr;
output			agtb;

DW_fp_cmp # (inst_sig_width, inst_exp_width, inst_ieee_compliance) U1 (.a(a), .b(b), .zctr(1'b0), .agtb(agtb));

//synopsys dc_script_begin
//set_implementation rtl U1
//synopsys dc_script_end
endmodule

module fp_div
(
	a,
	b,
	rnd,
	z
);
// IEEE floating point paramenters
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch = 0;
input	[31:0]	a;
input	[31:0]	b;
input	[2:0]	rnd;
output	[31:0]	z;

DW_fp_div # (inst_sig_width, inst_exp_width, inst_ieee_compliance) U1 (.a(a), .b(b), .rnd(3'd0), .z(z));

//synopsys dc_script_begin
//set_implementation rtl U1
//synopsys dc_script_end
endmodule

module fp_mult
(
	a,
	b,
	rnd,
	z
);
// IEEE floating point paramenters
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch = 0;
input	[31:0]	a;
input	[31:0]	b;
input	[2:0]	rnd;
output	[31:0]	z;

DW_fp_mult # (inst_sig_width, inst_exp_width, inst_ieee_compliance) U1 (.a(a), .b(b), .rnd(3'b0), .z(z));

//synopsys dc_script_begin
//set_implementation rtl U1
//synopsys dc_script_end
endmodule

module fp_sum3
(
	a,
	b,
	c,
	rnd,
	z
);
// IEEE floating point paramenters
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch = 0;
input	[31:0]	a;
input	[31:0]	b;
input	[31:0]	c;
input	[2:0]	rnd;
output	[31:0]	z;

DW_fp_sum3 # (inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) U1 (.a(a), .b(b), .c(c), .rnd(3'd0), .z(z));

//synopsys dc_script_begin
//set_implementation rtl U1
//synopsys dc_script_end
endmodule

module fp_sum4
(
	a,
	b,
	c,
	d,
	rnd,
	z
);
// IEEE floating point paramenters
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch = 0;
input	[31:0]	a;
input	[31:0]	b;
input	[31:0]	c;
input	[31:0]	d;
input	[2:0]	rnd;
output	[31:0]	z;

DW_fp_sum4 # (inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) U1 (.a(a), .b(b), .c(c), .d(d), .rnd(3'd0), .z(z));

//synopsys dc_script_begin
//set_implementation rtl U1
//synopsys dc_script_end
endmodule
