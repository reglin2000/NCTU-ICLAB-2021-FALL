`include "../00_TESTBED/pseudo_DRAM.sv"
`include "Usertype_PKG.sv"

program automatic PATTERN(input clk, INF.PATTERN inf);
import usertype::*;

//================================================================
// parameters & integer
//================================================================
parameter DRAM_p_r = "../00_TESTBED/DRAM/dram.dat";
parameter PATTERN_NUM = 256;
parameter DRAM_INIT = 1;
integer	  dram_init;
integer   i,k, a;
integer	  wdram_dat;
integer	  pat_num;
integer	  user_step;
integer	  USER_STEP;
integer	  gap;
integer	  golden_flag_buy_mon;
integer   user_cnt, act_cnt;
integer   wait_val_time, total_latency;
integer	  cycles;
integer	  total_cycles;

//================================================================
// wire & registers 
//================================================================
logic [7:0] golden_DRAM[(65536+256*8)-1:65536+0];



//****  GOLDEN   ****//
Error_Msg  golden_err_msg;
logic      golden_complete;
logic	   golden_flag_bracer;
logic [63:0]golden_out_info;
logic [3:0]golden_user_pw;
logic [7:0]golden_user_pw_en;

logic [7:0]golden_id;
logic [16:0]golden_DRAM_addr;
Action		 golden_act;
DATA		 golden_D;

Player_Info  golden_cur_p_info;
Player_Info  golden_opp_p_info;
Player_id	 golden_cur_id;
Player_id	 golden_opp_id;

PKM_Info ST_GR_LOW;
PKM_Info ST_GR_MID;
PKM_Info ST_GR_HIG;
PKM_Info ST_FI_LOW;
PKM_Info ST_FI_MID;
PKM_Info ST_FI_HIG;
PKM_Info ST_WA_LOW;
PKM_Info ST_WA_MID;
PKM_Info ST_WA_HIG;
PKM_Info ST_EL_LOW;
PKM_Info ST_EL_MID;
PKM_Info ST_EL_HIG;
PKM_Info NO_TYPE;

EXP GR_LOW_EXP;
EXP GR_MID_EXP;
EXP FI_LOW_EXP;
EXP FI_MID_EXP;
EXP WA_LOW_EXP;
EXP WA_MID_EXP;
EXP EL_LOW_EXP;
EXP EL_MID_EXP;

assign GR_LOW_EXP = 8'd32;
assign GR_MID_EXP = 8'd63;
assign FI_LOW_EXP = 8'd30;
assign FI_MID_EXP = 8'd59;
assign WA_LOW_EXP = 8'd28;
assign WA_MID_EXP = 8'd55;
assign EL_LOW_EXP = 8'd26;
assign EL_MID_EXP = 8'd51;

assign ST_GR_LOW.stage = 4'd1;
assign ST_GR_LOW.pkm_type = 4'd1;
assign ST_GR_LOW.hp = 8'd128;
assign ST_GR_LOW.atk = 8'd63;
assign ST_GR_LOW.exp = 8'd0;
assign ST_GR_MID.stage = 4'd2;
assign ST_GR_MID.pkm_type = 4'd1;
assign ST_GR_MID.hp = 8'd192;
assign ST_GR_MID.atk = 8'd94;
assign ST_GR_MID.exp = 8'd0;
assign ST_GR_HIG.stage = 4'd4;
assign ST_GR_HIG.pkm_type = 4'd1;
assign ST_GR_HIG.hp = 8'd254;
assign ST_GR_HIG.atk = 8'd123;
assign ST_GR_HIG.exp = 8'd0;
assign ST_FI_LOW.stage = 4'd1;
assign ST_FI_LOW.pkm_type = 4'd2;
assign ST_FI_LOW.hp = 8'd119;
assign ST_FI_LOW.atk = 8'd64;
assign ST_FI_LOW.exp = 8'd0;
assign ST_FI_MID.stage = 4'd2;
assign ST_FI_MID.pkm_type = 4'd2;
assign ST_FI_MID.hp = 8'd177;
assign ST_FI_MID.atk = 8'd96;
assign ST_FI_MID.exp = 8'd0;
assign ST_FI_HIG.stage = 4'd4;
assign ST_FI_HIG.pkm_type = 4'd2;
assign ST_FI_HIG.hp = 8'd225;
assign ST_FI_HIG.atk = 8'd127;
assign ST_FI_HIG.exp = 8'd0;
assign ST_WA_LOW.stage = 4'd1;
assign ST_WA_LOW.pkm_type = 4'd4;
assign ST_WA_LOW.hp = 8'd125;
assign ST_WA_LOW.atk = 8'd60;
assign ST_WA_LOW.exp = 8'd0;
assign ST_WA_MID.stage = 4'd2;
assign ST_WA_MID.pkm_type = 4'd4;
assign ST_WA_MID.hp = 8'd187;
assign ST_WA_MID.atk = 8'd89;
assign ST_WA_MID.exp = 8'd0;
assign ST_WA_HIG.stage = 4'd4;
assign ST_WA_HIG.pkm_type = 4'd4;
assign ST_WA_HIG.hp = 8'd245;
assign ST_WA_HIG.atk = 8'd113;
assign ST_WA_HIG.exp = 8'd0;
assign ST_EL_LOW.stage = 4'd1;
assign ST_EL_LOW.pkm_type = 4'd8;
assign ST_EL_LOW.hp = 8'd122;
assign ST_EL_LOW.atk = 8'd65;
assign ST_EL_LOW.exp = 8'd0;
assign ST_EL_MID.stage = 4'd2;
assign ST_EL_MID.pkm_type = 4'd8;
assign ST_EL_MID.hp = 8'd182;
assign ST_EL_MID.atk = 8'd97;
assign ST_EL_MID.exp = 8'd0;
assign ST_EL_HIG.stage = 4'd4;
assign ST_EL_HIG.pkm_type = 4'd8;
assign ST_EL_HIG.hp = 8'd235;
assign ST_EL_HIG.atk = 8'd124;
assign ST_EL_HIG.exp = 8'd0;
assign NO_TYPE = 0;



//================================================================
// class random
//================================================================
class random_id;
        randc logic [7:0] ran_id;
        constraint range{
            ran_id inside{[0:255]};
        }
endclass


class random_act;
        rand Action ran_act;
        constraint range{
            ran_act inside{No_action, Buy, Sell, Deposit, Use_item, Check, Attack, Attack};
        }
endclass

class random_user_act_cnt;
        rand integer    ran_act_cnt;
        constraint range{
            ran_act_cnt inside{[1:100]};
        }
endclass

class random_stage;
        rand Stage    ran_stage;
        constraint range{
            ran_stage inside{Lowest, Middle};
        }
endclass

class random_type;
        rand PKM_Type    ran_type;
        constraint range{
            ran_type inside{Grass, Fire, Water, Electric};
        }
endclass

class random_item;
        rand Item    ran_item;
        constraint range{
			ran_item inside{Berry, Medicine, Candy, Bracer};
		}
endclass

class random_money;
        rand Money    ran_money;
        constraint range{
            ran_money inside{[1:100]};
        }
endclass


//================================================================
// initial
//================================================================

random_id            r_id      =  new();
random_act           r_act     =  new();
random_user_act_cnt  r_act_cnt =  new();
random_item			 r_item	   =  new();
random_type			 r_type	   =  new();
random_stage		 r_stage   =  new();
random_money		 r_money   =  new();

initial begin
	dram_init = DRAM_INIT;
	if (dram_init == 0)
	begin
		wdram_dat = $fopen(DRAM_p_r, "w");
		dram_init_task;
	end
	else
	begin
		$readmemh(DRAM_p_r, golden_DRAM);
		inf.rst_n    = 1'b1;
		reset_signal_task;

		@(negedge clk);
		// for (pat_num = 0; pat_num < 256; pat_num = pat_num + 1)
		for (pat_num = 0; pat_num < 60; pat_num = pat_num + 1)
		begin
			// input_task;
			input_user_task;
			USER_STEP = $urandom_range(10, 30);
			for (user_step = 0; user_step < USER_STEP; user_step = user_step + 1)
			begin
				input_act_task;
				wait_out_valid;
				calculate_gold;
				check_exp;
				check_ans;
			end
		end
		@(negedge clk)
		$finish;
	end
end



//================================================================
// task definition
//================================================================
task dram_init_task;
begin
	@(negedge clk)
	for (pat_num = 0; pat_num < 256; pat_num = pat_num + 1)
	begin
		golden_flag_buy_mon = $urandom_range(0,2);
		if (golden_flag_buy_mon)
		begin
			golden_cur_p_info.bag_info.berry_num = 15;
			golden_cur_p_info.bag_info.medicine_num = 15;
			golden_cur_p_info.bag_info.candy_num = 15;
			golden_cur_p_info.bag_info.bracer_num = 15;
			golden_cur_p_info.bag_info.money = 15;
		end
		else
		begin
			golden_cur_p_info.bag_info.berry_num = 0;
			golden_cur_p_info.bag_info.medicine_num = 0;
			golden_cur_p_info.bag_info.candy_num = 0;
			golden_cur_p_info.bag_info.bracer_num = 0;
			golden_cur_p_info.bag_info.money = $urandom_range(0, 20);
		end
		r_type.randomize();
		r_stage.randomize();
		case (r_type.ran_type)
			Grass:
			begin
				case (r_stage.ran_stage)
					Lowest:
						golden_cur_p_info.pkm_info = ST_GR_LOW;
					Middle:
						golden_cur_p_info.pkm_info = ST_GR_MID;
				endcase
			end
			Fire:
			begin
				case (r_stage.ran_stage)
					Lowest:
						golden_cur_p_info.pkm_info = ST_FI_HIG;
					Middle:
						golden_cur_p_info.pkm_info = ST_FI_MID;
				endcase
			end
			Water:
			begin
				case (r_stage.ran_stage)
					Lowest:
						golden_cur_p_info.pkm_info = ST_WA_LOW;
					Middle:
						golden_cur_p_info.pkm_info = ST_WA_MID;
				endcase
			end
			Electric:
			begin
				case (r_stage.ran_stage)
					Lowest:
						golden_cur_p_info.pkm_info = ST_EL_HIG;
					Middle:
						golden_cur_p_info.pkm_info = ST_EL_MID;
				endcase
			end
		endcase
		if (r_stage.ran_stage !== Lowest)
			golden_cur_p_info.pkm_info.exp = $urandom_range(0,25);
		golden_cur_p_info.pkm_info.hp = $urandom_range(0,2);

		$fdisplay(wdram_dat, "@%5h", (32'h10000+pat_num*8));
		$fdisplay(wdram_dat, "%h%h %h%h %h %h",
			golden_cur_p_info.bag_info.berry_num,
			golden_cur_p_info.bag_info.medicine_num,
			golden_cur_p_info.bag_info.candy_num,
			golden_cur_p_info.bag_info.bracer_num,
			golden_cur_p_info.bag_info.money[15:8],
			golden_cur_p_info.bag_info.money[7:0],
		);
		$fdisplay(wdram_dat, "@%5h", (32'h10000+pat_num*8+4));
		$fdisplay(wdram_dat, "%h%h %h %h %h",
			golden_cur_p_info.pkm_info.stage,
			golden_cur_p_info.pkm_info.pkm_type,
			golden_cur_p_info.pkm_info.hp,
			golden_cur_p_info.pkm_info.atk,
			golden_cur_p_info.pkm_info.exp,
		);
	end
	
	repeat(3) @(negedge clk);
	$finish;
end
endtask
task reset_signal_task; begin 
    #(0.5);  inf.rst_n <= 0;
    $readmemh(DRAM_p_r, golden_DRAM);	

	inf.D        		= 0;
	inf.id_valid 	    = 0;
	inf.amnt_valid	    = 0;
	inf.item_valid	    = 0;
	inf.type_valid	    = 0;
	inf.act_valid  	    = 0;
	wait_val_time       = 0;
	total_latency       = 0;
	total_cycles        = 0;
	golden_flag_bracer = 0;

	#(5);
	
    #(10);  inf.rst_n <=1;
	
	
end endtask


task input_user_task;begin
	// gap = $urandom_range(2, 10);
	gap = 2;
    repeat(gap) @(negedge clk);
	inf.id_valid    =  'b1;
	r_id.randomize();
	
	golden_cur_id   = r_id.ran_id;
	inf.D       = {8'b0, golden_cur_id};
	
    repeat(1) @(negedge clk);
	inf.id_valid    =  'b0;
	inf.D           =  'dx; 
end
endtask

task input_act_task;begin
	// if (user_step === 0)
	// 	gap = $urandom_range(1, 5);
	// else
	// 	gap = $urandom_range(2, 10);
	if (user_step === 0)
		gap = 2;
	else
		gap = 2;
    repeat(gap) @(negedge clk);
	inf.act_valid    =  'b1;
	r_act.randomize();
	
	golden_act   = r_act.ran_act;
	if (golden_act == No_action)
		golden_act = Attack;
	inf.D       = {12'b0, golden_act};
	
    repeat(1) @(negedge clk);
	inf.act_valid    =  'b0;
	inf.D           =  'dx; 
	
	if (golden_act !== Sell && golden_act !== Check)
	begin
		gap = 2;
		repeat(gap) @(negedge clk);
		case (golden_act)
			Buy:
			begin
				golden_flag_buy_mon = $urandom_range(0, 1);
				if (!golden_flag_buy_mon)
				begin
					inf.item_valid = 'b1;
					r_item.randomize();
					golden_D = {12'b0, r_item.ran_item};
					inf.D = golden_D;
				end
				else
				begin
					inf.type_valid = 'b1;
					r_type.randomize();
					golden_D = {12'b0, r_type.ran_type};
					inf.D = golden_D;
				end
			end
			Deposit:
			begin
				inf.amnt_valid = 'b1;
				r_money.randomize();
				golden_D = r_money.ran_money;
				inf.D = golden_D;
			end
			Use_item:
			begin
				inf.item_valid = 'b1;
				r_type.randomize();
				golden_D = {12'b0, r_type.ran_type};
				inf.D = golden_D;
			end
			Attack:
			begin
				inf.id_valid = 'b1;
				r_id.randomize();
				golden_D = {8'b0, r_id.ran_id};
				golden_opp_id = r_id.ran_id;
				inf.D = golden_D;
			end
		endcase
		@(negedge clk);
		inf.type_valid = 'b0;
		inf.item_valid = 'b0;
		inf.amnt_valid = 'b0;
		inf.id_valid = 'b0;
		inf.D = 'dx;
	end

	golden_cur_p_info = {golden_DRAM[(65536+(golden_cur_id*8)+0)],
		golden_DRAM[(65536+(golden_cur_id*8)+1)],
		golden_DRAM[(65536+(golden_cur_id*8)+2)],
		golden_DRAM[(65536+(golden_cur_id*8)+3)],
		golden_DRAM[(65536+(golden_cur_id*8)+4)],
		golden_DRAM[(65536+(golden_cur_id*8)+5)],
		golden_DRAM[(65536+(golden_cur_id*8)+6)],
		golden_DRAM[(65536+(golden_cur_id*8)+7)]
	};
	golden_opp_p_info = {golden_DRAM[(65536+(golden_opp_id*8)+0)],
		golden_DRAM[(65536+(golden_opp_id*8)+1)],
		golden_DRAM[(65536+(golden_opp_id*8)+2)],
		golden_DRAM[(65536+(golden_opp_id*8)+3)],
		golden_DRAM[(65536+(golden_opp_id*8)+4)],
		golden_DRAM[(65536+(golden_opp_id*8)+5)],
		golden_DRAM[(65536+(golden_opp_id*8)+6)],
		golden_DRAM[(65536+(golden_opp_id*8)+7)]
	};
	golden_err_msg = 0;
end
endtask

task calculate_gold;
begin
	case (golden_act)
		Buy:
		begin
			if (golden_flag_buy_mon)
			begin
				if (golden_D.d_type[0]==Grass && golden_cur_p_info.bag_info.money >= 100)
				begin
					if (golden_cur_p_info.pkm_info.pkm_type == No_type)
					begin
						golden_cur_p_info.bag_info.money = golden_cur_p_info.bag_info.money - 100;
						golden_cur_p_info.pkm_info = ST_GR_LOW;
					end
					else
					begin
						golden_err_msg = 4'b0001;
					end
				end
				else if (golden_D.d_type[0]==Fire && golden_cur_p_info.bag_info.money >= 90)
				begin
					if (golden_cur_p_info.pkm_info.pkm_type == No_type)
					begin
						golden_cur_p_info.bag_info.money = golden_cur_p_info.bag_info.money - 90;
						golden_cur_p_info.pkm_info = ST_FI_LOW;
					end
					else
					begin
						golden_err_msg = 4'b0001;
					end
				end
				else if (golden_D.d_type[0]==Water && golden_cur_p_info.bag_info.money >= 110)
				begin
					if (golden_cur_p_info.pkm_info.pkm_type == No_type)
					begin
						golden_cur_p_info.bag_info.money = golden_cur_p_info.bag_info.money - 110;
						golden_cur_p_info.pkm_info = ST_WA_LOW;
					end
					else
					begin
						golden_err_msg = 4'b0001;
					end
				end
				else if (golden_D.d_type[0]==Electric && golden_cur_p_info.bag_info.money >= 120)
				begin
					if (golden_cur_p_info.pkm_info.pkm_type == No_type)
					begin
						golden_cur_p_info.bag_info.money = golden_cur_p_info.bag_info.money - 120;
						golden_cur_p_info.pkm_info = ST_EL_LOW;
					end
					else
					begin
						golden_err_msg = 4'b0001;
					end
				end
				else
				begin
					golden_err_msg = 4'b0010;
				end
			end
			else
			begin
				if (golden_D.d_item[0]==Berry && golden_cur_p_info.bag_info.money >= 16)
				begin
					if (golden_cur_p_info.bag_info.berry_num != 15)
					begin
						golden_cur_p_info.bag_info.money = golden_cur_p_info.bag_info.money - 16;
						golden_cur_p_info.bag_info.berry_num = golden_cur_p_info.bag_info.berry_num + 1;
					end
					else
					begin
						golden_err_msg = 4'b0100;
					end
				end
				else if (golden_D.d_item[0]==Medicine && golden_cur_p_info.bag_info.money >= 128)
				begin
					if (golden_cur_p_info.bag_info.medicine_num != 15)
					begin
						golden_cur_p_info.bag_info.money = golden_cur_p_info.bag_info.money - 128;
						golden_cur_p_info.bag_info.medicine_num = golden_cur_p_info.bag_info.medicine_num + 1;
					end
					else
					begin
						golden_err_msg = 4'b0100;
					end
				end
				else if (golden_D.d_item[0]==Candy && golden_cur_p_info.bag_info.money >= 300)
				begin
					if (golden_cur_p_info.bag_info.candy_num != 15)
					begin
						golden_cur_p_info.bag_info.money = golden_cur_p_info.bag_info.money - 300;
						golden_cur_p_info.bag_info.candy_num = golden_cur_p_info.bag_info.candy_num + 1;
					end
					else
					begin
						golden_err_msg = 4'b0100;
					end
				end
				else if (golden_D.d_item[0]==Bracer && golden_cur_p_info.bag_info.money >= 64)
				begin
					if (golden_cur_p_info.bag_info.bracer_num != 15)
					begin
						golden_cur_p_info.bag_info.money = golden_cur_p_info.bag_info.money - 64;
						golden_cur_p_info.bag_info.bracer_num = golden_cur_p_info.bag_info.bracer_num + 1;
					end
					else
					begin
						golden_err_msg = 4'b0100;
					end
				end
				else
				begin
					golden_err_msg = 4'b0010;
				end
			end
		end
		Sell:
		begin
			if (golden_cur_p_info.pkm_info.pkm_type == No_type)
			begin
				golden_err_msg = 4'b0110;
			end
			else if (golden_cur_p_info.pkm_info.stage==Lowest)
			begin
				golden_err_msg = 4'b1000;
			end
			else
			begin
				// TO OUT state
				if (golden_cur_p_info.pkm_info.stage==Middle && golden_cur_p_info.pkm_info.pkm_type==Grass)
					golden_cur_p_info.bag_info.money = golden_cur_p_info.bag_info.money + 510;
				else if (golden_cur_p_info.pkm_info.stage==Highest && golden_cur_p_info.pkm_info.pkm_type==Grass)
					golden_cur_p_info.bag_info.money = golden_cur_p_info.bag_info.money + 1100;
				else if (golden_cur_p_info.pkm_info.stage==Middle && golden_cur_p_info.pkm_info.pkm_type==Fire)
					golden_cur_p_info.bag_info.money = golden_cur_p_info.bag_info.money + 450;
				else if (golden_cur_p_info.pkm_info.stage==Highest && golden_cur_p_info.pkm_info.pkm_type==Fire)
					golden_cur_p_info.bag_info.money = golden_cur_p_info.bag_info.money + 1000;
				else if (golden_cur_p_info.pkm_info.stage==Middle && golden_cur_p_info.pkm_info.pkm_type==Water)
					golden_cur_p_info.bag_info.money = golden_cur_p_info.bag_info.money + 500;
				else if (golden_cur_p_info.pkm_info.stage==Highest && golden_cur_p_info.pkm_info.pkm_type==Water)
					golden_cur_p_info.bag_info.money = golden_cur_p_info.bag_info.money + 1200;
				else if (golden_cur_p_info.pkm_info.stage==Middle && golden_cur_p_info.pkm_info.pkm_type==Electric)
					golden_cur_p_info.bag_info.money = golden_cur_p_info.bag_info.money + 550;
				else
					golden_cur_p_info.bag_info.money = golden_cur_p_info.bag_info.money + 1300;
			end
		end
		Deposit:
		begin
			golden_cur_p_info.bag_info.money += golden_D.d_money;
		end
		Use_item:
		begin
			if (golden_cur_p_info.pkm_info.pkm_type == No_type)
			begin
				golden_err_msg = 4'b0110;
			end
			else if (golden_D.d_item[0]==Berry && golden_cur_p_info.bag_info.berry_num != 0)
			begin
				golden_cur_p_info.bag_info.berry_num = golden_cur_p_info.bag_info.berry_num - 1;
				if (golden_cur_p_info.pkm_info.pkm_type[0] && golden_cur_p_info.pkm_info.stage[0])
					golden_cur_p_info.pkm_info.hp = (golden_cur_p_info.pkm_info.hp>96) ? 128 : golden_cur_p_info.pkm_info.hp + 32;
				else if (golden_cur_p_info.pkm_info.pkm_type[0] && golden_cur_p_info.pkm_info.stage[1])
					golden_cur_p_info.pkm_info.hp = (golden_cur_p_info.pkm_info.hp>160) ? 192 : golden_cur_p_info.pkm_info.hp + 32;
				else if (golden_cur_p_info.pkm_info.pkm_type[0] && golden_cur_p_info.pkm_info.stage[2])
					golden_cur_p_info.pkm_info.hp = (golden_cur_p_info.pkm_info.hp>222) ? 254 : golden_cur_p_info.pkm_info.hp + 32;
				else if (golden_cur_p_info.pkm_info.pkm_type[1] && golden_cur_p_info.pkm_info.stage[0])
					golden_cur_p_info.pkm_info.hp = (golden_cur_p_info.pkm_info.hp>87) ? 119 : golden_cur_p_info.pkm_info.hp + 32;
				else if (golden_cur_p_info.pkm_info.pkm_type[1] && golden_cur_p_info.pkm_info.stage[1])
					golden_cur_p_info.pkm_info.hp = (golden_cur_p_info.pkm_info.hp>145) ? 177 : golden_cur_p_info.pkm_info.hp + 32;
				else if (golden_cur_p_info.pkm_info.pkm_type[1] && golden_cur_p_info.pkm_info.stage[2])
					golden_cur_p_info.pkm_info.hp = (golden_cur_p_info.pkm_info.hp>193) ? 225 : golden_cur_p_info.pkm_info.hp + 32;
				else if (golden_cur_p_info.pkm_info.pkm_type[2] && golden_cur_p_info.pkm_info.stage[0])
					golden_cur_p_info.pkm_info.hp = (golden_cur_p_info.pkm_info.hp>93) ? 125 : golden_cur_p_info.pkm_info.hp + 32;
				else if (golden_cur_p_info.pkm_info.pkm_type[2] && golden_cur_p_info.pkm_info.stage[1])
					golden_cur_p_info.pkm_info.hp = (golden_cur_p_info.pkm_info.hp>155) ? 187 : golden_cur_p_info.pkm_info.hp + 32;
				else if (golden_cur_p_info.pkm_info.pkm_type[2] && golden_cur_p_info.pkm_info.stage[2])
					golden_cur_p_info.pkm_info.hp = (golden_cur_p_info.pkm_info.hp>213) ? 245 : golden_cur_p_info.pkm_info.hp + 32;
				else if (golden_cur_p_info.pkm_info.pkm_type[3] && golden_cur_p_info.pkm_info.stage[0])
					golden_cur_p_info.pkm_info.hp = (golden_cur_p_info.pkm_info.hp>90) ? 122 : golden_cur_p_info.pkm_info.hp + 32;
				else if (golden_cur_p_info.pkm_info.pkm_type[3] && golden_cur_p_info.pkm_info.stage[1])
					golden_cur_p_info.pkm_info.hp = (golden_cur_p_info.pkm_info.hp>150) ? 182 : golden_cur_p_info.pkm_info.hp + 32;
				else
					golden_cur_p_info.pkm_info.hp = (golden_cur_p_info.pkm_info.hp>203) ? 235 : golden_cur_p_info.pkm_info.hp + 32;
			end
			else if (golden_D.d_item[0][1] && golden_cur_p_info.bag_info.medicine_num != 0)
			begin
				golden_cur_p_info.bag_info.medicine_num = golden_cur_p_info.bag_info.medicine_num - 1;
				if (golden_cur_p_info.pkm_info.pkm_type[0] && golden_cur_p_info.pkm_info.stage[0])
					golden_cur_p_info.pkm_info.hp = 128;
				else if (golden_cur_p_info.pkm_info.pkm_type[0] && golden_cur_p_info.pkm_info.stage[1])
					golden_cur_p_info.pkm_info.hp = 192;
				else if (golden_cur_p_info.pkm_info.pkm_type[0] && golden_cur_p_info.pkm_info.stage[2])
					golden_cur_p_info.pkm_info.hp = 254;
				else if (golden_cur_p_info.pkm_info.pkm_type[1] && golden_cur_p_info.pkm_info.stage[0])
					golden_cur_p_info.pkm_info.hp = 119;
				else if (golden_cur_p_info.pkm_info.pkm_type[1] && golden_cur_p_info.pkm_info.stage[1])
					golden_cur_p_info.pkm_info.hp = 177;
				else if (golden_cur_p_info.pkm_info.pkm_type[1] && golden_cur_p_info.pkm_info.stage[2])
					golden_cur_p_info.pkm_info.hp = 225;
				else if (golden_cur_p_info.pkm_info.pkm_type[2] && golden_cur_p_info.pkm_info.stage[0])
					golden_cur_p_info.pkm_info.hp = 125;
				else if (golden_cur_p_info.pkm_info.pkm_type[2] && golden_cur_p_info.pkm_info.stage[1])
					golden_cur_p_info.pkm_info.hp = 187;
				else if (golden_cur_p_info.pkm_info.pkm_type[2] && golden_cur_p_info.pkm_info.stage[2])
					golden_cur_p_info.pkm_info.hp = 245;
				else if (golden_cur_p_info.pkm_info.pkm_type[3] && golden_cur_p_info.pkm_info.stage[0])
					golden_cur_p_info.pkm_info.hp = 122;
				else if (golden_cur_p_info.pkm_info.pkm_type[3] && golden_cur_p_info.pkm_info.stage[1])
					golden_cur_p_info.pkm_info.hp = 182;
				else
					golden_cur_p_info.pkm_info.hp = 235;
			end
			else if (golden_D.d_item[0][2] && golden_cur_p_info.bag_info.candy_num != 0)
			begin
				golden_cur_p_info.bag_info.candy_num = golden_cur_p_info.bag_info.candy_num - 1;
				golden_cur_p_info.pkm_info.exp = golden_cur_p_info.pkm_info.exp + 15;
			end
			else if (golden_D.d_item[0][3] && golden_cur_p_info.bag_info.bracer_num != 0)
			begin
				golden_cur_p_info.bag_info.bracer_num = golden_cur_p_info.bag_info.bracer_num - 1;
				if (golden_flag_bracer === 0)
				begin
					golden_flag_bracer = 1;
					golden_cur_p_info.pkm_info.atk = golden_cur_p_info.pkm_info.atk + 32;
				end
			end
			else
			begin
				golden_err_msg = 4'b1010;
			end
		end
		Attack:
		begin
			if (golden_cur_p_info.pkm_info.pkm_type == No_type || golden_opp_p_info.pkm_info.pkm_type == No_type)
			begin
				golden_err_msg = 4'b0110;
			end
			else if (golden_cur_p_info.pkm_info.hp == 0 || golden_opp_p_info.pkm_info.hp == 0)
			begin
				golden_err_msg = 4'b1101;
			end
			else
			begin
				case (golden_cur_p_info.pkm_info.pkm_type)
					Grass:
					begin
						case (golden_opp_p_info.pkm_info.pkm_type)
							Grass:
								golden_opp_p_info.pkm_info.hp = (golden_opp_p_info.pkm_info.hp < golden_cur_p_info.pkm_info.atk / 2) ? 0 : (golden_opp_p_info.pkm_info.hp - golden_cur_p_info.pkm_info.atk / 2);
							Fire:
								golden_opp_p_info.pkm_info.hp = (golden_opp_p_info.pkm_info.hp < golden_cur_p_info.pkm_info.atk / 2) ? 0 : (golden_opp_p_info.pkm_info.hp - golden_cur_p_info.pkm_info.atk / 2);
							Water:
								golden_opp_p_info.pkm_info.hp = (golden_opp_p_info.pkm_info.hp < golden_cur_p_info.pkm_info.atk * 2) ? 0 : (golden_opp_p_info.pkm_info.hp - golden_cur_p_info.pkm_info.atk * 2);
							Electric:
								golden_opp_p_info.pkm_info.hp = (golden_opp_p_info.pkm_info.hp < golden_cur_p_info.pkm_info.atk) ? 0 : (golden_opp_p_info.pkm_info.hp - golden_cur_p_info.pkm_info.atk);
						endcase
					end
					Fire:
					begin
						case (golden_opp_p_info.pkm_info.pkm_type)
							Grass:
								golden_opp_p_info.pkm_info.hp = (golden_opp_p_info.pkm_info.hp < golden_cur_p_info.pkm_info.atk * 2) ? 0 : (golden_opp_p_info.pkm_info.hp - golden_cur_p_info.pkm_info.atk * 2);
							Fire:
								golden_opp_p_info.pkm_info.hp = (golden_opp_p_info.pkm_info.hp < golden_cur_p_info.pkm_info.atk / 2) ? 0 : (golden_opp_p_info.pkm_info.hp - golden_cur_p_info.pkm_info.atk / 2);
							Water:
								golden_opp_p_info.pkm_info.hp = (golden_opp_p_info.pkm_info.hp < golden_cur_p_info.pkm_info.atk / 2) ? 0 : (golden_opp_p_info.pkm_info.hp - golden_cur_p_info.pkm_info.atk / 2);
							Electric:
								golden_opp_p_info.pkm_info.hp = (golden_opp_p_info.pkm_info.hp < golden_cur_p_info.pkm_info.atk) ? 0 : (golden_opp_p_info.pkm_info.hp - golden_cur_p_info.pkm_info.atk);
						endcase
					end
					Water:
					begin
						case (golden_opp_p_info.pkm_info.pkm_type)
							Grass:
								golden_opp_p_info.pkm_info.hp = (golden_opp_p_info.pkm_info.hp < golden_cur_p_info.pkm_info.atk / 2) ? 0 : (golden_opp_p_info.pkm_info.hp - golden_cur_p_info.pkm_info.atk / 2);
							Fire:
								golden_opp_p_info.pkm_info.hp = (golden_opp_p_info.pkm_info.hp < golden_cur_p_info.pkm_info.atk * 2) ? 0 : (golden_opp_p_info.pkm_info.hp - golden_cur_p_info.pkm_info.atk * 2);
							Water:
								golden_opp_p_info.pkm_info.hp = (golden_opp_p_info.pkm_info.hp < golden_cur_p_info.pkm_info.atk / 2) ? 0 : (golden_opp_p_info.pkm_info.hp - golden_cur_p_info.pkm_info.atk / 2);
							Electric:
								golden_opp_p_info.pkm_info.hp = (golden_opp_p_info.pkm_info.hp < golden_cur_p_info.pkm_info.atk) ? 0 : (golden_opp_p_info.pkm_info.hp - golden_cur_p_info.pkm_info.atk);
						endcase
					end
					Electric:
					begin
						case (golden_opp_p_info.pkm_info.pkm_type)
							Grass:
								golden_opp_p_info.pkm_info.hp = (golden_opp_p_info.pkm_info.hp < golden_cur_p_info.pkm_info.atk / 2) ? 0 : (golden_opp_p_info.pkm_info.hp - golden_cur_p_info.pkm_info.atk / 2);
							Fire:
								golden_opp_p_info.pkm_info.hp = (golden_opp_p_info.pkm_info.hp < golden_cur_p_info.pkm_info.atk) ? 0 : (golden_opp_p_info.pkm_info.hp - golden_cur_p_info.pkm_info.atk);
							Water:
								golden_opp_p_info.pkm_info.hp = (golden_opp_p_info.pkm_info.hp < golden_cur_p_info.pkm_info.atk * 2) ? 0 : (golden_opp_p_info.pkm_info.hp - golden_cur_p_info.pkm_info.atk * 2);
							Electric:
								golden_opp_p_info.pkm_info.hp = (golden_opp_p_info.pkm_info.hp < golden_cur_p_info.pkm_info.atk / 2) ? 0 : (golden_opp_p_info.pkm_info.hp - golden_cur_p_info.pkm_info.atk / 2);
						endcase
					end
				endcase

				if (golden_flag_bracer)
				begin
					golden_flag_bracer = 0;
					golden_cur_p_info.pkm_info.atk -= 32;
				end
				
				if (golden_opp_p_info.pkm_info.stage[0])
				begin
					golden_cur_p_info.pkm_info.exp += 16;
				end
				else if (golden_opp_p_info.pkm_info.stage[1])
				begin
					golden_cur_p_info.pkm_info.exp += 24;
				end
				else if (golden_opp_p_info.pkm_info.stage[2])
				begin
					golden_cur_p_info.pkm_info.exp += 32;
				end
				
				if (golden_cur_p_info.pkm_info.stage[0])
				begin
					golden_opp_p_info.pkm_info.exp += 8;
				end
				else if (golden_cur_p_info.pkm_info.stage[1])
				begin
					golden_opp_p_info.pkm_info.exp += 12;
				end
				else if (golden_cur_p_info.pkm_info.stage[2])
				begin
					golden_opp_p_info.pkm_info.exp += 16;
				end
			end
		end
	endcase
end
endtask

task check_exp;
begin
	case (golden_cur_p_info.pkm_info.pkm_type)
		Grass:
		begin
			case (golden_cur_p_info.pkm_info.stage)
				Lowest:
				begin
					if (golden_cur_p_info.pkm_info.exp >= GR_LOW_EXP)
					begin
						golden_cur_p_info.pkm_info = ST_GR_MID;
						golden_flag_bracer = 0;
					end
				end
				Middle:
				begin
					if (golden_cur_p_info.pkm_info.exp >= GR_MID_EXP)
					begin
						golden_cur_p_info.pkm_info = ST_GR_HIG;
						golden_flag_bracer = 0;
					end
				end
			endcase
		end
		Fire:
		begin
			case (golden_cur_p_info.pkm_info.stage)
				Lowest:
				begin
					if (golden_cur_p_info.pkm_info.exp >= FI_LOW_EXP)
					begin
						golden_cur_p_info.pkm_info = ST_FI_MID;
						golden_flag_bracer = 0;
					end
				end
				Middle:
				begin
					if (golden_cur_p_info.pkm_info.exp >= FI_MID_EXP)
					begin
						golden_cur_p_info.pkm_info = ST_FI_HIG;
						golden_flag_bracer = 0;
					end
				end
			endcase
		end
		Water:
		begin
			case (golden_cur_p_info.pkm_info.stage)
				Lowest:
				begin
					if (golden_cur_p_info.pkm_info.exp >= WA_LOW_EXP)
					begin
						golden_cur_p_info.pkm_info = ST_WA_MID;
						golden_flag_bracer = 0;
					end
				end
				Middle:
				begin
					if (golden_cur_p_info.pkm_info.exp >= WA_MID_EXP)
					begin
						golden_cur_p_info.pkm_info = ST_WA_HIG;
						golden_flag_bracer = 0;
					end
				end
			endcase
		end
		Electric:
		begin
			case (golden_cur_p_info.pkm_info.stage)
				Lowest:
				begin
					if (golden_cur_p_info.pkm_info.exp >= EL_LOW_EXP)
					begin
						golden_cur_p_info.pkm_info = ST_EL_MID;
						golden_flag_bracer = 0;
					end
				end
				Middle:
				begin
					if (golden_cur_p_info.pkm_info.exp >= EL_MID_EXP)
					begin
						golden_cur_p_info.pkm_info = ST_EL_HIG;
						golden_flag_bracer = 0;
					end
				end
			endcase
		end
	endcase
	if (golden_cur_p_info.pkm_info.stage == Highest)
		golden_cur_p_info.pkm_info.exp = 0;
	
	case (golden_opp_p_info.pkm_info.pkm_type)
		Grass:
		begin
			case (golden_opp_p_info.pkm_info.stage)
				Lowest:
				begin
					if (golden_opp_p_info.pkm_info.exp >= GR_LOW_EXP)
					begin
						golden_opp_p_info.pkm_info = ST_GR_MID;
					end
				end
				Middle:
				begin
					if (golden_opp_p_info.pkm_info.exp >= GR_MID_EXP)
					begin
						golden_opp_p_info.pkm_info = ST_GR_HIG;
					end
				end
			endcase
		end
		Fire:
		begin
			case (golden_opp_p_info.pkm_info.stage)
				Lowest:
				begin
					if (golden_opp_p_info.pkm_info.exp >= FI_LOW_EXP)
					begin
						golden_opp_p_info.pkm_info = ST_FI_MID;
					end
				end
				Middle:
				begin
					if (golden_opp_p_info.pkm_info.exp >= FI_MID_EXP)
					begin
						golden_opp_p_info.pkm_info = ST_FI_HIG;
					end
				end
			endcase
		end
		Water:
		begin
			case (golden_opp_p_info.pkm_info.stage)
				Lowest:
				begin
					if (golden_opp_p_info.pkm_info.exp >= WA_LOW_EXP)
					begin
						golden_opp_p_info.pkm_info = ST_WA_MID;
					end
				end
				Middle:
				begin
					if (golden_opp_p_info.pkm_info.exp >= WA_MID_EXP)
					begin
						golden_opp_p_info.pkm_info = ST_WA_HIG;
					end
				end
			endcase
		end
		Electric:
		begin
			case (golden_opp_p_info.pkm_info.stage)
				Lowest:
				begin
					if (golden_opp_p_info.pkm_info.exp >= EL_LOW_EXP)
					begin
						golden_opp_p_info.pkm_info = ST_EL_MID;
					end
				end
				Middle:
				begin
					if (golden_opp_p_info.pkm_info.exp >= EL_MID_EXP)
					begin
						golden_opp_p_info.pkm_info = ST_EL_HIG;
					end
				end
			endcase
		end
	endcase
	if (golden_opp_p_info.pkm_info.stage == Highest)
		golden_opp_p_info.pkm_info.exp = 0;
end
endtask

task wait_out_valid;
begin
	cycles = 0;
	while(inf.out_valid === 0)begin
		cycles = cycles + 1;
	@(negedge clk);
	end
	total_cycles = total_cycles + cycles;
end
endtask

task check_ans;
begin
	if (golden_act == Sell)
	begin
		golden_flag_bracer = 0;
		golden_cur_p_info.pkm_info = 0;
	end
	
	if (user_step === USER_STEP - 1 && golden_flag_bracer === 1)
	begin
		golden_flag_bracer = 0;
		golden_cur_p_info.pkm_info.atk -= 32;
	end
	{golden_DRAM[(65536+(golden_cur_id*8)+0)],
		golden_DRAM[(65536+(golden_cur_id*8)+1)],
		golden_DRAM[(65536+(golden_cur_id*8)+2)],
		golden_DRAM[(65536+(golden_cur_id*8)+3)],
		golden_DRAM[(65536+(golden_cur_id*8)+4)],
		golden_DRAM[(65536+(golden_cur_id*8)+5)],
		golden_DRAM[(65536+(golden_cur_id*8)+6)],
		golden_DRAM[(65536+(golden_cur_id*8)+7)]
	} = golden_cur_p_info;
	{golden_DRAM[(65536+(golden_opp_id*8)+0)],
		golden_DRAM[(65536+(golden_opp_id*8)+1)],
		golden_DRAM[(65536+(golden_opp_id*8)+2)],
		golden_DRAM[(65536+(golden_opp_id*8)+3)],
		golden_DRAM[(65536+(golden_opp_id*8)+4)],
		golden_DRAM[(65536+(golden_opp_id*8)+5)],
		golden_DRAM[(65536+(golden_opp_id*8)+6)],
		golden_DRAM[(65536+(golden_opp_id*8)+7)]
	} = golden_opp_p_info;
end
endtask

endprogram

