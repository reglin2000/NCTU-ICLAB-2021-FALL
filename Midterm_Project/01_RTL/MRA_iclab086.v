//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Si2 LAB @NYCU ED430
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2021 Fall
//   Midterm Proejct            : MRA  
//   Author                     : Lin-Hung, Lai
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : MRA.v
//   Module Name : MRA
//   Release version : V1.0 (Release Date: 2021-10)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module MRA(
	// CHIP IO
	clk            	,	
	rst_n          	,	
	in_valid       	,	
	frame_id        ,	
	net_id         	,	  
	loc_x          	,	  
    loc_y         	,
	cost	 		,		
	busy         	,

    // AXI4 IO
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
	   rready_m_inf,
	
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
	   bready_m_inf 
);
parameter ID_WIDTH=4, DATA_WIDTH=128, ADDR_WIDTH=32;    // DO NOT modify AXI4 Parameter
parameter NUM_ROW = 64, NUM_COLUMN = 64; 				
parameter MAX_NUM_MACRO = 15;

// << CHIP io port with system >>
input 			  	clk,rst_n;
input 			   	in_valid;
input  [4:0] 		frame_id;
input  [3:0]       	net_id;     
input  [5:0]       	loc_x; 
input  [5:0]       	loc_y; 
output reg [13:0] 	cost;
output reg          busy;       
  
// AXI Interface wire connecttion for pseudo DRAM read/write
/* Hint:
       Your AXI-4 interface could be designed as a bridge in submodule,
	   therefore I declared output of AXI as wire.  
	   Ex: AXI4_interface AXI4_INF(...);
*/

// <<<<< AXI READ >>>>>
// (1)	axi read address channel 
output wire [ID_WIDTH-1:0]      arid_m_inf;
output wire [1:0]            arburst_m_inf;
output wire [2:0]             arsize_m_inf;
output wire [7:0]              arlen_m_inf;
output wire                  arvalid_m_inf;
input  wire                  arready_m_inf;
output wire [ADDR_WIDTH-1:0]  araddr_m_inf;
// (2)	axi read data channel 
input  wire [ID_WIDTH-1:0]       rid_m_inf;
input  wire                   rvalid_m_inf;
output wire                   rready_m_inf;
input  wire [DATA_WIDTH-1:0]   rdata_m_inf;
input  wire                    rlast_m_inf;
input  wire [1:0]              rresp_m_inf;
// <<<<< AXI WRITE >>>>>
// (1) 	axi write address channel 
output wire [ID_WIDTH-1:0]      awid_m_inf;
output wire [1:0]            awburst_m_inf;
output wire [2:0]             awsize_m_inf;
output wire [7:0]              awlen_m_inf;
output wire                  awvalid_m_inf;
input  wire                  awready_m_inf;
output wire [ADDR_WIDTH-1:0]  awaddr_m_inf;
// (2)	axi write data channel 
output wire                   wvalid_m_inf;
input  wire                   wready_m_inf;
output wire [DATA_WIDTH-1:0]   wdata_m_inf;
output wire                    wlast_m_inf;
// (3)	axi write response channel 
input  wire  [ID_WIDTH-1:0]      bid_m_inf;
input  wire                   bvalid_m_inf;
output wire                   bready_m_inf;
input  wire  [1:0]             bresp_m_inf;


parameter INPUT = 4'd0;
parameter READ_DRAM = 4'd2;
parameter WRITE_DRAM = 4'd3;
parameter BFS = 4'd4;
parameter TRACE_BACK = 4'd5;
parameter OUTPUT = 4'd6;
parameter CLEAR_BFS_MAP = 4'd7;

parameter EMPTY = 4'd0;
parameter MACRO = 4'd4;
parameter NET   = 4'd5;

reg		[3:0]	curr_state;
reg		[3:0]	curr_state_ns;
reg		[12:0]	index;
reg				data_type;
reg				data_type_ns;
reg		[4:0]	frame_id_reg;
reg		[4:0]	frame_id_reg_ns;
reg		[3:0]	net_id_reg		[0:14];
reg		[3:0]	net_id_reg_ns	[0:14];
reg		[5:0]	loc_x_reg		[0:14][0:1];
reg		[5:0]	loc_x_reg_ns	[0:14][0:1];
reg		[5:0]	loc_y_reg		[0:14][0:1];
reg		[5:0]	loc_y_reg_ns	[0:14][0:1];
reg		[3:0]	net_num;
reg		[3:0]	net_num_ns;
reg		[3:0]	ctr_net;
reg		[3:0]	ctr_net_ns;
reg		[6:0]	ctr_addr;
reg		[6:0]	ctr_addr_ns;

reg		[6:0]	counter_queue;
reg		[6:0]	counter_queue_ns;
reg		[6:0]	max_queue	[0:1];
reg		[6:0]	max_queue_ns[0:1];
reg		[5:0]	queue		[0:127][0:1];
reg		[5:0]	queue_ns	[0:127][0:1];
reg				select_queue;
reg				select_queue_ns;
reg		[3:0]	counter_bfs_state;
reg		[3:0]	counter_bfs_state_ns;
reg		[1:0]	cur_iteration;
reg		[1:0]	cur_iteration_ns;
reg		[13:0]	acc_cost;
reg		[13:0]	acc_cost_ns;

reg		[5:0]	cur_x;
reg		[5:0]	cur_y;
wire	[5:0]	cur_x_p_1;
wire	[5:0]	cur_x_m_1;
wire	[5:0]	cur_y_p_1;
wire	[5:0]	cur_y_m_1;

reg		[DATA_WIDTH-1:0]	dram_read_in;
wire	[DATA_WIDTH-1:0]	dram_read_out;

wire	[DATA_WIDTH-1:0]	lmap_Q;
reg							lmap_WEN;
reg		[6:0]				lmap_A;
reg		[DATA_WIDTH-1:0]	lmap_D;

wire	[DATA_WIDTH-1:0]	wmap_Q;
reg							wmap_WEN;
reg		[6:0]				wmap_A;
reg		[DATA_WIDTH-1:0]	wmap_D;

wire	[DATA_WIDTH-1:0]	bfsmap_Q;
reg							bfsmap_WEN;
reg		[6:0]				bfsmap_A;
reg		[DATA_WIDTH-1:0]	bfsmap_D;

wire	[127:0]				lmap_Q_x;
wire	[127:0]				lmap_Q_x_p;
wire	[127:0]				lmap_Q_x_m;
wire	[127:0]				bfsmap_Q_x;
wire	[127:0]				bfsmap_Q_x_p;
wire	[127:0]				bfsmap_Q_x_m;
wire	[3:0]				bfsmap_segment;
wire	[3:0]				bfsmap_p_segment;
wire	[3:0]				bfsmap_m_segment;
wire	[3:0]				wmap_segment;
wire	[3:0]				wmap_p_segment;
wire	[3:0]				wmap_m_segment;

integer i, j;

// assign curr_state = READ_DRAM;
// assign index = 0;


LOC_MEM LMAP (.Q(lmap_Q), .CLK(clk), .CEN(1'b0), .WEN(lmap_WEN), .A(lmap_A), .D(lmap_D), .OEN(1'b0));
LOC_MEM WMAP (.Q(wmap_Q), .CLK(clk), .CEN(1'b0), .WEN(wmap_WEN), .A(wmap_A), .D(wmap_D), .OEN(1'b0));
LOC_MEM BFSMAP (.Q(bfsmap_Q), .CLK(clk), .CEN(1'b0), .WEN(bfsmap_WEN), .A(bfsmap_A), .D(bfsmap_D), .OEN(1'b0));

CHANGE_SEGMENT LMAP_X (.TARGET(lmap_Q), .ELEMENT(net_id_reg[ctr_net]), .POSITION(cur_x), .RESULT(lmap_Q_x));
CHANGE_SEGMENT LMAP_X_P (.TARGET(lmap_Q), .ELEMENT(net_id_reg[ctr_net]), .POSITION(cur_x_p_1), .RESULT(lmap_Q_x_p));
CHANGE_SEGMENT LMAP_X_M (.TARGET(lmap_Q), .ELEMENT(net_id_reg[ctr_net]), .POSITION(cur_x_m_1), .RESULT(lmap_Q_x_m));
CHANGE_SEGMENT BFSMAP_X (.TARGET(bfsmap_Q), .ELEMENT({2'd0,cur_iteration}), .POSITION(cur_x), .RESULT(bfsmap_Q_x));
CHANGE_SEGMENT BFSMAP_X_P (.TARGET(bfsmap_Q), .ELEMENT({2'd0,cur_iteration}), .POSITION(cur_x_p_1), .RESULT(bfsmap_Q_x_p));
CHANGE_SEGMENT BFSMAP_X_M (.TARGET(bfsmap_Q), .ELEMENT({2'd0,cur_iteration}), .POSITION(cur_x_m_1), .RESULT(bfsmap_Q_x_m));

EXTRACT BFSMAP_EX (.TARGET(bfsmap_Q), .POSITION(cur_x), .RESULT(bfsmap_segment));
EXTRACT BFSMAP_EX_P (.TARGET(bfsmap_Q), .POSITION(cur_x_p_1), .RESULT(bfsmap_p_segment));
EXTRACT BFSMAP_EX_M (.TARGET(bfsmap_Q), .POSITION(cur_x_m_1), .RESULT(bfsmap_m_segment));
EXTRACT WMAP_EX (.TARGET(wmap_Q), .POSITION(cur_x), .RESULT(wmap_segment));
EXTRACT WMAP_EX_P (.TARGET(wmap_Q), .POSITION(cur_x_p_1), .RESULT(wmap_p_segment));
EXTRACT WMAP_EX_M (.TARGET(wmap_Q), .POSITION(cur_x_m_1), .RESULT(wmap_m_segment));

assign cur_x_p_1 = cur_x + 1;
assign cur_x_m_1 = cur_x - 1;
assign cur_y_p_1 = cur_y + 1;
assign cur_y_m_1 = cur_y - 1;

always @ (*)
begin
	curr_state_ns = curr_state;
	data_type_ns = data_type;
	frame_id_reg_ns = frame_id_reg;
	net_num_ns = net_num;
	ctr_net_ns = ctr_net;
	ctr_addr_ns = ctr_addr;
	
	counter_queue_ns = counter_queue;
	select_queue_ns = select_queue;
	counter_bfs_state_ns = counter_bfs_state;
	cur_iteration_ns = cur_iteration;
	acc_cost_ns = acc_cost;
	for (i = 0; i < 15; i = i + 1)
	begin
		net_id_reg_ns[i] = net_id_reg[i];
	end
	for (i = 0; i < 15; i = i + 1)
	begin
		for (j = 0; j < 2; j = j + 1)
		begin
			loc_x_reg_ns[i][j] = loc_x_reg[i][j];
			loc_y_reg_ns[i][j] = loc_y_reg[i][j];
		end
	end
	for (i = 0; i < 2; i = i + 1)
	begin
		max_queue_ns[i] = max_queue[i];
	end
	for (i = 0; i < 128; i = i + 1)
	begin
		for (j = 0; j < 2; j = j + 1)
		begin
			queue_ns[i][j] = queue[i][j];
		end
	end

	
	index = 0;
	dram_read_in = 0;

	cur_x = queue[counter_queue][0];
	cur_y = queue[counter_queue][1];
	
	dram_read_in = 0;
	lmap_WEN = 1;
	lmap_A = 0;
	lmap_D = 0;
	wmap_WEN = 1;
	wmap_A = 0;
	wmap_D = 0;
	bfsmap_WEN = 1;
	bfsmap_A = 0;
	bfsmap_D = 0;

	busy = 1;
	cost = 0;
	
	case (curr_state)
		INPUT:
		begin
			busy = 0;
			if (in_valid == 1 && ctr_addr % 2 == 0)
			begin
				frame_id_reg_ns = frame_id;
				ctr_addr_ns = ctr_addr + 1;
				net_id_reg_ns[net_num] = net_id;
				loc_x_reg_ns[net_num][0] = loc_x;
				loc_y_reg_ns[net_num][0] = loc_y;
			end
			else if (in_valid == 1 && ctr_addr % 2 == 1)
			begin
				frame_id_reg_ns = frame_id;
				ctr_addr_ns = ctr_addr + 1;
				net_id_reg_ns[net_num] = net_id;
				loc_x_reg_ns[net_num][1] = loc_x;
				loc_y_reg_ns[net_num][1] = loc_y;
				net_num_ns = net_num + 1;
			end
			else if (ctr_addr != 0)
			begin
				curr_state_ns = READ_DRAM;
				ctr_addr_ns = 0;
			end
		end
		READ_DRAM:
		begin
			if (data_type == 0)
			begin
				if (rvalid_m_inf == 1 && rlast_m_inf == 1)
				begin
					data_type_ns = 1;
					
					lmap_WEN = 0;
					lmap_A = ctr_addr;
					lmap_D = rdata_m_inf;
					bfsmap_WEN = 0;
					bfsmap_A = ctr_addr;
					ctr_addr_ns = 0;
					bfsmap_D[3:0] = (rdata_m_inf[3:0]) ? MACRO : EMPTY;
					bfsmap_D[7:4] = (rdata_m_inf[7:4]) ? MACRO : EMPTY;
					bfsmap_D[11:8] = (rdata_m_inf[11:8]) ? MACRO : EMPTY;
					bfsmap_D[15:12] = (rdata_m_inf[15:12]) ? MACRO : EMPTY;
					bfsmap_D[19:16] = (rdata_m_inf[19:16]) ? MACRO : EMPTY;
					bfsmap_D[23:20] = (rdata_m_inf[23:20]) ? MACRO : EMPTY;
					bfsmap_D[27:24] = (rdata_m_inf[27:24]) ? MACRO : EMPTY;
					bfsmap_D[31:28] = (rdata_m_inf[31:28]) ? MACRO : EMPTY;
					bfsmap_D[35:32] = (rdata_m_inf[35:32]) ? MACRO : EMPTY;
					bfsmap_D[39:36] = (rdata_m_inf[39:36]) ? MACRO : EMPTY;
					bfsmap_D[43:40] = (rdata_m_inf[43:40]) ? MACRO : EMPTY;
					bfsmap_D[47:44] = (rdata_m_inf[47:44]) ? MACRO : EMPTY;
					bfsmap_D[51:48] = (rdata_m_inf[51:48]) ? MACRO : EMPTY;
					bfsmap_D[55:52] = (rdata_m_inf[55:52]) ? MACRO : EMPTY;
					bfsmap_D[59:56] = (rdata_m_inf[59:56]) ? MACRO : EMPTY;
					bfsmap_D[63:60] = (rdata_m_inf[63:60]) ? MACRO : EMPTY;
					bfsmap_D[67:64] = (rdata_m_inf[67:64]) ? MACRO : EMPTY;
					bfsmap_D[71:68] = (rdata_m_inf[71:68]) ? MACRO : EMPTY;
					bfsmap_D[75:72] = (rdata_m_inf[75:72]) ? MACRO : EMPTY;
					bfsmap_D[79:76] = (rdata_m_inf[79:76]) ? MACRO : EMPTY;
					bfsmap_D[83:80] = (rdata_m_inf[83:80]) ? MACRO : EMPTY;
					bfsmap_D[87:84] = (rdata_m_inf[87:84]) ? MACRO : EMPTY;
					bfsmap_D[91:88] = (rdata_m_inf[91:88]) ? MACRO : EMPTY;
					bfsmap_D[95:92] = (rdata_m_inf[95:92]) ? MACRO : EMPTY;
					bfsmap_D[99:96] = (rdata_m_inf[99:96]) ? MACRO : EMPTY;
					bfsmap_D[103:100] = (rdata_m_inf[103:100]) ? MACRO : EMPTY;
					bfsmap_D[107:104] = (rdata_m_inf[107:104]) ? MACRO : EMPTY;
					bfsmap_D[111:108] = (rdata_m_inf[111:108]) ? MACRO : EMPTY;
					bfsmap_D[115:112] = (rdata_m_inf[115:112]) ? MACRO : EMPTY;
					bfsmap_D[119:116] = (rdata_m_inf[119:116]) ? MACRO : EMPTY;
					bfsmap_D[123:120] = (rdata_m_inf[123:120]) ? MACRO : EMPTY;
					bfsmap_D[127:124] = (rdata_m_inf[127:124]) ? MACRO : EMPTY;
				end
				else if (rvalid_m_inf == 1)
				begin
					lmap_WEN = 0;
					lmap_A = ctr_addr;
					lmap_D = rdata_m_inf;
					bfsmap_WEN = 0;
					bfsmap_A = ctr_addr;
					ctr_addr_ns = ctr_addr + 1;
					bfsmap_D[3:0] = (rdata_m_inf[3:0]) ? MACRO : EMPTY;
					bfsmap_D[7:4] = (rdata_m_inf[7:4]) ? MACRO : EMPTY;
					bfsmap_D[11:8] = (rdata_m_inf[11:8]) ? MACRO : EMPTY;
					bfsmap_D[15:12] = (rdata_m_inf[15:12]) ? MACRO : EMPTY;
					bfsmap_D[19:16] = (rdata_m_inf[19:16]) ? MACRO : EMPTY;
					bfsmap_D[23:20] = (rdata_m_inf[23:20]) ? MACRO : EMPTY;
					bfsmap_D[27:24] = (rdata_m_inf[27:24]) ? MACRO : EMPTY;
					bfsmap_D[31:28] = (rdata_m_inf[31:28]) ? MACRO : EMPTY;
					bfsmap_D[35:32] = (rdata_m_inf[35:32]) ? MACRO : EMPTY;
					bfsmap_D[39:36] = (rdata_m_inf[39:36]) ? MACRO : EMPTY;
					bfsmap_D[43:40] = (rdata_m_inf[43:40]) ? MACRO : EMPTY;
					bfsmap_D[47:44] = (rdata_m_inf[47:44]) ? MACRO : EMPTY;
					bfsmap_D[51:48] = (rdata_m_inf[51:48]) ? MACRO : EMPTY;
					bfsmap_D[55:52] = (rdata_m_inf[55:52]) ? MACRO : EMPTY;
					bfsmap_D[59:56] = (rdata_m_inf[59:56]) ? MACRO : EMPTY;
					bfsmap_D[63:60] = (rdata_m_inf[63:60]) ? MACRO : EMPTY;
					bfsmap_D[67:64] = (rdata_m_inf[67:64]) ? MACRO : EMPTY;
					bfsmap_D[71:68] = (rdata_m_inf[71:68]) ? MACRO : EMPTY;
					bfsmap_D[75:72] = (rdata_m_inf[75:72]) ? MACRO : EMPTY;
					bfsmap_D[79:76] = (rdata_m_inf[79:76]) ? MACRO : EMPTY;
					bfsmap_D[83:80] = (rdata_m_inf[83:80]) ? MACRO : EMPTY;
					bfsmap_D[87:84] = (rdata_m_inf[87:84]) ? MACRO : EMPTY;
					bfsmap_D[91:88] = (rdata_m_inf[91:88]) ? MACRO : EMPTY;
					bfsmap_D[95:92] = (rdata_m_inf[95:92]) ? MACRO : EMPTY;
					bfsmap_D[99:96] = (rdata_m_inf[99:96]) ? MACRO : EMPTY;
					bfsmap_D[103:100] = (rdata_m_inf[103:100]) ? MACRO : EMPTY;
					bfsmap_D[107:104] = (rdata_m_inf[107:104]) ? MACRO : EMPTY;
					bfsmap_D[111:108] = (rdata_m_inf[111:108]) ? MACRO : EMPTY;
					bfsmap_D[115:112] = (rdata_m_inf[115:112]) ? MACRO : EMPTY;
					bfsmap_D[119:116] = (rdata_m_inf[119:116]) ? MACRO : EMPTY;
					bfsmap_D[123:120] = (rdata_m_inf[123:120]) ? MACRO : EMPTY;
					bfsmap_D[127:124] = (rdata_m_inf[127:124]) ? MACRO : EMPTY;
				end
			end
			else
			begin
				if (rvalid_m_inf == 1 && rlast_m_inf == 1)
				begin
					curr_state_ns = BFS;
					data_type_ns = 0;
					counter_bfs_state_ns = 0;
					
					wmap_WEN = 0;
					wmap_A = ctr_addr;
					wmap_D = rdata_m_inf;
					ctr_addr_ns = 0;
				end
				else if (rvalid_m_inf == 1)
				begin
					wmap_WEN = 0;
					wmap_A = ctr_addr;
					wmap_D = rdata_m_inf;
					ctr_addr_ns = ctr_addr + 1;
				end
			end
		end
		BFS:
		begin
			case (counter_bfs_state)
				4'd0: //read original, initial
				begin
					queue_ns[0][0] = loc_x_reg[ctr_net][0];
					queue_ns[0][1] = loc_y_reg[ctr_net][0];
					counter_queue_ns = 0;
					max_queue_ns[0] = 0;
					max_queue_ns[1] = 0;
					cur_iteration_ns = 1;
					select_queue_ns = 0;
					// bfsmap_A = loc_x_reg[ctr_net][0] / 32 + loc_y_reg[ctr_net][0] * 2;
					counter_bfs_state_ns = 1;
				end
				4'd1: //read down
				begin
					if (cur_x == loc_x_reg[ctr_net][1] && cur_y+1 == loc_y_reg[ctr_net][1])
					begin
						counter_bfs_state_ns = 0;
						counter_queue_ns = 0;
						queue_ns[0][0] = loc_x_reg[ctr_net][1];
						queue_ns[0][1] = loc_y_reg[ctr_net][1];
						curr_state_ns = TRACE_BACK;
					end
					else if (cur_y != 63)
					begin
						bfsmap_A = cur_x / 32 + cur_y * 2 + 2;
						counter_bfs_state_ns = 2;
					end
					else if (cur_x == loc_x_reg[ctr_net][1] && cur_y-1 == loc_y_reg[ctr_net][1])
					begin
						counter_bfs_state_ns = 0;
						counter_queue_ns = 0;
						queue_ns[0][0] = loc_x_reg[ctr_net][1];
						queue_ns[0][1] = loc_y_reg[ctr_net][1];
						curr_state_ns = TRACE_BACK;
					end
					else
					begin
						bfsmap_A = cur_x / 32 + cur_y * 2 - 2;
						counter_bfs_state_ns = 4;
					end
				end
				4'd2: //write down
				begin
					if (bfsmap_segment == 0)
					begin
						bfsmap_WEN = 0;
						bfsmap_A = cur_x / 32 + cur_y * 2 + 2;
						bfsmap_D = bfsmap_Q_x;
						max_queue_ns[!select_queue] = max_queue[!select_queue] + 1;
						queue_ns[max_queue_ns[!select_queue]][0] = cur_x;
						queue_ns[max_queue_ns[!select_queue]][1] = cur_y + 1;
						counter_bfs_state_ns = 3;
					end
					else
					begin
						if (cur_x == loc_x_reg[ctr_net][1] && cur_y-1 == loc_y_reg[ctr_net][1])
						begin
							counter_bfs_state_ns = 0;
							counter_queue_ns = 0;
							queue_ns[0][0] = loc_x_reg[ctr_net][1];
							queue_ns[0][1] = loc_y_reg[ctr_net][1];
							curr_state_ns = TRACE_BACK;
						end
						else if (cur_y != 0)
						begin
							bfsmap_A = cur_x / 32 + cur_y * 2 - 2;
							counter_bfs_state_ns = 4;
						end
						else
						begin
							counter_bfs_state_ns = 5;
						end
					end
				end
				4'd3: //read up
				begin
					if (cur_x == loc_x_reg[ctr_net][1] && cur_y-1 == loc_y_reg[ctr_net][1])
					begin
						counter_bfs_state_ns = 0;
						counter_queue_ns = 0;
						queue_ns[0][0] = loc_x_reg[ctr_net][1];
						queue_ns[0][1] = loc_y_reg[ctr_net][1];
						curr_state_ns = TRACE_BACK;
					end
					else if (cur_y != 0)
					begin
						bfsmap_A = cur_x / 32 + cur_y * 2 - 2;
						counter_bfs_state_ns = 4;
					end
					else
					begin
						counter_bfs_state_ns = 5;
					end
				end
				4'd4: //write up
				begin
					if (bfsmap_segment == 0)
					begin
						bfsmap_WEN = 0;
						bfsmap_A = cur_x / 32 + cur_y * 2 - 2;
						bfsmap_D = bfsmap_Q_x;
						max_queue_ns[!select_queue] = max_queue[!select_queue] + 1;
						queue_ns[max_queue_ns[!select_queue]][0] = cur_x;
						queue_ns[max_queue_ns[!select_queue]][1] = cur_y - 1;
						counter_bfs_state_ns = 5;
					end
					else
					begin
						if (cur_x+1 == loc_x_reg[ctr_net][1] && cur_y == loc_y_reg[ctr_net][1])
						begin
							counter_bfs_state_ns = 0;
							counter_queue_ns = 0;
							queue_ns[0][0] = loc_x_reg[ctr_net][1];
							queue_ns[0][1] = loc_y_reg[ctr_net][1];
							curr_state_ns = TRACE_BACK;
						end
						else if (cur_x != 63)
						begin
							bfsmap_A = (cur_x+1) / 32 + cur_y * 2;
							counter_bfs_state_ns = 6;
						end
						else if (cur_x-1 == loc_x_reg[ctr_net][1] && cur_y == loc_y_reg[ctr_net][1])
						begin
							counter_bfs_state_ns = 0;
							counter_queue_ns = 0;
							queue_ns[0][0] = loc_x_reg[ctr_net][1];
							queue_ns[0][1] = loc_y_reg[ctr_net][1];
							curr_state_ns = TRACE_BACK;
						end
						else
						begin
							bfsmap_A = (cur_x-1) / 32 + cur_y * 2;
							counter_bfs_state_ns = 8;
						end
					end
				end
				4'd5: //read right
				begin
					if (cur_x+1 == loc_x_reg[ctr_net][1] && cur_y == loc_y_reg[ctr_net][1])
					begin
						counter_bfs_state_ns = 0;
						counter_queue_ns = 0;
						queue_ns[0][0] = loc_x_reg[ctr_net][1];
						queue_ns[0][1] = loc_y_reg[ctr_net][1];
						curr_state_ns = TRACE_BACK;
					end
					else if (cur_x != 63)
					begin
						bfsmap_A = (cur_x+1) / 32 + cur_y * 2;
						counter_bfs_state_ns = 6;
					end
					else if (cur_x-1 == loc_x_reg[ctr_net][1] && cur_y == loc_y_reg[ctr_net][1])
					begin
						counter_bfs_state_ns = 0;
						counter_queue_ns = 0;
						queue_ns[0][0] = loc_x_reg[ctr_net][1];
						queue_ns[0][1] = loc_y_reg[ctr_net][1];
						curr_state_ns = TRACE_BACK;
					end
					else
					begin
						bfsmap_A = (cur_x-1) / 32 + cur_y * 2;
						counter_bfs_state_ns = 8;
					end
				end
				4'd6: //write right
				begin
					if (bfsmap_p_segment == 0)
					begin
						bfsmap_WEN = 0;
						bfsmap_A = (cur_x+1) / 32 + cur_y * 2;
						bfsmap_D = bfsmap_Q_x_p;
						max_queue_ns[!select_queue] = max_queue[!select_queue] + 1;
						queue_ns[max_queue_ns[!select_queue]][0] = cur_x + 1;
						queue_ns[max_queue_ns[!select_queue]][1] = cur_y;
						if (cur_x-1 == loc_x_reg[ctr_net][1] && cur_y == loc_y_reg[ctr_net][1])
						begin
							counter_bfs_state_ns = 0;
							counter_queue_ns = 0;
							queue_ns[0][0] = loc_x_reg[ctr_net][1];
							queue_ns[0][1] = loc_y_reg[ctr_net][1];
							curr_state_ns = TRACE_BACK;
						end
						else if (cur_x == 0)
							counter_bfs_state_ns = 9;
						else if (cur_x != 32 && cur_x != 31)
							counter_bfs_state_ns = 8;
						else
							counter_bfs_state_ns = 7;
					end
					else
					begin
						if (cur_x-1 == loc_x_reg[ctr_net][1] && cur_y == loc_y_reg[ctr_net][1])
						begin
							counter_bfs_state_ns = 0;
							counter_queue_ns = 0;
							queue_ns[0][0] = loc_x_reg[ctr_net][1];
							queue_ns[0][1] = loc_y_reg[ctr_net][1];
							curr_state_ns = TRACE_BACK;
						end
						else if (cur_x != 0)
						begin
							bfsmap_A = (cur_x-1) / 32 + cur_y * 2;
							counter_bfs_state_ns = 8;
						end
						else
						begin
							counter_bfs_state_ns = 9;
						end
					end
				end
				4'd7: //read left
				begin
					if (cur_x-1 == loc_x_reg[ctr_net][1] && cur_y == loc_y_reg[ctr_net][1])
					begin
						counter_bfs_state_ns = 0;
						counter_queue_ns = 0;
						queue_ns[0][0] = loc_x_reg[ctr_net][1];
						queue_ns[0][1] = loc_y_reg[ctr_net][1];
						curr_state_ns = TRACE_BACK;
					end
					else if (cur_x != 0)
					begin
						bfsmap_A = (cur_x-1) / 32 + cur_y * 2;
						counter_bfs_state_ns = 8;
					end
					else
					begin
						counter_bfs_state_ns = 9;
					end
				end
				4'd8: //write left
				begin
					if (bfsmap_m_segment == 0)
					begin
						bfsmap_WEN = 0;
						bfsmap_A = (cur_x-1) / 32 + cur_y * 2;
						bfsmap_D = bfsmap_Q_x_m;
						max_queue_ns[!select_queue] = max_queue[!select_queue] + 1;
						queue_ns[max_queue_ns[!select_queue]][0] = cur_x - 1;
						queue_ns[max_queue_ns[!select_queue]][1] = cur_y;
						counter_bfs_state_ns = 9;
					end
					else
					begin
						counter_bfs_state_ns = 9;
					end
				end
				4'd9: //next grid
				begin
					counter_queue_ns = counter_queue + 1;
					if (counter_queue == max_queue[select_queue])
					begin
						select_queue_ns = !select_queue;
						max_queue_ns[select_queue] = max_queue[!select_queue];
						if (cur_iteration != 3)
							cur_iteration_ns = cur_iteration + 1;
						else
							cur_iteration_ns = 1;
					end
					counter_bfs_state_ns = 1;
				end
			endcase
		end
		TRACE_BACK:
		begin
			case (counter_bfs_state)
				4'd0: //read down
				begin
					if (cur_iteration != 1)
						cur_iteration_ns = cur_iteration - 1;
					else
						cur_iteration_ns = 3;
					if (cur_x == loc_x_reg[ctr_net][0] && cur_y+1 == loc_y_reg[ctr_net][0])
					begin
						if (ctr_net != net_num - 1)
						begin
							ctr_net_ns = ctr_net + 1;
							counter_bfs_state_ns = 0;
							curr_state_ns = CLEAR_BFS_MAP;
						end
						else
						begin
							ctr_net_ns = 0;
							counter_bfs_state_ns = 0;
							curr_state_ns = WRITE_DRAM;
						end
					end
					else if (cur_y != 63)
					begin
						bfsmap_A = cur_x / 32 + cur_y * 2 + 2;
						lmap_A = cur_x / 32 + cur_y * 2 + 2;
						wmap_A = cur_x / 32 + cur_y * 2 + 2;
						counter_bfs_state_ns = 1;
					end
					else if (cur_x == loc_x_reg[ctr_net][0] && cur_y-1 == loc_y_reg[ctr_net][0])
					begin
						if (ctr_net != net_num - 1)
						begin
							ctr_net_ns = ctr_net + 1;
							counter_bfs_state_ns = 0;
							curr_state_ns = CLEAR_BFS_MAP;
						end
						else
						begin
							ctr_net_ns = 0;
							counter_bfs_state_ns = 0;
							curr_state_ns = WRITE_DRAM;
						end
					end
					else
					begin
						bfsmap_A = cur_x / 32 + cur_y * 2 - 2;
						lmap_A = cur_x / 32 + cur_y * 2 - 2;
						wmap_A = cur_x / 32 + cur_y * 2 - 2;
						counter_bfs_state_ns = 2;
					end
				end
				4'd1: //write down
				begin
					if (bfsmap_segment == cur_iteration)
					begin
						lmap_WEN = 0;
						lmap_A = cur_x / 32 + cur_y * 2 + 2;
						lmap_D = lmap_Q_x;
						queue_ns[0][0] = cur_x;
						queue_ns[0][1] = cur_y + 1;
						counter_bfs_state_ns = 0;
						acc_cost_ns = acc_cost + wmap_segment;
					end
					else
					begin
						if (cur_x == loc_x_reg[ctr_net][0] && cur_y-1 == loc_y_reg[ctr_net][0])
						begin
							if (ctr_net != net_num - 1)
							begin
								ctr_net_ns = ctr_net + 1;
								counter_bfs_state_ns = 0;
								curr_state_ns = CLEAR_BFS_MAP;
							end
							else
							begin
								ctr_net_ns = 0;
								counter_bfs_state_ns = 0;
								curr_state_ns = WRITE_DRAM;
							end
						end
						else if (cur_y != 0)
						begin
							bfsmap_A = cur_x / 32 + cur_y * 2 - 2;
							lmap_A = cur_x / 32 + cur_y * 2 - 2;
							wmap_A = cur_x / 32 + cur_y * 2 - 2;
							counter_bfs_state_ns = 2;
						end
						else if (cur_x+1 == loc_x_reg[ctr_net][0] && cur_y == loc_y_reg[ctr_net][0])
						begin
							if (ctr_net != net_num - 1)
							begin
								ctr_net_ns = ctr_net + 1;
								counter_bfs_state_ns = 0;
								curr_state_ns = CLEAR_BFS_MAP;
							end
							else
							begin
								ctr_net_ns = 0;
								counter_bfs_state_ns = 0;
								curr_state_ns = WRITE_DRAM;
							end
						end
						else if (cur_x != 63)
						begin
							bfsmap_A = (cur_x+1) / 32 + cur_y * 2;
							lmap_A = (cur_x+1) / 32 + cur_y * 2;
							wmap_A = (cur_x+1) / 32 + cur_y * 2;
							counter_bfs_state_ns = 3;
						end
						else if (cur_x-1 == loc_x_reg[ctr_net][0] && cur_y == loc_y_reg[ctr_net][0])
						begin
							if (ctr_net != net_num - 1)
							begin
								ctr_net_ns = ctr_net + 1;
								counter_bfs_state_ns = 0;
								curr_state_ns = CLEAR_BFS_MAP;
							end
							else
							begin
								ctr_net_ns = 0;
								counter_bfs_state_ns = 0;
								curr_state_ns = WRITE_DRAM;
							end
						end
						else
						begin
							bfsmap_A = (cur_x-1) / 32 + cur_y * 2;
							lmap_A = (cur_x-1) / 32 + cur_y * 2;
							wmap_A = (cur_x-1) / 32 + cur_y * 2;
							counter_bfs_state_ns = 4;
						end
					end
				end
				4'd2: //write up
				begin
					if (bfsmap_segment == cur_iteration)
					begin
						lmap_WEN = 0;
						lmap_A = cur_x / 32 + cur_y * 2 - 2;
						lmap_D = lmap_Q_x;
						queue_ns[0][0] = cur_x;
						queue_ns[0][1] = cur_y - 1;
						counter_bfs_state_ns = 0;
						acc_cost_ns = acc_cost + wmap_segment;
					end
					else
					begin
						if (cur_x+1 == loc_x_reg[ctr_net][0] && cur_y == loc_y_reg[ctr_net][0])
						begin
							if (ctr_net != net_num - 1)
							begin
								ctr_net_ns = ctr_net + 1;
								counter_bfs_state_ns = 0;
								curr_state_ns = CLEAR_BFS_MAP;
							end
							else
							begin
								ctr_net_ns = 0;
								counter_bfs_state_ns = 0;
								curr_state_ns = WRITE_DRAM;
							end
						end
						else if (cur_x != 63)
						begin
							bfsmap_A = (cur_x+1) / 32 + cur_y * 2;
							lmap_A = (cur_x+1) / 32 + cur_y * 2;
							wmap_A = (cur_x+1) / 32 + cur_y * 2;
							counter_bfs_state_ns = 3;
						end
						else if (cur_x-1 == loc_x_reg[ctr_net][0] && cur_y == loc_y_reg[ctr_net][0])
						begin
							if (ctr_net != net_num - 1)
							begin
								ctr_net_ns = ctr_net + 1;
								counter_bfs_state_ns = 0;
								curr_state_ns = CLEAR_BFS_MAP;
							end
							else
							begin
								ctr_net_ns = 0;
								counter_bfs_state_ns = 0;
								curr_state_ns = WRITE_DRAM;
							end
						end
						else
						begin
							bfsmap_A = (cur_x-1) / 32 + cur_y * 2;
							lmap_A = (cur_x-1) / 32 + cur_y * 2;
							wmap_A = (cur_x-1) / 32 + cur_y * 2;
							counter_bfs_state_ns = 4;
						end
					end
				end
				4'd3: //write right
				begin
					if (bfsmap_p_segment == cur_iteration)
					begin
						lmap_WEN = 0;
						lmap_A = (cur_x+1) / 32 + cur_y * 2;
						lmap_D = lmap_Q_x_p;
						queue_ns[0][0] = (cur_x+1);
						queue_ns[0][1] = cur_y;
						counter_bfs_state_ns = 0;
						acc_cost_ns = acc_cost + wmap_p_segment;
					end
					else
					begin
						if (cur_x-1 == loc_x_reg[ctr_net][0] && cur_y == loc_y_reg[ctr_net][0])
						begin
							if (ctr_net != net_num - 1)
							begin
								ctr_net_ns = ctr_net + 1;
								counter_bfs_state_ns = 0;
								curr_state_ns = CLEAR_BFS_MAP;
							end
							else
							begin
								ctr_net_ns = 0;
								counter_bfs_state_ns = 0;
								curr_state_ns = WRITE_DRAM;
							end
						end
						else
						begin
							bfsmap_A = (cur_x-1) / 32 + cur_y * 2;
							lmap_A = (cur_x-1) / 32 + cur_y * 2;
							wmap_A = (cur_x-1) / 32 + cur_y * 2;
							counter_bfs_state_ns = 4;
						end
					end
				end
				4'd4: //write left
				begin
					lmap_WEN = 0;
					lmap_A = (cur_x-1) / 32 + cur_y * 2;
					lmap_D = lmap_Q_x_m;
					queue_ns[0][0] = (cur_x-1);
					queue_ns[0][1] = cur_y;
					counter_bfs_state_ns = 0;
					acc_cost_ns = acc_cost + wmap_m_segment;
				end
			endcase
		end
		CLEAR_BFS_MAP:
		begin
			if (counter_bfs_state == 0 && ctr_addr != 0)
			begin
				lmap_A = ctr_addr;
				bfsmap_WEN = 0;
				bfsmap_A = ctr_addr - 1;
				bfsmap_D[3:0] = (lmap_Q[3:0]) ? MACRO : EMPTY;
				bfsmap_D[7:4] = (lmap_Q[7:4]) ? MACRO : EMPTY;
				bfsmap_D[11:8] = (lmap_Q[11:8]) ? MACRO : EMPTY;
				bfsmap_D[15:12] = (lmap_Q[15:12]) ? MACRO : EMPTY;
				bfsmap_D[19:16] = (lmap_Q[19:16]) ? MACRO : EMPTY;
				bfsmap_D[23:20] = (lmap_Q[23:20]) ? MACRO : EMPTY;
				bfsmap_D[27:24] = (lmap_Q[27:24]) ? MACRO : EMPTY;
				bfsmap_D[31:28] = (lmap_Q[31:28]) ? MACRO : EMPTY;
				bfsmap_D[35:32] = (lmap_Q[35:32]) ? MACRO : EMPTY;
				bfsmap_D[39:36] = (lmap_Q[39:36]) ? MACRO : EMPTY;
				bfsmap_D[43:40] = (lmap_Q[43:40]) ? MACRO : EMPTY;
				bfsmap_D[47:44] = (lmap_Q[47:44]) ? MACRO : EMPTY;
				bfsmap_D[51:48] = (lmap_Q[51:48]) ? MACRO : EMPTY;
				bfsmap_D[55:52] = (lmap_Q[55:52]) ? MACRO : EMPTY;
				bfsmap_D[59:56] = (lmap_Q[59:56]) ? MACRO : EMPTY;
				bfsmap_D[63:60] = (lmap_Q[63:60]) ? MACRO : EMPTY;
				bfsmap_D[67:64] = (lmap_Q[67:64]) ? MACRO : EMPTY;
				bfsmap_D[71:68] = (lmap_Q[71:68]) ? MACRO : EMPTY;
				bfsmap_D[75:72] = (lmap_Q[75:72]) ? MACRO : EMPTY;
				bfsmap_D[79:76] = (lmap_Q[79:76]) ? MACRO : EMPTY;
				bfsmap_D[83:80] = (lmap_Q[83:80]) ? MACRO : EMPTY;
				bfsmap_D[87:84] = (lmap_Q[87:84]) ? MACRO : EMPTY;
				bfsmap_D[91:88] = (lmap_Q[91:88]) ? MACRO : EMPTY;
				bfsmap_D[95:92] = (lmap_Q[95:92]) ? MACRO : EMPTY;
				bfsmap_D[99:96] = (lmap_Q[99:96]) ? MACRO : EMPTY;
				bfsmap_D[103:100] = (lmap_Q[103:100]) ? MACRO : EMPTY;
				bfsmap_D[107:104] = (lmap_Q[107:104]) ? MACRO : EMPTY;
				bfsmap_D[111:108] = (lmap_Q[111:108]) ? MACRO : EMPTY;
				bfsmap_D[115:112] = (lmap_Q[115:112]) ? MACRO : EMPTY;
				bfsmap_D[119:116] = (lmap_Q[119:116]) ? MACRO : EMPTY;
				bfsmap_D[123:120] = (lmap_Q[123:120]) ? MACRO : EMPTY;
				bfsmap_D[127:124] = (lmap_Q[127:124]) ? MACRO : EMPTY;
				if (ctr_addr != 127)
					ctr_addr_ns = ctr_addr + 1;
				else
				begin
					ctr_addr_ns = 0;
					counter_bfs_state_ns = 1;
				end
			end
			else if (counter_bfs_state == 0)
			begin
				lmap_A = 0;
				ctr_addr_ns = ctr_addr + 1;
			end
			else
			begin
				bfsmap_WEN = 0;
				bfsmap_A = ctr_addr - 1;
				bfsmap_D[3:0] = (lmap_Q[3:0]) ? MACRO : EMPTY;
				bfsmap_D[7:4] = (lmap_Q[7:4]) ? MACRO : EMPTY;
				bfsmap_D[11:8] = (lmap_Q[11:8]) ? MACRO : EMPTY;
				bfsmap_D[15:12] = (lmap_Q[15:12]) ? MACRO : EMPTY;
				bfsmap_D[19:16] = (lmap_Q[19:16]) ? MACRO : EMPTY;
				bfsmap_D[23:20] = (lmap_Q[23:20]) ? MACRO : EMPTY;
				bfsmap_D[27:24] = (lmap_Q[27:24]) ? MACRO : EMPTY;
				bfsmap_D[31:28] = (lmap_Q[31:28]) ? MACRO : EMPTY;
				bfsmap_D[35:32] = (lmap_Q[35:32]) ? MACRO : EMPTY;
				bfsmap_D[39:36] = (lmap_Q[39:36]) ? MACRO : EMPTY;
				bfsmap_D[43:40] = (lmap_Q[43:40]) ? MACRO : EMPTY;
				bfsmap_D[47:44] = (lmap_Q[47:44]) ? MACRO : EMPTY;
				bfsmap_D[51:48] = (lmap_Q[51:48]) ? MACRO : EMPTY;
				bfsmap_D[55:52] = (lmap_Q[55:52]) ? MACRO : EMPTY;
				bfsmap_D[59:56] = (lmap_Q[59:56]) ? MACRO : EMPTY;
				bfsmap_D[63:60] = (lmap_Q[63:60]) ? MACRO : EMPTY;
				bfsmap_D[67:64] = (lmap_Q[67:64]) ? MACRO : EMPTY;
				bfsmap_D[71:68] = (lmap_Q[71:68]) ? MACRO : EMPTY;
				bfsmap_D[75:72] = (lmap_Q[75:72]) ? MACRO : EMPTY;
				bfsmap_D[79:76] = (lmap_Q[79:76]) ? MACRO : EMPTY;
				bfsmap_D[83:80] = (lmap_Q[83:80]) ? MACRO : EMPTY;
				bfsmap_D[87:84] = (lmap_Q[87:84]) ? MACRO : EMPTY;
				bfsmap_D[91:88] = (lmap_Q[91:88]) ? MACRO : EMPTY;
				bfsmap_D[95:92] = (lmap_Q[95:92]) ? MACRO : EMPTY;
				bfsmap_D[99:96] = (lmap_Q[99:96]) ? MACRO : EMPTY;
				bfsmap_D[103:100] = (lmap_Q[103:100]) ? MACRO : EMPTY;
				bfsmap_D[107:104] = (lmap_Q[107:104]) ? MACRO : EMPTY;
				bfsmap_D[111:108] = (lmap_Q[111:108]) ? MACRO : EMPTY;
				bfsmap_D[115:112] = (lmap_Q[115:112]) ? MACRO : EMPTY;
				bfsmap_D[119:116] = (lmap_Q[119:116]) ? MACRO : EMPTY;
				bfsmap_D[123:120] = (lmap_Q[123:120]) ? MACRO : EMPTY;
				bfsmap_D[127:124] = (lmap_Q[127:124]) ? MACRO : EMPTY;
				counter_bfs_state_ns = 0;
				curr_state_ns = BFS;
			end
		end
		WRITE_DRAM:
		begin
			if (ctr_addr != 127)
			begin
				dram_read_in = lmap_Q;
				if (wready_m_inf == 1)
				begin
					ctr_addr_ns = ctr_addr + 1;
					lmap_A = ctr_addr + 1;
				end
			end
			else
			begin
				dram_read_in = lmap_Q;
				if (bvalid_m_inf == 1)
				begin
					ctr_addr_ns = 0;
					curr_state_ns = OUTPUT;
				end
			end
		end
		OUTPUT:
		begin
			busy = 0;
			cost = acc_cost;
			ctr_addr_ns = 0;
			curr_state_ns = INPUT;
			data_type_ns = 0;
			frame_id_reg_ns = 0;
			net_num_ns = 0;
			ctr_net_ns = 0;

			counter_queue_ns = 0;
			select_queue_ns = 0;
			counter_bfs_state_ns = 0;
			cur_iteration_ns = 0;
			acc_cost_ns = 0;
			for (i = 0; i < 15; i = i + 1)
			begin
				net_id_reg_ns[i] = 0;
			end
			for (i = 0; i < 15; i = i + 1)
			begin
				for (j = 0; j < 2; j = j + 1)
				begin
					loc_x_reg_ns[i][j] = 0;
					loc_y_reg_ns[i][j] = 0;
				end
			end
			for (i = 0; i < 2; i = i + 1)
			begin
				max_queue_ns[i] = 0;
			end
			for (i = 0; i < 128; i = i + 1)
			begin
				for (j = 0; j < 2; j = j + 1)
				begin
					queue_ns[i][j] = 0;
				end
			end
		end
	endcase
end

always @ (posedge clk or negedge rst_n)
begin
	if (!rst_n)
	begin
		curr_state <= INPUT;
		data_type <= 0;
		frame_id_reg <= 0;
		net_num <= 0;
		ctr_net <= 0;
		ctr_addr <= 0;

		counter_queue <= 0;
		select_queue <= 0;
		counter_bfs_state <= 0;
		cur_iteration <= 0;
		acc_cost <= 0;
		for (i = 0; i < 15; i = i + 1)
		begin
			net_id_reg[i] <= 0;
		end
		for (i = 0; i < 15; i = i + 1)
		begin
			for (j = 0; j < 2; j = j + 1)
			begin
				loc_x_reg[i][j] <= 0;
				loc_y_reg[i][j] <= 0;
			end
		end
		for (i = 0; i < 2; i = i + 1)
		begin
			max_queue[i] <= 0;
		end
		for (i = 0; i < 128; i = i + 1)
		begin
			for (j = 0; j < 2; j = j + 1)
			begin
				queue[i][j] <= 0;
			end
		end
	end
	else
	begin
		curr_state <= curr_state_ns;
		data_type <= data_type_ns;
		frame_id_reg <= frame_id_reg_ns;
		net_num <= net_num_ns;
		ctr_net <= ctr_net_ns;
		ctr_addr <= ctr_addr_ns;

		counter_queue <= counter_queue_ns;
		select_queue <= select_queue_ns;
		counter_bfs_state <= counter_bfs_state_ns;
		cur_iteration <= cur_iteration_ns;
		acc_cost <= acc_cost_ns;
		for (i = 0; i < 15; i = i + 1)
		begin
			net_id_reg[i] <= net_id_reg_ns[i];
		end
		for (i = 0; i < 15; i = i + 1)
		begin
			for (j = 0; j < 2; j = j + 1)
			begin
				loc_x_reg[i][j] <= loc_x_reg_ns[i][j];
				loc_y_reg[i][j] <= loc_y_reg_ns[i][j];
			end
		end
		for (i = 0; i < 2; i = i + 1)
		begin
			max_queue[i] <= max_queue_ns[i];
		end
		for (i = 0; i < 128; i = i + 1)
		begin
			for (j = 0; j < 2; j = j + 1)
			begin
				queue[i][j] <= queue_ns[i][j];
			end
		end
	end
end

// ===============================================================
//  					AXI4 Interfaces
// ===============================================================
// You can desing your own module here
AXI4_READ INF_AXI4_READ(
	.clk(clk),.rst_n(rst_n),.curr_state(curr_state),.index(index),.data_type(data_type) ,.frame_id_reg(frame_id_reg) ,.dram_read_out(dram_read_out),
	.arid_m_inf(arid_m_inf),
	.arburst_m_inf(arburst_m_inf), .arsize_m_inf(arsize_m_inf), .arlen_m_inf(arlen_m_inf), 
	.arvalid_m_inf(arvalid_m_inf), .arready_m_inf(arready_m_inf), .araddr_m_inf(araddr_m_inf),
	.rid_m_inf(rid_m_inf),
	.rvalid_m_inf(rvalid_m_inf), .rready_m_inf(rready_m_inf), .rdata_m_inf(rdata_m_inf),
	.rlast_m_inf(rlast_m_inf), .rresp_m_inf(rresp_m_inf)
);
// You can desing your own module here
AXI4_WRITE INF_AXI4_WRITE(
	.clk(clk),.rst_n(rst_n),.curr_state(curr_state),.index(index),.frame_id_reg(frame_id_reg) , .dram_read_in(dram_read_in), 
	.awid_m_inf(awid_m_inf),
	.awburst_m_inf(awburst_m_inf), .awsize_m_inf(awsize_m_inf), .awlen_m_inf(awlen_m_inf),
	.awvalid_m_inf(awvalid_m_inf), .awready_m_inf(awready_m_inf), .awaddr_m_inf(awaddr_m_inf),
   	.wvalid_m_inf(wvalid_m_inf), .wready_m_inf(wready_m_inf),
	.wdata_m_inf(wdata_m_inf), .wlast_m_inf(wlast_m_inf),
    .bid_m_inf(bid_m_inf),
   	.bvalid_m_inf(bvalid_m_inf), .bready_m_inf(bready_m_inf), .bresp_m_inf(bresp_m_inf)
);


endmodule


// ############################################################################
//  					AXI4 Interfaces Module
// ############################################################################
// Read Data from DRAM 
module AXI4_READ(
	clk,rst_n,curr_state, index, data_type, frame_id_reg, dram_read_out, 
	arid_m_inf,
	arburst_m_inf, arsize_m_inf, arlen_m_inf, 
	arvalid_m_inf, arready_m_inf, araddr_m_inf,
	rid_m_inf,
	rvalid_m_inf, rready_m_inf, rdata_m_inf,
	rlast_m_inf, rresp_m_inf
);
parameter ID_WIDTH=4, DATA_WIDTH=128, ADDR_WIDTH=32;    // DO NOT modify


// (0)	CHIP IO
input clk,rst_n,data_type;
input [3:0] curr_state;
input [12:0] index;
input [4:0] frame_id_reg;
output reg [DATA_WIDTH-1:0] dram_read_out;

// (1)	axi read address channel 
output wire [ID_WIDTH-1:0]      arid_m_inf;
output wire [1:0]            arburst_m_inf;
output wire [2:0]             arsize_m_inf;
output wire [7:0]              arlen_m_inf;
output reg                   arvalid_m_inf;
input  wire                  arready_m_inf;
output reg [ADDR_WIDTH-1:0]  araddr_m_inf;
// (2)	axi read data channel 
input  wire [ID_WIDTH-1:0]       rid_m_inf;
input  wire                   rvalid_m_inf;
output reg                    rready_m_inf;
input  wire [DATA_WIDTH-1:0]   rdata_m_inf;
input  wire                    rlast_m_inf;
input  wire [1:0]              rresp_m_inf;

parameter READ_DRAM = 4'd2;

parameter AR_VALID = 2'd0;
parameter R_VALID = 2'd1;

reg		[1:0]	state;
reg		[1:0]	state_ns;


// axi_master read_request
// << Burst & ID >>
assign arid_m_inf = 4'd0; 			// fixed id to 0 
assign arburst_m_inf = 2'd1;		// fixed mode to INCR mode 
assign arsize_m_inf = 3'b100;		// fixed size to 2^4 = 16 Bytes 

// axi_master read_catch
assign arlen_m_inf = 127;

always @ (*)
begin
	state_ns = state;
	araddr_m_inf = 0;
	arvalid_m_inf = 0;
	rready_m_inf = 0;
	dram_read_out = 0;
	
	case (state)
		AR_VALID:
		begin
			if (curr_state == READ_DRAM)
			begin
				if (data_type == 0)
				begin
					araddr_m_inf = 20'h10000 + frame_id_reg * (12'h800) + index;
					arvalid_m_inf = 1;
					if (arready_m_inf == 1)
					begin
						state_ns = R_VALID;
					end
				end
				else if (data_type == 1)
				begin
					araddr_m_inf = 20'h20000 + frame_id_reg * (12'h800) + index;
					arvalid_m_inf = 1;
					if (arready_m_inf == 1)
					begin
						state_ns = R_VALID;
					end
				end
			end
		end
		R_VALID:
		begin
			rready_m_inf = 1;
			if (rlast_m_inf == 1)
			begin
				state_ns = AR_VALID;
			end
			if (rvalid_m_inf == 1)
			begin
				dram_read_out = rdata_m_inf;
			end
		end
	endcase
end

always @ (posedge clk or negedge rst_n)
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


endmodule

// Write Data to DRAM 
module AXI4_WRITE(
	clk,rst_n,curr_state, index, frame_id_reg, dram_read_in, 
	awid_m_inf,
	awburst_m_inf,awsize_m_inf,awlen_m_inf,
	awvalid_m_inf, awready_m_inf, awaddr_m_inf,
   	wvalid_m_inf,wready_m_inf,
	wdata_m_inf, wlast_m_inf,
    bid_m_inf,
   	bvalid_m_inf, bready_m_inf, bresp_m_inf
  
);
parameter ID_WIDTH=4, DATA_WIDTH=128, ADDR_WIDTH=32;    // DO NOT modify

// (0)	CHIP IO
input clk,rst_n;
input [3:0] curr_state;
input [12:0] index;
input [4:0] frame_id_reg;
input [DATA_WIDTH-1:0] dram_read_in;
// (1) 	axi write address channel 
output wire [ID_WIDTH-1:0]      awid_m_inf;
output wire [1:0]            awburst_m_inf;
output wire [2:0]             awsize_m_inf;
output wire [7:0]              awlen_m_inf;
output reg                   awvalid_m_inf;
input  wire                  awready_m_inf;
output reg  [ADDR_WIDTH-1:0]  awaddr_m_inf;
// (2)	axi write data channel 
output reg                    wvalid_m_inf;
input  wire                   wready_m_inf;
output wire [DATA_WIDTH-1:0]   wdata_m_inf;
output reg                     wlast_m_inf;
// (3)	axi write response channel 
input  wire  [ID_WIDTH-1:0]      bid_m_inf;
input  wire                   bvalid_m_inf;
output reg                    bready_m_inf;
input  wire  [1:0]             bresp_m_inf;

parameter WRITE_DRAM = 4'd3;
parameter AW_VALID = 2'd0;
parameter W_VALID = 2'd1;
parameter W_NON_VALID = 2'd2;

reg		[1:0]	state;
reg		[1:0]	state_ns;
reg		[7:0]	counter;
reg		[7:0]	counter_ns;

// axi_master write request
// << Burst & ID >>
assign awid_m_inf = 4'd0;
assign awburst_m_inf = 2'd1;
assign awsize_m_inf = 3'b100;
assign wdata_m_inf = dram_read_in;


// axi_master write send
assign awlen_m_inf = 127;
// assign awlen_m_inf = 1;

always @ (*)
begin

	state_ns = state;
	counter_ns = counter;

	awaddr_m_inf = 0;
	awvalid_m_inf = 0;
	wvalid_m_inf = 0;
	bready_m_inf = 0;
	wlast_m_inf = 0;
	
	case (state)
		AW_VALID:
		begin
			if (curr_state == WRITE_DRAM)
			begin
				awaddr_m_inf = 20'h10000 + frame_id_reg * (12'h800) + index;
				awvalid_m_inf = 1;
				if (awready_m_inf == 1)
				begin
					state_ns = W_VALID;
				end
			end
		end
		W_VALID:
		begin
			wvalid_m_inf = 1;
			bready_m_inf = 1;
			
			if (counter == awlen_m_inf)
				wlast_m_inf = 1;
			
			if (bvalid_m_inf == 1)
			begin
				counter_ns = 0;
				state_ns = AW_VALID;
			end
			else if (wready_m_inf == 1)
			begin
				counter_ns = counter + 1;
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
	end
	else
	begin
		state <= state_ns;
		counter <= counter_ns;
	end
end

endmodule

module CHANGE_SEGMENT
(
	TARGET,
	ELEMENT,
	POSITION,
	RESULT
);
input [127:0] TARGET;
input [3:0] ELEMENT;
input [5:0]	POSITION;
output [127:0] RESULT;

wire [127:0] target_shift_right;
wire [127:0] changed_target;
wire [127:0] changed_target_shift_left;
wire [127:0] target_shift_left;
wire [127:0] target_LSB_segment;

assign target_shift_right = TARGET >> ((POSITION%32) * 4);
assign changed_target = {target_shift_right[127:4], ELEMENT};
assign changed_target_shift_left = changed_target << ((POSITION%32) * 4);
assign target_shift_left = TARGET << (128 - (POSITION%32) * 4);
assign target_LSB_segment = target_shift_left >> (128 - (POSITION%32) * 4);
assign RESULT = changed_target_shift_left | target_LSB_segment;

endmodule

module EXTRACT
(
	TARGET,
	POSITION,
	RESULT
);
input [127:0] TARGET;
input [5:0] POSITION;
output [3:0] RESULT;

wire [127:0] target_shift_right;

assign target_shift_right = TARGET >> ((POSITION%32)*4);
assign RESULT = target_shift_right[3:0];
endmodule
