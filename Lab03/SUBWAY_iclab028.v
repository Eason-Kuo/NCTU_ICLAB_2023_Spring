module SUBWAY(
    //Input Port
    clk,
    rst_n,
    in_valid,
    init,
    in0,
    in1,
    in2,
    in3,
    //Output Port
    out_valid,
    out
);


input clk, rst_n;
input in_valid;
input [1:0] init;
input [1:0] in0, in1, in2, in3; 
output reg       out_valid;
output reg [1:0] out;


//==============================================//
//       parameter & integer declaration        //
//==============================================//
integer i,j ;
parameter IDLE = 4'd0;
parameter STATE1 = 4'd1;
//parameter out_state = 4'd2;


//==============================================//
//           reg & wire declaration             //
//==============================================//
reg   [1:0]map[0:3][0:63] ;
reg   [6:0]cnter,cnter2 ;
reg   [4:0]current_state;
reg   [4:0]next_state;
reg   [1:0]initial_position;
reg  signed [4:0]decision1 ;
reg  signed [4:0]decision2 ;
reg  signed [4:0]decision3 ;
reg  signed [4:0]decision4 ;
reg  signed [4:0]decision5 ;
reg  signed [4:0]decision6 ;
reg  signed [4:0]decision7 ;
reg   [4:0]decision_pt1 ;
reg   [4:0]decision_pt2 ;
reg   [4:0]decision_pt3 ;
reg   [4:0]decision_pt4 ;
reg   [4:0]decision_pt5 ;
reg   [4:0]decision_pt6 ;
reg   [4:0]decision_pt7 ;
reg   [1:0]out_action[0:63];

reg   [1:0]point1,point2,point3,point4,point5,point6,point7;

//Compute the row of the point
always@(*)begin
    if(decision1 > 0) point1 = initial_position - 1;
    else if (decision1 < 0) point1 = initial_position + 1;
    else  point1 = initial_position ;  
end
always@(*)begin
    if(decision2 > 0) point2 = decision_pt1 - 1;
    else if (decision2 < 0) point2 = decision_pt1 + 1;
    else  point2 = decision_pt1 ;  
end
always@(*)begin
    if(decision3 > 0) point3 = decision_pt2 - 1;
    else if (decision3 < 0) point3 = decision_pt2 + 1;
    else  point3 = decision_pt2 ;  
end
always@(*)begin
    if(decision4 > 0) point4 = decision_pt3 - 1;
    else if (decision4 < 0) point4 = decision_pt3 + 1;
    else  point4 = decision_pt3 ;  
end
always@(*)begin
    if(decision5 > 0) point5 = decision_pt4 - 1;
    else if (decision5 < 0) point5 = decision_pt4 + 1;
    else  point5 = decision_pt4 ;  
end
always@(*)begin
    if(decision6 > 0) point6 = decision_pt5 - 1;
    else if (decision6 < 0) point6 = decision_pt5 + 1;
    else  point6 = decision_pt5 ;  
end
always@(*)begin
    if(decision7 > 0) point7 = decision_pt6 - 1;
    else if (decision7 < 0) point7 = decision_pt6 + 1;
    else  point7 = decision_pt6 ;  
end

//==============================================//
//                  design                      //
//==============================================//
///decide the direction
always@(*)
begin
    if(map[0][8] == 2'b00)  begin
        decision1 = initial_position - 0 ;
        decision_pt1 = initial_position - decision1; 
    end
    else if(map[1][8] == 2'b00) begin
         decision1 = initial_position - 1 ;
         decision_pt1 = initial_position - decision1; 
    end
    else if(map[2][8] == 2'b00) begin
         decision1 = initial_position - 2;
         decision_pt1 = initial_position - decision1; 
    end
    else begin
        decision1 = initial_position - 3;
        decision_pt1 = initial_position - decision1; 
    end
end
always@(*)
begin
    if(map[0][16] == 2'b00)  begin
        decision2 = decision_pt1 - 0 ;
        decision_pt2 = decision_pt1 - decision2; 
    end
    else if(map[1][16] == 2'b00) begin
        decision2 = decision_pt1 - 1 ;
        decision_pt2 = decision_pt1 - decision2; 
    end
    else if(map[2][16] == 2'b00) begin
        decision2 = decision_pt1 - 2 ;
        decision_pt2 = decision_pt1 - decision2; 
    end
    else begin
        decision2 = decision_pt1 - 3 ;
        decision_pt2 = decision_pt1 - decision2;  
    end
end
always@(*)
begin
    if(map[0][24] == 2'b00)  begin
        decision3 = decision_pt2 - 0 ;
        decision_pt3 = decision_pt2 - decision3;  
    end
    else if(map[1][24] == 2'b00) begin
        decision3 = decision_pt2 - 1 ;
        decision_pt3 = decision_pt2 - decision3;  
    end
    else if(map[2][24] == 2'b00) begin
        decision3 = decision_pt2 - 2 ;
        decision_pt3 = decision_pt2 - decision3;  
    end
    else begin
        decision3 = decision_pt2 - 3 ;
        decision_pt3 = decision_pt2 - decision3;  
    end
end
always@(*)
begin
    if(map[0][32] == 2'b00)  begin
        decision4 = decision_pt3 - 0 ;
        decision_pt4 = decision_pt3 - decision4;  
    end
    else if(map[1][32] == 2'b00) begin
        decision4 = decision_pt3 - 1 ;
        decision_pt4 = decision_pt3- decision4;   
    end
    else if(map[2][32] == 2'b00) begin
         decision4 = decision_pt3 - 2 ;
        decision_pt4 = decision_pt3 - decision4;  
    end
    else begin
         decision4 = decision_pt3 - 3 ;
        decision_pt4 = decision_pt3 - decision4;   
    end
end
always@(*)
begin
    if(map[0][40] == 2'b00)  begin
        decision5 = decision_pt4 - 0 ;
        decision_pt5 = decision_pt4 - decision5;  
    end
    else if(map[1][40] == 2'b00) begin
        decision5 = decision_pt4 - 1 ;
        decision_pt5 = decision_pt4- decision5;   
    end
    else if(map[2][40] == 2'b00) begin
         decision5 = decision_pt4 - 2 ;
        decision_pt5 = decision_pt4 - decision5;  
    end
    else begin
         decision5 = decision_pt4 - 3 ;
        decision_pt5 = decision_pt4 - decision5;   
    end
end
always@(*)
begin
    if(map[0][48] == 2'b00)  begin
        decision6 = decision_pt5 - 0 ;
        decision_pt6 = decision_pt5 - decision6; 
    end
    else if(map[1][48] == 2'b00) begin
        decision6 = decision_pt5 - 1 ;
        decision_pt6 = decision_pt5 - decision6; 
    end
    else if(map[2][48] == 2'b00) begin
        decision6 = decision_pt5 - 2 ;
        decision_pt6 = decision_pt5 - decision6; 
    end
    else begin
        decision6 = decision_pt5 - 3 ;
        decision_pt6 = decision_pt5 - decision6; 
    end
end
always@(*)
begin
    if(map[0][56] == 2'b00)  begin
        decision7 = decision_pt6 - 0 ;
        decision_pt7 = decision_pt6 - decision7; 
    end
    else if(map[1][56] == 2'b00) begin
        decision7 = decision_pt6 - 1 ;
        decision_pt7 = decision_pt6 - decision7; 
    end
    else if(map[2][56] == 2'b00) begin
        decision7 = decision_pt6 - 2 ;
        decision_pt7 = decision_pt6 - decision7; 
    end
    else begin
        decision7 = decision_pt6 - 3 ;
        decision_pt7 = decision_pt6 - decision7; 
    end
end
/////////////////////////////////////////////

//map reset
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)begin
        for(i=0 ; i < 4 ; i=i+1 )begin
            for(j=0 ; j < 64 ; j=j+1)begin
                map[i][j]  <= 2'b00;
            end
        end
    end
    else if(in_valid)begin
        map[0][cnter] <= in0; 
        map[1][cnter] <= in1; 
        map[2][cnter] <= in2; 
        map[3][cnter] <= in3; 
    end
    else begin
        for(i=0 ; i < 4 ; i=i+1 )begin
            for(j=0 ; j < 64 ; j=j+1)begin
                map[i][j]  <= map[i][j];
            end
        end
    end
end

//counter to enter input to map
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)begin
       cnter <= 4'b0000;
    end
    else if(in_valid)begin
        cnter <= cnter + 1;        
    end
    else begin
        cnter <= 4'b0000;
    end
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)  initial_position = 2'b00;
    else if((in_valid == 1'b1) && (cnter == 4'b0000)) initial_position = init;
    else initial_position = initial_position;

end


//Finite-State Machine
always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)  current_state <= IDLE;
    else current_state <= next_state;
end

always@(*)
begin
    case(current_state)
    IDLE : begin
        if(!in_valid && cnter > 5) next_state = STATE1;
        else         next_state = IDLE;
    end
    STATE1 :begin
        if(!out_valid && cnter2 != 0) next_state = IDLE;
        else           next_state = STATE1;
    end
    // out_state : begin
    //     if(out_valid) next_state = out_state;
    //     else          next_state = IDLE;
    // end
    default : next_state = current_state;
    endcase
end


always@(posedge clk or negedge rst_n)begin
    if(!rst_n)     out_valid <= 1'b0;
    else begin
        case(current_state)
        STATE1 : begin
            if(cnter2 < 63)out_valid <= 1'b1;
            else           out_valid <= 1'b0;
        end
        default:;
        endcase
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)     out <= 2'b00;
    else begin
        case(current_state)
        IDLE : begin
            out <= 2'b00;
        end
        STATE1 : begin
            if(cnter2 < 63)   out <= out_action[cnter2];
            else            out <= 2'b00;
        end
        default:;
        endcase
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)    cnter2 <= 2'b00;
    else begin
        case(current_state)
        IDLE : begin
            cnter2 <= 2'b00;
        end
        STATE1: begin
            cnter2 <= cnter2 + 1;
        end
        default:;
        endcase
end
end



//game

//first group (0-7)
always@(*)begin
    if(current_state == IDLE) out_action[0] = 2'b00;
    else                      out_action[0] = 2'b00;   
end

always@(*)begin
    if(current_state == IDLE) out_action[1] = 2'b00;
    else begin 
        if(map[initial_position][2] == 2'b01) out_action[1] = 2'b11 ;
        else out_action[1] = 2'b00;
    end
end

always@(*)begin
    if(current_state == IDLE) out_action[2] = 2'b00;
    else out_action[2] =  2'b00;
end

always@(*)begin
    if(current_state == IDLE) out_action[3] = 2'b00;
    else begin
         if(map[initial_position][4] == 2'b01) out_action[3] = 2'b11;
         else  out_action[3] = 2'b00;
    end
end

always@(*)begin
    if(current_state == IDLE) out_action[4] = 2'b00;
    else begin 
        if(decision1 > 0) out_action[4] = 2'b10;  //left
        else if(decision1 < 0 ) out_action[4] = 2'b01; //right
        else out_action[4] = 2'b00;

    end
end

always@(*)begin 
    if(current_state == IDLE) out_action[5] = 2'b00;
    else begin
        if(map[point1][6] == 2'b01) out_action[5] = 2'b11;
        else                        out_action[5] = 2'b00;  
    end
end
//////////////////////////////////////////////
always@(*)begin 
    if(current_state == IDLE) out_action[6] = 2'b00;
    else begin
        if(decision1 > 0) begin //during rise 
            if(decision1 -1 > 0) out_action[6] = 2'b10; //rise not enough
            else out_action[6] = 2'b00; //rise is enough, then go straight
        end
        else if(decision1 < 0)begin //during fall
            if(decision1 + 1 < 0) out_action[6] = 2'b01;//fall not enough
            else out_action[6] = 2'b00; // fall is enough, then go straight
        end
        else    out_action[6] =2'b00; //in the beginneing decision equals zero
    end
end

always@(*)begin 
    if(current_state == IDLE) out_action[7] = 2'b00;
    else begin
        if(decision1 > 0) begin //during rise 
            if(decision1 - 2 > 0) out_action[7] = 2'b10; //rise not enough
            else out_action[7] = 2'b00; //rise is enough, then go straight
        end
        else if(decision1 < 0)begin //during fall
            if(decision1 + 2 < 0) out_action[7] = 2'b01;//fall not enough
            else out_action[7] = 2'b00; // fall is enough, then go straight
        end
        else    out_action[7] =2'b00; //in the beginneing decision equals zero
    end
end


///second group (8-15)
always@(*)begin
    if(current_state == IDLE) out_action[8] = 2'b00;
    else                      out_action[8] = 2'b00;   
end

always@(*)begin
    if(current_state == IDLE) out_action[9] = 2'b00;
    else begin 
        if(map[decision_pt1][10] == 2'b01) out_action[9] = 2'b11 ;
        else out_action[9] = 2'b00;
    end
end

always@(*)begin
    if(current_state == IDLE) out_action[10] = 2'b00;
    else out_action[10] =  2'b00;
end

always@(*)begin
    if(current_state == IDLE) out_action[11] = 2'b00;
    else begin
         if(map[decision_pt1][12] == 2'b01) out_action[11] = 2'b11;
         else  out_action[11] = 2'b00;
    end
end

always@(*)begin
    if(current_state == IDLE) out_action[12] = 2'b00;
    else begin 
        if(decision2 > 0) out_action[12] = 2'b10;  //left
        else if(decision2 < 0 ) out_action[12] = 2'b01; //right
        else out_action[12] = 2'b00;

    end
end

always@(*)begin 
    if(current_state == IDLE) out_action[13] = 2'b00;
    else begin
        if(map[point2][14] == 2'b01) out_action[13] = 2'b11;
        else                        out_action[13] = 2'b00;  
    end
end

always@(*)begin 
    if(current_state == IDLE) out_action[14] = 2'b00;
    else begin
        if(decision2 > 0) begin //during rise 
            if(decision2 -1 > 0) out_action[14] = 2'b10; //rise not enough
            else out_action[14] = 2'b00; //rise is enough, then go straight
        end
        else if(decision2 < 0)begin //during fall
            if(decision2 + 1 < 0) out_action[14] = 2'b01;//fall not enough
            else out_action[14] = 2'b00; // fall is enough, then go straight
        end
        else    out_action[14] =2'b00; //in the beginneing decision equals zero
    end
end

always@(*)begin 
    if(current_state == IDLE) out_action[15] = 2'b00;
    else begin
        if(decision2 > 0) begin //during rise 
            if(decision2 - 2 > 0) out_action[15] = 2'b10; //rise not enough
            else out_action[15] = 2'b00; //rise is enough, then go straight
        end
        else if(decision2 < 0)begin //during fall
            if(decision2 + 2 < 0) out_action[15] = 2'b01;//fall not enough
            else out_action[15] = 2'b00; // fall is enough, then go straight
        end
        else    out_action[15] =2'b00; //in the beginneing decision equals zero
    end
end

///third group (8-15)
always@(*)begin
    if(current_state == IDLE) out_action[16] = 2'b00;
    else                      out_action[16] = 2'b00;   
end

always@(*)begin
    if(current_state == IDLE) out_action[17] = 2'b00;
    else begin 
        if(map[decision_pt2][18] == 2'b01) out_action[17] = 2'b11 ;
        else out_action[17] = 2'b00;
    end
end

always@(*)begin
    if(current_state == IDLE) out_action[18] = 2'b00;
    else out_action[18] =  2'b00;
end

always@(*)begin
    if(current_state == IDLE) out_action[19] = 2'b00;
    else begin
         if(map[decision_pt2][20] == 2'b01) out_action[19] = 2'b11;
         else  out_action[19] = 2'b00;
    end
end

always@(*)begin
    if(current_state == IDLE) out_action[20] = 2'b00;
    else begin 
        if(decision3 > 0) out_action[20] = 2'b10;  //left
        else if(decision3 < 0 ) out_action[20] = 2'b01; //right
        else out_action[20] = 2'b00;

    end
end

always@(*)begin 
    if(current_state == IDLE) out_action[21] = 2'b00;
    else begin
        if(map[point3][22] == 2'b01) out_action[21] = 2'b11;
        else                        out_action[21] = 2'b00;  
    end
end

always@(*)begin 
    if(current_state == IDLE) out_action[22] = 2'b00;
    else begin
        if(decision3 > 0) begin //during rise 
            if(decision3 -1 > 0) out_action[22] = 2'b10; //rise not enough
            else out_action[22] = 2'b00; //rise is enough, then go straight
        end
        else if(decision3 < 0)begin //during fall
            if(decision3 + 1 < 0) out_action[22] = 2'b01;//fall not enough
            else out_action[22] = 2'b00; // fall is enough, then go straight
        end
        else    out_action[22] =2'b00; //in the beginneing decision equals zero
    end
end

always@(*)begin 
    if(current_state == IDLE) out_action[23] = 2'b00;
    else begin
        if(decision3 > 0) begin //during rise 
            if(decision3 - 2 > 0) out_action[23] = 2'b10; //rise not enough
            else out_action[23] = 2'b00; //rise is enough, then go straight
        end
        else if(decision3 < 0)begin //during fall
            if(decision3 + 2 < 0) out_action[23] = 2'b01;//fall not enough
            else out_action[23] = 2'b00; // fall is enough, then go straight
        end
        else    out_action[23] =2'b00; //in the beginneing decision equals zero
    end
end

//forth group
always@(*)begin
    if(current_state == IDLE) out_action[24] = 2'b00;
    else                      out_action[24] = 2'b00;   
end

always@(*)begin
    if(current_state == IDLE) out_action[25] = 2'b00;
    else begin 
        if(map[decision_pt3][26] == 2'b01) out_action[25] = 2'b11 ;
        else out_action[25] = 2'b00;
    end
end

always@(*)begin
    if(current_state == IDLE) out_action[26] = 2'b00;
    else out_action[26] =  2'b00;
end

always@(*)begin
    if(current_state == IDLE) out_action[27] = 2'b00;
    else begin
         if(map[decision_pt3][28] == 2'b01) out_action[27] = 2'b11;
         else  out_action[27] = 2'b00;
    end
end

always@(*)begin
    if(current_state == IDLE) out_action[28] = 2'b00;
    else begin 
        if(decision4 > 0) out_action[28] = 2'b10;  //left
        else if(decision4 < 0 ) out_action[28] = 2'b01; //right
        else out_action[28] = 2'b00;

    end
end

always@(*)begin 
    if(current_state == IDLE) out_action[29] = 2'b00;
    else begin
        if(map[point4][30] == 2'b01) out_action[29] = 2'b11;
        else                        out_action[29] = 2'b00;  
    end
end

always@(*)begin 
    if(current_state == IDLE) out_action[30] = 2'b00;
    else begin
        if(decision4 > 0) begin //during rise 
            if(decision4 -1 > 0) out_action[30] = 2'b10; //rise not enough
            else out_action[30] = 2'b00; //rise is enough, then go straight
        end
        else if(decision4 < 0)begin //during fall
            if(decision4 + 1 < 0) out_action[30] = 2'b01;//fall not enough
            else out_action[30] = 2'b00; // fall is enough, then go straight
        end
        else    out_action[30] =2'b00; //in the beginneing decision equals zero
    end
end

always@(*)begin 
    if(current_state == IDLE) out_action[31] = 2'b00;
    else begin
        if(decision4 > 0) begin //during rise 
            if(decision4 - 2 > 0) out_action[31] = 2'b10; //rise not enough
            else out_action[31] = 2'b00; //rise is enough, then go straight
        end
        else if(decision4 < 0)begin //during fall
            if(decision4 + 2 < 0) out_action[31] = 2'b01;//fall not enough
            else out_action[31] = 2'b00; // fall is enough, then go straight
        end
        else    out_action[31] =2'b00; //in the beginneing decision equals zero
    end
end

//five group

always@(*)begin
    if(current_state == IDLE) out_action[32] = 2'b00;
    else                      out_action[32] = 2'b00;   
end

always@(*)begin
    if(current_state == IDLE) out_action[33] = 2'b00;
    else begin 
        if(map[decision_pt4][34] == 2'b01) out_action[33] = 2'b11 ;
        else out_action[33] = 2'b00;
    end
end

always@(*)begin
    if(current_state == IDLE) out_action[34] = 2'b00;
    else out_action[34] =  2'b00;
end

always@(*)begin
    if(current_state == IDLE) out_action[35] = 2'b00;
    else begin
         if(map[decision_pt4][36] == 2'b01) out_action[35] = 2'b11;
         else  out_action[35] = 2'b00;
    end
end

always@(*)begin
    if(current_state == IDLE) out_action[36] = 2'b00;
    else begin 
        if(decision5 > 0) out_action[36] = 2'b10;  //left
        else if(decision5 < 0 ) out_action[36] = 2'b01; //right
        else out_action[36] = 2'b00;

    end
end

always@(*)begin 
    if(current_state == IDLE) out_action[37] = 2'b00;
    else begin
        if(map[point5][38] == 2'b01) out_action[37] = 2'b11;
        else                        out_action[37] = 2'b00;  
    end
end

always@(*)begin 
    if(current_state == IDLE) out_action[38] = 2'b00;
    else begin
        if(decision5 > 0) begin //during rise 
            if(decision5 -1 > 0) out_action[38] = 2'b10; //rise not enough
            else out_action[38] = 2'b00; //rise is enough, then go straight
        end
        else if(decision5 < 0)begin //during fall
            if(decision5 + 1 < 0) out_action[38] = 2'b01;//fall not enough
            else out_action[38] = 2'b00; // fall is enough, then go straight
        end
        else    out_action[38] =2'b00; //in the beginneing decision equals zero
    end
end

always@(*)begin 
    if(current_state == IDLE) out_action[39] = 2'b00;
    else begin
        if(decision5 > 0) begin //during rise 
            if(decision5 - 2 > 0) out_action[39] = 2'b10; //rise not enough
            else out_action[39] = 2'b00; //rise is enough, then go straight
        end
        else if(decision5 < 0)begin //during fall
            if(decision5 + 2 < 0) out_action[39] = 2'b01;//fall not enough
            else out_action[39] = 2'b00; // fall is enough, then go straight
        end
        else    out_action[39] =2'b00; //in the beginneing decision equals zero
    end

end

//six group
always@(*)begin
    if(current_state == IDLE) out_action[40] = 2'b00;
    else                      out_action[40] = 2'b00;   
end

always@(*)begin
    if(current_state == IDLE) out_action[41] = 2'b00;
    else begin 
        if(map[decision_pt5][42] == 2'b01) out_action[41] = 2'b11 ;
        else out_action[41] = 2'b00;
    end
end

always@(*)begin
    if(current_state == IDLE) out_action[42] = 2'b00;
    else out_action[42] =  2'b00;
end

always@(*)begin
    if(current_state == IDLE) out_action[43] = 2'b00;
    else begin
         if(map[decision_pt5][44] == 2'b01) out_action[43] = 2'b11;
         else  out_action[43] = 2'b00;
    end
end

always@(*)begin
    if(current_state == IDLE) out_action[44] = 2'b00;
    else begin 
        if(decision6 > 0) out_action[44] = 2'b10;  //left
        else if(decision6 < 0 ) out_action[44] = 2'b01; //right
        else out_action[44] = 2'b00;

    end
end

always@(*)begin 
    if(current_state == IDLE) out_action[45] = 2'b00;
    else begin
        if(map[point6][46] == 2'b01) out_action[45] = 2'b11;
        else                        out_action[45] = 2'b00;  
    end
end

always@(*)begin 
    if(current_state == IDLE) out_action[46] = 2'b00;
    else begin
        if(decision6 > 0) begin //during rise 
            if(decision6 -1 > 0) out_action[46] = 2'b10; //rise not enough
            else out_action[46] = 2'b00; //rise is enough, then go straight
        end
        else if(decision6 < 0)begin //during fall
            if(decision6 + 1 < 0) out_action[46] = 2'b01;//fall not enough
            else out_action[46] = 2'b00; // fall is enough, then go straight
        end
        else    out_action[46] =2'b00; //in the beginneing decision equals zero
    end
end

always@(*)begin 
    if(current_state == IDLE) out_action[47] = 2'b00;
    else begin
        if(decision6 > 0) begin //during rise 
            if(decision6 - 2 > 0) out_action[47] = 2'b10; //rise not enough
            else out_action[47] = 2'b00; //rise is enough, then go straight
        end
        else if(decision6 < 0)begin //during fall
            if(decision6 + 2 < 0) out_action[47] = 2'b01;//fall not enough
            else out_action[47] = 2'b00; // fall is enough, then go straight
        end
        else    out_action[47] =2'b00; //in the beginneing decision equals zero
    end

end

//seven group

always@(*)begin
    if(current_state == IDLE) out_action[48] = 2'b00;
    else                      out_action[48] = 2'b00;   
end

always@(*)begin
    if(current_state == IDLE) out_action[49] = 2'b00;
    else begin 
        if(map[decision_pt6][50] == 2'b01) out_action[49] = 2'b11 ;
        else out_action[49] = 2'b00;
    end
end

always@(*)begin
    if(current_state == IDLE) out_action[50] = 2'b00;
    else out_action[50] =  2'b00;
end

always@(*)begin
    if(current_state == IDLE) out_action[51] = 2'b00;
    else begin
         if(map[decision_pt6][52] == 2'b01) out_action[51] = 2'b11;
         else  out_action[51] = 2'b00;
    end
end

always@(*)begin
    if(current_state == IDLE) out_action[52] = 2'b00;
    else begin 
        if(decision7 > 0) out_action[52] = 2'b10;  //left
        else if(decision7 < 0 ) out_action[52] = 2'b01; //right
        else out_action[52] = 2'b00;

    end
end

always@(*)begin 
    if(current_state == IDLE) out_action[53] = 2'b00;
    else begin
        if(map[point7][54] == 2'b01) out_action[53] = 2'b11;
        else                        out_action[53] = 2'b00;  
    end
end

always@(*)begin 
    if(current_state == IDLE) out_action[54] = 2'b00;
    else begin
        if(decision7 > 0) begin //during rise 
            if(decision7 -1 > 0) out_action[54] = 2'b10; //rise not enough
            else out_action[54] = 2'b00; //rise is enough, then go straight
        end
        else if(decision7 < 0)begin //during fall
            if(decision7 + 1 < 0) out_action[54] = 2'b01;//fall not enough
            else out_action[54] = 2'b00; // fall is enough, then go straight
        end
        else    out_action[54] =2'b00; //in the beginneing decision equals zero
    end
end

always@(*)begin 
    if(current_state == IDLE) out_action[55] = 2'b00;
    else begin
        if(decision7 > 0) begin //during rise 
            if(decision7 - 2 > 0) out_action[55] = 2'b10; //rise not enough
            else out_action[55] = 2'b00; //rise is enough, then go straight
        end
        else if(decision7 < 0)begin //during fall
            if(decision7 + 2 < 0) out_action[55] = 2'b01;//fall not enough
            else out_action[55] = 2'b00; // fall is enough, then go straight
        end
        else    out_action[55]=2'b00; //in the beginneing decision equals zero
    end

end
// wire [4:0]a,b;
// assign a = map[3][57];
// assign b = map[3][58];
//eight group
always@(*)begin
    if(current_state == IDLE) out_action[56] = 2'b00;
    else begin
         out_action[56] = 2'b00;
    end
end
always@(*)begin
    if(current_state == IDLE) out_action[57] = 2'b00;
    else begin
        if(map[decision_pt7][58] == 2'b01) out_action[57] = 2'b11;
        else                               out_action[57] = 2'b00;
    end
end
always@(*)begin
    if(current_state == IDLE) out_action[58] = 2'b00;
    else begin
        out_action[58] = 2'b00;
    end
end
always@(*)begin
    if(current_state == IDLE) out_action[59] = 2'b00;
    else begin
        if(map[decision_pt7][60] == 2'b01) out_action[59] = 2'b11;
        else                               out_action[59] = 2'b00;
    end
end
always@(*)begin
    if(current_state == IDLE) out_action[60] = 2'b00;
    else begin
        out_action[60] = 2'b00;
    end
end
always@(*)begin
    if(current_state == IDLE) out_action[61] = 2'b00;
    else begin
        if(map[decision_pt7][62] == 2'b01) out_action[61] = 2'b11;
        else                               out_action[61] = 2'b00;
    end
end
always@(*)begin
    if(current_state == IDLE) out_action[62] = 2'b00;
    else begin
        out_action[62] = 2'b00;
    end
end
always@(*)begin
    if(current_state == IDLE) out_action[63] = 2'b00;
    else begin
        out_action[63] = 2'b00;
    end
end


endmodule

