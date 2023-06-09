//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright Optimum Application-Specific Integrated System Laboratory
//    All Right Reserved
//		Date		: 2023/03
//		Version		: v1.0
//   	File Name   : EC_TOP.v
//   	Module Name : EC_TOP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

//synopsys translate_off
`include "INV_IP.v"
//synopsys translate_on

module EC_TOP(
    // Input signals
    clk, rst_n, in_valid,
    in_Px, in_Py, in_Qx, in_Qy, in_prime, in_a,
    // Output signals
    out_valid, out_Rx, out_Ry
);

// ===============================================================
// Input and Output Declaration
// ===============================================================
input clk, rst_n, in_valid;
input [6-1:0] in_Px, in_Py, in_Qx, in_Qy, in_prime, in_a;
output reg out_valid;
output reg [6-1:0] out_Rx, out_Ry;
// ===============================================================
// Parameter & Register & Wire
// ===============================================================
parameter IP_WIDTH = 6;
parameter IDLE    = 4'd0; 
parameter COMPUTE_1   = 4'd1;
parameter COMPUTE_2   = 4'd2;
parameter COMPUTE_3   = 4'd3;
parameter COMPUTE_4   = 4'd4;
parameter COMPUTE_5   = 4'd5;
parameter RESULT   = 4'd6;

reg 	[3:0]current_state ;
reg		[3:0]next_state;

reg     [5:0]prime;
reg     [3:0]cnt_in;
reg     [5:0]Px,Py,Qx,Qy,a;
wire     EQUAL;
wire signed [20:0]DOWN;
wire signed [20:0]UP;
wire signed [20:0]DOWN_1;
wire signed [20:0]UP_1;
wire        [5:0]DOWN_pa ;

wire        [5:0]DOWN_INV;
reg         [5:0]DOWN_REG;
reg         [5:0]PRIME_REG;

wire        [5:0]DOWN_IP ;
wire        [5:0]prime_IP;
reg         [5:0]DOWN_RESULT;
            
wire        [20:0]s;  
reg         [20:0]s_REG;

wire  signed[20:0]x1,x2,x3,x4;
wire        [5:0] x5;
reg         [5:0] x5_REG;

wire  signed[20:0]y1,y2,y3,y4;
wire        [5:0] y5;
reg         [5:0] y4_REG;

assign prime_IP = PRIME_REG;
assign DOWN_IP = DOWN_REG;

INV_IP #(.IP_WIDTH(IP_WIDTH)) IV1(.IN_1(prime), .IN_2(DOWN_IP), .OUT_INV(DOWN_INV));

always@(posedge clk or negedge rst_n)begin
    if(!rst_n) DOWN_REG <= 6'b000000;
    else begin
        case(current_state)
            IDLE : DOWN_REG <= 6'b000000;
            COMPUTE_1 : DOWN_REG <= DOWN_pa;
            default :;
        endcase
    end
end
// always@(posedge clk or negedge rst_n)begin
//     if(!rst_n) PRIME_REG <= 6'b000000;
//     else begin
//         case(current_state)
//             IDLE : PRIME_REG <= 6'b000000;
//             COMPUTE_1 : PRIME_REG <= prime;
//             default :;
//         endcase
//     end
// end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n) DOWN_RESULT <= 6'b000000;
    else begin
        case(current_state)
            IDLE : DOWN_RESULT <= 6'b000000;
            COMPUTE_2 : DOWN_RESULT <= DOWN_INV;
            default :;
        endcase
    end
end
// ===============================================================
// Finite-State Machine
// ===============================================================
always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)  current_state <= IDLE;
    else current_state <= next_state;
end

always@(*)begin
    case(current_state)
        IDLE : begin
            if(!in_valid && cnt_in != 0) next_state = COMPUTE_1;
            else                         next_state = IDLE;
        end
        COMPUTE_1 : begin
            next_state = COMPUTE_2;
        end
        COMPUTE_2 : begin
            next_state = COMPUTE_3;
        end
        COMPUTE_3 : begin
            next_state = COMPUTE_4;
        end
        COMPUTE_4 : begin
            next_state = COMPUTE_5;
        end
        COMPUTE_5 : begin
            next_state = RESULT;
        end
        RESULT : begin
            next_state = IDLE;
        end

        default: next_state = current_state;
    endcase

end

//EAT_INPUT
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        Px <= 6'b000000;
        Py <= 6'b000000;
    end
    else if(in_valid)begin
        Px <= in_Px;
        Py <= in_Py;
    end

    else begin
        Px <= Px;
        Py <= Py;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        Qx <= 6'b000000;
        Qy <= 6'b000000;
    end
    else if(in_valid)begin
        Qx <= in_Qx;
        Qy <= in_Qy;
    end

    else begin
        Qx <= Qx;
        Qy <= Qy;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        prime <= 6'b000000;
    end
    else if(in_valid)begin
        prime <= in_prime;
    end
    else begin
        prime <= prime;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        a <= 6'b000000;
    end
    else if(in_valid)begin
        a <= in_a;
    end
    else begin
        a <= a;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)          cnt_in <= 4'b0000;
    else if(in_valid)   cnt_in <= cnt_in + 1 ;
    else                cnt_in <= 4'b0000;
end


//JUDGE P AND Q IS EQUAL OR NOT
assign EQUAL = ((Px == Qx) && (Py == Qy)) ? 1 : 0;
assign UP    = (EQUAL == 1) ? 3*Px*Px + a  : Qy - Py;
assign DOWN  = (EQUAL == 1) ? 2*Py         : Qx - Px;


//ENSURE UP & DOWN WILL BE POSITIVE
assign UP_1   = (UP < 0)   ? UP + prime : UP ;
assign DOWN_1 = (DOWN < 0) ? DOWN + prime : DOWN ;
assign DOWN_pa = DOWN_1 % prime;

//COMPUTE S
assign s = (DOWN_RESULT * UP_1) % prime;

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)  s_REG = 6'b000000;
    else begin
        case(current_state)
            IDLE : s_REG = 6'b000000;
            COMPUTE_3 : s_REG = s;
            default:;
        endcase
    end
end

//COMPUTE X && Y
assign  x1 = s_REG*s_REG - Px;
assign  x2 = (x1 < 0 ) ? x1 + prime : x1;
assign  x3 = x2 - Qx;
assign  x4 = (x3 < 0 ) ? x3 + prime : x3;
assign  x5 = x4 % prime ;

always@(posedge clk or negedge rst_n)begin
    if(!rst_n) x5_REG <= 6'b000000;
    else begin
        case(current_state)
            IDLE : x5_REG <= 6'b000000;
            COMPUTE_4 : x5_REG <= x5;
            default:;
        endcase
    end
end

assign  y1 = Px - x5_REG ;
assign  y2 = (y1 < 0 ) ? y1 + prime : y1;
assign  y3 = s_REG * y2 - Py;
assign  y4 = (y3 < 0 ) ? y3 + prime : y3;
assign  y5 = y4 % prime ;

// always@(posedge clk or negedge rst_n)begin
//     if(!rst_n) y4_REG <= 6'b000000;
//     else begin
//         case(current_state)
//             IDLE : y4_REG <= 6'b000000;
//             COMPUTE_5 : y4_REG <= y4;
//             default:;
//         endcase
//     end
// end

//OUTPUT
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        out_valid <= 0 ;
    end
    else begin
    case(current_state)
        IDLE : out_valid <= 0 ;
        COMPUTE_5 : out_valid <= 1 ;
        default : out_valid <= 0 ;
    endcase
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        out_Rx <= 0 ;
    end
    else begin
    case(current_state)
        IDLE : out_Rx <= 0 ;
        COMPUTE_5 : out_Rx <= x5_REG;
        default : out_Rx <= 0 ;
    endcase
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        out_Ry <= 0 ;
    end
    else begin
    case(current_state)
        IDLE : out_Ry <= 0 ;
        COMPUTE_5 : out_Ry <= y5 ;
        default : out_Ry <= 0 ;
    endcase
    end
end





endmodule 

