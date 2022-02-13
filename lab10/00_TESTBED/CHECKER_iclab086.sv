//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//
//   File Name   : CHECKER.sv
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module Checker(input clk, INF.CHECKER inf);
import usertype::*;

covergroup Spec1 @(negedge clk iff inf.out_valid);
	option.per_instance = 1;
	option.at_least = 20;
	coverpoint inf.out_info[31:28]
	{
		bins b1 = {No_stage};
		bins b2 = {Lowest};
		bins b3 = {Middle};
		bins b4 = {Highest};
	}
	coverpoint inf.out_info[27:24]
	{
		bins b1 = {No_type};
		bins b2 = {Grass};
		bins b3 = {Fire};
		bins b4 = {Water};
		bins b5 = {Electric};
	}
endgroup

covergroup Spec2 @(posedge clk iff inf.id_valid);
	option.per_instance = 1;
	option.at_least = 1;
	coverpoint inf.D.d_id[0]
	{
		option.auto_bin_max = 256;
	}
endgroup

covergroup Spec3 @(posedge clk iff inf.act_valid);
	option.per_instance = 1;
	option.at_least = 5;
	coverpoint inf.D.d_act[0]
	{
		bins t1[] = (Buy, Sell, Deposit, Check, Use_item, Attack => Buy, Sell, Deposit, Check, Use_item, Attack);
	}
endgroup

covergroup Spec4 @(negedge clk iff inf.out_valid);
	option.per_instance = 1;
	coverpoint inf.complete
	{
		option.at_least = 200;
	}
endgroup

covergroup Spec5 @(negedge clk iff inf.out_valid);
	option.per_instance = 1;
	option.at_least = 20;
	coverpoint inf.err_msg
	{
		bins b1 = {Already_Have_PKM};
		bins b2 = {Out_of_money};
		bins b3 = {Bag_is_full};
		bins b4 = {Not_Having_PKM};
		bins b5 = {Has_Not_Grown};
		bins b6 = {Not_Having_Item};
		bins b7 = {HP_is_Zero};
	}
endgroup

//declare other cover group



//declare the cover group 
Spec1 cov_inst_1 = new();
Spec2 cov_inst_2 = new();
Spec3 cov_inst_3 = new();
Spec4 cov_inst_4 = new();
Spec5 cov_inst_5 = new();


//************************************ below assertion is to check your pattern ***************************************** 
//                                          Please finish and hand in it
// This is an example assertion given by TA, please write the required assertions below
//  assert_interval : assert property ( @(posedge clk)  inf.out_valid |=> inf.id_valid == 0 [*2])
//  else
//  begin
//  	$display("Assertion X is violated");
//  	$fatal; 
//  end

//write other assertions

// Spec1
always @(negedge inf.rst_n) begin
	#1;
	assert ((inf.out_valid===0)&&(inf.err_msg==No_Err)&&(inf.complete===0)&&(inf.out_info===0))
	else begin
		$display("Assertion 1 is violated");
		$fatal; 
	end
end

// Spec2
assert property ( @(posedge clk) (inf.complete===1 && inf.out_valid === 1) |-> (inf.err_msg===No_Err) )
else
begin
	$display("Assertion 2 is violated");
	$fatal; 
end

// Spec3
assert property ( @(posedge clk) (inf.complete===0 && inf.out_valid === 1) |-> (inf.out_info===0) )
else
begin
	$display("Assertion 3 is violated");
	$fatal; 
end

Action cur_act;

always_comb
begin
	if (!inf.rst_n)
		cur_act = No_action;
	else if (inf.act_valid)
		cur_act = inf.D.d_act[0];
	else if (inf.out_valid)
		cur_act = No_action;
end


// Spec4
assert property ( @(posedge clk) (cur_act === No_action && inf.id_valid) |-> ##[2:6] (inf.act_valid) )
else
begin
	$display("Assertion 4 is violated");
	$fatal; 
end
assert property ( @(posedge clk) ((cur_act == Buy) && inf.act_valid) |-> ##[2:6] (inf.type_valid || inf.item_valid) )
else
begin
	$display("Assertion 4 is violated");
	$fatal; 
end
assert property ( @(posedge clk) ((cur_act == Deposit) && inf.act_valid) |-> ##[2:6] (inf.amnt_valid) )
else
begin
	$display("Assertion 4 is violated");
	$fatal; 
end
assert property ( @(posedge clk) ((cur_act == Use_item) && inf.act_valid) |-> ##[2:6] (inf.item_valid) )
else
begin
	$display("Assertion 4 is violated");
	$fatal; 
end
assert property ( @(posedge clk) ((cur_act == Attack) && inf.act_valid) |-> ##[2:6] (inf.id_valid) )
else
begin
	$display("Assertion 4 is violated");
	$fatal; 
end

//Spec5
assert property ( @(posedge clk) !((inf.id_valid && inf.act_valid) || (inf.id_valid && inf.item_valid) || (inf.id_valid && inf.type_valid) || (inf.id_valid && inf.amnt_valid) || (inf.act_valid && inf.item_valid) || (inf.act_valid && inf.type_valid) || (inf.act_valid && inf.amnt_valid) || (inf.item_valid && inf.type_valid) || (inf.item_valid && inf.amnt_valid) || (inf.type_valid && inf.amnt_valid)) )
else
begin
	$display("Assertion 5 is violated");
	$fatal; 
end
// Spec6
assert property ( @(posedge clk)  (inf.out_valid===1) |-> ##1 (inf.out_valid===0) )
else
begin
	$display("Assertion 6 is violated");
	$fatal; 
end

logic flag_out_valid;

always @ (posedge clk or negedge inf.rst_n)
begin
	if (!inf.rst_n)
	begin
		flag_out_valid = 0;
	end
	else if (inf.act_valid === 1 || inf.id_valid === 1)
	begin
		flag_out_valid = 0;
	end
	else if (inf.out_valid === 1)
	begin
		flag_out_valid = 1;
	end
end
// Spec7
assert property ( @(posedge clk) (inf.out_valid==1) |-> ##[2:10] ( (flag_out_valid == 1 && inf.id_valid===1) || (flag_out_valid === 1 && inf.act_valid===1)) )  
else begin
	$display("Assertion 7 is violated");
	$fatal; 
end
// Spec8
assert property ( @(posedge clk) ((cur_act == Buy) && (inf.type_valid||inf.item_valid)) |-> ##[1:1200] (inf.out_valid) )
else
begin
	// $fatal(0, "Assertion 8 is violated"); 
	$display("Assertion 8 is violated");
	$fatal; 
end
assert property ( @(posedge clk) ((cur_act == Deposit) && inf.amnt_valid) |-> ##[1:1200] (inf.out_valid) )
else
begin
	// $fatal(0, "Assertion 8 is violated"); 
	$display("Assertion 8 is violated");
	$fatal; 
end
assert property ( @(posedge clk) ((cur_act == Use_item) && inf.item_valid) |-> ##[1:1200] (inf.out_valid) )
else
begin
	// $fatal(0, "Assertion 8 is violated"); 
	$display("Assertion 8 is violated");
	$fatal; 
end
assert property ( @(posedge clk) ((cur_act == Attack) && inf.id_valid) |-> ##[1:1200] (inf.out_valid) )
else
begin
	// $fatal(0, "Assertion 8 is violated"); 
	$display("Assertion 8 is violated");
	$fatal; 
end
assert property ( @(posedge clk) ((cur_act == Check) && inf.act_valid) |-> ##[1:1200] (inf.out_valid) )
else
begin
	// $fatal(0, "Assertion 8 is violated"); 
	$display("Assertion 8 is violated");
	$fatal; 
end
assert property ( @(posedge clk) ((cur_act == Sell) && inf.act_valid) |-> ##[1:1200] (inf.out_valid) )
else
begin
	// $fatal(0, "Assertion 8 is violated"); 
	$display("Assertion 8 is violated");
	$fatal; 
end

endmodule
