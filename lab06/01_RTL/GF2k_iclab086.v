module GF2k
#( parameter DEG = 2 , parameter OP = 0)
(
input[DEG:0] POLY,
input[DEG-1:0] IN1,
input[DEG-1:0] IN2,
output [DEG-1:0] RESULT
);

generate
	case (OP)
		0:
			GF2k_add #(DEG) adder (.IN1(IN1), .IN2(IN2), .RESULT(RESULT));
		1:
			GF2k_add #(DEG) adder (.IN1(IN1), .IN2(IN2), .RESULT(RESULT));
		2:
			GF2k_mult #(DEG) multer (.IN1(IN1), .IN2(IN2), .POLY(POLY), .RESULT(RESULT));
		3:
			GF2k_div #(DEG) divider (.IN1(IN1), .IN2(IN2), .POLY(POLY), .RESULT(RESULT));
	endcase
endgenerate

endmodule

module GF2k_add
#(parameter DEG = 2)
(
	input[DEG-1:0] IN1,
	input[DEG-1:0] IN2,
	output [DEG-1:0] RESULT
);

assign RESULT = IN1 ^ IN2;

endmodule

module GF2k_mult
#(parameter DEG = 2)
(
	input[DEG:0] POLY,
	input[DEG-1:0] IN1,
	input[DEG-1:0] IN2,
	output[DEG-1:0] RESULT
);
wire [2*DEG-2:0] product [0:DEG-1];
reg [2*DEG-2:0] cur_R [0:DEG-1];

genvar i;
generate
	for (i = 0; i < DEG; i = i + 1)
	begin:	loop_product
		wire [2*DEG-2:0] cur_product;
		assign cur_product = (IN2[i]) ? IN1<<i : 0;
		
		if (i == 0)
			assign product[0] = cur_product;
		else
		begin
			GF2k_add #(2*DEG-1) ADD_PRODUCT (.IN1({cur_product}), .IN2(product[i - 1]), .RESULT(product[i]));
		end
	end
endgenerate

always @ (*)
begin
	cur_R[0] = product[DEG-1];
end

generate
	for (i = 0; i < DEG-1; i = i + 1)
	begin:	loop_r
		wire [2*DEG-i-2:0] next_R;
		wire [2*DEG-i-2:0] cur_S;
		
		assign cur_S = POLY << DEG-i-2;
		GF2k_add #(2*DEG-i-1) MOD (.IN1(cur_R[i][2*DEG-i-2:0]), .IN2(cur_S), .RESULT(next_R));
		always @ (*)
		begin
			if (cur_R[i][2*DEG-2-i] == 1)
				cur_R[i+1] = next_R;
			else
				cur_R[i+1] = cur_R[i];
		end
	end
endgenerate

assign RESULT = cur_R[DEG-1];

endmodule

module GF2k_div
#(parameter DEG = 2)
(
	input[DEG:0] POLY,
	input[DEG-1:0] IN1,
	input[DEG-1:0] IN2,
	output[DEG-1:0] RESULT
);

wire [DEG-1:0] mult_result;
wire [DEG-1:0] mult_in;

genvar i, j;
generate
	for (i = 0; i < 2*DEG; i = i + 1)
	begin:	loop_Euclid
		wire [DEG-i/2:0] DN;
		wire [DEG-i/2-1:0] DR;
		wire [DEG-i/2:0] DR_shift;
		wire [DEG-i/2:0] R;
		wire [DEG-i/2:0] msb_DR[0:DEG-i/2-1];
		wire [DEG-i/2:0] msb_DN[0:DEG-i/2];

		wire [DEG-1:0] mqh;
		wire [DEG-1:0] mql;
		wire [DEG-1:0] mql_Q;
		wire [DEG-1:0] MQ;
		wire [DEG-1:0] B_inv;
		wire R_flag;

		if (i == 0)
		begin
			assign DN = POLY;
			assign DR = IN2;
			assign mql = 1;
			assign mqh = 0;
		end
		else
		begin
			assign DN = (loop_Euclid[i-1].R > loop_Euclid[i-1].DR) ? loop_Euclid[i-1].R : loop_Euclid[i-1].DR;
			assign DR = (loop_Euclid[i-1].R > loop_Euclid[i-1].DR) ? loop_Euclid[i-1].DR : loop_Euclid[i-1].R;
			assign mql = (loop_Euclid[i-1].R > loop_Euclid[i-1].DR) ? loop_Euclid[i-1].mql : loop_Euclid[i-1].MQ;
			assign mqh = (loop_Euclid[i-1].R > loop_Euclid[i-1].DR) ? loop_Euclid[i-1].MQ : loop_Euclid[i-1].mql;
		end

		for (j = 0; j < DEG-i/2; j = j + 1)
		begin
			if (j == 0)
				assign msb_DR[j] = 0;
			else
				assign msb_DR[j] = (DR[j] == 1) ? j : msb_DR[j-1];
		end
		for (j = 0; j <= DEG-i/2; j = j + 1)
		begin
			if (j == 0)
				assign msb_DN[j] = 0;
			else
				assign msb_DN[j] = (DN[j] == 1) ? j : msb_DN[j-1];
		end
		assign DR_shift = DR << (msb_DN[DEG-i/2] - msb_DR[DEG-i/2-1]);
		GF2k_add #(DEG-i/2+1) mod_DR_DN (.IN1(DN), .IN2(DR_shift), .RESULT(R));
		assign mql_Q = mql << (msb_DN[DEG-i/2] - msb_DR[DEG-i/2-1]);
		GF2k_add #(DEG) GEN_MQ (.IN1(mqh), .IN2(mql_Q), .RESULT(MQ));

		if (i == 0)
		begin
			assign R_flag = (R == 1) ? 1 : 0;
			assign B_inv = MQ;
		end
		else
		begin
			assign R_flag = (R == 1 || loop_Euclid[i-1].R_flag == 1) ? 1 : 0;
			assign B_inv = (loop_Euclid[i-1].R_flag) ? loop_Euclid[i-1].B_inv : MQ;
		end
	end
endgenerate

assign mult_in = (IN2 == 1) ? 1 : (loop_Euclid[2*DEG-1].B_inv);

GF2k_mult #(DEG) GEN_RES (.IN1(IN1), .IN2(mult_in), .POLY(POLY), .RESULT(RESULT));
// GF2k_mult #(DEG) GEN_RES (.IN1(IN1), .IN2(mult_in), .POLY(POLY), .RESULT(mult_result));

// assign RESULT = (IN2 == 1) ? 1 : mult_result;

endmodule
