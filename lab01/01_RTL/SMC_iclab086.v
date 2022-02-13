module SMC(
  // Input signals
    mode,
    W_0, V_GS_0, V_DS_0,
    W_1, V_GS_1, V_DS_1,
    W_2, V_GS_2, V_DS_2,
    W_3, V_GS_3, V_DS_3,
    W_4, V_GS_4, V_DS_4,
    W_5, V_GS_5, V_DS_5,
  // Output signals
    out_n
);

//================================================================
//   INPUT AND OUTPUT DECLARATION
//================================================================
input [2:0] W_0, V_GS_0, V_DS_0;
input [2:0] W_1, V_GS_1, V_DS_1;
input [2:0] W_2, V_GS_2, V_DS_2;
input [2:0] W_3, V_GS_3, V_DS_3;
input [2:0] W_4, V_GS_4, V_DS_4;
input [2:0] W_5, V_GS_5, V_DS_5;
input [1:0] mode;
//output [8:0] out_n;         							// use this if using continuous assignment for out_n  // Ex: assign out_n = XXX;
output reg [9:0] out_n; 								// use this if using procedure assignment for out_n   // Ex: always@(*) begin out_n = XXX; end

//================================================================
//    Wire & Registers
//================================================================
// Declare the wire/reg you would use in your circuit
// remember
// wire for port connection and cont. assignment
// reg for proc. assignment
wire	[6:0]	n0, n1, n2, n3, n4, n5;
reg		[6:0]	n0_temp, n1_temp, n2_temp, n3_temp, n4_temp, n5_temp;
wire	[6:0]	result0_temp, result1_temp, result2_temp;
reg		[6:0]	result0, result1, result2;


//================================================================
//    DESIGN
//================================================================
// --------------------------------------------------
// write your design here
// --------------------------------------------------

CALCULATOR c0 (.w(W_0), .vgs(V_GS_0), .vds(V_DS_0), .mode0(mode[0]), .result(n0));
CALCULATOR c1 (.w(W_1), .vgs(V_GS_1), .vds(V_DS_1), .mode0(mode[0]), .result(n1));
CALCULATOR c2 (.w(W_2), .vgs(V_GS_2), .vds(V_DS_2), .mode0(mode[0]), .result(n2));
CALCULATOR c3 (.w(W_3), .vgs(V_GS_3), .vds(V_DS_3), .mode0(mode[0]), .result(n3));
CALCULATOR c4 (.w(W_4), .vgs(V_GS_4), .vds(V_DS_4), .mode0(mode[0]), .result(n4));
CALCULATOR c5 (.w(W_5), .vgs(V_GS_5), .vds(V_DS_5), .mode0(mode[0]), .result(n5));

always @(*)
begin
	if (mode[1] == 0)
	begin
		n0_temp = ~(n0);
		n1_temp = ~(n1);
		n2_temp = ~(n2);
		n3_temp = ~(n3);
		n4_temp = ~(n4);
		n5_temp = ~(n5);
	end
	else
	begin
		n0_temp = n0;
		n1_temp = n1;
		n2_temp = n2;
		n3_temp = n3;
		n4_temp = n4;
		n5_temp = n5;
	end
end

CHOOSE_MAX_3 C1 (n0_temp, n1_temp, n2_temp, n3_temp, n4_temp, n5_temp, result0_temp, result1_temp, result2_temp);

always @(*)
begin
	if (mode[1] == 0)
	begin
		result0 = ~(result2_temp);
		result1 = ~(result1_temp);
		result2 = ~(result0_temp);
	end
	else
	begin
		result0 = result0_temp;
		result1 = result1_temp;
		result2 = result2_temp;
	end
	case (mode[0])
		1'b0:
			out_n = result0 + result1 +result2;
		1'b1:
			out_n = 3 * result0 + 4 * result1 + 5 * result2;
	endcase
end







endmodule








//================================================================
//   SUB MODULE
//================================================================

module CALCULATOR (w, vgs, vds, mode0, result);

input	wire	[2:0]	w, vgs, vds;
input	wire			mode0;
output	wire	[6:0]	result;

reg		[2:0]	vgs_minus_1;
reg		[5:0]	w_mul_vgs_minus_1;
reg		[5:0]	w_mul_vds;
reg		[1:0]	operation_mode;
reg		[8:0]	result_reg;
reg		[6:0]	result_temp;

always @(*)
begin
	vgs_minus_1 = vgs - 1;
	w_mul_vgs_minus_1 = w * vgs_minus_1;
	w_mul_vds = w * vds;
	operation_mode = {(vgs_minus_1 > vds), mode0};

	case (operation_mode)
		2'b11:
			result_reg = (w_mul_vds * (2 * vgs_minus_1 - vds));
		2'b10:
			result_reg = ((w_mul_vds * 2));
		2'b01:
			result_reg = (w_mul_vgs_minus_1 * vgs_minus_1);
		default:
			result_reg = ((w_mul_vgs_minus_1 * 2));
	endcase
	result_temp = result_reg / 3;
end

assign result = result_temp;

endmodule

//module CHOOSE_MAX_3 (n0, n1, n2, n3, n4, n5, result0, result1, result2);

//input	[6:0]	n0, n1, n2, n3, n4, n5;
//output	[6:0]	result0, result1, result2;

//wire	[6:0]	n0_1, n0_2, n0_3, n0_4, n0_5, n0_6;
//wire	[6:0]	n1_1, n1_2, n1_3, n1_4, n1_5, n1_6;
//wire	[6:0]	n2_1, n2_2, n2_3, n2_4, n2_5, n2_6;
//wire	[6:0]	n3_1, n3_2, n3_3, n3_4, n3_5, n3_6;
//wire	[6:0]	n4_1, n4_2, n4_3, n4_4, n4_5, n4_6;
//wire	[6:0]	n5_1, n5_2, n5_3, n5_4, n5_5, n5_6;

//COMPARATOR c1 (n0, n1, n0_1, n1_1);
//COMPARATOR c2 (n2, n3, n2_1, n3_1);
//COMPARATOR c3 (n4, n5, n4_1, n5_1);
//assign n0_2 = n0_1;
//assign n5_2 = n5_1;
//COMPARATOR c4 (n1_1, n2_1, n1_2, n2_2);
//COMPARATOR c5 (n3_1, n4_1, n3_2, n4_2);
//COMPARATOR c6 (n0_2, n1_2, n0_3, n1_3);
//COMPARATOR c7 (n2_2, n3_2, n2_3, n3_3);
//COMPARATOR c8 (n4_2, n5_2, n4_3, n5_3);
//assign n0_4 = n0_3;
//assign n5_4 = n5_3;
//COMPARATOR c9 (n1_3, n2_3, n1_4, n2_4);
//COMPARATOR c10 (n3_3, n4_3, n3_4, n4_4);
//COMPARATOR c11 (n0_4, n1_4, n0_5, n1_5);
//COMPARATOR c12 (n2_4, n3_4, n2_5, n3_5);
//COMPARATOR c13 (n4_4, n5_4, n4_5, n5_5);
//assign n0_6 = n0_5;
//assign n5_6 = n5_5;
//COMPARATOR c14 (n1_5, n2_5, n1_6, n2_6);
//COMPARATOR c15 (n3_5, n4_5, n3_6, n4_6);

//assign result0 = n0_6;
//assign result1 = n1_6;
//assign result2 = n2_6;

//endmodule

//module COMPARATOR (n0, n1, result0, result1);

//input		[6:0]	n0, n1;
//output	reg	[6:0]	result0, result1;

//always @(*)
//begin
	//if (n0 > n1)
	//begin
		//result0 = n0;
		//result1 = n1;
	//end
	//else
	//begin
		//result0 = n1;
		//result1 = n0;
	//end
//end

//endmodule

module CHOOSE_MAX_3 (n0, n1, n2, n3, n4, n5, result0, result1, result2);

input	[6:0]	n0, n1, n2, n3, n4, n5;
output	[6:0]	result0, result1, result2;

reg		[6:0]	temp_max1, temp_max2;
reg		[6:0]	temp_max1_1, temp_max2_1, temp_max3_1;
wire	[6:0]	wtemp_max1, wtemp_max2, wtemp_max3;
wire	[6:0]	temp_max1_2, temp_max2_2, temp_max3_2;
wire	[6:0]	temp_max1_3, temp_max2_3, temp_max3_3;
wire	[6:0]	temp_max1_4, temp_max2_4, temp_max3_4;

always @(*)
begin
	if (n0 > n1)
	begin
		temp_max1 = n0;
		temp_max2 = n1;
	end
	else
	begin
		temp_max1 = n1;
		temp_max2 = n0;
	end


	if (n2 > temp_max2)
	begin
		if (n2 > temp_max1)
		begin
			temp_max3_1 = temp_max2;
			temp_max2_1 = temp_max1;
			temp_max1_1 = n2;
		end
		else
		begin
			temp_max3_1 = temp_max2;
			temp_max2_1 = n2;
			temp_max1_1 = temp_max1;
		end
	end
	else
	begin
		temp_max3_1 = n2;
		temp_max2_1 = temp_max2;
		temp_max1_1 = temp_max1;
	end
end

INSERT_GROUP I1 (.n(n3), .temp_max1(temp_max1_1), .temp_max2(temp_max2_1), .temp_max3(temp_max3_1), .result1(temp_max1_2), .result2(temp_max2_2), .result3(temp_max3_2));
INSERT_GROUP I2 (.n(n4), .temp_max1(temp_max1_2), .temp_max2(temp_max2_2), .temp_max3(temp_max3_2), .result1(temp_max1_3), .result2(temp_max2_3), .result3(temp_max3_3));
INSERT_GROUP I3 (.n(n5), .temp_max1(temp_max1_3), .temp_max2(temp_max2_3), .temp_max3(temp_max3_3), .result1(result0), .result2(result1), .result3(result2));

endmodule

module INSERT_GROUP (n, temp_max1, temp_max2, temp_max3, result1, result2, result3);

input		[6:0]	n, temp_max1, temp_max2, temp_max3;
output	reg	[6:0]	result1, result2, result3;
//reg			[2:0]	big_mode;

always @(*)
begin
	result1 = temp_max1;
	result2 = temp_max2;
	result3 = temp_max3;
	//big_mode = {(n > temp_max3), (n > temp_max2), (n > temp_max1)};

	//case (big_mode)
		//3'b111:
		//begin
			//result3 = temp_max2;
			//result2 = temp_max1;
			//result1 = n;
		//end
		//3'b110:
		//begin
			//result3 = temp_max2;
			//result2 = n;
		//end
		//3'b100:
			//result3 = n;
		//3'b101:
			//result3 = n;
	//endcase

	if (n > temp_max3)
	begin
		if (n > temp_max2)
		begin
			if (n > temp_max1)
			begin
				result3 = temp_max2;
				result2 = temp_max1;
				result1 = n;
			end
			else
			begin
				result3 = temp_max2;
				result2 = n;
			end
		end
		else
			result3 = n;
	end
end

endmodule

// module BBQ (meat,vagetable,water,cost);
// input XXX;
// output XXX;
//
// endmodule

// --------------------------------------------------
// Example for using submodule
// BBQ bbq0(.meat(meat_0), .vagetable(vagetable_0), .water(water_0),.cost(cost[0]));
// --------------------------------------------------
// Example for continuous assignment
// assign out_n = XXX;
// --------------------------------------------------
// Example for procedure assignment
// always@(*) begin
// 	out_n = XXX;
// end
// --------------------------------------------------
// Example for case statement
// always @(*) begin
// 	case(op)
// 		2'b00: output_reg = a + b;
// 		2'b10: output_reg = a - b;
// 		2'b01: output_reg = a * b;
// 		2'b11: output_reg = a / b;
// 		default: output_reg = 0;
// 	endcase
// end
// --------------------------------------------------
