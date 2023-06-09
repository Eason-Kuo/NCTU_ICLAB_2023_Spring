//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//
//   File Name   : CHECKER.sv
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
//`include "Usertype_PKG.sv"

module Checker(input clk, INF.CHECKER inf);
import usertype::*;

//covergroup Spec1 @();
//	
//       finish your covergroup here
//	
//	
//endgroup

//declare other cover group

//declare the cover group 
//Spec1 cov_inst_1 = new();


//SPEC1 money, at least 10 times
covergroup Spec1@(posedge clk iff inf.amnt_valid);
    coverpoint inf.D.d_money{
        bins money_range1 = {[16'd0     : 16'd12000]};
        bins money_range2 = {[16'd12001 : 16'd24000]};
        bins money_range3 = {[16'd24001 : 16'd36000]};
        bins money_range4 = {[16'd36001 : 16'd48000]};
        bins money_range5 = {[16'd48001 : 16'd60000]};
        option.at_least = 10;
    }
endgroup: Spec1 

//SPEC2 id=0~255 at least 2 times
covergroup Spec2 @(posedge clk iff inf.id_valid);
    coverpoint inf.D.d_id[0]{
        option.auto_bin_max = 256;
        option.at_least = 2;
    }
endgroup: Spec2

//SPEC3 action_transition , at least 10 times
covergroup Spec3 @(posedge clk iff inf.act_valid);
   	coverpoint inf.D.d_act[0] {
		bins action_transition[] = (Buy, Check, Deposit, Return => Buy, Check, Deposit, Return);
   		option.at_least = 10;
   	}
endgroup: Spec3

//SPEC4 item_id = small, Medium, Large. at least 20 times
covergroup Spec4@(posedge clk iff inf.item_valid);
    coverpoint inf.D.d_item[0]{
        bins item[] = {Large, Medium, Small};
        option.at_least = 20;
    }
endgroup: Spec4

//SPEC5 all error message except No_Err. at least 20 times 
covergroup Spec5 @(negedge clk iff inf.out_valid);
   	coverpoint inf.err_msg {
		bins err[] = {INV_Not_Enough, Out_of_money, INV_Full, Wallet_is_Full, Wrong_ID, Wrong_Num, Wrong_Item, Wrong_act};
   		option.at_least = 20;	
   	}
endgroup: Spec5

//SPEC6 complete. at least 200 times
covergroup Spec6 @(negedge clk iff inf.out_valid);
   	coverpoint inf.complete {
		bins zero = {0};
		bins one  = {1};
   		option.at_least = 200;
   	}
endgroup: Spec6

Spec1 cov_inst_1 = new();
Spec2 cov_inst_2 = new();
Spec3 cov_inst_3 = new();
Spec4 cov_inst_4 = new();
Spec5 cov_inst_5 = new();
Spec6 cov_inst_6 = new();
//************************************ below assertion is to check your pattern ***************************************** 
//                                          Please finish and hand in it
// This is an example assertion given by TA, please write other assertions at the below
// assert_interval : assert property ( @(posedge clk)  inf.out_valid |=> inf.id_valid == 0)
// else
// begin
// 	$display("Assertion X is violated");
// 	$fatal; 
// end
wire #(0.5) rst_reg = inf.rst_n;
logic   [3:0] total_valids;
logic   check_flag; //1 for stocks 
logic   [6:0]cnt_exceed_five;

Action act;

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        act <= No_action;
    end
    else if (inf.act_valid) begin
        act <= inf.D.d_act[0];
    end
    else if (inf.out_valid) begin
        act <= No_action;
    end
end

always_comb begin
	total_valids = inf.id_valid + inf.act_valid + inf.item_valid + inf.num_valid + inf.amnt_valid;
end

always_ff @(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)begin
        check_flag <= 0;
    end
    else begin
        if(act == Check && cnt_exceed_five <= 5  && inf.id_valid)   check_flag <= 1; //1 for stocks
        else if(act != Check)                                       check_flag <= 0; //0 for money
    end
end

always_ff @(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)          cnt_exceed_five <= 0;
    else begin
        if(act == Check)    cnt_exceed_five <= cnt_exceed_five + 1 ;
        else                cnt_exceed_five <= 0;
    end
end



//==================================================================
// Assertion 1 ( All outputs signals (including FD.sv and bridge.sv) should be zero after reset.)
always @(negedge rst_reg) begin
	#1;
	assert_1 : assert (
		(inf.out_valid    === 0) && (inf.err_msg      === 0) &&
		(inf.complete     === 0) && (inf.out_info     === 0) &&

		(inf.C_addr       === 0) && (inf.C_data_w     === 0) &&
		(inf.C_in_valid   === 0) && (inf.C_r_wb       === 0) &&
		(inf.C_out_valid  === 0) && (inf.C_data_r     === 0) &&
		(inf.AR_VALID     === 0) && (inf.AR_ADDR      === 0) &&
		(inf.R_READY      === 0) && (inf.AW_VALID     === 0) &&
		(inf.AW_ADDR      === 0) && (inf.W_VALID      === 0) &&
		(inf.W_DATA       === 0) && (inf.B_READY      === 0)
	)
	else begin 
        $display("Assertion 1 is violated"); 
        $fatal; 
    end
end

//==================================================================
// Assertion 2 If action is completed, err_msg should be 4’b0.
assert_2 : assert property (@(negedge clk)  ((inf.complete === 1) && (inf.out_valid === 1)) |-> (inf.err_msg === 0) )
else begin
    $display("Assertion 2 is violated");
    $fatal;
end

//==================================================================
// Assertion 3 If action is not completed, out_info should be 64’b0
assert_3 : assert property ( @(negedge clk) ( (inf.complete === 0) && (inf.out_valid === 1 )) |-> (inf.out_info === 0) )
else begin 
    $display("Assertion 3 is violated"); 
    $fatal; 
end

//==================================================================
// Assertion 4 All input valid can only be high for exactly one cycle
assert_4_1 : assert property (@(negedge clk) ((inf.id_valid === 1) |-> (##1(inf.id_valid === 0))))
else begin 
    $display("Assertion 4 is violated"); 
    $fatal; 
end
assert_4_2 : assert property (@(negedge clk) ((inf.act_valid === 1) |-> (##1(inf.act_valid === 0))))
else begin 
    $display("Assertion 4 is violated"); 
    $fatal; 
end
assert_4_3 : assert property (@(negedge clk) ((inf.item_valid === 1) |-> (##1(inf.item_valid === 0))))
else begin 
    $display("Assertion 4 is violated"); 
    $fatal; 
end
assert_4_4 : assert property (@(negedge clk) ((inf.num_valid === 1) |-> (##1(inf.num_valid === 0))))
else begin 
    $display("Assertion 4 is violated"); 
    $fatal; 
end
assert_4_5 : assert property (@(negedge clk) ((inf.amnt_valid === 1) |-> (##1(inf.amnt_valid === 0))))
else begin 
    $display("Assertion 4 is violated"); 
    $fatal; 
end





//==================================================================
// Assertion 5 All input valid signals won’t overlap with each other.
assert_5_1 : assert property (@(posedge clk) (total_valids < 2 ))
else begin
 	$display("Assertion 5 is violated");
 	$fatal; 
end


//==================================================================
// Assertion 6 The gap between each input valid is at least 1 cycle and at most 5 cycles.
assert_6_1 : assert property ( @(negedge clk) (((act == No_action) && (inf.id_valid === 1) ) |-> (##[2:6] (inf.act_valid === 1))))
else begin 
    $display("Assertion 6 is violated"); 
    $fatal; 
end

assert_6_2 : assert property ( @(negedge clk) (((act == No_action) && (inf.id_valid === 1) ) |-> (##1 (inf.act_valid === 0))))
else begin 
    $display("Assertion 6 is violated"); 
    $fatal; 
end

assert_6_3 : assert property ( @(negedge clk) ( ((inf.act_valid === 1) && ((act == Buy) || (act == Return)))  |-> (##[2:6] (inf.item_valid === 1))))
else begin 
    $display("Assertion 6 is violated"); 
    $fatal; 
end

assert_6_4 : assert property ( @(negedge clk) ( ((inf.act_valid === 1) && ((act == Buy) || (act == Return)) ) |-> (##1 (inf.item_valid === 0))))
else begin 
    $display("Assertion 6 is violated"); 
    $fatal; 
end

assert_6_5 : assert property (@(negedge clk) (inf.item_valid === 1) |-> (##[2:6] (inf.num_valid === 1 ))) 
else begin 
    $display("Assertion 6 is violated"); 
    $fatal; 
end

assert_6_6 : assert property (@(negedge clk) (inf.item_valid === 1) |-> (##1 (inf.num_valid === 0))) 
else begin 
    $display("Assertion 6 is violated"); 
    $fatal; 
end

assert_6_7 : assert property (@(negedge clk) ((inf.num_valid === 1) |->  (##[2:6] (inf.id_valid === 1)) ))
else begin 
    $display("Assertion 6 is violated"); 
    $fatal; 
end

assert_6_8 : assert property (@(negedge clk) ((inf.num_valid === 1) |->  (##1 (inf.id_valid === 0)) )) 
else begin 
    $display("Assertion 6 is violated"); 
    $fatal; 
end

aasert_6_9 : assert property (@(negedge clk) ((act == Deposit) && (inf.act_valid))   |->  (##[2:6] (inf.amnt_valid === 1)))
else begin 
    $display("Assertion 6 is violated"); 
    $fatal; 
end

aasert_6_10 : assert property (@(negedge clk) ((act == Deposit) && (inf.act_valid))   |->  (##1 (inf.amnt_valid === 0)))
else begin 
    $display("Assertion 6 is violated"); 
    $fatal; 
end

aasert_6_11 : assert property (@(negedge clk) ((act == Check) && (inf.act_valid === 1))   |->  (##1 (inf.id_valid === 0)))
else begin 
    $display("Assertion 6 is violated"); 
    $fatal; 
end

assert_6_12 : assert property (@(negedge clk)  (act == Check) && (inf.act_valid === 1) |-> ##[1:6] ((inf.amnt_valid === 0) && (inf.act_valid === 0) && (inf.num_valid === 0) && (inf.item_valid === 0)) )
else begin 
    $display("Assertion 6 is violated"); 
    $fatal; 
end
// ====== WRITE HERE=========//
assert_6_13 : assert property (@(negedge  clk)  (act == Check) && (inf.act_valid === 1) |-> ##8 (inf.id_valid === 0))
else begin 
    $display("Assertion 6 is violated"); 
    $fatal; 
end
// ====== WRITE HERE=========//



//==================================================================
// Assertion 7 Out_valid will be high for one cycle
assert_7_1 : assert property(@(negedge clk) ((inf.out_valid === 1) |->  ##1 (inf.out_valid === 0)))
else begin
 	$display("Assertion 7 is violated");
 	$fatal; 
end

//==================================================================
// Assertion 8 Next operation will be valid 2-10 cycles after out_valid fall
assert_8_1 :assert property ( @(posedge clk) (inf.out_valid === 1)  |-> ##[2:10] ((inf.act_valid === 1) || (inf.id_valid === 1)) )  
else begin
 	$display("Assertion 8 is violated");
 	$fatal; 
end

assert8_2 : assert property ( @(posedge clk)  (inf.out_valid === 1) |-> ##1  ((inf.act_valid === 0) && (inf.id_valid === 0 )) )
else begin
    $display("Assertion 8 is violated");
    $fatal; 
end


//==================================================================
//Assertion 9 Latency less than 10000 cycle
assert_9_1 : assert property ( @(negedge clk) (check_flag == 1)   |-> (##[1:10000] (inf.out_valid === 1)) )
else begin
    $display("Assertion 9 is violated");
    $fatal; 
end

assert_9_2 : assert property ( @(negedge clk) ((check_flag == 0) && (act == Check) && (inf.act_valid === 1) )  |-> ##[1:10000] (inf.out_valid === 1) )
else begin
    $display("Assertion 9 is violated");
    $fatal; 
end

assert_9_3 : assert property ( @(negedge clk) ((act == Deposit) && (inf.amnt_valid === 1)) |-> ##[1:10000] (inf.out_valid === 1) )
else begin
    $display("Assertion 9 is violated");
    $fatal; 
end

assert_9_4 : assert property ( @(negedge clk) ((act == Buy) && (inf.id_valid === 1)) |-> ##[1:10000] (inf.out_valid === 1) )
else begin
    $display("Assertion 9 is violated");
    $fatal; 
end

assert_9_5 : assert property ( @(negedge clk) ((act == Return) && (inf.id_valid === 1)) |-> ##[1:10000] (inf.out_valid === 1) )
else begin
    $display("Assertion 9 is violated");
    $fatal; 
end




endmodule
