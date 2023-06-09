`include "AFIFO.v"

module CDC #(parameter DSIZE = 8,
			   parameter ASIZE = 4)(
	//Input Port
	rst_n,
	clk1,
    clk2,
	in_valid,
    doraemon_id,
    size,
    iq_score,
    eq_score,
    size_weight,
    iq_weight,
    eq_weight,
    //Output Port
	ready,
    out_valid,
	out,
    
); 
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION
//---------------------------------------------------------------------
output reg  [7:0] out;
output reg	out_valid,ready;

input rst_n, clk1, clk2, in_valid;
input  [4:0]doraemon_id;
input  [7:0]size;
input  [7:0]iq_score;
input  [7:0]eq_score;
input  [2:0]size_weight,iq_weight,eq_weight;
//---------------------------------------------------------------------
//   WIRE AND REG DECLARATION
//---------------------------------------------------------------------
reg     [4:0]id_reg[0:4];
reg     [7:0]size_reg[0:4];
reg     [7:0]iq_score_reg[0:4];
reg     [7:0]eq_score_reg[0:4];
reg     [2:0]size_weight_reg, iq_weight_reg, eq_weight_reg;
reg     [15:0]cnt_in, cnt_out;

wire    [13:0]preference_score[0:4];
wire    [21:0]pre_output[0:4];
wire    [21:0]max_score[0:3] ;
wire    [7:0]result_temp;
wire    [3:0]door;

reg     w_en ;
reg     r_en ;
wire    rempty, wfull ;
wire    [7:0]wdata;
wire    [7:0]rdata;
reg     [7:0]temp_out ;
reg     [6:0]cnt;
reg     in_valid_reg;
reg     [4:0]cnt_six_thousand;
//---------------------------------------------------------------------
//   EAT INPUT
//---------------------------------------------------------------------
always @(posedge clk1 or negedge rst_n) begin
    if(!rst_n)begin
        id_reg[0] <= 0 ;
        id_reg[1] <= 0 ;
        id_reg[2] <= 0 ;
        id_reg[3] <= 0 ;
        id_reg[4] <= 0 ;
        id_reg[5] <= 0 ;
    end
    else if(in_valid) begin
        if(cnt_in <= 4 )id_reg[cnt_in] <= doraemon_id ;    
        else            id_reg[door] <= doraemon_id ; 
    end
    else begin
        id_reg[0] <= id_reg[0]  ;
        id_reg[1] <= id_reg[1]  ;
        id_reg[2] <= id_reg[2]  ;
        id_reg[3] <= id_reg[3]  ;
        id_reg[4] <= id_reg[4]  ;
        id_reg[5] <= id_reg[5]  ;
    end
end

always@(posedge clk1 or negedge rst_n)begin
    if(!rst_n) begin
        size_reg[0] <= 0 ;
        size_reg[1] <= 0 ;
        size_reg[2] <= 0 ;
        size_reg[3] <= 0 ;
        size_reg[4] <= 0 ;
    end
    else if(in_valid) begin
        if(cnt_in <= 4)     size_reg[cnt_in] <= size ;
        else                size_reg[door]   <= size ;
    end
    else begin
        size_reg[0] <= size_reg[0] ;
        size_reg[1] <= size_reg[1] ;
        size_reg[2] <= size_reg[2] ;
        size_reg[3] <= size_reg[3] ;
        size_reg[4] <= size_reg[4] ;
    end

end

always@(posedge clk1 or negedge rst_n)begin
    if(!rst_n)begin
        iq_score_reg[0] <= 0 ;
        iq_score_reg[1] <= 0 ;
        iq_score_reg[2] <= 0 ;
        iq_score_reg[3] <= 0 ;
        iq_score_reg[4] <= 0 ;
    end
    else if(in_valid) begin
        if(cnt_in <= 4)     iq_score_reg[cnt_in] <= iq_score ;
        else                iq_score_reg[door] <= iq_score ;
    end
    else begin
        iq_score_reg[0] <= iq_score_reg[0] ;
        iq_score_reg[1] <= iq_score_reg[1] ;
        iq_score_reg[2] <= iq_score_reg[2] ;
        iq_score_reg[3] <= iq_score_reg[3] ;
        iq_score_reg[4] <= iq_score_reg[4] ;

    end
end

always@(posedge clk1 or negedge rst_n)begin
    if(!rst_n)begin
        eq_score_reg[0] <= 0 ;
        eq_score_reg[1] <= 0 ;
        eq_score_reg[2] <= 0 ;
        eq_score_reg[3] <= 0 ;
        eq_score_reg[4] <= 0 ;
    end
    else if(in_valid)begin
        if(cnt_in <= 4)     eq_score_reg[cnt_in] <= eq_score ;
        else                eq_score_reg[door]   <= eq_score ;
    end
    else begin
        eq_score_reg[0] <= eq_score_reg[0] ;
        eq_score_reg[1] <= eq_score_reg[1] ;
        eq_score_reg[2] <= eq_score_reg[2] ;
        eq_score_reg[3] <= eq_score_reg[3] ;
        eq_score_reg[4] <= eq_score_reg[4] ;
    end
end

always@(posedge clk1 or negedge rst_n)begin
    if(!rst_n)      size_weight_reg <= 0 ;
    else if(in_valid)begin
        if(cnt_in >= 4) size_weight_reg <= size_weight;
    end
    else begin
        size_weight_reg <= size_weight_reg ;
    end
end

always@(posedge clk1 or negedge rst_n)begin
    if(!rst_n)      iq_weight_reg <= 0 ;
    else if(in_valid)begin
         if(cnt_in >= 4) iq_weight_reg <= iq_weight;
    end
    else begin
        iq_weight_reg <= iq_weight_reg ;
    end
end

always@(posedge clk1 or negedge rst_n)begin
    if(!rst_n)      eq_weight_reg <= 0 ;
    else if(in_valid)begin
        if(cnt_in >= 4) eq_weight_reg <= eq_weight;
    end
    else begin
        eq_weight_reg <= eq_weight_reg ;
    end
end


assign  preference_score[0] = ( size_reg[0]*size_weight_reg ) + ( iq_score_reg[0]*iq_weight_reg ) + (eq_score_reg[0]*eq_weight_reg ) ;
assign  preference_score[1] = ( size_reg[1]*size_weight_reg ) + ( iq_score_reg[1]*iq_weight_reg ) + (eq_score_reg[1]*eq_weight_reg ) ;
assign  preference_score[2] = ( size_reg[2]*size_weight_reg ) + ( iq_score_reg[2]*iq_weight_reg ) + (eq_score_reg[2]*eq_weight_reg ) ;
assign  preference_score[3] = ( size_reg[3]*size_weight_reg ) + ( iq_score_reg[3]*iq_weight_reg ) + (eq_score_reg[3]*eq_weight_reg ) ;
assign  preference_score[4] = ( size_reg[4]*size_weight_reg ) + ( iq_score_reg[4]*iq_weight_reg ) + (eq_score_reg[4]*eq_weight_reg ) ;


assign  pre_output[0] = {3'b000, id_reg[0], preference_score[0]};
assign  pre_output[1] = {3'b001, id_reg[1], preference_score[1]};
assign  pre_output[2] = {3'b010, id_reg[2], preference_score[2]};
assign  pre_output[3] = {3'b011, id_reg[3], preference_score[3]};
assign  pre_output[4] = {3'b100, id_reg[4], preference_score[4]};

assign  max_score[0] = (preference_score[0]     >=  preference_score[1]) ? pre_output[0]       : pre_output[1] ;
assign  max_score[1] = (max_score[0][13:0]      >=  preference_score[2]) ? max_score[0]        : pre_output[2] ;
assign  max_score[2] = (max_score[1][13:0]      >=  preference_score[3]) ? max_score[1]        : pre_output[3] ;
assign  max_score[3] = (max_score[2][13:0]      >=  preference_score[4]) ? max_score[2]        : pre_output[4] ;


assign  door = max_score[3][21:19];
assign  result_temp = max_score[3][21:14] ;


always@(posedge clk1 or negedge rst_n)begin
    if(!rst_n)  cnt_in <= 0;
    else begin
        if(in_valid == 1'b1)  cnt_in <= cnt_in + 1;
    end
end

// always@(posedge clk1 or negedge rst_n)begin
//     if(!rst_n)                  cnt <= 0 ;
//     else begin
//         if(cnt_in > 5999)       cnt <= cnt + 1 ;
//         else                    cnt <= 0 ;
//     end
// end


AFIFO #(DSIZE , ASIZE )
    F1( .rst_n(rst_n) ,
        //Input Port (read)
        .rclk(clk2),
        .rinc(r_en),
	    //Input Port (write)
        .wclk(clk1),
        .winc(w_en),
	    .wdata(wdata),

        //Output Port (read)
        .rempty(rempty),
	    .rdata(rdata),
        //Output Port (write)
        .wfull(wfull)
    ); 

always@(*)begin
    if(wfull == 1'b1)          w_en = 1'b0 ;  
    else begin
        if(cnt_in == 6000 && cnt_six_thousand == 1'b0)    w_en = in_valid_reg ;
        else if(cnt_in > 4 )       w_en = in_valid;
        else                       w_en = 1'b0 ;
    end
end

always@(posedge clk1 or negedge rst_n)begin
    if(!rst_n)         cnt_six_thousand = 0;
    else begin
        if(cnt_in == 6000)  cnt_six_thousand = cnt_six_thousand + 1 ;
    end

end

// always@(*)begin
//     if(wfull == 1'b1)  r_en = 1'b1;
//     else               r_en = 1'b0;     

// end



always@(*)begin
    if(rempty == 1'b0)  r_en = 1'b1;
    else                r_en = 1'b0;
end


assign  wdata = result_temp;

// always@(*)begin
//     r_en = 0 ;
// end

always@(posedge clk1 or negedge rst_n)begin
    if(!rst_n)      in_valid_reg <= 0;
    else begin
                    in_valid_reg <= in_valid;
    end
end

// always@(*)begin
//     if(wfull == 1'b1)  wdata = 0 ;
//     else if(in_valid)  wdata = result_temp ;
//     else               wdata = 0 ;
// end


// always@(*)begin
//     if(wfull == 1'b1)  wdata = 0 ;
//     else if(in_valid)  wdata = result_temp ;
//     else if(in_valid_reg == 1'b1 && cnt_in == 6000)  wdata = result_temp ;
//     else               wdata = 0  ;
// end

always@(*)begin
    if(!rst_n)                ready = 1'b0;
    else if(cnt_in == 6000 )  ready = 1'b0;
    else begin
        if(wfull == 1'b0 )     ready = 1'b1 ;
        else                   ready = 1'b0 ;
    
    end
end


always@(posedge clk2 or negedge rst_n)begin
    if(!rst_n)          out_valid <= 0;
    else begin
        if(r_en)       out_valid <= 1;
        else           out_valid <= 0;
    end
end

always@(posedge clk2 or negedge rst_n)begin
    if(!rst_n)              out <= 0 ;
    else begin
        if(r_en)            out <= rdata;
        else                out <= 0;
    end
end
//OUTPUT


always@(posedge clk2 or negedge rst_n)begin
    if(!rst_n)         cnt_out <= 0 ;
    else begin
        if(out_valid)  cnt_out <= cnt_out + 1 ;
    end
end

















endmodule
