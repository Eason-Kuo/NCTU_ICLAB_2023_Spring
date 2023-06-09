`include "../00_TESTBED/pseudo_DRAM.sv"
`include "Usertype_OS.sv"

program automatic PATTERN(input clk, INF.PATTERN inf);
import usertype::*;


`define CYCLE_TIME 1
//always #(CYCLE/2.0) clk = ~clk;
//================================================================
// parameters & integer
//================================================================
integer cycles, total_cycles;
integer i ,j;
parameter patnum = 437;
integer patcnt,delay;



parameter DRAM_p_r = "../00_TESTBED/DRAM/dram.dat";
parameter BASE_Addr = 65536;
parameter BASE_Addr_d_man = 65540;
parameter BASE_Last_resid = 65536 + 255*8;
//================================================================
// wire & registers 
//================================================================
logic [7:0] golden_DRAM[(BASE_Addr+0):((BASE_Last_resid+256*8)-1)];
Error_Msg golden_err_msg;
logic     golden_complete;
logic     [31:0]golden_out_info;

reg		[10*8:1] txt_blue_prefix   = "\033[1;34m";
reg		[10*8:1] bkg_green_prefix  = "\033[42;1m";
reg     [10*8:1] txt_green_prefix  = "\033[1;32m";
reg		[9*8:1]  reset_color       = "\033[1;0m";

reg 	[7:0]temp_id1, temp_id2 ;
reg 	[15:0]temp_money1, temp_money2;

//================================================================
// initial
//================================================================
initial begin

	$readmemh(DRAM_p_r, golden_DRAM);
	inf.rst_n = 1'b1 ;
	inf.id_valid   = 1'b0 ;
	inf.act_valid  = 1'b0 ;
	inf.item_valid = 1'b0 ;
	inf.num_valid  = 1'b0 ;
	inf.amnt_valid = 1'b0 ;
	inf.D = 'bx;
	reset_task;
	
    j=0;
	cycles = 0;
	total_cycles = 0;
	temp_id1 = 0;
	temp_id2 = 1;
	temp_money1 = 0;
    temp_money2 = 0;

	golden_complete = 0;
	golden_out_info = 0;
	golden_err_msg = No_Err;

	patcnt = 0;

    repeat(5) @(negedge clk);
	for(j = 0 ; j < 20 ; j = j + 1)begin
		temp_id1 = j;
        temp_id2 = j + 20;
        temp_money1 = 16'd60000;
        temp_money2 = 16'd0;

        deposit_task1;
        check_golden_answer;
        $display("%0sPASS PATTERN %0sNO.%4d%0s",txt_blue_prefix, txt_green_prefix ,patcnt, reset_color);
        patcnt = patcnt + 1;
        repeat(2) @(negedge clk);

       
        deposit_task2;
        check_golden_answer;
        $display("%0sPASS PATTERN %0sNO.%4d%0s",txt_blue_prefix, txt_green_prefix, patcnt, reset_color);
        patcnt = patcnt + 1;
        repeat(2) @(negedge clk);


        return_task1;
        check_golden_answer;
        $display("%0sPASS PATTERN %0sNO.%4d%0s",txt_blue_prefix, txt_green_prefix, patcnt, reset_color);
        patcnt = patcnt + 1;
        repeat(2) @(negedge clk);

        buy_task1;
        check_golden_answer;
        $display("%0sPASS PATTERN %0sNO.%4d%0s",txt_blue_prefix, txt_green_prefix, patcnt, reset_color);
        patcnt = patcnt + 1;
        repeat(2) @(negedge clk);
	end
	
    for(j = 40; j < 60 ; j = j + 1) begin
		temp_id1 = j;
		temp_id2 = j + 20;
        temp_money1 = 16'd12001;
        temp_money2 = 16'd24001;
        
        deposit_task1;
        check_golden_answer;
        $display("%0sPASS PATTERN %0sNO.%4d%0s",txt_blue_prefix, txt_green_prefix ,patcnt, reset_color);
        patcnt = patcnt + 1;
        repeat(2) @(negedge clk);

        deposit_task2;
        check_golden_answer;
        $display("%0sPASS PATTERN %0sNO.%4d%0s",txt_blue_prefix, txt_green_prefix ,patcnt, reset_color);
        patcnt = patcnt + 1;
        repeat(2) @(negedge clk);

        buy_task1;
        check_golden_answer;
        $display("%0sPASS PATTERN %0sNO.%4d%0s",txt_blue_prefix, txt_green_prefix, patcnt, reset_color);
        patcnt = patcnt + 1;
        repeat(2) @(negedge clk);

        return_task1;
        check_golden_answer;
        $display("%0sPASS PATTERN %0sNO.%4d%0s",txt_blue_prefix, txt_green_prefix, patcnt, reset_color);
        patcnt = patcnt + 1;
        repeat(2) @(negedge clk);
    end
	
	for( j = 80; j < 100 ; j = j + 1)begin
        temp_id1 = j;
		temp_id2 = j + 20;
        temp_money1 = 16'd0;
        temp_money2 = 16'd36001;

        deposit_task1;
        check_golden_answer;
        $display("%0sPASS PATTERN %0sNO.%4d%0s",txt_blue_prefix, txt_green_prefix ,patcnt, reset_color);
        patcnt = patcnt + 1;
        repeat(2) @(negedge clk);

        deposit_task2;
        check_golden_answer;
        $display("%0sPASS PATTERN %0sNO.%4d%0s",txt_blue_prefix, txt_green_prefix ,patcnt, reset_color);
        patcnt = patcnt + 1;
        repeat(2) @(negedge clk);

        buy_task1;
        check_golden_answer;
        $display("%0sPASS PATTERN %0sNO.%4d%0s",txt_blue_prefix, txt_green_prefix, patcnt, reset_color);
        patcnt = patcnt + 1;
        repeat(2) @(negedge clk);

        check_task;
        check_golden_answer;
        $display("%0sPASS PATTERN %0sNO.%4d%0s",txt_blue_prefix, txt_green_prefix, patcnt, reset_color);
        patcnt = patcnt + 1;
        repeat(2) @(negedge clk);
    end
	/////////////////////////////////////////
	for( j = 120; j < 130 ; j = j + 1 )begin 
        temp_id1 = j;
		temp_id2 = j + 10;

        buy_task1;
        check_golden_answer;
        $display("%0sPASS PATTERN %0sNO.%4d%0s",txt_blue_prefix, txt_green_prefix, patcnt, reset_color);
        patcnt = patcnt + 1;
        repeat(2) @(negedge clk);
    end

    for( j = 120; j < 130 ; j= j+1) begin  //wrong ID
        temp_id1 = j;
        case (j)
            'd120 : temp_id2 = 139;
            'd121 : temp_id2 = 138;
            'd122 : temp_id2 = 137;
            'd123 : temp_id2 = 136;
            'd124 : temp_id2 = 135;
            'd125 : temp_id2 = 134;
            'd126 : temp_id2 = 133;
            'd127 : temp_id2 = 132; 
            'd128 : temp_id2 = 131;
            'd128 : temp_id2 = 130;
        endcase

        return_task1;
        check_golden_answer;
        $display("%0sPASS PATTERN %0sNO.%4d%0s",txt_blue_prefix, txt_green_prefix, patcnt, reset_color);
        patcnt = patcnt + 1;
        repeat(2) @(negedge clk);
    
    end
    /////////////////////////////////////////
    for(j = 140; j < 150; j=j+1) begin
        temp_id1 = j;
        temp_id2 = j + 10;

        buy_task1;
        check_golden_answer;
        $display("%0sPASS PATTERN %0sNO.%4d%0s",txt_blue_prefix, txt_green_prefix, patcnt, reset_color);
        patcnt = patcnt + 1;
        repeat(2) @(negedge clk);


    end

    for(j = 140 ; j < 150; j=j+1)begin

        temp_id1 = j;
        temp_id2 = j + 10;
     
        return_task1;
        check_golden_answer;
        $display("%0sPASS PATTERN %0sNO.%4d%0s",txt_blue_prefix, txt_green_prefix, patcnt, reset_color);
        patcnt = patcnt + 1;
        repeat(2) @(negedge clk);
    
    
    end
    /////////////////////////////////////////   
    for(j = 160; j < 170; j=j+1)begin
        temp_id1 = j;
        temp_id2 = j + 10;

        buy_task1;
        check_golden_answer;
        $display("%0sPASS PATTERN %0sNO.%4d%0s",txt_blue_prefix, txt_green_prefix, patcnt, reset_color);
        patcnt = patcnt + 1;
        repeat(2) @(negedge clk);
    
    end

    for(j = 160; j < 170 ; j=j+1)begin
        temp_id1 = j;
        temp_id2 = j + 10;

        return_task1;
        check_golden_answer;
        $display("%0sPASS PATTERN %0sNO.%4d%0s",txt_blue_prefix, txt_green_prefix, patcnt, reset_color);
        patcnt = patcnt + 1;
        repeat(2) @(negedge clk);

        check_task;
        check_golden_answer;
        $display("%0sPASS PATTERN %0sNO.%4d%0s",txt_blue_prefix, txt_green_prefix, patcnt, reset_color);
        patcnt = patcnt + 1;
        repeat(2) @(negedge clk);

    end
    ///////////////////////////////////////// 
    for(j = 180; j < 190 ; j=j+1)begin
        temp_id1 = j;
        temp_money1 = 16'd65535;
        case(j)
            'd180 : temp_id2 = 189 ;
            'd181 : temp_id2 = 188 ;
            'd182 : temp_id2 = 187 ;
            'd183 : temp_id2 = 186 ;
            'd184 : temp_id2 = 185 ;
            'd185 : temp_id2 = 184 ;
            'd186 : temp_id2 = 183 ;
            'd187 : temp_id2 = 182 ;
            'd188 : temp_id2 = 181 ;
            'd189 : temp_id2 = 180 ;
        endcase
    
        deposit_task1;
        check_golden_answer;
        $display("%0sPASS PATTERN %0sNO.%4d%0s",txt_blue_prefix, txt_green_prefix, patcnt, reset_color);
        patcnt = patcnt + 1;
        repeat(2) @(negedge clk);

        check_task;
        check_golden_answer;
        $display("%0sPASS PATTERN %0sNO.%4d%0s",txt_blue_prefix, txt_green_prefix, patcnt, reset_color);
        patcnt = patcnt + 1;
        repeat(2) @(negedge clk);
    end
    

    ///////////////////////////////////////// 
    for(j = 190; j < 200; j=j+1)begin
        temp_id1 = j;
        case(j)
            'd190 : temp_id2 = 180 ;
            'd191 : temp_id2 = 181 ;
            'd192 : temp_id2 = 182 ;
            'd193 : temp_id2 = 183 ;
            'd194 : temp_id2 = 184 ;
            'd195 : temp_id2 = 185 ;
            'd196 : temp_id2 = 186 ;
            'd197 : temp_id2 = 187 ;
            'd198 : temp_id2 = 188 ;
            'd199 : temp_id2 = 199 ;
        endcase

        check_task;
        check_golden_answer;
        $display("%0sPASS PATTERN %0sNO.%4d%0s",txt_blue_prefix, txt_green_prefix, patcnt, reset_color);
        patcnt = patcnt + 1;
        repeat(2) @(negedge clk);

        buy_task1;
        check_golden_answer;
        $display("%0sPASS PATTERN %0sNO.%4d%0s",txt_blue_prefix, txt_green_prefix, patcnt, reset_color);
        patcnt = patcnt + 1;
        repeat(2) @(negedge clk);
    end

    /////////////////////////////////////////
    j=500;
    temp_id1 = 181;
    temp_id2 = 182;
    temp_money1 = 16'd65535;

    deposit_task1;
    check_golden_answer;
    $display("%0sPASS PATTERN %0sNO.%4d%0s",txt_blue_prefix, txt_green_prefix, patcnt, reset_color);
    patcnt = patcnt + 1;
    repeat(2) @(negedge clk);

    check_task;
    check_golden_answer;
    $display("%0sPASS PATTERN %0sNO.%4d%0s",txt_blue_prefix, txt_green_prefix, patcnt, reset_color);
    patcnt = patcnt + 1;
    repeat(2) @(negedge clk);

    return_task1;
    check_golden_answer;
    $display("%0sPASS PATTERN %0sNO.%4d%0s",txt_blue_prefix, txt_green_prefix, patcnt, reset_color);
    patcnt = patcnt + 1;
    repeat(2) @(negedge clk);
    

    j=501;
    deposit_task1;
    check_golden_answer;
    $display("%0sPASS PATTERN %0sNO.%4d%0s",txt_blue_prefix, txt_green_prefix, patcnt, reset_color);
    patcnt = patcnt + 1;
    repeat(2) @(negedge clk);



    for(j = 200; j < 228; j=j+1)begin
        temp_id1 = j;
        temp_id2 = j + 28;

        buy_task1;
        check_golden_answer;
        $display("%0sPASS PATTERN %0sNO.%4d%0s",txt_blue_prefix, txt_green_prefix, patcnt, reset_color);
        patcnt = patcnt + 1;
        repeat(2) @(negedge clk);

    end

    for(j = 200 ; j < 256; j=j+1)begin
        temp_id1 = j;

        check_task;
        check_golden_answer;
        $display("%0sPASS PATTERN %0sNO.%4d%0s",txt_blue_prefix, txt_green_prefix, patcnt, reset_color);
        patcnt = patcnt + 1;
        repeat(2) @(negedge clk);
        
    
    end

    for(j = 600; j < 610 ; j=j+1)begin
        temp_id1 = 121 ;
        temp_id2 = 139;
      

        return_task1;  //WRONG_ID
        check_golden_answer;
        $display("%0sPASS PATTERN %0sNO.%4d%0s",txt_blue_prefix, txt_green_prefix, patcnt, reset_color);
        patcnt = patcnt + 1;
        repeat(2) @(negedge clk);

    end

     for(j = 700; j < 710 ; j=j+1)begin
        temp_id1 = 121 ;
        temp_id2 = 131 ;


        return_task1;  //WRONG_NUM
        check_golden_answer;
        $display("%0sPASS PATTERN %0sNO.%4d%0s",txt_blue_prefix, txt_green_prefix, patcnt, reset_color);
        patcnt = patcnt + 1;
        repeat(2) @(negedge clk);


        
    end

    for(j = 800; j < 810 ; j=j+1)begin
        temp_id1 = 121 ;
        temp_id2 = 131 ;


        return_task1;  //WRONG_NUM
        check_golden_answer;
        $display("%0sPASS PATTERN %0sNO.%4d%0s",txt_blue_prefix, txt_green_prefix, patcnt, reset_color);
        patcnt = patcnt + 1;
        repeat(2) @(negedge clk);

    end

    //j = 1000; 
    temp_id1 = 130;
    check_seller;
    check_golden_answer;
    $display("%0sPASS PATTERN %0sNO.%4d%0s",txt_blue_prefix, txt_green_prefix, patcnt, reset_color);
    patcnt = patcnt + 1;
    //repeat(2) @(negedge clk);




    repeat (3) @(negedge clk);
     
	pass_task;
    
end



//================================================================
// TASK
//================================================================

//================================================================
// PATTERN 0-80
//================================================================

task check_seller; begin


        inf.act_valid = 1'b1;
	    inf.D = {12'd0,4'b0010}; 
	    @(negedge clk);
	    inf.act_valid = 1'b0;
	    inf.D = 'dx; 

	    repeat(3) @(negedge clk);


        inf.id_valid = 1'b1 ;
	    inf.D = {8'd0,temp_id1};
	    @(negedge clk);
	    inf.id_valid = 1'b0 ;
	    inf.D = 'dx;



	    

        golden_complete = 1 ;
        golden_err_msg =  No_Err ;
        golden_out_info = {14'd0, 18'h3ffffe};

end endtask
task deposit_task1; begin //0-79 pattern

    if(j < 20) begin
	    inf.id_valid = 1'b1 ;
	    inf.D = {8'd0,temp_id1};
	    @(negedge clk);
	    inf.id_valid = 1'b0 ;
	    inf.D = 'dx;

	    repeat(3) @(negedge clk);

	    inf.act_valid = 1'b1;
	    inf.D = {12'd0,4'b0100}; //deposit
	    @(negedge clk);
	    inf.act_valid = 1'b0;
	    inf.D = 'dx; 


	    repeat(3) @(negedge clk);

	    inf.amnt_valid = 1'b1;
	    inf.D = {temp_money1}; 
	    @(negedge clk);
	    inf.amnt_valid = 1'b0;
	    inf.D = 'dx; 

        golden_complete = 0 ;
        golden_err_msg = Wallet_is_Full ;
        golden_out_info = 0;
    end
    else if(j < 60)begin
        inf.id_valid = 1'b1 ;
	    inf.D = {8'd0,temp_id1};
	    @(negedge clk);
	    inf.id_valid = 1'b0 ;
	    inf.D = 'dx;

	    repeat(3) @(negedge clk);

	    inf.act_valid = 1'b1;
	    inf.D = {12'd0,4'b0100}; //deposit
	    @(negedge clk);
	    inf.act_valid = 1'b0;
	    inf.D = 'dx; 


	    repeat(3) @(negedge clk);

	    inf.amnt_valid = 1'b1;
	    inf.D = {temp_money1}; 
	    @(negedge clk);
	    inf.amnt_valid = 1'b0;
	    inf.D = 'dx; 

        golden_complete = 1 ;
        golden_err_msg = No_Err ;
        golden_out_info = {16'd0,16'd12001};
    end
    else if(j < 100)begin
        inf.id_valid = 1'b1 ;
	    inf.D = {8'd0,temp_id1};
	    @(negedge clk);
	    inf.id_valid = 1'b0 ;
	    inf.D = 'dx;

	    repeat(3) @(negedge clk);

	    inf.act_valid = 1'b1;
	    inf.D = {12'd0,4'b0100}; //deposit
	    @(negedge clk);
	    inf.act_valid = 1'b0;
	    inf.D = 'dx; 


	    repeat(3) @(negedge clk);

	    inf.amnt_valid = 1'b1;
	    inf.D = {temp_money1}; 
	    @(negedge clk);
	    inf.amnt_valid = 1'b0;
	    inf.D = 'dx; 

        golden_complete = 1 ;
        golden_err_msg = No_Err ;
        golden_out_info = {16'd0,16'd0};
    end

    else if(j < 190)begin
        inf.id_valid = 1'b1 ;
	    inf.D = {8'd0,temp_id1};
	    @(negedge clk);
	    inf.id_valid = 1'b0 ;
	    inf.D = 'dx;

	    repeat(3) @(negedge clk);

	    inf.act_valid = 1'b1;
	    inf.D = {12'd0,4'b0100}; //deposit
	    @(negedge clk);
	    inf.act_valid = 1'b0;
	    inf.D = 'dx; 


	    repeat(3) @(negedge clk);

	    inf.amnt_valid = 1'b1;
	    inf.D = {temp_money1}; 
	    @(negedge clk);
	    inf.amnt_valid = 1'b0;
	    inf.D = 'dx; 

        golden_complete = 0 ;
        golden_err_msg = Wallet_is_Full ;
        golden_out_info = 0;
    
    end

    else if(j == 500)begin
        inf.id_valid = 1'b1 ;
	    inf.D = {8'd0,temp_id1};
	    @(negedge clk);
	    inf.id_valid = 1'b0 ;
	    inf.D = 'dx;

	    repeat(3) @(negedge clk);

	    inf.act_valid = 1'b1;
	    inf.D = {12'd0,4'b0100}; //deposit
	    @(negedge clk);
	    inf.act_valid = 1'b0;
	    inf.D = 'dx; 


	    repeat(3) @(negedge clk);

	    inf.amnt_valid = 1'b1;
	    inf.D = {temp_money1}; 
	    @(negedge clk);
	    inf.amnt_valid = 1'b0;
	    inf.D = 'dx; 

        golden_complete = 0 ;
        golden_err_msg = Wallet_is_Full ;
        golden_out_info = 0;
    end

    else if(j == 501)begin
        inf.id_valid = 1'b1 ;
	    inf.D = {8'd0,temp_id1};
	    @(negedge clk);
	    inf.id_valid = 1'b0 ;
	    inf.D = 'dx;

	    repeat(3) @(negedge clk);

	    inf.act_valid = 1'b1;
	    inf.D = {12'd0,4'b0100}; //deposit
	    @(negedge clk);
	    inf.act_valid = 1'b0;
	    inf.D = 'dx; 


	    repeat(3) @(negedge clk);

	    inf.amnt_valid = 1'b1;
	    inf.D = {temp_money1}; 
	    @(negedge clk);
	    inf.amnt_valid = 1'b0;
	    inf.D = 'dx; 

        golden_complete = 0 ;
        golden_err_msg = Wallet_is_Full ;
        golden_out_info = 0;
        
    end
end endtask

task deposit_task2; begin //0-19 pattern
    if(j < 20)begin
	    inf.id_valid = 1'b1 ;
	    inf.D = {8'd0,temp_id2};
	    @(negedge clk)
	    inf.id_valid = 1'b0 ;
	    inf.D = 'dx;

	    repeat(3) @(negedge clk);

	    inf.act_valid = 1'b1;
	    inf.D = {12'd0,4'b0100}; //deposit
	    @(negedge clk);
	    inf.act_valid = 1'b0;
	    inf.D = 'dx; 


	    repeat(3) @(negedge clk);

	    inf.amnt_valid = 1'b1;
	    inf.D = {temp_money2}; 
	    @(negedge clk);
	    inf.amnt_valid = 1'b0;
	    inf.D = 'dx; 

        golden_complete = 1 ;
        golden_err_msg =  No_Err ;
        golden_out_info = 0;
    end

    else if(j < 60)begin
        inf.id_valid = 1'b1 ;
	    inf.D = {8'd0,temp_id2};
	    @(negedge clk);
	    inf.id_valid = 1'b0 ;
	    inf.D = 'dx;

	    repeat(3) @(negedge clk);

	    inf.act_valid = 1'b1;
	    inf.D = {12'd0,4'b0100}; //deposit
	    @(negedge clk);
	    inf.act_valid = 1'b0;
	    inf.D = 'dx; 


	    repeat(3) @(negedge clk);

	    inf.amnt_valid = 1'b1;
	    inf.D = {temp_money2}; 
	    @(negedge clk);
	    inf.amnt_valid = 1'b0;
	    inf.D = 'dx; 

        golden_complete = 1 ;
        golden_err_msg = No_Err ;
        golden_out_info = {16'd0,16'd24001};
    
    end

    else if(j < 100)begin
        inf.id_valid = 1'b1 ;
	    inf.D = {8'd0,temp_id2};
	    @(negedge clk);
	    inf.id_valid = 1'b0 ;
	    inf.D = 'dx;

	    repeat(3) @(negedge clk);

	    inf.act_valid = 1'b1;
	    inf.D = {12'd0,4'b0100}; //deposit
	    @(negedge clk);
	    inf.act_valid = 1'b0;
	    inf.D = 'dx; 


	    repeat(3) @(negedge clk);

	    inf.amnt_valid = 1'b1;
	    inf.D = {temp_money2}; 
	    @(negedge clk);
	    inf.amnt_valid = 1'b0;
	    inf.D = 'dx; 

        golden_complete = 1 ;
        golden_err_msg = No_Err ;
        golden_out_info = {16'd0,16'd36001};
    end
end endtask

task return_task1; begin
    if(j < 20)begin
        inf.id_valid = 1'b1 ;
	    inf.D = {8'd0,temp_id1};
	    @(negedge clk);
	    inf.id_valid = 1'b0 ;
	    inf.D = 'dx;


	    repeat(3) @(negedge clk);

	    inf.act_valid = 1'b1;
	    inf.D = {12'd0,4'b1000}; //return
	    @(negedge clk);
	    inf.act_valid = 1'b0;
	    inf.D = 'dx; 

        repeat(3) @(negedge clk);

        inf.item_valid = 1'b1 ;
        inf.D= 16'd0;
        @(negedge clk);
        inf.item_valid = 1'b0;
        inf.D= 'dx;

        repeat(3) @(negedge clk);
        inf.num_valid = 1'b1;
        inf.D = 16'd0;
        @(negedge clk);
        inf.num_valid = 1'b0;
        inf.D = 'dx;

        repeat(3) @(negedge clk);
        inf.id_valid = 1'b1;
        inf.D = {8'd0,temp_id2};
        @(negedge clk);
        inf.id_valid = 1'b0;
        inf.D = 'dx;

        golden_complete = 0 ;
        golden_err_msg =  Wrong_act ;
        golden_out_info = 0;
    end
    else if( j < 60 )begin
        inf.id_valid = 1'b1 ;
	    inf.D = {8'd0,temp_id1};
	    @(negedge clk);
	    inf.id_valid = 1'b0 ;
	    inf.D = 'dx;


	    repeat(3) @(negedge clk);

	    inf.act_valid = 1'b1;
	    inf.D = {12'd0,4'b1000}; //return
	    @(negedge clk);
	    inf.act_valid = 1'b0;
	    inf.D = 'dx; 

        repeat(3) @(negedge clk);

        inf.item_valid = 1'b1 ;
        inf.D= 16'd0;
        @(negedge clk);
        inf.item_valid = 1'b0;
        inf.D= 'dx;

        repeat(3) @(negedge clk);
        inf.num_valid = 1'b1;
        inf.D = 16'd0;
        @(negedge clk);
        inf.num_valid = 1'b0;
        inf.D = 'dx;

        repeat(3) @(negedge clk);
        inf.id_valid = 1'b1;
        inf.D = {8'd0,temp_id2};
        @(negedge clk);
        inf.id_valid = 1'b0;
        inf.D = 'dx;

        golden_complete = 0 ;
        golden_err_msg =  Wrong_act ;
        golden_out_info = 0;

    end

    else if (j < 130) begin
        inf.id_valid = 1'b1 ;
	    inf.D = {8'd0,temp_id1};
	    @(negedge clk);
	    inf.id_valid = 1'b0 ;
	    inf.D = 'dx;


	    repeat(3) @(negedge clk);

	    inf.act_valid = 1'b1;
	    inf.D = {12'd0,4'b1000}; //return
	    @(negedge clk);
	    inf.act_valid = 1'b0;
	    inf.D = 'dx; 

        repeat(3) @(negedge clk);

        inf.item_valid = 1'b1 ;
        inf.D= 16'd0;
        @(negedge clk);
        inf.item_valid = 1'b0;
        inf.D= 'dx;

        repeat(3) @(negedge clk);
        inf.num_valid = 1'b1;
        inf.D = 16'd0;
        @(negedge clk);
        inf.num_valid = 1'b0;
        inf.D = 'dx;

        repeat(3) @(negedge clk);
        inf.id_valid = 1'b1;
        inf.D = {8'd0,temp_id2};
        @(negedge clk);
        inf.id_valid = 1'b0;
        inf.D = 'dx;

        golden_complete = 0 ;
        golden_err_msg =  Wrong_ID ;
        golden_out_info = 0;

    end

    else if(j < 150) begin
        inf.id_valid = 1'b1 ;
	    inf.D = {8'd0,temp_id1};
	    @(negedge clk);
	    inf.id_valid = 1'b0 ;
	    inf.D = 'dx;


	    repeat(3) @(negedge clk);

	    inf.act_valid = 1'b1;
	    inf.D = {12'd0,4'b1000}; //return
	    @(negedge clk);
	    inf.act_valid = 1'b0;
	    inf.D = 'dx; 

        repeat(3) @(negedge clk);

        inf.item_valid = 1'b1 ;
        inf.D= 16'd0;
        @(negedge clk);
        inf.item_valid = 1'b0;
        inf.D= 'dx;

        repeat(3) @(negedge clk);
        inf.num_valid = 1'b1;
        inf.D = {10'd0,6'd63};
        @(negedge clk);
        inf.num_valid = 1'b0;
        inf.D = 'dx;

        repeat(3) @(negedge clk);
        inf.id_valid = 1'b1;
        inf.D = {8'd0,temp_id2};
        @(negedge clk);
        inf.id_valid = 1'b0;
        inf.D = 'dx;

        golden_complete = 0 ;
        golden_err_msg =  Wrong_Num ;
        golden_out_info = 0;
    
    end

    else if(j < 170) begin
        inf.id_valid = 1'b1 ;
	    inf.D = {8'd0,temp_id1};
	    @(negedge clk);
	    inf.id_valid = 1'b0 ;
	    inf.D = 'dx;


	    repeat(3) @(negedge clk);

	    inf.act_valid = 1'b1;
	    inf.D = {12'd0,4'b1000}; //return
	    @(negedge clk);
	    inf.act_valid = 1'b0;
	    inf.D = 'dx; 

        repeat(3) @(negedge clk);

        inf.item_valid = 1'b1 ;
        inf.D= {14'd0, 2'b01};
        @(negedge clk);
        inf.item_valid = 1'b0;
        inf.D= 'dx;

        repeat(3) @(negedge clk);
        inf.num_valid = 1'b1;
        inf.D = {10'd0,6'd1};
        @(negedge clk);
        inf.num_valid = 1'b0;
        inf.D = 'dx;

        repeat(3) @(negedge clk);
        inf.id_valid = 1'b1;
        inf.D = {8'd0,temp_id2};
        @(negedge clk);
        inf.id_valid = 1'b0;
        inf.D = 'dx;

        golden_complete = 0 ;
        golden_err_msg =  Wrong_Item ;
        golden_out_info = 0;
    
    end

    else if(j == 500) begin
        inf.id_valid = 1'b1 ;
	    inf.D = {8'd0,temp_id1};
	    @(negedge clk);
	    inf.id_valid = 1'b0 ;
	    inf.D = 'dx;


	    repeat(3) @(negedge clk);

	    inf.act_valid = 1'b1;
	    inf.D = {12'd0,4'b1000}; //return
	    @(negedge clk);
	    inf.act_valid = 1'b0;
	    inf.D = 'dx; 

        repeat(3) @(negedge clk);

        inf.item_valid = 1'b1 ;
        inf.D= {14'd0, 2'b01};
        @(negedge clk);
        inf.item_valid = 1'b0;
        inf.D= 'dx;

        repeat(3) @(negedge clk);
        inf.num_valid = 1'b1;
        inf.D = {10'd0,6'd1};
        @(negedge clk);
        inf.num_valid = 1'b0;
        inf.D = 'dx;

        repeat(3) @(negedge clk);
        inf.id_valid = 1'b1;
        inf.D = {8'd0,temp_id2};
        @(negedge clk);
        inf.id_valid = 1'b0;
        inf.D = 'dx;

        golden_complete = 0 ;
        golden_err_msg =  Wrong_act ;
        golden_out_info = 0;
    end

    else if( j < 610) begin
        inf.id_valid = 1'b1 ;
	    inf.D = {8'd0,temp_id1};
	    @(negedge clk);
	    inf.id_valid = 1'b0 ;
	    inf.D = 'dx;


	    repeat(3) @(negedge clk);

	    inf.act_valid = 1'b1;
	    inf.D = {12'd0,4'b1000}; //return
	    @(negedge clk);
	    inf.act_valid = 1'b0;
	    inf.D = 'dx; 

        repeat(3) @(negedge clk);

        inf.item_valid = 1'b1 ;
        inf.D= {14'd0, 2'b01};
        @(negedge clk);
        inf.item_valid = 1'b0;
        inf.D= 'dx;

        repeat(3) @(negedge clk);
        inf.num_valid = 1'b1;
        inf.D = {10'd0,6'd1};
        @(negedge clk);
        inf.num_valid = 1'b0;
        inf.D = 'dx;

        repeat(3) @(negedge clk);
        inf.id_valid = 1'b1;
        inf.D = {8'd0,temp_id2};
        @(negedge clk);
        inf.id_valid = 1'b0;
        inf.D = 'dx;

        golden_complete = 0 ;
        golden_err_msg =  Wrong_ID ;
        golden_out_info = 0;
    
    end

    else if( j < 710) begin
        inf.id_valid = 1'b1 ;
	    inf.D = {8'd0,temp_id1};
	    @(negedge clk);
	    inf.id_valid = 1'b0 ;
	    inf.D = 'dx;


	    repeat(3) @(negedge clk);

	    inf.act_valid = 1'b1;
	    inf.D = {12'd0,4'b1000}; //return
	    @(negedge clk);
	    inf.act_valid = 1'b0;
	    inf.D = 'dx; 

        repeat(3) @(negedge clk);

        inf.item_valid = 1'b1 ;
        inf.D= {14'd0, 2'b01};
        @(negedge clk);
        inf.item_valid = 1'b0;
        inf.D= 'dx;

        repeat(3) @(negedge clk);
        inf.num_valid = 1'b1;
        inf.D = {10'd0,6'd63};
        @(negedge clk);
        inf.num_valid = 1'b0;
        inf.D = 'dx;

        repeat(3) @(negedge clk);
        inf.id_valid = 1'b1;
        inf.D = {8'd0,temp_id2};
        @(negedge clk);
        inf.id_valid = 1'b0;
        inf.D = 'dx;

        golden_complete = 0 ;
        golden_err_msg =  Wrong_Num ;
        golden_out_info = 0;
    
    
    end

    else if(j < 810) begin
        inf.id_valid = 1'b1 ;
	    inf.D = {8'd0,temp_id1};
	    @(negedge clk);
	    inf.id_valid = 1'b0 ;
	    inf.D = 'dx;


	    repeat(3) @(negedge clk);

	    inf.act_valid = 1'b1;
	    inf.D = {12'd0,4'b1000}; //return
	    @(negedge clk);
	    inf.act_valid = 1'b0;
	    inf.D = 'dx; 

        repeat(3) @(negedge clk);

        inf.item_valid = 1'b1 ;
        inf.D= {14'd0, 2'b10};
        @(negedge clk);
        inf.item_valid = 1'b0;
        inf.D= 'dx;

        repeat(3) @(negedge clk);
        inf.num_valid = 1'b1;
        inf.D = {10'd0,6'd1};
        @(negedge clk);
        inf.num_valid = 1'b0;
        inf.D = 'dx;

        repeat(3) @(negedge clk);
        inf.id_valid = 1'b1;
        inf.D = {8'd0,temp_id2};
        @(negedge clk);
        inf.id_valid = 1'b0;
        inf.D = 'dx;

        golden_complete = 0 ;
        golden_err_msg =  Wrong_Item ;
        golden_out_info = 0;
    
    end
end endtask



task buy_task1; begin
    if(j < 20)begin
        inf.id_valid = 1'b1 ;
	    inf.D = {8'd0,temp_id1};
	    @(negedge clk);
	    inf.id_valid = 1'b0 ;
	    inf.D = 'dx;


	    repeat(3) @(negedge clk);

	    inf.act_valid = 1'b1;
	    inf.D = {12'd0,4'b0001}; //buy
	    @(negedge clk);
	    inf.act_valid = 1'b0;
	    inf.D = 'dx; 

        repeat(3) @(negedge clk);

        inf.item_valid = 1'b1 ;
        inf.D= {14'd0,2'b11}; //small
        @(negedge clk);
        inf.item_valid = 1'b0;
        inf.D= 'dx;

        repeat(3) @(negedge clk);
        inf.num_valid = 1'b1;
        inf.D = {10'd0,6'd63};
        @(negedge clk);
        inf.num_valid = 1'b0;
        inf.D = 'dx;

        repeat(3) @(negedge clk);
        inf.id_valid = 1'b1;
        inf.D = {8'd0,temp_id2};
        @(negedge clk);
        inf.id_valid = 1'b0;
        inf.D = 'dx;

        golden_complete = 0 ;
        golden_err_msg =  INV_Full ;
        golden_out_info = 0;
    end
    else if(j < 60)begin
        inf.id_valid = 1'b1 ;
	    inf.D = {8'd0,temp_id1};
	    @(negedge clk);
	    inf.id_valid = 1'b0 ;
	    inf.D = 'dx;


	    repeat(3) @(negedge clk);

	    inf.act_valid = 1'b1;
	    inf.D = {12'd0,4'b0001}; //buy
	    @(negedge clk);
	    inf.act_valid = 1'b0;
	    inf.D = 'dx; 

        repeat(3) @(negedge clk);

        inf.item_valid = 1'b1 ;
        inf.D= {14'd0,2'b10}; //medium
        @(negedge clk);
        inf.item_valid = 1'b0;
        inf.D= 'dx;

        repeat(3) @(negedge clk);
        inf.num_valid = 1'b1;
        inf.D = {10'd0,6'd63};
        @(negedge clk);
        inf.num_valid = 1'b0;
        inf.D = 'dx;

        repeat(3) @(negedge clk);
        inf.id_valid = 1'b1;
        inf.D = {8'd0,temp_id2};
        @(negedge clk);
        inf.id_valid = 1'b0;
        inf.D = 'dx;

        golden_complete = 0 ;
        golden_err_msg =  INV_Not_Enough ;
        golden_out_info = 0;
    end


    else if(j < 100)begin
        inf.id_valid = 1'b1 ;
	    inf.D = {8'd0,temp_id1};
	    @(negedge clk);
	    inf.id_valid = 1'b0 ;
	    inf.D = 'dx;


	    repeat(3) @(negedge clk);

	    inf.act_valid = 1'b1;
	    inf.D = {12'd0,4'b0001}; //buy
	    @(negedge clk);
	    inf.act_valid = 1'b0;
	    inf.D = 'dx; 

        repeat(3) @(negedge clk);

        inf.item_valid = 1'b1 ;
        inf.D= {14'd0,2'b01}; //large
        @(negedge clk);
        inf.item_valid = 1'b0;
        inf.D= 'dx;

        repeat(3) @(negedge clk);
        inf.num_valid = 1'b1;
        inf.D = {10'd0,6'd63};
        @(negedge clk);
        inf.num_valid = 1'b0;
        inf.D = 'dx;

        repeat(3) @(negedge clk);
        inf.id_valid = 1'b1;
        inf.D = {8'd0,temp_id2};
        @(negedge clk);
        inf.id_valid = 1'b0;
        inf.D = 'dx;

        golden_complete = 0 ;
        golden_err_msg =  Out_of_money ;
        golden_out_info = 0;
        
    end

    else if(j < 130) begin

        inf.id_valid = 1'b1 ;
	    inf.D = {8'd0,temp_id1};
	    @(negedge clk);
	    inf.id_valid = 1'b0 ;
	    inf.D = 'dx;


	    repeat(3) @(negedge clk);

	    inf.act_valid = 1'b1;
	    inf.D = {12'd0,4'b0001}; //buy
	    @(negedge clk);
	    inf.act_valid = 1'b0;
	    inf.D = 'dx; 

        repeat(3) @(negedge clk);

        inf.item_valid = 1'b1 ;
        inf.D= {14'd0,2'b11}; //small
        @(negedge clk);
        inf.item_valid = 1'b0;
        inf.D= 'dx;

        repeat(3) @(negedge clk);
        inf.num_valid = 1'b1;
        inf.D = {10'd0,6'd1};
        @(negedge clk);
        inf.num_valid = 1'b0;
        inf.D = 'dx;

        repeat(3) @(negedge clk);
        inf.id_valid = 1'b1;
        inf.D = {8'd0,temp_id2};
        @(negedge clk);
        inf.id_valid = 1'b0;
        inf.D = 'dx;

        golden_complete = 1 ;
        golden_err_msg =  No_Err ;
        golden_out_info = {16'd59990,2'b11,6'd1,temp_id2};
    
    end

    else if(j < 150)begin
        
        inf.id_valid = 1'b1 ;
	    inf.D = {8'd0,temp_id1};
	    @(negedge clk);
	    inf.id_valid = 1'b0 ;
	    inf.D = 'dx;


	    repeat(3) @(negedge clk);

	    inf.act_valid = 1'b1;
	    inf.D = {12'd0,4'b0001}; //buy
	    @(negedge clk);
	    inf.act_valid = 1'b0;
	    inf.D = 'dx; 

        repeat(3) @(negedge clk);

        inf.item_valid = 1'b1 ;
        inf.D= {14'd0,2'b11}; //small
        @(negedge clk);
        inf.item_valid = 1'b0;
        inf.D= 'dx;

        repeat(3) @(negedge clk);
        inf.num_valid = 1'b1;
        inf.D = {10'd0,6'd1};
        @(negedge clk);
        inf.num_valid = 1'b0;
        inf.D = 'dx;

        repeat(3) @(negedge clk);
        inf.id_valid = 1'b1;
        inf.D = {8'd0,temp_id2};
        @(negedge clk);
        inf.id_valid = 1'b0;
        inf.D = 'dx;

        golden_complete = 1 ;
        golden_err_msg =  No_Err ;
        golden_out_info = {16'd59990,2'b11,6'd1,temp_id2};
    end

    else if(j < 170)begin
        inf.id_valid = 1'b1 ;
	    inf.D = {8'd0,temp_id1};
	    @(negedge clk);
	    inf.id_valid = 1'b0 ;
	    inf.D = 'dx;


	    repeat(3) @(negedge clk);

	    inf.act_valid = 1'b1;
	    inf.D = {12'd0,4'b0001}; //buy
	    @(negedge clk);
	    inf.act_valid = 1'b0;
	    inf.D = 'dx; 

        repeat(3) @(negedge clk);

        inf.item_valid = 1'b1 ;
        inf.D= {14'd0,2'b11}; //small
        @(negedge clk);
        inf.item_valid = 1'b0;
        inf.D= 'dx;

        repeat(3) @(negedge clk);
        inf.num_valid = 1'b1;
        inf.D = {10'd0,6'd1};
        @(negedge clk);
        inf.num_valid = 1'b0;
        inf.D = 'dx;

        repeat(3) @(negedge clk);
        inf.id_valid = 1'b1;
        inf.D = {8'd0,temp_id2};
        @(negedge clk);
        inf.id_valid = 1'b0;
        inf.D = 'dx;

        golden_complete = 1 ;
        golden_err_msg =  No_Err ;
        golden_out_info = {16'd59990,2'b11,6'd1,temp_id2};
    end
     
    else if(j < 200) begin
        inf.id_valid = 1'b1 ;
	    inf.D = {8'd0,temp_id2};
	    @(negedge clk);
	    inf.id_valid = 1'b0 ;
	    inf.D = 'dx;


	    repeat(3) @(negedge clk);

	    inf.act_valid = 1'b1;
	    inf.D = {12'd0,4'b0001}; //buy
	    @(negedge clk);
	    inf.act_valid = 1'b0;
	    inf.D = 'dx; 

        repeat(3) @(negedge clk);

        inf.item_valid = 1'b1 ;
        inf.D= {14'd0,2'b11}; //small
        @(negedge clk);
        inf.item_valid = 1'b0;
        inf.D= 'dx;

        repeat(3) @(negedge clk);
        inf.num_valid = 1'b1;
        inf.D = {10'd0,6'd63};
        @(negedge clk);
        inf.num_valid = 1'b0;
        inf.D = 'dx;

        repeat(3) @(negedge clk);
        inf.id_valid = 1'b1;
        inf.D = {8'd0,temp_id1};
        @(negedge clk);
        inf.id_valid = 1'b0;
        inf.D = 'dx;

        golden_complete = 0 ;
        golden_err_msg =  INV_Not_Enough ;
        golden_out_info = 0;

    end

    else if(j < 228)begin
        inf.id_valid = 1'b1 ;
	    inf.D = {8'd0,temp_id1};
	    @(negedge clk);
	    inf.id_valid = 1'b0 ;
	    inf.D = 'dx;


	    repeat(3) @(negedge clk);

	    inf.act_valid = 1'b1;
	    inf.D = {12'd0,4'b0001}; //buy
	    @(negedge clk);
	    inf.act_valid = 1'b0;
	    inf.D = 'dx; 

        repeat(3) @(negedge clk);

        inf.item_valid = 1'b1 ;
        inf.D= {14'd0,2'b11}; //small
        @(negedge clk);
        inf.item_valid = 1'b0;
        inf.D= 'dx;

        repeat(3) @(negedge clk);
        inf.num_valid = 1'b1;
        inf.D = {10'd0,6'd63};
        @(negedge clk);
        inf.num_valid = 1'b0;
        inf.D = 'dx;

        repeat(3) @(negedge clk);
        inf.id_valid = 1'b1;
        inf.D = {8'd0,temp_id2};
        @(negedge clk);
        inf.id_valid = 1'b0;
        inf.D = 'dx;

        golden_complete = 0 ;
        golden_err_msg =  Out_of_money ;
        golden_out_info = 0;

    end

end endtask

task check_task; begin
    if(j < 100)begin

        inf.id_valid = 1'b1 ;
	    inf.D = {8'd0,temp_id1};
	    @(negedge clk);
	    inf.id_valid = 1'b0 ;
	    inf.D = 'dx;


	    repeat(3) @(negedge clk);

	    inf.act_valid = 1'b1;
	    inf.D = {12'd0,4'b0010}; 
	    @(negedge clk);
	    inf.act_valid = 1'b0;
	    inf.D = 'dx; 

        golden_complete = 1 ;
        golden_err_msg =  No_Err ;
        golden_out_info = {16'd0, 16'd0};
    end

    else if (j < 170)begin
        inf.id_valid = 1'b1 ;
	    inf.D = {8'd0,temp_id1};
	    @(negedge clk);
	    inf.id_valid = 1'b0 ;
	    inf.D = 'dx;


	    repeat(3) @(negedge clk);

	    inf.act_valid = 1'b1;
	    inf.D = {12'd0,4'b0010}; 
	    @(negedge clk);
	    inf.act_valid = 1'b0;
	    inf.D = 'dx; 

        golden_complete = 1 ;
        golden_err_msg =  No_Err ;
        golden_out_info = {16'd0, 16'd59990};
    end


    else if(j < 190)begin
        inf.id_valid = 1'b1 ;
	    inf.D = {8'd0,temp_id2};
	    @(negedge clk);
	    inf.id_valid = 1'b0 ;
	    inf.D = 'dx;


	    repeat(3) @(negedge clk);

	    inf.act_valid = 1'b1;
	    inf.D = {12'd0,4'b0010}; 
	    @(negedge clk);
	    inf.act_valid = 1'b0;
	    inf.D = 'dx; 

        golden_complete = 1 ;
        golden_err_msg =  No_Err ;
        golden_out_info = {16'd0, 16'd65535};
    end

    else if(j < 200)begin
        inf.id_valid = 1'b1 ;
	    inf.D = {8'd0,temp_id1};
	    @(negedge clk);
	    inf.id_valid = 1'b0 ;
	    inf.D = 'dx;


	    repeat(3) @(negedge clk);

	    inf.act_valid = 1'b1;
	    inf.D = {12'd0,4'b0010}; 
	    @(negedge clk);
	    inf.act_valid = 1'b0;
	    inf.D = 'dx; 

        golden_complete = 1 ;
        golden_err_msg =  No_Err ;
        golden_out_info = {16'd0, 16'd0};
    
    end

    else if(j == 500) begin
        inf.id_valid = 1'b1 ;
	    inf.D = {8'd0,temp_id2};
	    @(negedge clk);
	    inf.id_valid = 1'b0 ;
	    inf.D = 'dx;


	    repeat(3) @(negedge clk);

	    inf.act_valid = 1'b1;
	    inf.D = {12'd0,4'b0010}; 
	    @(negedge clk);
	    inf.act_valid = 1'b0;
	    inf.D = 'dx; 

        golden_complete = 1 ;
        golden_err_msg =  No_Err ;
        golden_out_info = {16'd0, 16'd65535};
    end


    else if(j < 256)begin
        inf.id_valid = 1'b1 ;
	    inf.D = {8'd0,temp_id1};
	    @(negedge clk);
	    inf.id_valid = 1'b0 ;
	    inf.D = 'dx;


	    repeat(3) @(negedge clk);

	    inf.act_valid = 1'b1;
	    inf.D = {12'd0,4'b0010}; 
	    @(negedge clk);
	    inf.act_valid = 1'b0;
	    inf.D = 'dx; 

        golden_complete = 1 ;
        golden_err_msg =  No_Err ;
        golden_out_info = {16'd0, 16'd0};
    end
end endtask


//================================================================
// OUTPUT
//================================================================
task check_golden_answer ; begin
	wait_outvalid_task;
	while(inf.out_valid === 1 && ((inf.err_msg !== golden_err_msg) || (inf.complete !== golden_complete) || (inf.out_info !== golden_out_info)))  begin
		$display ("------------------------------------------------------------------------------------------");
        $display ("                                  Wrong Answer                                            ");
        $display ("                                  			                                             ");
        $display ("------------------------------------------------------------------------------------------");
        $finish;
	end


end endtask

task reset_task ; begin   // bridge reset
	#(2.0);	inf.rst_n = 0 ;
	#(3.0);
	if (inf.out_valid!==0 || inf.err_msg!==0 || inf.complete!==0 || inf.out_info!==0 ) begin
        $display ("------------------------------------------------------------------------------------------");
        $display ("                                  Wrong Answer                                            ");
        $display ("                                  			                                             ");
        $display ("------------------------------------------------------------------------------------------");
        $finish;
	end
	#(2.0);	inf.rst_n = 1 ;
end endtask


task wait_outvalid_task; begin
	cycles = 0 ;
	while (inf.out_valid!==1) begin
		cycles = cycles + 1 ;
		if (cycles==10000) begin
		$display ("------------------------------------------------------------------------------------------");
        $display ("                                  Wrong Answer                                            ");
        $display ("                                  			                                             ");
        $display ("------------------------------------------------------------------------------------------");
        $finish;
	end
		@(negedge clk);
	end
	//total_cycles = total_cycles + cycles ;
	
end endtask


task pass_task; begin
    $display("");
    $display("");
    $display("\033[1;33m                `oo+oy+`                            Congratulation!!!      						                             ");
    $display("\033[1;33m               /h/----+y        `+++++:                                    													 ");
    $display("\033[1;33m             .y------:m/+ydoo+:y:---:+o             										                                 ");
    $display("\033[1;33m              o+------/y--::::::+oso+:/y                                                                                     ");
    $display("\033[1;33m              s/-----:/:----------:+ooy+-                                                                                    ");
    $display("\033[1;33m             /o----------------/yhyo/::/o+/:-.`                                                                              ");
    $display("\033[1;33m            `ys----------------:::--------:::+yyo+                                                                           ");
    $display("\033[1;33m            .d/:-------------------:--------/--/hos/                                                                         ");
    $display("\033[1;33m            y/-------------------::ds------:s:/-:sy-                                                                         ");
    $display("\033[1;33m           +y--------------------::os:-----:ssm/o+`                                                                          ");
    $display("\033[1;33m          `d:-----------------------:-----/+o++yNNmms                                                                        ");
    $display("\033[1;33m           /y-----------------------------------hMMMMN.                                                                      ");
    $display("\033[1;33m           o+---------------------://:----------:odmdy/+.                                                                    ");
    $display("\033[1;33m           o+---------------------::y:------------::+o-/h                                                                    ");
    $display("\033[1;33m           :y-----------------------+s:------------/h:-:d                                                                    ");
    $display("\033[1;33m           `m/-----------------------+y/---------:oy:--/y                                                                    ");
    $display("\033[1;33m            /h------------------------:os++/:::/+o/:--:h-                                                                    ");
    $display("\033[1;33m         `:+ym--------------------------://++++o/:---:h/                                                                     ");
    $display("\033[1;31m        `hhhhhoooo++oo+/:\033[1;33m--------------------:oo----\033[1;31m+dd+                                                 ");
    $display("\033[1;31m         shyyyhhhhhhhhhhhso/:\033[1;33m---------------:+/---\033[1;31m/ydyyhs:`                                              ");
    $display("\033[1;31m         .mhyyyyyyhhhdddhhhhhs+:\033[1;33m----------------\033[1;31m:sdmhyyyyyyo:                                            ");
    $display("\033[1;31m        `hhdhhyyyyhhhhhddddhyyyyyo++/:\033[1;33m--------\033[1;31m:odmyhmhhyyyyhy                                            ");
    $display("\033[1;31m        -dyyhhyyyyyyhdhyhhddhhyyyyyhhhs+/::\033[1;33m-\033[1;31m:ohdmhdhhhdmdhdmy:                                           ");
    $display("\033[1;31m         hhdhyyyyyyyyyddyyyyhdddhhyyyyyhhhyyhdhdyyhyys+ossyhssy:-`                                                           ");
    $display("\033[1;31m         `Ndyyyyyyyyyyymdyyyyyyyhddddhhhyhhhhhhhhy+/:\033[1;33m-------::/+o++++-`                                            ");
    $display("\033[1;31m          dyyyyyyyyyyyyhNyydyyyyyyyyyyhhhhyyhhy+/\033[1;33m------------------:/ooo:`                                         ");
    $display("\033[1;31m         :myyyyyyyyyyyyyNyhmhhhyyyyyhdhyyyhho/\033[1;33m-------------------------:+o/`                                       ");
    $display("\033[1;31m        /dyyyyyyyyyyyyyyddmmhyyyyyyhhyyyhh+:\033[1;33m-----------------------------:+s-                                      ");
    $display("\033[1;31m      +dyyyyyyyyyyyyyyydmyyyyyyyyyyyyyds:\033[1;33m---------------------------------:s+                                      ");
    $display("\033[1;31m      -ddhhyyyyyyyyyyyyyddyyyyyyyyyyyhd+\033[1;33m------------------------------------:oo              `-++o+:.`             ");
    $display("\033[1;31m       `/dhshdhyyyyyyyyyhdyyyyyyyyyydh:\033[1;33m---------------------------------------s/            -o/://:/+s             ");
    $display("\033[1;31m         os-:/oyhhhhyyyydhyyyyyyyyyds:\033[1;33m----------------------------------------:h:--.`      `y:------+os            ");
    $display("\033[1;33m         h+-----\033[1;31m:/+oosshdyyyyyyyyhds\033[1;33m-------------------------------------------+h//o+s+-.` :o-------s/y  ");
    $display("\033[1;33m         m:------------\033[1;31mdyyyyyyyyymo\033[1;33m--------------------------------------------oh----:://++oo------:s/d  ");
    $display("\033[1;33m        `N/-----------+\033[1;31mmyyyyyyyydo\033[1;33m---------------------------------------------sy---------:/s------+o/d  ");
    $display("\033[1;33m        .m-----------:d\033[1;31mhhyyyyyyd+\033[1;33m----------------------------------------------y+-----------+:-----oo/h  ");
    $display("\033[1;33m        +s-----------+N\033[1;31mhmyyyyhd/\033[1;33m----------------------------------------------:h:-----------::-----+o/m  ");
    $display("\033[1;33m        h/----------:d/\033[1;31mmmhyyhh:\033[1;33m-----------------------------------------------oo-------------------+o/h  ");
    $display("\033[1;33m       `y-----------so /\033[1;31mNhydh:\033[1;33m-----------------------------------------------/h:-------------------:soo  ");
    $display("\033[1;33m    `.:+o:---------+h   \033[1;31mmddhhh/:\033[1;33m---------------:/osssssoo+/::---------------+d+//++///::+++//::::::/y+`  ");
    $display("\033[1;33m   -s+/::/--------+d.   \033[1;31mohso+/+y/:\033[1;33m-----------:yo+/:-----:/oooo/:----------:+s//::-.....--:://////+/:`    ");
    $display("\033[1;33m   s/------------/y`           `/oo:--------:y/-------------:/oo+:------:/s:                                                 ");
    $display("\033[1;33m   o+:--------::++`              `:so/:-----s+-----------------:oy+:--:+s/``````                                             ");
    $display("\033[1;33m    :+o++///+oo/.                   .+o+::--os-------------------:oy+oo:`/o+++++o-                                           ");
    $display("\033[1;33m       .---.`                          -+oo/:yo:-------------------:oy-:h/:---:+oyo                                          ");
    $display("\033[1;33m                                          `:+omy/---------------------+h:----:y+//so                                         ");
    $display("\033[1;33m                                              `-ys:-------------------+s-----+s///om                                         ");
    $display("\033[1;33m                                                 -os+::---------------/y-----ho///om                                         ");
    $display("\033[1;33m                                                    -+oo//:-----------:h-----h+///+d                                         ");
    $display("\033[1;33m                                                       `-oyy+:---------s:----s/////y                                         ");
    $display("\033[1;33m                                                           `-/o+::-----:+----oo///+s                                         ");
    $display("\033[1;33m                                                               ./+o+::-------:y///s:                                         ");
    $display("\033[1;33m                                                                   ./+oo/-----oo/+h                                          ");
    $display("\033[1;33m                                                                       `://++++syo`                                          ");
    $display("\033[1;0m"); 
    ///repeat(5) @(negedge clk);
    $finish;
end endtask







endprogram
