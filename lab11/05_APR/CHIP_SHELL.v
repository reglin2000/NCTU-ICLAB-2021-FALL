module CHIP(
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

output        out_valid;
output [3:0]  out_x, out_y;
output [7:0]  out_img_pos;
output [39:0] out_value;

// =======================================
//   Wires
// =======================================

wire			C_clk, C_rst_n, C_in_valid, C_in_valid_2;
wire	[15:0]	C_image, C_template;
wire	[4:0]	C_img_size;
wire	[1:0]	C_action;

wire			C_out_valid;
wire	[3:0]	C_out_x, C_out_y;
wire	[7:0]	C_out_img_pos;
wire	[39:0]	C_out_value;

// =======================================
//   TMIP module
// =======================================
TMIP U_TMIP(
    .clk(C_clk),
    .rst_n(C_rst_n),
    .in_valid(C_in_valid),
    .in_valid_2(C_in_valid_2),
    .image(C_image),
    .img_size(C_img_size),
    .template(C_template),
    .action(C_action),

    .out_valid(C_out_valid),
    .out_x(C_out_x),
    .out_y(C_out_y),
    .out_img_pos(C_out_img_pos),
    .out_value(C_out_value)
);

// =======================================
//   Buffers and Pads
// =======================================

///////////////
// input PAD //
///////////////
P8C	I_CLK		(.Y(C_clk),				.P(clk),			.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	I_RST_N		(.Y(C_rst_n),			.P(rst_n),			.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P4C	I_IN_VAL	(.Y(C_in_valid),		.P(in_valid),		.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P4C	I_IN_VAL2	(.Y(C_in_valid_2),		.P(in_valid_2),		.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));

P4C	I_IMG0		(.Y(C_image[0]),		.P(image[0]),		.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P4C	I_IMG1		(.Y(C_image[1]),		.P(image[1]),		.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P4C	I_IMG2		(.Y(C_image[2]),		.P(image[2]),		.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P4C	I_IMG3		(.Y(C_image[3]),		.P(image[3]),		.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P4C	I_IMG4		(.Y(C_image[4]),		.P(image[4]),		.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P4C	I_IMG5		(.Y(C_image[5]),		.P(image[5]),		.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P4C	I_IMG6		(.Y(C_image[6]),		.P(image[6]),		.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P4C	I_IMG7		(.Y(C_image[7]),		.P(image[7]),		.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P4C	I_IMG8		(.Y(C_image[8]),		.P(image[8]),		.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P4C	I_IMG9		(.Y(C_image[9]),		.P(image[9]),		.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P4C	I_IMG10		(.Y(C_image[10]),		.P(image[10]),		.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P4C	I_IMG11		(.Y(C_image[11]),		.P(image[11]),		.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P4C	I_IMG12		(.Y(C_image[12]),		.P(image[12]),		.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P4C	I_IMG13		(.Y(C_image[13]),		.P(image[13]),		.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P4C	I_IMG14		(.Y(C_image[14]),		.P(image[14]),		.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P4C	I_IMG15		(.Y(C_image[15]),		.P(image[15]),		.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));

P4C	I_TPL0		(.Y(C_template[0]),		.P(template[0]),	.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P4C	I_TPL1		(.Y(C_template[1]),		.P(template[1]),	.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P4C	I_TPL2		(.Y(C_template[2]),		.P(template[2]),	.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P4C	I_TPL3		(.Y(C_template[3]),		.P(template[3]),	.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P4C	I_TPL4		(.Y(C_template[4]),		.P(template[4]),	.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P4C	I_TPL5		(.Y(C_template[5]),		.P(template[5]),	.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P4C	I_TPL6		(.Y(C_template[6]),		.P(template[6]),	.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P4C	I_TPL7		(.Y(C_template[7]),		.P(template[7]),	.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P4C	I_TPL8		(.Y(C_template[8]),		.P(template[8]),	.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P4C	I_TPL9		(.Y(C_template[9]),		.P(template[9]),	.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P4C	I_TPL10		(.Y(C_template[10]),	.P(template[10]),	.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P4C	I_TPL11		(.Y(C_template[11]),	.P(template[11]),	.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P4C	I_TPL12		(.Y(C_template[12]),	.P(template[12]),	.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P4C	I_TPL13		(.Y(C_template[13]),	.P(template[13]),	.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P4C	I_TPL14		(.Y(C_template[14]),	.P(template[14]),	.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P4C	I_TPL15		(.Y(C_template[15]),	.P(template[15]),	.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));

P4C	I_IMSI0		(.Y(C_img_size[0]),		.P(img_size[0]),	.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P4C	I_IMSI1		(.Y(C_img_size[1]),		.P(img_size[1]),	.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P4C	I_IMSI2		(.Y(C_img_size[2]),		.P(img_size[2]),	.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P4C	I_IMSI3		(.Y(C_img_size[3]),		.P(img_size[3]),	.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P4C	I_IMSI4		(.Y(C_img_size[4]),		.P(img_size[4]),	.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));

P4C	I_ACT0		(.Y(C_action[0]),		.P(action[0]),		.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P4C	I_ACT1		(.Y(C_action[1]),		.P(action[1]),		.A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));

////////////////
// output PAD //
////////////////
P8C	O_VALID		(.A(C_out_valid),		.P(out_valid),		.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));

P8C	O_OUTX0		(.A(C_out_x[0]),		.P(out_x[0]),		.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OUTX1		(.A(C_out_x[1]),		.P(out_x[1]),		.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OUTX2		(.A(C_out_x[2]),		.P(out_x[2]),		.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OUTX3		(.A(C_out_x[3]),		.P(out_x[3]),		.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OUTY0		(.A(C_out_y[0]),		.P(out_y[0]),		.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OUTY1		(.A(C_out_y[1]),		.P(out_y[1]),		.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OUTY2		(.A(C_out_y[2]),		.P(out_y[2]),		.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OUTY3		(.A(C_out_y[3]),		.P(out_y[3]),		.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));

P8C	O_IMGP0		(.A(C_out_img_pos[0]),	.P(out_img_pos[0]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_IMGP1		(.A(C_out_img_pos[1]),	.P(out_img_pos[1]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_IMGP2		(.A(C_out_img_pos[2]),	.P(out_img_pos[2]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_IMGP3		(.A(C_out_img_pos[3]),	.P(out_img_pos[3]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_IMGP4		(.A(C_out_img_pos[4]),	.P(out_img_pos[4]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_IMGP5		(.A(C_out_img_pos[5]),	.P(out_img_pos[5]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_IMGP6		(.A(C_out_img_pos[6]),	.P(out_img_pos[6]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_IMGP7		(.A(C_out_img_pos[7]),	.P(out_img_pos[7]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));

P8C	O_OVALUE0	(.A(C_out_value[0]),	.P(out_value[0]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE1	(.A(C_out_value[1]),	.P(out_value[1]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE2	(.A(C_out_value[2]),	.P(out_value[2]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE3	(.A(C_out_value[3]),	.P(out_value[3]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE4	(.A(C_out_value[4]),	.P(out_value[4]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE5	(.A(C_out_value[5]),	.P(out_value[5]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE6	(.A(C_out_value[6]),	.P(out_value[6]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE7	(.A(C_out_value[7]),	.P(out_value[7]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE8	(.A(C_out_value[8]),	.P(out_value[8]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE9	(.A(C_out_value[9]),	.P(out_value[9]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE10	(.A(C_out_value[10]),	.P(out_value[10]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE11	(.A(C_out_value[11]),	.P(out_value[11]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE12	(.A(C_out_value[12]),	.P(out_value[12]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE13	(.A(C_out_value[13]),	.P(out_value[13]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE14	(.A(C_out_value[14]),	.P(out_value[14]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE15	(.A(C_out_value[15]),	.P(out_value[15]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE16	(.A(C_out_value[16]),	.P(out_value[16]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE17	(.A(C_out_value[17]),	.P(out_value[17]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE18	(.A(C_out_value[18]),	.P(out_value[18]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE19	(.A(C_out_value[19]),	.P(out_value[19]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE20	(.A(C_out_value[20]),	.P(out_value[20]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE21	(.A(C_out_value[21]),	.P(out_value[21]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE22	(.A(C_out_value[22]),	.P(out_value[22]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE23	(.A(C_out_value[23]),	.P(out_value[23]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE24	(.A(C_out_value[24]),	.P(out_value[24]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE25	(.A(C_out_value[25]),	.P(out_value[25]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE26	(.A(C_out_value[26]),	.P(out_value[26]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE27	(.A(C_out_value[27]),	.P(out_value[27]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE28	(.A(C_out_value[28]),	.P(out_value[28]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE29	(.A(C_out_value[29]),	.P(out_value[29]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE30	(.A(C_out_value[30]),	.P(out_value[30]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE31	(.A(C_out_value[31]),	.P(out_value[31]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE32	(.A(C_out_value[32]),	.P(out_value[32]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE33	(.A(C_out_value[33]),	.P(out_value[33]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE34	(.A(C_out_value[34]),	.P(out_value[34]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE35	(.A(C_out_value[35]),	.P(out_value[35]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE36	(.A(C_out_value[36]),	.P(out_value[36]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE37	(.A(C_out_value[37]),	.P(out_value[37]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE38	(.A(C_out_value[38]),	.P(out_value[38]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C	O_OVALUE39	(.A(C_out_value[39]),	.P(out_value[39]),	.ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));

// =======================================
//   I/O power 3.3V pads x? (DVDD + DGND)
// =======================================

PVDDR VDDP0 ();
PVSSR GNDP0 ();
PVDDR VDDP1 ();
PVSSR GNDP1 ();
PVDDR VDDP2 ();
PVSSR GNDP2 ();
PVDDR VDDP3 ();
PVSSR GNDP3 ();
PVDDR VDDP4 ();
PVSSR GNDP4 ();
PVDDR VDDP5 ();
PVSSR GNDP5 ();
PVDDR VDDP6 ();
PVSSR GNDP6 ();
PVDDR VDDP7 ();
PVSSR GNDP7 ();

// =======================================
//  Core poweri 1.8V pads x? (VDD + GND)
// =======================================

PVDDC VDDC0 ();
PVSSC GNDC0 ();
PVDDC VDDC1 ();
PVSSC GNDC1 ();
PVDDC VDDC2 ();
PVSSC GNDC2 ();
PVDDC VDDC3 ();
PVSSC GNDC3 ();

endmodule
