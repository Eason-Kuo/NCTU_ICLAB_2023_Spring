`ifdef RTL
    `define CYCLE_TIME 10.0
`endif
`ifdef GATE
    `define CYCLE_TIME 10.0
`endif


module PATTERN(
    // Output Signals
    clk,
    rst_n,
    in_valid,
    init,
    in0,
    in1,
    in2,
    in3,
    // Input Signals
    out_valid,
    out
);


/* Input for design */
output reg       clk, rst_n;
output reg       in_valid;
output reg [1:0] init;
output reg [1:0] in0, in1, in2, in3; 


/* Output for pattern */
input            out_valid;
input      [1:0] out; 
/* define clock cycle */
real CYCLE = `CYCLE_TIME;
always #(CYCLE/2.0) clk = ~clk;

/* parameter and integer*/
integer patnum,i,j,seed,PATNUM,patcount,t;
integer train0,train1,train2,train3,train4;
integer trainsum;
integer obstacle0,obstacle1,obstacle2,obstacle3;
integer obstaclex0,obstaclex1,obstaclex2,obstaclex3;
integer cnt,out_count;
integer latency;
integer current_position;

//////Output
integer golden_init;
integer out_counter;

reg [1:0]map_pattern[0:3][0:63];


//================================================================
// initial
//================================================================
initial begin

    force clk = 0;
	#CYCLE; rst_n = 0; 
    #CYCLE; rst_n = 1;
    reset_task; //SPEC-3
	#CYCLE; release clk;
    PATNUM = 300;

	for(patcount = 0; patcount < PATNUM ; patcount = patcount + 1)
	begin

		t = $urandom_range(2,4);
        repeat(t)@(negedge clk);
        cnt = 0;
        gen_input;
        in_valid = 1'b0;
        unknown_task;
        wait_out_valid_task; //SPEC-4 + SPEC-6
        check_ans_task;
        
       $display("\033[0;32mPASS PATTERN NO.%3d \033[m", patcount);

        

        
	
	end

    ERIC_task;
    repeat(3) @(negedge clk); 
    $finish;

end
task unknown_task;begin
    in0 = 'dx;
    in1 = 'dx;
    in2 = 'dx;
    in3 = 'dx;
    init = 'dx;
end endtask


task gen_input;begin
   

    for(j=0; j<64 ;j=j+1)begin
        
        input_while_outvalid_task;
        

        if(j%8 == 0)begin
            trainsum = 0;
            while(trainsum == 0 || trainsum == 4)begin
            
                train0 = $urandom_range(0,1);
                train1 = $urandom_range(0,1);
                train2 = $urandom_range(0,1);
                train3 = $urandom_range(0,1);
                trainsum = train0 + train1 + train2 + train3;
            end

            in0 = (train0 == 0) ? 2'b00 : 2'b11;
            in1 = (train1 == 0) ? 2'b00 : 2'b11;
            in2 = (train2 == 0) ? 2'b00 : 2'b11;
            in3 = (train3 == 0) ? 2'b00 : 2'b11;

            if(j==0)begin
                if(in0 == 0)    init = 2'b00;
                    else if (in1 == 0) init = 2'b01;
                    else if (in2 == 0) init = 2'b10;
                    else if (in3 == 0) init = 2'b11; 
                golden_init = init;
            end

                    
            map_task;
            in_valid = 1'b1 ;
            input_while_outvalid_task;
            
            @(negedge clk);
            init = 'dx;
            
            
           
        end

        else if(j % 8 < 4)begin
            obstaclex0= $urandom_range(0,2);
            obstaclex1= $urandom_range(0,2);
            obstaclex2= $urandom_range(0,2);
            obstaclex3= $urandom_range(0,2);

            if(j % 8 == 2)begin
                if(in0 != 3)begin
                    if(obstaclex0 == 0) in0 = 2'b00;
                    else if(obstaclex0 ==1) in0 = 2'b01;
                    else if(obstaclex0 == 2) in0 = 2'b10;
                end
                if(in1 != 3)begin
                    if(obstaclex1 == 0 ) in1 = 2'b00;
                    else if(obstaclex1 ==1) in1 = 2'b01;
                    else if(obstaclex1 == 2) in1 = 2'b10;
                end
                if(in2 != 3)begin
                    if(obstaclex2 == 0 ) in2 = 2'b00;
                    else if(obstaclex2 ==1) in2 = 2'b01;
                    else if(obstaclex2 == 2) in2 = 2'b10;
                end
                if(in3 != 3)begin
                    if(obstaclex3 == 0 ) in3 = 2'b00;
                    else if(obstaclex3 ==1) in3 = 2'b01;
                    else if(obstaclex3 == 2) in3 = 2'b10;
                end

                map_task;
                @(negedge clk);
            end
            else if(j % 8 == 3)begin
                if(in0 != 3) in0 = 2'b00;
                if(in1 != 3) in1 = 2'b00;
                if(in2 != 3) in2 = 2'b00;
                if(in3 != 3) in3 = 2'b00;
                map_task;
                @(negedge clk);
            end

            else begin
                map_task;
                @(negedge clk);
            end
            
        end

        

        else if(j % 8 == 4 || j % 8 == 6)begin
            obstacle0 = $urandom_range(0,2);
            obstacle1 = $urandom_range(0,2);
            obstacle2 = $urandom_range(0,2);
            obstacle3 = $urandom_range(0,2);

            if(obstacle0 == 1) in0 = 2'b01;
                else if(obstacle0 == 2) in0 = 2'b10;
                else    in0 = 2'b00;
            if(obstacle1 == 1) in1 = 2'b01;
                else if(obstacle1 == 2) in1 = 2'b10;
                else    in1 = 2'b00;
            if(obstacle2 == 1) in2 = 2'b01;
                else if(obstacle2 == 2) in2 = 2'b10;
                else    in2 = 2'b00;
            if(obstacle3 == 1) in3 = 2'b01;
                else if(obstacle3 == 2) in3 = 2'b10;
                else    in3 = 2'b00;
            map_task;
             @(negedge clk);
        end
        else begin
            in0=2'b00;
            in1=2'b00;
            in2=2'b00;
            in3=2'b00;
            map_task;
            @(negedge clk);

        end

        
        cnt = cnt + 1;
        
    end
end endtask

task map_task;begin
    map_pattern[0][cnt] = in0;
    map_pattern[1][cnt] = in1;
    map_pattern[2][cnt] = in2;
    map_pattern[3][cnt] = in3;

end endtask


task reset_task; begin//SPEC-3 

     rst_n = 1'b1;
     in_valid = 'b0;
     in0 = 'dx;
	 in1 = 'dx;
	 in2 = 'dx;
	 in3 = 'dx;
	 init = 'dx;
	 seed = 32;
     trainsum = 0;
     cnt = 0;

    for(i=0;i<64;i=i+1)begin
        for(j=0;j<4;j=j+1)begin
            map_pattern[j][i] = 2'b00;
        end
    end
    if(out_valid !== 1'b0 || out !=='b0) begin //out!==0
        $display("************************************************************");   
        $display("                     SPEC 3 IS FAIL!                        ");   
        $display("*  Output signal should be 0 after initial RESET  at %8t   *",$time);
        $display("************************************************************");
        $finish;
    end
end endtask


task wait_out_valid_task; begin  //SPEC-6 
    latency = 1;                   
	
    while(out_valid !== 1'b1) begin
	    out_low_task;
	    latency = latency + 1;
	
      if( latency == 3000) begin
          $display("********************************************************");     
          $display("                          SPEC 6 IS FAIL!                    ");
          $display("*  The execution latency are over 3000 cycles  at %8t   *",$time);
          $display("********************************************************");
		  $display("%d ", latency);
		  $finish;
      end
     @(negedge clk);
   end
end endtask

task  out_low_task; begin //SPEC-4 
	
	if(out_valid === 'b0)begin //out_valid is low
	
	if( out !== 'd0) begin //out!==0
        $display("************************************************************");   
        $display("                     SPEC 4 IS FAIL!                        ");   
        $display("*  Output should be 0 while out_valid == 0  at %8t   *",$time);
        $display("************************************************************");
        $finish;
    end

	end

end endtask

task input_while_outvalid_task; begin //SPEC-5 out_valid should be 0 while in_valid is high 
	
	while(in_valid === 'b1 && out_valid !== 'b0)begin
		$display("************************************************************");   
        $display("                     SPEC 5 IS FAIL!                        ");   
        $display("*  Out_valid should be 0 while in_valid == 1  at %8t    *",$time);
        $display("************************************************************");
        $finish;
	
	end
	
end endtask



task check_ans_task;begin //SPEC-8
    out_count = 0;
    out_counter = 0;
    
    while (out_valid===1) begin
        out_count = out_count + 1;
        outside_map; //SPEC8-1
        avoid_lower_obstacles; //SPEC8-2
        avoid_higher_obstacles;
        hitting_train_task;
        jump_task;
        out_counter = out_counter +1 ;
        @(negedge clk);
    end   

    out_low_task;


    if(out_count!=63) begin
		// fail;
		$display ("----------------------------------------------------------------------");
		$display ("                            SPEC 7 IS FAIL!                            ");
		$display ("             out_valid should be high only for 63 cycles -- your out is&d           ",out_count);
		$finish;

    end
end endtask

task outside_map;begin //SPEC8-1
    if(out == 2) golden_init = golden_init - 1 ;
    else if(out == 1) golden_init = golden_init + 1 ;
    
    while(golden_init < 0 || golden_init > 3)begin
        $display ("----------------------------------------------------------------------");
		$display ("                            SPEC 8-1 IS FAIL!                          ");
		$display ("                                                                       ");
        $display ("                                                                       ");
		$finish;
    end
end endtask

task avoid_lower_obstacles;begin //SPEC8-2
    if( out == 2'b10 )begin  //
        while ( map_pattern[golden_init - 1][out_counter + 1] == 2'b01) begin
            $display ("----------------------------------------------------------------------");
	    	$display ("                            SPEC 8-2 IS FAIL!                          ");
	    	$display ("                                                                       ");
            $display ("                                                                       ");
	    	$finish;
        end
    end
    else if(out == 2'b00)begin //
        while ( map_pattern[golden_init][out_counter + 1] == 2'b01) begin
            $display ("----------------------------------------------------------------------");
	    	$display ("                            SPEC 8-2 IS FAIL!                          ");
	    	$display ("                                                                       ");
            $display ("                                                                       ");
	    	$finish;
        end
    end
    else if(out == 2'b01)begin //
        while ( map_pattern[golden_init + 1][out_counter + 1] == 2'b01) begin
            $display ("----------------------------------------------------------------------");
	    	$display ("                            SPEC 8-2 IS FAIL!                          ");
	    	$display ("                                                                       ");
            $display ("                                                                       ");
	    	$finish;
        end
    end

end endtask

task avoid_higher_obstacles;begin
     if( out == 2'b10 )begin  //
        while ( map_pattern[golden_init - 1][out_counter + 1] == 2'b10) begin
            $display ("----------------------------------------------------------------------");
	    	$display ("                            SPEC 8-3 IS FAIL!                          ");
	    	$display ("                                                                       ");
            $display ("                                                                       ");
	    	$finish;
        end
    end
    else if(out == 2'b01)begin //
        while ( map_pattern[golden_init + 1][out_counter + 1] == 2'b10) begin
            $display ("----------------------------------------------------------------------");
	    	$display ("                            SPEC 8-3 IS FAIL!                          ");
	    	$display ("                                                                       ");
            $display ("                                                                       ");
	    	$finish;
        end
    end
    else if(out == 2'b11)begin //
        while ( map_pattern[golden_init ][out_counter + 1] == 2'b10) begin
            $display ("----------------------------------------------------------------------");
	    	$display ("                            SPEC 8-3 IS FAIL!                          ");
	    	$display ("                                                                       ");
            $display ("                                                                       ");
	    	$finish;
        end
    end

end endtask

task hitting_train_task ;begin
    if( out == 2'b10 )begin  //
        while ( map_pattern[golden_init - 1][out_counter + 1] == 2'b11) begin
            $display ("----------------------------------------------------------------------");
	    	$display ("                            SPEC 8-4 IS FAIL!                          ");
	    	$display ("                                                                       ");
            $display ("                                                                       ");
	    	$finish;
        end
    end
    else if(out == 2'b00)begin //
        while ( map_pattern[golden_init][out_counter + 1] == 2'b11) begin
            $display ("----------------------------------------------------------------------");
	    	$display ("                            SPEC 8-4 IS FAIL!                          ");
	    	$display ("                                                                       ");
            $display ("                                                                       ");
	    	$finish;
        end
    end
    else if(out == 2'b01)begin //
        while ( map_pattern[golden_init + 1][out_counter + 1] == 2'b11) begin
            $display ("----------------------------------------------------------------------");
	    	$display ("                            SPEC 8-4 IS FAIL!                          ");
	    	$display ("                                                                       ");
            $display ("                                                                       ");
	    	$finish;
        end
    end

end endtask

task jump_task;begin
    while( map_pattern[golden_init][out_counter] == 2'b01 && out == 2'b11 ) begin
        $display ("----------------------------------------------------------------------");
	    $display ("                            SPEC 8-5 IS FAIL!                          ");
	    $display ("                                                                       ");
        $display ("                                                                       ");
	    $finish;
    end
    



end endtask


task ERIC_task; begin
    
    $display("\033[37m                                                                                                                                          ");        
    $display("\033[37m                                                                                \033[32m      :BBQvi.                                              ");        
    $display("\033[37m                                                              .i7ssrvs7         \033[32m     BBBBBBBBQi                                           ");        
    $display("\033[37m                        .:r7rrrr:::.        .::::::...   .i7vr:.      .B:       \033[32m    :BBBP :7BBBB.                                         ");        
    $display("\033[37m                      .Kv.........:rrvYr7v7rr:.....:rrirJr.   .rgBBBBg  Bi      \033[32m    BBBB     BBBB                                         ");        
    $display("\033[37m                     7Q  :rubEPUri:.       ..:irrii:..    :bBBBBBBBBBBB  B      \033[32m   iBBBv     BBBB       vBr                               ");        
    $display("\033[37m                    7B  BBBBBBBBBBBBBBB::BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB :R     \033[32m   BBBBBKrirBBBB.     :BBBBBB:                            ");        
    $display("\033[37m                   Jd .BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB: Bi    \033[32m  rBBBBBBBBBBBR.    .BBBM:BBB                             ");        
    $display("\033[37m                  uZ .BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB .B    \033[32m  BBBB   .::.      EBBBi :BBU                             ");        
    $display("\033[37m                 7B .BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB  B    \033[32m MBBBr           vBBBu   BBB.                             ");        
    $display("\033[37m                .B  BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB: JJ   \033[32m i7PB          iBBBBB.  iBBB                              ");        
    $display("\033[37m                B. BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB  Lu             \033[32m  vBBBBPBBBBPBBB7       .7QBB5i                ");        
    $display("\033[37m               Y1 KBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBi XBBBBBBBi :B            \033[32m :RBBB.  .rBBBBB.      rBBBBBBBB7              ");        
    $display("\033[37m              :B .BBBBBBBBBBBBBsRBBBBBBBBBBBrQBBBBB. UBBBRrBBBBBBr 1BBBBBBBBB  B.          \033[32m    .       BBBB       BBBB  :BBBB             ");        
    $display("\033[37m              Bi BBBBBBBBBBBBBi :BBBBBBBBBBE .BBK.  .  .   QBBBBBBBBBBBBBBBBBB  Bi         \033[32m           rBBBr       BBBB    BBBU            ");        
    $display("\033[37m             .B .BBBBBBBBBBBBBBQBBBBBBBBBBBB       \033[38;2;242;172;172mBBv \033[37m.LBBBBBBBBBBBBBBBBBBBBBB. B7.:ii:   \033[32m           vBBB        .BBBB   :7i.            ");        
    $display("\033[37m            .B  PBBBBBBBBBBBBBBBBBBBBBBBBBBBBbYQB. \033[38;2;242;172;172mBB: \033[37mBBBBBBBBBBBBBBBBBBBBBBBBB  Jr:::rK7 \033[32m             .7  BBB7   iBBBg                  ");        
    $display("\033[37m           7M  PBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB  \033[38;2;242;172;172mBB. \033[37mBBBBBBBBBBBBBBBBBBBBBBB..i   .   v1                  \033[32mdBBB.   5BBBr                 ");        
    $display("\033[37m          sZ .BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB  \033[38;2;242;172;172mBB. \033[37mBBBBBBBBBBBBBBBBBBBBBBBBBBB iD2BBQL.                 \033[32m ZBBBr  EBBBv     YBBBBQi     ");        
    $display("\033[37m  .7YYUSIX5 .BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB  \033[38;2;242;172;172mBB. \033[37mBBBBBBBBBBBBBBBBBBBBBBBBY.:.      :B                 \033[32m  iBBBBBBBBD     BBBBBBBBB.   ");        
    $display("\033[37m LB.        ..BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB. \033[38;2;242;172;172mBB: \033[37mBBBBBBBBBBBBBBBBBBBBBBBBMBBB. BP17si                 \033[32m    :LBBBr      vBBBi  5BBB   ");        
    $display("\033[37m  KvJPBBB :BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB: \033[38;2;242;172;172mZB: \033[37mBBBBBBBBBBBBBBBBBBBBBBBBBsiJr .i7ssr:                \033[32m          ...   :BBB:   BBBu  ");        
    $display("\033[37m i7ii:.   ::BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBj \033[38;2;242;172;172muBi \033[37mQBBBBBBBBBBBBBBBBBBBBBBBBi.ir      iB                \033[32m         .BBBi   BBBB   iMBu  ");        
    $display("\033[37mDB    .  vBdBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBg \033[38;2;242;172;172m7Bi \033[37mBBBBBBBBBBBBBBBBBBBBBBBBBBBBB rBrXPv.                \033[32m          BBBX   :BBBr        ");        
    $display("\033[37m :vQBBB. BQBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBQ \033[38;2;242;172;172miB: \033[37mBBBBBBBBBBBBBBBBBBBBBBBBBBBBB .L:ii::irrrrrrrr7jIr   \033[32m          .BBBv  :BBBQ        ");        
    $display("\033[37m :7:.   .. 5BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB  \033[38;2;242;172;172mBr \033[37mBBBBBBBBBBBBBBBBBBBBBBBBBBBB:            ..... ..YB. \033[32m           .BBBBBBBBB:        ");        
    $display("\033[37mBU  .:. BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB  \033[38;2;242;172;172mB7 \033[37mgBBBBBBBBBBBBBBBBBBBBBBBBBB. gBBBBBBBBBBBBBBBBBB. BL \033[32m             rBBBBB1.         ");        
    $display("\033[37m rY7iB: BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB: \033[38;2;242;172;172mB7 \033[37mBBBBBBBBBBBBBBBBBBBBBBBBBB. QBBBBBBBBBBBBBBBBBi  v5                                ");        
    $display("\033[37m     us EBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB \033[38;2;242;172;172mIr \033[37mBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBgu7i.:BBBBBBBr Bu                                 ");        
    $display("\033[37m      B  7BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB.\033[38;2;242;172;172m:i \033[37mBBBBBBBBBBBBBBBBBBBBBBBBBBBv:.  .. :::  .rr    rB                                  ");        
    $display("\033[37m      us  .BBBBBBBBBBBBBQLXBBBBBBBBBBBBBBBBBBBBBBBBq  .BBBBBBBBBBBBBBBBBBBBBBBBBv  :iJ7vri:::1Jr..isJYr                                   ");        
    $display("\033[37m      B  BBBBBBB  MBBBM      qBBBBBBBBBBBBBBBBBBBBBB: BBBBBBBBBBBBBBBBBBBBBBBBBB  B:           iir:                                       ");        
    $display("\033[37m     iB iBBBBBBBL       BBBP. :BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB  B.                                                       ");        
    $display("\033[37m     P: BBBBBBBBBBB5v7gBBBBBB  BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB: Br                                                        ");        
    $display("\033[37m     B  BBBs 7BBBBBBBBBBBBBB7 :BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB .B                                                         ");        
    $display("\033[37m    .B :BBBB.  EBBBBBQBBBBBJ .BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB. B.                                                         ");        
    $display("\033[37m    ij qBBBBBg          ..  .BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB .B                                                          ");        
    $display("\033[37m    UY QBBBBBBBBSUSPDQL...iBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBK EL                                                          ");        
    $display("\033[37m    B7 BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB: B:                                                          ");        
    $display("\033[37m    B  BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBYrBB vBBBBBBBBBBBBBBBBBBBBBBBB. Ls                                                          ");        
    $display("\033[37m    B  BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBi_  /UBBBBBBBBBBBBBBBBBBBBBBBBB. :B:                                                        ");        
    $display("\033[37m   rM .BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB  ..IBBBBBBBBBBBBBBBBQBBBBBBBBBB  B                                                        ");        
    $display("\033[37m   B  BBBBBBBBBdZBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBPBBBBBBBBBBBBEji:..     sBBBBBBBr Br                                                       ");        
    $display("\033[37m  7B 7BBBBBBBr     .:vXQBBBBBBBBBBBBBBBBBBBBBBBBBQqui::..  ...i:i7777vi  BBBBBBr Bi                                                       ");        
    $display("\033[37m  Ki BBBBBBB  rY7vr:i....  .............:.....  ...:rii7vrr7r:..      7B  BBBBB  Bi                                                       ");        
    $display("\033[37m  B. BBBBBB  B:    .::ir77rrYLvvriiiiiiirvvY7rr77ri:..                 bU  iQBB:..rI                                                      ");        
    $display("\033[37m.S: 7BBBBP  B.                                                          vI7.  .:.  B.                                                     ");        
    $display("\033[37mB: ir:.   :B.                                                             :rvsUjUgU.                                                      ");        
    $display("\033[37mrMvrrirJKur                                                                                                                               \033[m");
    $display ("-----------------------------------------------------------------------------------------------------------------------------------");
    $display ("                                                  Congratulations!                                                ");
    $display ("                                           You have passed all patterns!                                          ");
    $display ("                                                                                                                  ");
    $display ("-----------------------------------------------------------------------------------------------------------------------------------");

    $finish; 
end endtask



endmodule
