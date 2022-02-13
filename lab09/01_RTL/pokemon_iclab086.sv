module pokemon(input clk, INF.pokemon_inf inf);
import usertype::*;

//================================================================
// logic 
//================================================================

DATA D_reg;
DATA D_reg_ns;
typedef enum	logic	[3:0]	{
							IN=4'd0, RDRAM=4'd1, WDRAM=4'd2, BUY=4'd3,
							SELL=4'd4, DEPOSIT=4'd5, CHECK=4'd6, UITEM=4'd7,
							ATTACK=4'd8, OUT=4'd9, IN_ID=4'd10
						}	STATE;
STATE		state;
STATE		state_ns;
Error_Msg	err_msg_ns;
Player_id	cur_id;
Player_id	cur_id_ns;
Player_id	next_id;
Player_id	next_id_ns;
Player_id	opp_id;
Player_id	opp_id_ns;
Player_Info	cur_p_info;
Player_Info	cur_p_info_ns;
Player_Info	opp_p_info;
Player_Info	opp_p_info_ns;
logic		flag_change_id;
logic		flag_change_id_ns;
logic		flag_first_id;
logic		flag_first_id_ns;
logic		flag_buy_mon;
logic		flag_buy_mon_ns;
logic		flag_bracer;
logic		flag_bracer_ns;
logic	[7:0]	cur_pkm_atk;
logic		flag_C_invalid;
logic		flag_C_invalid_ns;
Action		cur_act;
Action		cur_act_ns;

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

//================================================================
// design 
//================================================================

assign ST_GR_LOW.stage = Lowest;
assign ST_GR_LOW.pkm_type = Grass;
assign ST_GR_LOW.hp = 8'd128;
assign ST_GR_LOW.atk = 8'd63;
// assign ST_GR_LOW.exp = 8'd32;
assign ST_GR_LOW.exp = 8'd0;
assign ST_GR_MID.stage = Middle;
assign ST_GR_MID.pkm_type = Grass;
assign ST_GR_MID.hp = 8'd192;
assign ST_GR_MID.atk = 8'd94;
// assign ST_GR_MID.exp = 8'd63;
assign ST_GR_MID.exp = 8'd0;
assign ST_GR_HIG.stage = Highest;
assign ST_GR_HIG.pkm_type = Grass;
assign ST_GR_HIG.hp = 8'd254;
assign ST_GR_HIG.atk = 8'd123;
// assign ST_GR_HIG.exp = 8'dx;
assign ST_GR_HIG.exp = 8'd0;
assign ST_FI_LOW.stage = Lowest;
assign ST_FI_LOW.pkm_type = Fire;
assign ST_FI_LOW.hp = 8'd119;
assign ST_FI_LOW.atk = 8'd64;
// assign ST_FI_LOW.exp = 8'd30;
assign ST_FI_LOW.exp = 8'd0;
assign ST_FI_MID.stage = Middle;
assign ST_FI_MID.pkm_type = Fire;
assign ST_FI_MID.hp = 8'd177;
assign ST_FI_MID.atk = 8'd96;
// assign ST_FI_MID.exp = 8'd59;
assign ST_FI_MID.exp = 8'd0;
assign ST_FI_HIG.stage = Highest;
assign ST_FI_HIG.pkm_type = Fire;
assign ST_FI_HIG.hp = 8'd225;
assign ST_FI_HIG.atk = 8'd127;
// assign ST_FI_HIG.exp = 8'dx;
assign ST_FI_HIG.exp = 8'd0;
assign ST_WA_LOW.stage = Lowest;
assign ST_WA_LOW.pkm_type = Water;
assign ST_WA_LOW.hp = 8'd125;
assign ST_WA_LOW.atk = 8'd60;
// assign ST_WA_LOW.exp = 8'd28;
assign ST_WA_LOW.exp = 8'd0;
assign ST_WA_MID.stage = Middle;
assign ST_WA_MID.pkm_type = Water;
assign ST_WA_MID.hp = 8'd187;
assign ST_WA_MID.atk = 8'd89;
// assign ST_WA_MID.exp = 8'd55;
assign ST_WA_MID.exp = 8'd0;
assign ST_WA_HIG.stage = Highest;
assign ST_WA_HIG.pkm_type = Water;
assign ST_WA_HIG.hp = 8'd245;
assign ST_WA_HIG.atk = 8'd113;
// assign ST_WA_HIG.exp = 8'dx;
assign ST_WA_HIG.exp = 8'd0;
assign ST_EL_LOW.stage = Lowest;
assign ST_EL_LOW.pkm_type = Electric;
assign ST_EL_LOW.hp = 8'd122;
assign ST_EL_LOW.atk = 8'd65;
// assign ST_EL_LOW.exp = 8'd26;
assign ST_EL_LOW.exp = 8'd0;
assign ST_EL_MID.stage = Middle;
assign ST_EL_MID.pkm_type = Electric;
assign ST_EL_MID.hp = 8'd182;
assign ST_EL_MID.atk = 8'd97;
// assign ST_EL_MID.exp = 8'd51;
assign ST_EL_MID.exp = 8'd0;
assign ST_EL_HIG.stage = Highest;
assign ST_EL_HIG.pkm_type = Electric;
assign ST_EL_HIG.hp = 8'd235;
assign ST_EL_HIG.atk = 8'd124;
// assign ST_EL_HIG.exp = 8'dx;
assign ST_EL_HIG.exp = 8'd0;

assign cur_pkm_atk = cur_p_info.pkm_info.atk + (32 * flag_bracer);

always_comb
begin
	err_msg_ns = inf.err_msg;
	cur_id_ns = cur_id;
	next_id_ns = next_id;
	opp_id_ns = opp_id;
	cur_p_info_ns = cur_p_info;
	opp_p_info_ns = opp_p_info;
	flag_change_id_ns = flag_change_id;
	flag_first_id_ns = flag_first_id;
	flag_buy_mon_ns = flag_buy_mon;
	flag_bracer_ns = flag_bracer;
	cur_act_ns = cur_act;
	state_ns = state;
	D_reg_ns = D_reg;
	flag_C_invalid_ns = flag_C_invalid;
	
	inf.out_valid = 0;
	inf.complete = 0;
	inf.out_info = 0;
	inf.C_addr = 0;
	inf.C_data_w = 0;
	inf.C_in_valid = 0;
	inf.C_r_wb = 0;
	
	case (state)
		IN:
		begin
			if (inf.id_valid && cur_act != Attack)
			begin
				if (flag_first_id)
				begin
					flag_change_id_ns = 1;
					cur_id_ns = inf.D.d_id[0];
					next_id_ns = inf.D.d_id[0];
				end
				else
				begin
					flag_change_id_ns = 1;
					next_id_ns = inf.D.d_id[0];
				end
				flag_bracer_ns = 0;
			end
			else if (inf.act_valid)
			begin
				cur_act_ns = inf.D.d_act[0];
				if (inf.D.d_act == Sell && !flag_change_id)
					state_ns = SELL;
				else if (inf.D.d_act == Sell && flag_change_id)
					state_ns = WDRAM;
				else if (inf.D.d_act == Check && !flag_change_id)
					state_ns = CHECK;
				else if (inf.D.d_act == Check && flag_change_id)
					state_ns = WDRAM;
			end
			else if (inf.item_valid)
			begin
				D_reg_ns = inf.D;
				if (flag_change_id)
					state_ns = WDRAM;
				else if (cur_act == Buy)
					state_ns = BUY;
				else
					state_ns = UITEM;
			end
			else if (inf.type_valid)
			begin
				D_reg_ns = inf.D;
				flag_buy_mon_ns = 1;
				if (flag_change_id)
					state_ns = WDRAM;
				else
					state_ns = BUY;
			end
			else if (inf.amnt_valid)
			begin
				D_reg_ns = inf.D;
				if (flag_change_id)
					state_ns = WDRAM;
				else
					state_ns = DEPOSIT;
			end
			else if (inf.id_valid)
			begin
				D_reg_ns = inf.D;
				if (flag_change_id)
					state_ns = WDRAM;
				else
					state_ns = RDRAM;
			end
		end
		
		WDRAM:
		begin
			if (flag_first_id)
			begin
				flag_first_id_ns = 0;
				state_ns = RDRAM;
			end
			else if (flag_change_id)
			begin
				inf.C_in_valid = flag_C_invalid;
				flag_C_invalid_ns = 0;
				inf.C_addr = cur_id;
				{inf.C_data_w[7:0],
					inf.C_data_w[15:8],
					inf.C_data_w[23:16],
					inf.C_data_w[31:24],
					inf.C_data_w[39:32],
					inf.C_data_w[47:40],
					inf.C_data_w[55:48],
					inf.C_data_w[63:56]
				} = cur_p_info;
				if (inf.C_out_valid)
				begin
					flag_C_invalid_ns = 1;
					state_ns = RDRAM;
				end
			end
			else
			begin
				inf.C_in_valid = flag_C_invalid;
				flag_C_invalid_ns = 0;
				inf.C_addr = opp_id;
				{inf.C_data_w[7:0],
					inf.C_data_w[15:8],
					inf.C_data_w[23:16],
					inf.C_data_w[31:24],
					inf.C_data_w[39:32],
					inf.C_data_w[47:40],
					inf.C_data_w[55:48],
					inf.C_data_w[63:56]
				} = opp_p_info;
				if (inf.C_out_valid)
				begin
					flag_C_invalid_ns = 1;
					state_ns = OUT;
				end
			end
		end

		RDRAM:
		begin
			inf.C_in_valid = flag_C_invalid;
			flag_C_invalid_ns = 0;
			inf.C_r_wb = 1;
			if (flag_change_id)
			begin
				inf.C_addr = next_id;
				cur_id_ns = next_id;
				if (inf.C_out_valid)
				begin
					flag_C_invalid_ns = 1;
					flag_change_id_ns = 0;
					cur_p_info_ns = {inf.C_data_r[7:0],
						inf.C_data_r[15:8],
						inf.C_data_r[23:16],
						inf.C_data_r[31:24],
						inf.C_data_r[39:32],
						inf.C_data_r[47:40],
						inf.C_data_r[55:48],
						inf.C_data_r[63:56]
					};
					if (cur_act == Sell)
						state_ns = SELL;
					else if (cur_act == Check)
						state_ns = CHECK;
					else if (cur_act == Buy)
						state_ns = BUY;
					else if (cur_act == Use_item)
						state_ns = UITEM;
					else if (cur_act == Deposit)
						state_ns = DEPOSIT;
				end
			end
			else
			begin
				inf.C_addr = D_reg.d_id[0];
				opp_id_ns = D_reg.d_id[0];
				if (inf.C_out_valid)
				begin
					flag_C_invalid_ns = 1;
					opp_p_info_ns = inf.C_data_r;
					opp_p_info_ns = {inf.C_data_r[7:0],
						inf.C_data_r[15:8],
						inf.C_data_r[23:16],
						inf.C_data_r[31:24],
						inf.C_data_r[39:32],
						inf.C_data_r[47:40],
						inf.C_data_r[55:48],
						inf.C_data_r[63:56]
					};
					state_ns = ATTACK;
				end
			end
		end
		
		BUY:
		begin
			state_ns = OUT;
			if (flag_buy_mon)
			begin
				if (D_reg.d_type[0][0] && cur_p_info.bag_info.money >= 100)
				begin
					if (cur_p_info.pkm_info.pkm_type == No_type)
					begin
						cur_p_info_ns.bag_info.money = cur_p_info.bag_info.money - 100;
						cur_p_info_ns.pkm_info = ST_GR_LOW;
					end
					else
					begin
						err_msg_ns = Already_Have_PKM;
					end
				end
				else if (D_reg.d_type[0][1] && cur_p_info.bag_info.money >= 90)
				begin
					if (cur_p_info.pkm_info.pkm_type == No_type)
					begin
						cur_p_info_ns.bag_info.money = cur_p_info.bag_info.money - 90;
						cur_p_info_ns.pkm_info = ST_FI_LOW;
					end
					else
					begin
						err_msg_ns = Already_Have_PKM;
					end
				end
				else if (D_reg.d_type[0][2] && cur_p_info.bag_info.money >= 110)
				begin
					if (cur_p_info.pkm_info.pkm_type == No_type)
					begin
						cur_p_info_ns.bag_info.money = cur_p_info.bag_info.money - 110;
						cur_p_info_ns.pkm_info = ST_WA_LOW;
					end
					else
					begin
						err_msg_ns = Already_Have_PKM;
					end
				end
				else if (D_reg.d_type[0][3] && cur_p_info.bag_info.money >= 120)
				begin
					if (cur_p_info.pkm_info.pkm_type == No_type)
					begin
						cur_p_info_ns.bag_info.money = cur_p_info.bag_info.money - 120;
						cur_p_info_ns.pkm_info = ST_EL_LOW;
					end
					else
					begin
						err_msg_ns = Already_Have_PKM;
					end
				end
				else
				begin
					err_msg_ns = Out_of_money;
				end
			end
			else
			begin
				if (D_reg.d_item[0][0] && cur_p_info.bag_info.money >= 16)
				begin
					if (cur_p_info.bag_info.berry_num != 15)
					begin
						cur_p_info_ns.bag_info.money = cur_p_info.bag_info.money - 16;
						cur_p_info_ns.bag_info.berry_num = cur_p_info.bag_info.berry_num + 1;
					end
					else
					begin
						err_msg_ns = Bag_is_full;
					end
				end
				else if (D_reg.d_item[0][1] && cur_p_info.bag_info.money >= 128)
				begin
					if (cur_p_info.bag_info.medicine_num != 15)
					begin
						cur_p_info_ns.bag_info.money = cur_p_info.bag_info.money - 128;
						cur_p_info_ns.bag_info.medicine_num = cur_p_info.bag_info.medicine_num + 1;
					end
					else
					begin
						err_msg_ns = Bag_is_full;
					end
				end
				else if (D_reg.d_item[0][2] && cur_p_info.bag_info.money >= 300)
				begin
					if (cur_p_info.bag_info.candy_num != 15)
					begin
						cur_p_info_ns.bag_info.money = cur_p_info.bag_info.money - 300;
						cur_p_info_ns.bag_info.candy_num = cur_p_info.bag_info.candy_num + 1;
					end
					else
					begin
						err_msg_ns = Bag_is_full;
					end
				end
				else if (D_reg.d_item[0][3] && cur_p_info.bag_info.money >= 64)
				begin
					if (cur_p_info.bag_info.bracer_num != 15)
					begin
						cur_p_info_ns.bag_info.money = cur_p_info.bag_info.money - 64;
						cur_p_info_ns.bag_info.bracer_num = cur_p_info.bag_info.bracer_num + 1;
					end
					else
					begin
						err_msg_ns = Bag_is_full;
					end
				end
				else
				begin
					err_msg_ns = Out_of_money;
				end
			end
		end

		SELL:
		begin
			state_ns = OUT;
			if (cur_p_info.pkm_info.pkm_type == No_type)
			begin
				err_msg_ns = Not_Having_PKM;
			end
			else if (cur_p_info.pkm_info.stage[0])
			begin
				err_msg_ns = Has_Not_Grown;
			end
			else
			begin
				// TO OUT state
				// cur_p_info_ns.pkm_info = 0;
				if (cur_p_info.pkm_info.stage[1] && cur_p_info.pkm_info.pkm_type[0])
					cur_p_info_ns.bag_info.money = cur_p_info.bag_info.money + 510;
				else if (cur_p_info.pkm_info.stage[2] && cur_p_info.pkm_info.pkm_type[0])
					cur_p_info_ns.bag_info.money = cur_p_info.bag_info.money + 1100;
				else if (cur_p_info.pkm_info.stage[1] && cur_p_info.pkm_info.pkm_type[1])
					cur_p_info_ns.bag_info.money = cur_p_info.bag_info.money + 450;
				else if (cur_p_info.pkm_info.stage[2] && cur_p_info.pkm_info.pkm_type[1])
					cur_p_info_ns.bag_info.money = cur_p_info.bag_info.money + 1000;
				else if (cur_p_info.pkm_info.stage[1] && cur_p_info.pkm_info.pkm_type[2])
					cur_p_info_ns.bag_info.money = cur_p_info.bag_info.money + 500;
				else if (cur_p_info.pkm_info.stage[2] && cur_p_info.pkm_info.pkm_type[2])
					cur_p_info_ns.bag_info.money = cur_p_info.bag_info.money + 1200;
				else if (cur_p_info.pkm_info.stage[1] && cur_p_info.pkm_info.pkm_type[3])
					cur_p_info_ns.bag_info.money = cur_p_info.bag_info.money + 550;
				else
					cur_p_info_ns.bag_info.money = cur_p_info.bag_info.money + 1300;
			end
		end
		DEPOSIT:
		begin
			state_ns = OUT;
			cur_p_info_ns.bag_info.money = cur_p_info.bag_info.money + D_reg.d_money;
		end
		CHECK:
		begin
			state_ns = OUT;
		end
		UITEM:
		begin
			state_ns = OUT;
			if (cur_p_info.pkm_info.pkm_type == No_type)
			begin
				err_msg_ns = Not_Having_PKM;
			end
			else if (D_reg.d_item[0][0] && cur_p_info.bag_info.berry_num != 0)
			begin
				cur_p_info_ns.bag_info.berry_num = cur_p_info.bag_info.berry_num - 1;
				if (cur_p_info.pkm_info.pkm_type[0] && cur_p_info.pkm_info.stage[0])
					cur_p_info_ns.pkm_info.hp = (cur_p_info.pkm_info.hp>96) ? 128 : cur_p_info.pkm_info.hp + 32;
				else if (cur_p_info.pkm_info.pkm_type[0] && cur_p_info.pkm_info.stage[1])
					cur_p_info_ns.pkm_info.hp = (cur_p_info.pkm_info.hp>160) ? 192 : cur_p_info.pkm_info.hp + 32;
				else if (cur_p_info.pkm_info.pkm_type[0] && cur_p_info.pkm_info.stage[2])
					cur_p_info_ns.pkm_info.hp = (cur_p_info.pkm_info.hp>222) ? 254 : cur_p_info.pkm_info.hp + 32;
				else if (cur_p_info.pkm_info.pkm_type[1] && cur_p_info.pkm_info.stage[0])
					cur_p_info_ns.pkm_info.hp = (cur_p_info.pkm_info.hp>87) ? 119 : cur_p_info.pkm_info.hp + 32;
				else if (cur_p_info.pkm_info.pkm_type[1] && cur_p_info.pkm_info.stage[1])
					cur_p_info_ns.pkm_info.hp = (cur_p_info.pkm_info.hp>145) ? 177 : cur_p_info.pkm_info.hp + 32;
				else if (cur_p_info.pkm_info.pkm_type[1] && cur_p_info.pkm_info.stage[2])
					cur_p_info_ns.pkm_info.hp = (cur_p_info.pkm_info.hp>193) ? 225 : cur_p_info.pkm_info.hp + 32;
				else if (cur_p_info.pkm_info.pkm_type[2] && cur_p_info.pkm_info.stage[0])
					cur_p_info_ns.pkm_info.hp = (cur_p_info.pkm_info.hp>93) ? 125 : cur_p_info.pkm_info.hp + 32;
				else if (cur_p_info.pkm_info.pkm_type[2] && cur_p_info.pkm_info.stage[1])
					cur_p_info_ns.pkm_info.hp = (cur_p_info.pkm_info.hp>155) ? 187 : cur_p_info.pkm_info.hp + 32;
				else if (cur_p_info.pkm_info.pkm_type[2] && cur_p_info.pkm_info.stage[2])
					cur_p_info_ns.pkm_info.hp = (cur_p_info.pkm_info.hp>213) ? 245 : cur_p_info.pkm_info.hp + 32;
				else if (cur_p_info.pkm_info.pkm_type[3] && cur_p_info.pkm_info.stage[0])
					cur_p_info_ns.pkm_info.hp = (cur_p_info.pkm_info.hp>90) ? 122 : cur_p_info.pkm_info.hp + 32;
				else if (cur_p_info.pkm_info.pkm_type[3] && cur_p_info.pkm_info.stage[1])
					cur_p_info_ns.pkm_info.hp = (cur_p_info.pkm_info.hp>150) ? 182 : cur_p_info.pkm_info.hp + 32;
				else
					cur_p_info_ns.pkm_info.hp = (cur_p_info.pkm_info.hp>203) ? 235 : cur_p_info.pkm_info.hp + 32;
			end
			else if (D_reg.d_item[0][1] && cur_p_info.bag_info.medicine_num != 0)
			begin
				cur_p_info_ns.bag_info.medicine_num = cur_p_info.bag_info.medicine_num - 1;
				if (cur_p_info.pkm_info.pkm_type[0] && cur_p_info.pkm_info.stage[0])
					cur_p_info_ns.pkm_info.hp = 128;
				else if (cur_p_info.pkm_info.pkm_type[0] && cur_p_info.pkm_info.stage[1])
					cur_p_info_ns.pkm_info.hp = 192;
				else if (cur_p_info.pkm_info.pkm_type[0] && cur_p_info.pkm_info.stage[2])
					cur_p_info_ns.pkm_info.hp = 254;
				else if (cur_p_info.pkm_info.pkm_type[1] && cur_p_info.pkm_info.stage[0])
					cur_p_info_ns.pkm_info.hp = 119;
				else if (cur_p_info.pkm_info.pkm_type[1] && cur_p_info.pkm_info.stage[1])
					cur_p_info_ns.pkm_info.hp = 177;
				else if (cur_p_info.pkm_info.pkm_type[1] && cur_p_info.pkm_info.stage[2])
					cur_p_info_ns.pkm_info.hp = 225;
				else if (cur_p_info.pkm_info.pkm_type[2] && cur_p_info.pkm_info.stage[0])
					cur_p_info_ns.pkm_info.hp = 125;
				else if (cur_p_info.pkm_info.pkm_type[2] && cur_p_info.pkm_info.stage[1])
					cur_p_info_ns.pkm_info.hp = 187;
				else if (cur_p_info.pkm_info.pkm_type[2] && cur_p_info.pkm_info.stage[2])
					cur_p_info_ns.pkm_info.hp = 245;
				else if (cur_p_info.pkm_info.pkm_type[3] && cur_p_info.pkm_info.stage[0])
					cur_p_info_ns.pkm_info.hp = 122;
				else if (cur_p_info.pkm_info.pkm_type[3] && cur_p_info.pkm_info.stage[1])
					cur_p_info_ns.pkm_info.hp = 182;
				else
					cur_p_info_ns.pkm_info.hp = 235;
			end
			else if (D_reg.d_item[0][2] && cur_p_info.bag_info.candy_num != 0)
			begin
				cur_p_info_ns.bag_info.candy_num = cur_p_info.bag_info.candy_num - 1;
				if (cur_p_info.pkm_info.pkm_type[0] && cur_p_info.pkm_info.stage[0] && cur_p_info.pkm_info.exp >= 17)
					cur_p_info_ns.pkm_info = ST_GR_MID;
				else if (cur_p_info.pkm_info.pkm_type[0] && cur_p_info.pkm_info.stage[1] && cur_p_info.pkm_info.exp >= 48)
					cur_p_info_ns.pkm_info = ST_GR_HIG;
				else if (cur_p_info.pkm_info.pkm_type[1] && cur_p_info.pkm_info.stage[0] && cur_p_info.pkm_info.exp >= 15)
					cur_p_info_ns.pkm_info = ST_FI_MID;
				else if (cur_p_info.pkm_info.pkm_type[1] && cur_p_info.pkm_info.stage[1] && cur_p_info.pkm_info.exp >= 44)
					cur_p_info_ns.pkm_info = ST_FI_HIG;
				else if (cur_p_info.pkm_info.pkm_type[2] && cur_p_info.pkm_info.stage[0] && cur_p_info.pkm_info.exp >= 13)
					cur_p_info_ns.pkm_info = ST_WA_MID;
				else if (cur_p_info.pkm_info.pkm_type[2] && cur_p_info.pkm_info.stage[1] && cur_p_info.pkm_info.exp >= 40)
					cur_p_info_ns.pkm_info = ST_WA_HIG;
				else if (cur_p_info.pkm_info.pkm_type[3] && cur_p_info.pkm_info.stage[0] && cur_p_info.pkm_info.exp >= 11)
					cur_p_info_ns.pkm_info = ST_EL_MID;
				else if (cur_p_info.pkm_info.pkm_type[3] && cur_p_info.pkm_info.stage[1] && cur_p_info.pkm_info.exp >= 36)
					cur_p_info_ns.pkm_info = ST_EL_HIG;
				else if (!cur_p_info.pkm_info.stage[2])
					cur_p_info_ns.pkm_info.exp = cur_p_info.pkm_info.exp + 15;
				
				if (!cur_p_info_ns.pkm_info.exp && !cur_p_info.pkm_info.stage[2])
					flag_bracer_ns = 0;
			end
			else if (D_reg.d_item[0][3] && cur_p_info.bag_info.bracer_num != 0)
			begin
				cur_p_info_ns.bag_info.bracer_num = cur_p_info.bag_info.bracer_num - 1;
				flag_bracer_ns = 1;
			end
			else
			begin
				err_msg_ns = Not_Having_Item;
			end
		end

		ATTACK:
		begin
			if (cur_p_info.pkm_info.pkm_type == No_type || opp_p_info.pkm_info.pkm_type == No_type)
			begin
				err_msg_ns = Not_Having_PKM;
				state_ns = OUT;
			end
			else if (cur_p_info.pkm_info.hp == 0 || opp_p_info.pkm_info.hp == 0)
			begin
				err_msg_ns = HP_is_Zero;
				state_ns = OUT;
			end
			else
			begin
				state_ns = WDRAM;
				case (cur_p_info.pkm_info.pkm_type)
					Grass:
					begin
						case (opp_p_info.pkm_info.pkm_type)
							Grass:
								opp_p_info_ns.pkm_info.hp = (opp_p_info.pkm_info.hp < cur_pkm_atk / 2) ? 0 : (opp_p_info.pkm_info.hp - cur_pkm_atk / 2);
							Fire:
								opp_p_info_ns.pkm_info.hp = (opp_p_info.pkm_info.hp < cur_pkm_atk / 2) ? 0 : (opp_p_info.pkm_info.hp - cur_pkm_atk / 2);
							Water:
								opp_p_info_ns.pkm_info.hp = (opp_p_info.pkm_info.hp < cur_pkm_atk * 2) ? 0 : (opp_p_info.pkm_info.hp - cur_pkm_atk * 2);
							Electric:
								opp_p_info_ns.pkm_info.hp = (opp_p_info.pkm_info.hp < cur_pkm_atk) ? 0 : (opp_p_info.pkm_info.hp - cur_pkm_atk);
						endcase
					end
					Fire:
					begin
						case (opp_p_info.pkm_info.pkm_type)
							Grass:
								opp_p_info_ns.pkm_info.hp = (opp_p_info.pkm_info.hp < cur_pkm_atk * 2) ? 0 : (opp_p_info.pkm_info.hp - cur_pkm_atk * 2);
							Fire:
								opp_p_info_ns.pkm_info.hp = (opp_p_info.pkm_info.hp < cur_pkm_atk / 2) ? 0 : (opp_p_info.pkm_info.hp - cur_pkm_atk / 2);
							Water:
								opp_p_info_ns.pkm_info.hp = (opp_p_info.pkm_info.hp < cur_pkm_atk / 2) ? 0 : (opp_p_info.pkm_info.hp - cur_pkm_atk / 2);
							Electric:
								opp_p_info_ns.pkm_info.hp = (opp_p_info.pkm_info.hp < cur_pkm_atk) ? 0 : (opp_p_info.pkm_info.hp - cur_pkm_atk);
						endcase
					end
					Water:
					begin
						case (opp_p_info.pkm_info.pkm_type)
							Grass:
								opp_p_info_ns.pkm_info.hp = (opp_p_info.pkm_info.hp < cur_pkm_atk / 2) ? 0 : (opp_p_info.pkm_info.hp - cur_pkm_atk / 2);
							Fire:
								opp_p_info_ns.pkm_info.hp = (opp_p_info.pkm_info.hp < cur_pkm_atk * 2) ? 0 : (opp_p_info.pkm_info.hp - cur_pkm_atk * 2);
							Water:
								opp_p_info_ns.pkm_info.hp = (opp_p_info.pkm_info.hp < cur_pkm_atk / 2) ? 0 : (opp_p_info.pkm_info.hp - cur_pkm_atk / 2);
							Electric:
								opp_p_info_ns.pkm_info.hp = (opp_p_info.pkm_info.hp < cur_pkm_atk) ? 0 : (opp_p_info.pkm_info.hp - cur_pkm_atk);
						endcase
					end
					Electric:
					begin
						case (opp_p_info.pkm_info.pkm_type)
							Grass:
								opp_p_info_ns.pkm_info.hp = (opp_p_info.pkm_info.hp < cur_pkm_atk / 2) ? 0 : (opp_p_info.pkm_info.hp - cur_pkm_atk / 2);
							Fire:
								opp_p_info_ns.pkm_info.hp = (opp_p_info.pkm_info.hp < cur_pkm_atk) ? 0 : (opp_p_info.pkm_info.hp - cur_pkm_atk);
							Water:
								opp_p_info_ns.pkm_info.hp = (opp_p_info.pkm_info.hp < cur_pkm_atk * 2) ? 0 : (opp_p_info.pkm_info.hp - cur_pkm_atk * 2);
							Electric:
								opp_p_info_ns.pkm_info.hp = (opp_p_info.pkm_info.hp < cur_pkm_atk / 2) ? 0 : (opp_p_info.pkm_info.hp - cur_pkm_atk / 2);
						endcase
					end
				endcase
				flag_bracer_ns = 0;
				
				if (opp_p_info.pkm_info.stage[0])
				begin
					if (cur_p_info.pkm_info.pkm_type[0] && cur_p_info.pkm_info.stage[0] && cur_p_info.pkm_info.exp >= 16)
						cur_p_info_ns.pkm_info = ST_GR_MID;
					else if (cur_p_info.pkm_info.pkm_type[0] && cur_p_info.pkm_info.stage[1] && cur_p_info.pkm_info.exp >= 47)
						cur_p_info_ns.pkm_info = ST_GR_HIG;
					else if (cur_p_info.pkm_info.pkm_type[1] && cur_p_info.pkm_info.stage[0] && cur_p_info.pkm_info.exp >= 14)
						cur_p_info_ns.pkm_info = ST_FI_MID;
					else if (cur_p_info.pkm_info.pkm_type[1] && cur_p_info.pkm_info.stage[1] && cur_p_info.pkm_info.exp >= 43)
						cur_p_info_ns.pkm_info = ST_FI_HIG;
					else if (cur_p_info.pkm_info.pkm_type[2] && cur_p_info.pkm_info.stage[0] && cur_p_info.pkm_info.exp >= 12)
						cur_p_info_ns.pkm_info = ST_WA_MID;
					else if (cur_p_info.pkm_info.pkm_type[2] && cur_p_info.pkm_info.stage[1] && cur_p_info.pkm_info.exp >= 39)
						cur_p_info_ns.pkm_info = ST_WA_HIG;
					else if (cur_p_info.pkm_info.pkm_type[3] && cur_p_info.pkm_info.stage[0] && cur_p_info.pkm_info.exp >= 10)
						cur_p_info_ns.pkm_info = ST_EL_MID;
					else if (cur_p_info.pkm_info.pkm_type[3] && cur_p_info.pkm_info.stage[1] && cur_p_info.pkm_info.exp >= 35)
						cur_p_info_ns.pkm_info = ST_EL_HIG;
					else if (!cur_p_info.pkm_info.stage[2])
						cur_p_info_ns.pkm_info.exp = cur_p_info.pkm_info.exp + 16;
				end
				else if (opp_p_info.pkm_info.stage[1])
				begin
					if (cur_p_info.pkm_info.pkm_type[0] && cur_p_info.pkm_info.stage[0] && cur_p_info.pkm_info.exp >= 8)
						cur_p_info_ns.pkm_info = ST_GR_MID;
					else if (cur_p_info.pkm_info.pkm_type[0] && cur_p_info.pkm_info.stage[1] && cur_p_info.pkm_info.exp >= 39)
						cur_p_info_ns.pkm_info = ST_GR_HIG;
					else if (cur_p_info.pkm_info.pkm_type[1] && cur_p_info.pkm_info.stage[0] && cur_p_info.pkm_info.exp >= 6)
						cur_p_info_ns.pkm_info = ST_FI_MID;
					else if (cur_p_info.pkm_info.pkm_type[1] && cur_p_info.pkm_info.stage[1] && cur_p_info.pkm_info.exp >= 35)
						cur_p_info_ns.pkm_info = ST_FI_HIG;
					else if (cur_p_info.pkm_info.pkm_type[2] && cur_p_info.pkm_info.stage[0] && cur_p_info.pkm_info.exp >= 4)
						cur_p_info_ns.pkm_info = ST_WA_MID;
					else if (cur_p_info.pkm_info.pkm_type[2] && cur_p_info.pkm_info.stage[1] && cur_p_info.pkm_info.exp >= 31)
						cur_p_info_ns.pkm_info = ST_WA_HIG;
					else if (cur_p_info.pkm_info.pkm_type[3] && cur_p_info.pkm_info.stage[0] && cur_p_info.pkm_info.exp >= 2)
						cur_p_info_ns.pkm_info = ST_EL_MID;
					else if (cur_p_info.pkm_info.pkm_type[3] && cur_p_info.pkm_info.stage[1] && cur_p_info.pkm_info.exp >= 27)
						cur_p_info_ns.pkm_info = ST_EL_HIG;
					else if (!cur_p_info.pkm_info.stage[2])
						cur_p_info_ns.pkm_info.exp = cur_p_info.pkm_info.exp + 24;
				end
				else if (opp_p_info.pkm_info.stage[2])
				begin
					if (cur_p_info.pkm_info.pkm_type[0] && cur_p_info.pkm_info.stage[0])
						cur_p_info_ns.pkm_info = ST_GR_MID;
					else if (cur_p_info.pkm_info.pkm_type[0] && cur_p_info.pkm_info.stage[1] && cur_p_info.pkm_info.exp >= 31)
						cur_p_info_ns.pkm_info = ST_GR_HIG;
					else if (cur_p_info.pkm_info.pkm_type[1] && cur_p_info.pkm_info.stage[0])
						cur_p_info_ns.pkm_info = ST_FI_MID;
					else if (cur_p_info.pkm_info.pkm_type[1] && cur_p_info.pkm_info.stage[1] && cur_p_info.pkm_info.exp >= 27)
						cur_p_info_ns.pkm_info = ST_FI_HIG;
					else if (cur_p_info.pkm_info.pkm_type[2] && cur_p_info.pkm_info.stage[0])
						cur_p_info_ns.pkm_info = ST_WA_MID;
					else if (cur_p_info.pkm_info.pkm_type[2] && cur_p_info.pkm_info.stage[1] && cur_p_info.pkm_info.exp >= 23)
						cur_p_info_ns.pkm_info = ST_WA_HIG;
					else if (cur_p_info.pkm_info.pkm_type[3] && cur_p_info.pkm_info.stage[0])
						cur_p_info_ns.pkm_info = ST_EL_MID;
					else if (cur_p_info.pkm_info.pkm_type[3] && cur_p_info.pkm_info.stage[1] && cur_p_info.pkm_info.exp >= 19)
						cur_p_info_ns.pkm_info = ST_EL_HIG;
					else if (!cur_p_info.pkm_info.stage[2])
						cur_p_info_ns.pkm_info.exp = cur_p_info.pkm_info.exp + 32;
				end
				
				if (cur_p_info.pkm_info.stage[0])
				begin
					if (opp_p_info.pkm_info.pkm_type[0] && opp_p_info.pkm_info.stage[0] && opp_p_info.pkm_info.exp >= 24)
						opp_p_info_ns.pkm_info = ST_GR_MID;
					else if (opp_p_info.pkm_info.pkm_type[0] && opp_p_info.pkm_info.stage[1] && opp_p_info.pkm_info.exp >= 55)
						opp_p_info_ns.pkm_info = ST_GR_HIG;
					else if (opp_p_info.pkm_info.pkm_type[1] && opp_p_info.pkm_info.stage[0] && opp_p_info.pkm_info.exp >= 22)
						opp_p_info_ns.pkm_info = ST_FI_MID;
					else if (opp_p_info.pkm_info.pkm_type[1] && opp_p_info.pkm_info.stage[1] && opp_p_info.pkm_info.exp >= 51)
						opp_p_info_ns.pkm_info = ST_FI_HIG;
					else if (opp_p_info.pkm_info.pkm_type[2] && opp_p_info.pkm_info.stage[0] && opp_p_info.pkm_info.exp >= 20)
						opp_p_info_ns.pkm_info = ST_WA_MID;
					else if (opp_p_info.pkm_info.pkm_type[2] && opp_p_info.pkm_info.stage[1] && opp_p_info.pkm_info.exp >= 47)
						opp_p_info_ns.pkm_info = ST_WA_HIG;
					else if (opp_p_info.pkm_info.pkm_type[3] && opp_p_info.pkm_info.stage[0] && opp_p_info.pkm_info.exp >= 18)
						opp_p_info_ns.pkm_info = ST_EL_MID;
					else if (opp_p_info.pkm_info.pkm_type[3] && opp_p_info.pkm_info.stage[1] && opp_p_info.pkm_info.exp >= 43)
						opp_p_info_ns.pkm_info = ST_EL_HIG;
					else if (!opp_p_info.pkm_info.stage[2])
						opp_p_info_ns.pkm_info.exp = opp_p_info.pkm_info.exp + 8;
				end
				else if (cur_p_info.pkm_info.stage[1])
				begin
					if (opp_p_info.pkm_info.pkm_type[0] && opp_p_info.pkm_info.stage[0] && opp_p_info.pkm_info.exp >= 20)
						opp_p_info_ns.pkm_info = ST_GR_MID;
					else if (opp_p_info.pkm_info.pkm_type[0] && opp_p_info.pkm_info.stage[1] && opp_p_info.pkm_info.exp >= 51)
						opp_p_info_ns.pkm_info = ST_GR_HIG;
					else if (opp_p_info.pkm_info.pkm_type[1] && opp_p_info.pkm_info.stage[0] && opp_p_info.pkm_info.exp >= 18)
						opp_p_info_ns.pkm_info = ST_FI_MID;
					else if (opp_p_info.pkm_info.pkm_type[1] && opp_p_info.pkm_info.stage[1] && opp_p_info.pkm_info.exp >= 47)
						opp_p_info_ns.pkm_info = ST_FI_HIG;
					else if (opp_p_info.pkm_info.pkm_type[2] && opp_p_info.pkm_info.stage[0] && opp_p_info.pkm_info.exp >= 16)
						opp_p_info_ns.pkm_info = ST_WA_MID;
					else if (opp_p_info.pkm_info.pkm_type[2] && opp_p_info.pkm_info.stage[1] && opp_p_info.pkm_info.exp >= 43)
						opp_p_info_ns.pkm_info = ST_WA_HIG;
					else if (opp_p_info.pkm_info.pkm_type[3] && opp_p_info.pkm_info.stage[0] && opp_p_info.pkm_info.exp >= 14)
						opp_p_info_ns.pkm_info = ST_EL_MID;
					else if (opp_p_info.pkm_info.pkm_type[3] && opp_p_info.pkm_info.stage[1] && opp_p_info.pkm_info.exp >= 39)
						opp_p_info_ns.pkm_info = ST_EL_HIG;
					else if (!opp_p_info.pkm_info.stage[2])
						opp_p_info_ns.pkm_info.exp = opp_p_info.pkm_info.exp + 12;
				end
				else if (cur_p_info.pkm_info.stage[2])
				begin
					if (opp_p_info.pkm_info.pkm_type[0] && opp_p_info.pkm_info.stage[0] && opp_p_info.pkm_info.exp >= 16)
						opp_p_info_ns.pkm_info = ST_GR_MID;
					else if (opp_p_info.pkm_info.pkm_type[0] && opp_p_info.pkm_info.stage[1] && opp_p_info.pkm_info.exp >= 47)
						opp_p_info_ns.pkm_info = ST_GR_HIG;
					else if (opp_p_info.pkm_info.pkm_type[1] && opp_p_info.pkm_info.stage[0] && opp_p_info.pkm_info.exp >= 14)
						opp_p_info_ns.pkm_info = ST_FI_MID;
					else if (opp_p_info.pkm_info.pkm_type[1] && opp_p_info.pkm_info.stage[1] && opp_p_info.pkm_info.exp >= 43)
						opp_p_info_ns.pkm_info = ST_FI_HIG;
					else if (opp_p_info.pkm_info.pkm_type[2] && opp_p_info.pkm_info.stage[0] && opp_p_info.pkm_info.exp >= 12)
						opp_p_info_ns.pkm_info = ST_WA_MID;
					else if (opp_p_info.pkm_info.pkm_type[2] && opp_p_info.pkm_info.stage[1] && opp_p_info.pkm_info.exp >= 39)
						opp_p_info_ns.pkm_info = ST_WA_HIG;
					else if (opp_p_info.pkm_info.pkm_type[3] && opp_p_info.pkm_info.stage[0] && opp_p_info.pkm_info.exp >= 10)
						opp_p_info_ns.pkm_info = ST_EL_MID;
					else if (opp_p_info.pkm_info.pkm_type[3] && opp_p_info.pkm_info.stage[1] && opp_p_info.pkm_info.exp >= 35)
						opp_p_info_ns.pkm_info = ST_EL_HIG;
					else if (!opp_p_info.pkm_info.stage[2])
						opp_p_info_ns.pkm_info.exp = opp_p_info.pkm_info.exp + 16;
				end
			end
		end
		
		OUT:
		begin
			inf.out_valid = 1;
			state_ns = IN;
			err_msg_ns = No_Err;
			opp_id_ns = 0;
			flag_buy_mon_ns = 0;
			cur_act_ns = No_action;
			if (inf.err_msg != 0)
			begin
				inf.out_info = 0;
			end
			else if (cur_act == Attack)
			begin
				inf.complete = 1;
				inf.out_info = {cur_p_info.pkm_info, opp_p_info.pkm_info};
			end
			else if (cur_act == Sell)
			begin
				inf.complete = 1;
				inf.out_info = cur_p_info + flag_bracer * 8192;
				flag_bracer_ns = 0;
				cur_p_info_ns.pkm_info = 0;
			end
			else
			begin
				inf.complete = 1;
				inf.out_info = cur_p_info + flag_bracer * 8192;
			end
		end
		
	endcase
end

always_ff@(posedge clk or negedge inf.rst_n)
begin
	if (!inf.rst_n)
	begin
		inf.err_msg <= No_Err;
		cur_id <= 0;
		next_id <= 0;
		opp_id <= 0;
		cur_p_info <= 0;
		opp_p_info <= 0;
		flag_change_id <= 0;
		flag_first_id <= 1;
		flag_buy_mon <= 0;
		flag_bracer <= 0;
		cur_act <= No_action;
		state <= IN;
		D_reg <= 0;
		flag_C_invalid <= 1;
	end
	else
	begin
		inf.err_msg <= err_msg_ns;
		cur_id <= cur_id_ns;
		next_id <= next_id_ns;
		opp_id <= opp_id_ns;
		cur_p_info <= cur_p_info_ns;
		opp_p_info <= opp_p_info_ns;
		flag_change_id <= flag_change_id_ns;
		flag_first_id <= flag_first_id_ns;
		flag_buy_mon <= flag_buy_mon_ns;
		flag_bracer <= flag_bracer_ns;
		cur_act <= cur_act_ns;
		state <= state_ns;
		D_reg <= D_reg_ns;
		flag_C_invalid <= flag_C_invalid_ns;
	end
end

endmodule
