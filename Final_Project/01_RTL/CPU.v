//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2021 Final Project: Customized ISA Processor 
//   Author              : Hsi-Hao Huang
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : CPU.v
//   Module Name : CPU.v
//   Release version : V1.0 (Release Date: 2021-May)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module CPU(

				clk,
			  rst_n,
  
		   IO_stall,

         awid_m_inf,
       awaddr_m_inf,
       awsize_m_inf,
      awburst_m_inf,
        awlen_m_inf,
      awvalid_m_inf,
      awready_m_inf,
                    
        wdata_m_inf,
        wlast_m_inf,
       wvalid_m_inf,
       wready_m_inf,
                    
          bid_m_inf,
        bresp_m_inf,
       bvalid_m_inf,
       bready_m_inf,
                    
         arid_m_inf,
       araddr_m_inf,
        arlen_m_inf,
       arsize_m_inf,
      arburst_m_inf,
      arvalid_m_inf,
                    
      arready_m_inf, 
          rid_m_inf,
        rdata_m_inf,
        rresp_m_inf,
        rlast_m_inf,
       rvalid_m_inf,
       rready_m_inf 

);
// Input port
input  wire clk, rst_n;
// Output port
output reg  IO_stall;

parameter ID_WIDTH = 4 , ADDR_WIDTH = 32, DATA_WIDTH = 16, DRAM_NUMBER=2, WRIT_NUMBER=1;

// AXI Interface wire connecttion for pseudo DRAM read/write
/* Hint:
  your AXI-4 interface could be designed as convertor in submodule(which used reg for output signal),
  therefore I declared output of AXI as wire in CPU
*/



// axi write address channel 
output  wire [WRIT_NUMBER * ID_WIDTH-1:0]        awid_m_inf;
output  wire [WRIT_NUMBER * ADDR_WIDTH-1:0]    awaddr_m_inf;
output  wire [WRIT_NUMBER * 3 -1:0]            awsize_m_inf;
output  wire [WRIT_NUMBER * 2 -1:0]           awburst_m_inf;
output  wire [WRIT_NUMBER * 7 -1:0]             awlen_m_inf;
output  wire [WRIT_NUMBER-1:0]                awvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                awready_m_inf;
// axi write data channel 
output  wire [WRIT_NUMBER * DATA_WIDTH-1:0]     wdata_m_inf;
output  wire [WRIT_NUMBER-1:0]                  wlast_m_inf;
output  wire [WRIT_NUMBER-1:0]                 wvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                 wready_m_inf;
// axi write response channel
input   wire [WRIT_NUMBER * ID_WIDTH-1:0]         bid_m_inf;
input   wire [WRIT_NUMBER * 2 -1:0]             bresp_m_inf;
input   wire [WRIT_NUMBER-1:0]             	   bvalid_m_inf;
output  wire [WRIT_NUMBER-1:0]                 bready_m_inf;
// -----------------------------
// axi read address channel 
output  wire [DRAM_NUMBER * ID_WIDTH-1:0]       arid_m_inf;
output  wire [DRAM_NUMBER * ADDR_WIDTH-1:0]   araddr_m_inf;
output  wire [DRAM_NUMBER * 7 -1:0]            arlen_m_inf;
output  wire [DRAM_NUMBER * 3 -1:0]           arsize_m_inf;
output  wire [DRAM_NUMBER * 2 -1:0]          arburst_m_inf;
output  wire [DRAM_NUMBER-1:0]               arvalid_m_inf;
input   wire [DRAM_NUMBER-1:0]               arready_m_inf;
// -----------------------------
// axi read data channel 
input   wire [DRAM_NUMBER * ID_WIDTH-1:0]         rid_m_inf;
input   wire [DRAM_NUMBER * DATA_WIDTH-1:0]     rdata_m_inf;
input   wire [DRAM_NUMBER * 2 -1:0]             rresp_m_inf;
input   wire [DRAM_NUMBER-1:0]                  rlast_m_inf;
input   wire [DRAM_NUMBER-1:0]                 rvalid_m_inf;
output  wire [DRAM_NUMBER-1:0]                 rready_m_inf;
// -----------------------------

/* Register in each core:
  There are sixteen registers in your CPU. You should not change the name of those registers.
  TA will check the value in each register when your core is not busy.
  If you change the name of registers below, you must get the fail in this lab.
*/

reg signed [15:0] core_r0 , core_r1 , core_r2 , core_r3 ;
reg signed [15:0] core_r4 , core_r5 , core_r6 , core_r7 ;
reg signed [15:0] core_r8 , core_r9 , core_r10, core_r11;
reg signed [15:0] core_r12, core_r13, core_r14, core_r15;

reg signed [15:0] core_r0_ns , core_r1_ns , core_r2_ns , core_r3_ns ;
reg signed [15:0] core_r4_ns , core_r5_ns , core_r6_ns , core_r7_ns ;
reg signed [15:0] core_r8_ns , core_r9_ns , core_r10_ns, core_r11_ns;
reg signed [15:0] core_r12_ns, core_r13_ns, core_r14_ns, core_r15_ns;
//####################################################
//               reg & wire
//####################################################
wire			[15:0]	mem_data_Q;
wire					mem_data_WEN;
wire			[6:0]	mem_data_A;
wire			[15:0]	mem_data_D;
wire			[15:0]	mem_inst_Q;
wire					mem_inst_WEN;
wire			[6:0]	mem_inst_A;
wire			[15:0]	mem_inst_D;

wire					mem_data_WEN_r;
wire			[6:0]	mem_data_A_r;
wire			[15:0]	mem_data_D_r;
wire					mem_data_WEN_w;
wire			[6:0]	mem_data_A_w;
wire			[15:0]	mem_data_D_w;

reg						ins_read;
reg						dat_read;
reg				[11:0]	index_data;
reg				[11:0]	index_inst;
wire			[DRAM_NUMBER * DATA_WIDTH-1:0] dram_read_out;
wire					dat_read_valid;
wire					ins_read_valid;
wire					dat_read_ready;
wire					ins_read_ready;
reg						dat_write;
reg	[DATA_WIDTH-1:0]	dram_read_in;
wire			[11:0]	cur_index_data;

reg				[11:0]	pc;
reg				[11:0]	pc_ns;
reg		signed	[15:0]	rs;
reg		signed	[15:0]	rs_ns;
reg		signed	[15:0]	rt;
reg		signed	[15:0]	rt_ns;
reg		signed	[15:0]	rd;
reg		signed	[15:0]	rd_ns;
reg		signed	[15:0]	imm;
reg		signed	[15:0]	imm_ns;
reg				[15:0]	cur_instruction;
reg				[15:0]	cur_instruction_ns;
reg				[2:0]	state;
reg				[2:0]	state_ns;
reg						flag_init;
reg						flag_init_ns;
reg				[3:0]	counter_mult;
reg				[3:0]	counter_mult_ns;

reg				[15:0]	alu_in1;
reg				[15:0]	alu_in2;
reg		signed	[15:0]	wb_number;
reg				[3:0]	wb_ins;

parameter				IF	=	3'd0;
parameter				ID	=	3'd1;
parameter				EX	=	3'd2;
parameter				MUL	=	3'd3;
parameter				MEM	=	3'd4;
parameter				WB	=	3'd5;

always @ (*)
begin
	case (cur_instruction[15:13])
		3'b000:
		begin
			alu_in1 = rs;
			alu_in2 = rt;
		end
		3'b100:
		begin
			alu_in1 = pc;
			alu_in2 = imm * 2;
		end
		default:
		begin
			alu_in1 = rs;
			alu_in2 = imm;
		end
	endcase
end

always @ (*)
begin
	core_r0_ns  =  core_r0;
	core_r1_ns  =  core_r1;
	core_r2_ns  =  core_r2;
	core_r3_ns  =  core_r3;
	core_r4_ns  =  core_r4;
	core_r5_ns  =  core_r5;
	core_r6_ns  =  core_r6;
	core_r7_ns  =  core_r7;
	core_r8_ns  =  core_r8;
	core_r9_ns  =  core_r9;
	core_r10_ns = core_r10;
	core_r11_ns = core_r11;
	core_r12_ns = core_r12;
	core_r13_ns = core_r13;
	core_r14_ns = core_r14;
	core_r15_ns = core_r15;
	
	pc_ns = pc;
	rs_ns = rs;
	rt_ns = rt;
	rd_ns = rd;
	imm_ns = imm;
	cur_instruction_ns = cur_instruction;
	state_ns = state;
	flag_init_ns = flag_init;
	counter_mult_ns = counter_mult;

	IO_stall = 1;
	
	ins_read = 0;
	dat_read = 0;
	index_data = rd * 2;
	index_inst = pc;
	dat_write = 0;
	dram_read_in = rt;

	wb_ins = cur_instruction[14] ? cur_instruction[8:5] : cur_instruction[4:1];
	wb_number = cur_instruction[14] ? rt : rd;


	case(state)
		IF:
		begin
			ins_read = 1;
			if (!flag_init)
			begin
				IO_stall = 0;
				flag_init_ns = 1;
			end
			if (ins_read_valid)
			begin
				flag_init_ns = 0;
				pc_ns = pc + 2;
				cur_instruction_ns = dram_read_out[31:16];
				state_ns = ID;
			end
		end
		ID:
		begin
			case (cur_instruction[12:9])
				4'd0:	rs_ns =  core_r0;
				4'd1:	rs_ns =  core_r1;
				4'd2:	rs_ns =  core_r2;
				4'd3:	rs_ns =  core_r3;
				4'd4:	rs_ns =  core_r4;
				4'd5:	rs_ns =  core_r5;
				4'd6:	rs_ns =  core_r6;
				4'd7:	rs_ns =  core_r7;
				4'd8:	rs_ns =  core_r8;
				4'd9:	rs_ns =  core_r9;
				4'd10:	rs_ns = core_r10;
				4'd11:	rs_ns = core_r11;
				4'd12:	rs_ns = core_r12;
				4'd13:	rs_ns = core_r13;
				4'd14:	rs_ns = core_r14;
				4'd15:	rs_ns = core_r15;
			endcase
			case (cur_instruction[8:5])
				4'd0:	rt_ns =  core_r0;
				4'd1:	rt_ns =  core_r1;
				4'd2:	rt_ns =  core_r2;
				4'd3:	rt_ns =  core_r3;
				4'd4:	rt_ns =  core_r4;
				4'd5:	rt_ns =  core_r5;
				4'd6:	rt_ns =  core_r6;
				4'd7:	rt_ns =  core_r7;
				4'd8:	rt_ns =  core_r8;
				4'd9:	rt_ns =  core_r9;
				4'd10:	rt_ns = core_r10;
				4'd11:	rt_ns = core_r11;
				4'd12:	rt_ns = core_r12;
				4'd13:	rt_ns = core_r13;
				4'd14:	rt_ns = core_r14;
				4'd15:	rt_ns = core_r15;
			endcase
			imm_ns = $signed(cur_instruction[4:0]);
			
			if (cur_instruction[15:13] == 3'b001 && cur_instruction[0] == 1'b1)
			begin
				state_ns = MUL;
				rd_ns = 0;
			end
			else
				state_ns = EX;
		end
		EX:
		begin
			if (cur_instruction[15:13] == 3'b001)
				rd_ns = (rs < rt) ? 1 : 0;
			else if (cur_instruction[15:14] == 2'b00 && cur_instruction[0])
				rd_ns = rs - rt;
			else
				rd_ns = alu_in1 + alu_in2;
			if (cur_instruction[14] && dat_read_ready)
				state_ns = MEM;
			else if (!cur_instruction[14])
				state_ns = WB;
		end
		MUL:
		begin
			// rd_ns = rs * rt;
			// if (rt[15])
			// 	rd_ns = ((rd << 1) + rs);
			// else
			// 	rd_ns = (rd << 1);
			rd_ns = (rd << 1) + (rs & {16{rt[15]}});
			rt_ns = rt << 1;
			if (counter_mult == 15)
			begin
				state_ns = WB;
			end
			counter_mult_ns = counter_mult + 1;
		end
		MEM:
		begin
			if (cur_instruction[13])
			begin
				dat_write = 1;
				if (bvalid_m_inf)
					state_ns = IF;
			end
			else
			begin
				dat_read = 1;
				if (dat_read_valid)
				begin
					rt_ns = dram_read_out[15:0];
					state_ns = WB;
				end
			end
		end
		WB:
		begin
			if (cur_instruction[15])
			begin
				if (cur_instruction[13])
					pc_ns = cur_instruction[12:0];
				else
					pc_ns = (rs == rt) ? rd : pc;
			end
			else
			begin
				case (wb_ins)
					4'd0:	core_r0_ns  = wb_number;
					4'd1:	core_r1_ns  = wb_number;
					4'd2:	core_r2_ns  = wb_number;
					4'd3:	core_r3_ns  = wb_number;
					4'd4:	core_r4_ns  = wb_number;
					4'd5:	core_r5_ns  = wb_number;
					4'd6:	core_r6_ns  = wb_number;
					4'd7:	core_r7_ns  = wb_number;
					4'd8:	core_r8_ns  = wb_number;
					4'd9:	core_r9_ns  = wb_number;
					4'd10:	core_r10_ns = wb_number;
					4'd11:	core_r11_ns = wb_number;
					4'd12:	core_r12_ns = wb_number;
					4'd13:	core_r13_ns = wb_number;
					4'd14:	core_r14_ns = wb_number;
					4'd15:	core_r15_ns = wb_number;
				endcase
			end
			if (!cur_instruction[15] || ins_read_ready)
				state_ns = IF;
		end
	endcase

end

always @ (posedge clk or negedge rst_n)
begin
	if (!rst_n)
	begin
		core_r0  <= 0;
		core_r1  <= 0;
		core_r2  <= 0;
		core_r3  <= 0;
		core_r4  <= 0;
		core_r5  <= 0;
		core_r6  <= 0;
		core_r7  <= 0;
		core_r8  <= 0;
		core_r9  <= 0;
		core_r10 <= 0;
		core_r11 <= 0;
		core_r12 <= 0;
		core_r13 <= 0;
		core_r14 <= 0;
		core_r15 <= 0;

		pc <= 0;
		rs <= 0;
		rt <= 0;
		rd <= 0;
		imm <= 0;
		cur_instruction <= 0;
		state <= 0;
		flag_init <= 1;
		counter_mult <= 0;
	end
	else
	begin
		core_r0  <=  core_r0_ns;
		core_r1  <=  core_r1_ns;
		core_r2  <=  core_r2_ns;
		core_r3  <=  core_r3_ns;
		core_r4  <=  core_r4_ns;
		core_r5  <=  core_r5_ns;
		core_r6  <=  core_r6_ns;
		core_r7  <=  core_r7_ns;
		core_r8  <=  core_r8_ns;
		core_r9  <=  core_r9_ns;
		core_r10 <= core_r10_ns;
		core_r11 <= core_r11_ns;
		core_r12 <= core_r12_ns;
		core_r13 <= core_r13_ns;
		core_r14 <= core_r14_ns;
		core_r15 <= core_r15_ns;

		pc <= pc_ns;
		rs <= rs_ns;
		rt <= rt_ns;
		rd <= rd_ns;
		imm <= imm_ns;
		cur_instruction <= cur_instruction_ns;
		state <= state_ns;
		flag_init <= flag_init_ns;
		counter_mult <= counter_mult_ns;
	end
end




/////////////////
// AXI4 Module //
/////////////////
AXI4_READ INF_AXI4_READ(
	.clk(clk),.rst_n(rst_n), .ins_read(ins_read), .dat_read(dat_read), .index_inst(index_inst), .index_data(index_data),.dram_read_out(dram_read_out),
	.dat_read_valid(dat_read_valid), .ins_read_valid(ins_read_valid),
	.dat_read_ready(dat_read_ready), .ins_read_ready(ins_read_ready),
	.cur_index_data(cur_index_data),
	.mem_data_WEN_r(mem_data_WEN_r), .mem_data_A_r(mem_data_A_r),
	.mem_data_D_r(mem_data_D_r), .mem_data_Q(mem_data_Q),
	.mem_inst_WEN(mem_inst_WEN), .mem_inst_A(mem_inst_A),
	.mem_inst_D(mem_inst_D), .mem_inst_Q(mem_inst_Q),
	.arid_m_inf(arid_m_inf),
	.arburst_m_inf(arburst_m_inf), .arsize_m_inf(arsize_m_inf), .arlen_m_inf(arlen_m_inf), 
	.arvalid_m_inf(arvalid_m_inf), .arready_m_inf(arready_m_inf), .araddr_m_inf(araddr_m_inf),
	.rid_m_inf(rid_m_inf),
	.rvalid_m_inf(rvalid_m_inf), .rready_m_inf(rready_m_inf), .rdata_m_inf(rdata_m_inf),
	.rlast_m_inf(rlast_m_inf), .rresp_m_inf(rresp_m_inf)
);
// You can desing your own module here
AXI4_WRITE INF_AXI4_WRITE(
	.clk(clk),.rst_n(rst_n),.dat_write(dat_write),.index_data(index_data), .dram_read_in(dram_read_in), 
	.cur_index_data(cur_index_data),
	.mem_data_WEN_w(mem_data_WEN_w), .mem_data_A_w(mem_data_A_w),
	.mem_data_D_w(mem_data_D_w), .mem_data_Q(mem_data_Q),
	.awid_m_inf(awid_m_inf),
	.awburst_m_inf(awburst_m_inf), .awsize_m_inf(awsize_m_inf), .awlen_m_inf(awlen_m_inf),
	.awvalid_m_inf(awvalid_m_inf), .awready_m_inf(awready_m_inf), .awaddr_m_inf(awaddr_m_inf),
   	.wvalid_m_inf(wvalid_m_inf), .wready_m_inf(wready_m_inf),
	.wdata_m_inf(wdata_m_inf), .wlast_m_inf(wlast_m_inf),
    .bid_m_inf(bid_m_inf),
   	.bvalid_m_inf(bvalid_m_inf), .bready_m_inf(bready_m_inf), .bresp_m_inf(bresp_m_inf)
);

/////////////////
// SRAM Module //
/////////////////
CACHE CACHE_DATA (.Q(mem_data_Q), .CLK(clk), .CEN(1'b0), .WEN(mem_data_WEN), .A(mem_data_A), .D(mem_data_D), .OEN(1'b0));
CACHE CACHE_INST (.Q(mem_inst_Q), .CLK(clk), .CEN(1'b0), .WEN(mem_inst_WEN), .A(mem_inst_A), .D(mem_inst_D), .OEN(1'b0));

assign mem_data_WEN = (cur_instruction[15:13] != 3'b011 || state != MEM) ? mem_data_WEN_r : mem_data_WEN_w;
assign mem_data_A = (cur_instruction[15:13] != 3'b011 || state != MEM) ? mem_data_A_r : mem_data_A_w;
assign mem_data_D = (cur_instruction[15:13] != 3'b011 || state != MEM) ? mem_data_D_r : mem_data_D_w;

endmodule

///////////////////////////////////////////////////////////////////////////////
//  					AXI4 Interfaces Module
///////////////////////////////////////////////////////////////////////////////
// Read Data from DRAM 
module AXI4_READ(
	clk,rst_n, ins_read, dat_read, index_inst, index_data, dram_read_out, 
	dat_read_valid, ins_read_valid,
	dat_read_ready, ins_read_ready,
	cur_index_data,
	arid_m_inf,
	mem_data_WEN_r, mem_data_A_r,
	mem_data_D_r, mem_data_Q,
	mem_inst_WEN, mem_inst_A,
	mem_inst_D, mem_inst_Q,
	arburst_m_inf, arsize_m_inf, arlen_m_inf, 
	arvalid_m_inf, arready_m_inf, araddr_m_inf,
	rid_m_inf,
	rvalid_m_inf, rready_m_inf, rdata_m_inf,
	rlast_m_inf, rresp_m_inf
);
parameter ID_WIDTH = 4 , ADDR_WIDTH = 32, DATA_WIDTH = 16, DRAM_NUMBER=2, WRIT_NUMBER=1;


// (0)	CHIP IO
input clk,rst_n;
input ins_read;
input dat_read;
input [11:0] index_data;
input [11:0] index_inst;
output reg [DRAM_NUMBER * DATA_WIDTH-1:0] dram_read_out;
output reg dat_read_valid;
output reg ins_read_valid;
output reg dat_read_ready;
output reg ins_read_ready;
output reg mem_data_WEN_r;
output reg [6:0] mem_data_A_r;
output reg [15:0] mem_data_D_r;
input [15:0] mem_data_Q;
output reg mem_inst_WEN;
output reg [6:0] mem_inst_A;
output reg [15:0] mem_inst_D;
input [15:0] mem_inst_Q;

// (1)	axi read address channel 
output  wire [DRAM_NUMBER * ID_WIDTH-1:0]       arid_m_inf;
output  reg  [DRAM_NUMBER * ADDR_WIDTH-1:0]   araddr_m_inf;
output  wire [DRAM_NUMBER * 7 -1:0]            arlen_m_inf;
output  wire [DRAM_NUMBER * 3 -1:0]           arsize_m_inf;
output  wire [DRAM_NUMBER * 2 -1:0]          arburst_m_inf;
output  reg	 [DRAM_NUMBER-1:0]               arvalid_m_inf;
input   wire [DRAM_NUMBER-1:0]               arready_m_inf;
// (2)	axi read data channel 
input   wire [DRAM_NUMBER * ID_WIDTH-1:0]         rid_m_inf;
input   wire [DRAM_NUMBER * DATA_WIDTH-1:0]     rdata_m_inf;
input   wire [DRAM_NUMBER * 2 -1:0]             rresp_m_inf;
input   wire [DRAM_NUMBER-1:0]                  rlast_m_inf;
input   wire [DRAM_NUMBER-1:0]                 rvalid_m_inf;
output  reg  [DRAM_NUMBER-1:0]                 rready_m_inf;

parameter READ_DRAM = 4'd2;

parameter AR_VALID = 2'd0;
parameter R_VALID = 2'd1;
parameter SRAM_FETCH_RES = 2'd2;
parameter OUT = 2'd3;

reg		[1:0]	state_inst;
reg		[1:0]	state_inst_ns;
reg		[1:0]	state_data;
reg		[1:0]	state_data_ns;
reg		[11:0]	cur_index_inst;
reg		[11:0]	cur_index_inst_ns;
output reg		[11:0]	cur_index_data;
reg		[11:0]	cur_index_data_ns;
reg		[6:0]	counter_index_inst;
reg		[6:0]	counter_index_inst_ns;
reg		[6:0]	counter_index_data;
reg		[6:0]	counter_index_data_ns;

reg				flag_init;
reg				flag_init_ns;
reg				flag_init_1;
reg				flag_init_1_ns;

reg  [DRAM_NUMBER * ADDR_WIDTH-1:0]   araddr_m_inf_ns;
reg	 [DRAM_NUMBER-1:0]               arvalid_m_inf_ns;


// axi_master read_request
// << Burst & ID >>
assign arid_m_inf = 7'd0; 			// fixed id to 0 
assign arburst_m_inf = 4'b0101;		// fixed mode to INCR mode 
assign arsize_m_inf = 6'b100100;	// fixed size to 2^4 = 16 Bytes 

// axi_master read_catch
assign arlen_m_inf = 14'b11111111111111;

always @ (*)
begin
	state_inst_ns = state_inst;
	state_data_ns = state_data;
	cur_index_inst_ns = cur_index_inst;
	cur_index_data_ns = cur_index_data;
	counter_index_data_ns = counter_index_data;
	counter_index_inst_ns = counter_index_inst;
	flag_init_ns = flag_init;
	flag_init_1_ns = flag_init_1;
	araddr_m_inf_ns = 0;
	arvalid_m_inf_ns = 0;
	rready_m_inf = 0;
	dram_read_out = 0;
	
	mem_data_WEN_r = 1;
	mem_data_A_r = 0;
	mem_data_D_r = 0;
	mem_inst_WEN = 1;
	mem_inst_A = 0;
	mem_inst_D = 0;
	ins_read_valid = 0;
	dat_read_valid = 0;
	ins_read_ready = 0;
	dat_read_ready = 0;
	
	case (state_inst)
		AR_VALID:
		begin
			ins_read_ready = 1;
			if (ins_read)
			begin
				if (((cur_index_inst) > index_inst) || ((cur_index_inst + 254) < index_inst) || !flag_init)
				begin
					// araddr_m_inf[63:32] = 32'h1000 + index_inst - 126;
					if (index_inst < 126)
						araddr_m_inf_ns[63:32] = 32'h1000;
					else if (index_inst > 12'hF7E)
						araddr_m_inf_ns[63:32] = 32'h1F00;
					else
						araddr_m_inf_ns[63:32] = 3970 + index_inst;
					if (araddr_m_inf[63:32])
						arvalid_m_inf_ns[1] = 1;
					if (arready_m_inf[1] == 1)
					begin
						state_inst_ns = R_VALID;
						cur_index_inst_ns = araddr_m_inf[43:32];
						arvalid_m_inf_ns[1] = 0;
						flag_init_ns = 1;
					end
				end
				else
				begin
					mem_inst_A = (index_inst - cur_index_inst) / 2;
					state_inst_ns = OUT;
				end
			end
		end
		R_VALID:
		begin
			rready_m_inf[1] = 1;
			if (rlast_m_inf[1] == 1)
			begin
				state_inst_ns = AR_VALID;
				counter_index_inst_ns = 0;
			end
			if (rvalid_m_inf[1] == 1)
			begin
				mem_inst_A = counter_index_inst;
				mem_inst_D = rdata_m_inf[31:16];
				mem_inst_WEN = 0;
				if (counter_index_inst == (index_inst - cur_index_inst) / 2)
				begin
					dram_read_out[31:16] = rdata_m_inf[31:16];
					ins_read_valid = 1;
				end
				counter_index_inst_ns = counter_index_inst + 1;
			end
		end
		OUT:
		begin
			dram_read_out[31:16] = mem_inst_Q;
			ins_read_valid = 1;
			state_inst_ns = AR_VALID;
			counter_index_data_ns = 0;
		end
	endcase
	
	case (state_data)
		AR_VALID:
		begin
			dat_read_ready = 1;
			if (dat_read)
			begin
				if (((cur_index_data) > index_data) || ((cur_index_data + 254) < index_data) || !flag_init_1)
				begin
					// araddr_m_inf[63:32] = 32'h1000 + index_data - 126;
					if (index_data < 126)
						araddr_m_inf_ns[31:0] = 32'h1000;
					else if (index_data > 12'hF7E)
						araddr_m_inf_ns[31:0] = 32'h1F00;
					else
						araddr_m_inf_ns[31:0] = 3970 + index_data;
					if (araddr_m_inf[31:0])
						arvalid_m_inf_ns[0] = 1;
					if (arready_m_inf[0] == 1)
					begin
						state_data_ns = R_VALID;
						cur_index_data_ns = araddr_m_inf[11:0];
						arvalid_m_inf_ns[0] = 0;
						flag_init_1_ns = 1;
					end
				end
				else
				begin
					mem_data_A_r = (index_data - cur_index_data) / 2;
					state_data_ns = OUT;
				end
			end
		end
		R_VALID:
		begin
			rready_m_inf[0] = 1;
			if (rlast_m_inf[0] == 1)
			begin
				state_data_ns = AR_VALID;
				counter_index_data_ns = 0;
			end
			if (rvalid_m_inf[0] == 1)
			begin
				mem_data_A_r = counter_index_data;
				mem_data_D_r = rdata_m_inf[15:0];
				mem_data_WEN_r = 0;
				if (counter_index_data == (index_data - cur_index_data) / 2)
				begin
					dram_read_out[15:0] = rdata_m_inf[15:0];
					dat_read_valid = 1;
				end
				counter_index_data_ns = counter_index_data + 1;
			end
		end
		OUT:
		begin
			dram_read_out[15:0] = mem_data_Q;
			dat_read_valid = 1;
			state_data_ns = AR_VALID;
			counter_index_data_ns = 0;
		end
	endcase
end

always @ (posedge clk or negedge rst_n)
begin
	if (!rst_n)
	begin
		state_inst <= 0;
		state_data <= 0;
		cur_index_inst <= 0;
		cur_index_data <= 0;
		counter_index_inst <= 0;
		counter_index_data <= 0;
		flag_init <= 0;
		flag_init_1 <= 0;
		araddr_m_inf <= 0;
		arvalid_m_inf <= 0;
	end
	else
	begin
		state_inst <= state_inst_ns;
		state_data <= state_data_ns;
		cur_index_inst <= cur_index_inst_ns;
		cur_index_data <= cur_index_data_ns;
		counter_index_inst <= counter_index_inst_ns;
		counter_index_data <= counter_index_data_ns;
		flag_init <= flag_init_ns;
		flag_init_1 <= flag_init_1_ns;
		araddr_m_inf <= araddr_m_inf_ns;
		arvalid_m_inf <= arvalid_m_inf_ns;
	end
end


endmodule

// Write Data to DRAM 
module AXI4_WRITE(
	clk,rst_n,dat_write, index_data, dram_read_in, 
	cur_index_data,
	mem_data_WEN_w, mem_data_A_w,
	mem_data_D_w, mem_data_Q,
	awid_m_inf,
	awburst_m_inf,awsize_m_inf,awlen_m_inf,
	awvalid_m_inf, awready_m_inf, awaddr_m_inf,
   	wvalid_m_inf,wready_m_inf,
	wdata_m_inf, wlast_m_inf,
    bid_m_inf,
   	bvalid_m_inf, bready_m_inf, bresp_m_inf
  
);
parameter ID_WIDTH = 4 , ADDR_WIDTH = 32, DATA_WIDTH = 16, DRAM_NUMBER=2, WRIT_NUMBER=1;

// (0)	CHIP IO
input clk,rst_n;
input dat_write;
input [11:0] index_data;
input [DATA_WIDTH-1:0] dram_read_in;
output reg mem_data_WEN_w;
output reg [6:0] mem_data_A_w;
output reg [15:0] mem_data_D_w;
input [15:0] mem_data_Q;
// (1) 	axi write address channel 
output  wire [WRIT_NUMBER * ID_WIDTH-1:0]        awid_m_inf;
output  reg  [WRIT_NUMBER * ADDR_WIDTH-1:0]    awaddr_m_inf;
output  wire [WRIT_NUMBER * 3 -1:0]            awsize_m_inf;
output  wire [WRIT_NUMBER * 2 -1:0]           awburst_m_inf;
output  wire [WRIT_NUMBER * 7 -1:0]             awlen_m_inf;
output  reg  [WRIT_NUMBER-1:0]                awvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                awready_m_inf;
// (2)	axi write data channel 
output  wire [WRIT_NUMBER * DATA_WIDTH-1:0]     wdata_m_inf;
output  reg  [WRIT_NUMBER-1:0]                  wlast_m_inf;
output  reg  [WRIT_NUMBER-1:0]                 wvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                 wready_m_inf;
// (3)	axi write response channel 
input   wire [WRIT_NUMBER * ID_WIDTH-1:0]         bid_m_inf;
input   wire [WRIT_NUMBER * 2 -1:0]             bresp_m_inf;
input   wire [WRIT_NUMBER-1:0]             	   bvalid_m_inf;
output  reg  [WRIT_NUMBER-1:0]                 bready_m_inf;

parameter WRITE_DRAM = 4'd3;
parameter AW_VALID = 2'd0;
parameter W_VALID = 2'd1;
parameter W_NON_VALID = 2'd2;

reg		[1:0]	state;
reg		[1:0]	state_ns;
input	[11:0]	cur_index_data;

reg  [WRIT_NUMBER * ADDR_WIDTH-1:0]    awaddr_m_inf_ns;
reg  [WRIT_NUMBER-1:0]                awvalid_m_inf_ns;

// axi_master write request
// << Burst & ID >>
assign awid_m_inf = 4'd0;
assign awburst_m_inf = 2'd1;
assign awsize_m_inf = 3'b100;
assign wdata_m_inf = dram_read_in;


// axi_master write send
assign awlen_m_inf = 0;
// assign awlen_m_inf = 1;

always @ (*)
begin
	state_ns = state;

	awaddr_m_inf_ns = 0;
	awvalid_m_inf_ns = 0;
	wvalid_m_inf = 0;
	bready_m_inf = 0;
	wlast_m_inf = 0;
	
	mem_data_WEN_w = 1;
	mem_data_A_w = (index_data - cur_index_data) / 2;
	mem_data_D_w = dram_read_in;
	
	case (state)
		AW_VALID:
		begin
			if (dat_write)
			begin
				awaddr_m_inf_ns = 32'h1000 + index_data;
				awvalid_m_inf_ns = 1;
				if (awready_m_inf == 1)
				begin
					state_ns = W_VALID;
					awvalid_m_inf_ns = 0;
				end
				if (((cur_index_data) <= index_data) && ((cur_index_data + 254) >= index_data))
				begin
					mem_data_WEN_w = 0;
				end
			end
		end
		W_VALID:
		begin
			wvalid_m_inf = 1;
			bready_m_inf = 1;
			wlast_m_inf = 1;
			
			if (bvalid_m_inf == 1)
			begin
				state_ns = AW_VALID;
			end
		end
	endcase
end

always @ (posedge clk or negedge rst_n)
begin
	if (!rst_n)
	begin
		state <= 0;
		awaddr_m_inf <= 0;
		awvalid_m_inf <= 0;
	end
	else
	begin
		state <= state_ns;
		awaddr_m_inf <= awaddr_m_inf_ns;
		awvalid_m_inf <= awvalid_m_inf_ns;
	end
end

endmodule

