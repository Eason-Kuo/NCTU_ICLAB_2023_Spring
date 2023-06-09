//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Si2 LAB @NCTU ED415
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2023 spring
//   Midterm Proejct            : GLCM 
//   Author                     : Hsi-Hao Huang
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : GLCM.v
//   Module Name : GLCM
//   Release version : V1.0 (Release Date: 2023-04)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module GLCM(
				clk,	
			  rst_n,	
	
			in_addr_M,
			in_addr_G,
			in_dir,
			in_dis,
			in_valid,
			out_valid,
	

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
       bready_m_inf,
                    
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
       rready_m_inf 
);
parameter ID_WIDTH = 4 , ADDR_WIDTH = 32, DATA_WIDTH = 32;
input			  clk,rst_n;



// AXI Interface wire connecttion for pseudo DRAM read/write
/* Hint:
       your AXI-4 interface could be designed as convertor in submodule(which used reg for output signal),
	   therefore I declared output of AXI as wire in Poly_Ring
*/
   
// -----------------------------
// IO port
input [ADDR_WIDTH-1:0]      in_addr_M;
input [ADDR_WIDTH-1:0]      in_addr_G;
input [1:0]  	  		  in_dir;
input [3:0]	    		  in_dis;
input 			    	  in_valid;
output reg 	              out_valid;
// -----------------------------


// axi write address channel 
output  wire [ID_WIDTH-1:0]        awid_m_inf;
output  reg  [ADDR_WIDTH-1:0]    awaddr_m_inf;
output  wire [2:0]            awsize_m_inf;
output  wire [1:0]           awburst_m_inf;
output  wire [3:0]             awlen_m_inf;
output  reg                    awvalid_m_inf;
input   wire                 awready_m_inf;
// axi write data channel 
output  reg  [ DATA_WIDTH-1:0]     wdata_m_inf;
output  wire                   wlast_m_inf;
output  reg                    wvalid_m_inf;
input   wire                  wready_m_inf;
// axi write response channel
input   wire [ID_WIDTH-1:0]         bid_m_inf;
input   wire [1:0]             bresp_m_inf;
input   wire              	   bvalid_m_inf;
output  wire                    bready_m_inf;
// -----------------------------
// axi read address channel 
output  wire [ID_WIDTH-1:0]       arid_m_inf;
output  reg  [ADDR_WIDTH-1:0]   araddr_m_inf;
output  wire [3:0]            arlen_m_inf;
output  wire [2:0]           arsize_m_inf;
output  wire [1:0]           arburst_m_inf;
output  reg                  arvalid_m_inf;
input   wire                 arready_m_inf;
// -----------------------------
// axi read data channel 
input   wire [ID_WIDTH-1:0]         rid_m_inf;
input   wire [DATA_WIDTH-1:0]     rdata_m_inf;
input   wire [1:0]                rresp_m_inf;
input   wire                      rlast_m_inf;
input   wire                      rvalid_m_inf;
output  reg                       rready_m_inf;
// -----------------------------


// REGISTER && WIRE--------------
reg  [ADDR_WIDTH-1:0]      addr_M;
reg  [ADDR_WIDTH-1:0]      addr_G;
reg  [1:0]                 dir;
reg  [3:0]                 dis;

reg  [3:0]                 cnt_in ; 
wire [7:0]data[0:3];
reg  [7:0]data_matrix[0:15][0:15];
reg  [7:0]take_matrix[0:15][0:15];
reg  [4:0]cnt_row;
reg  [4:0]cnt_col;

reg  [3:0]cnt_times  ;
reg  [4:0]cnt_times2 ;
reg  [4:0]cnt_write_num ;
reg  [4:0]cnt_write_row, cnt_write_col;

reg  [3:0]cnt_sram, cnt_take, cnt_wait;
wire MEM_cen, MEM_oen;
reg  MEM_wen_X;
wire [3:0]MEM_adr_X;
reg  [7:0]MEM_in_X[0:15];
wire [7:0]MEM_out_X[0:15];


reg [4:0] offset_row, offset_col     ;
reg [4:0] result_row   , result_col   ;
reg [7:0] result_matrix[0:31][0:31];
wire [1:0]      range[0:15][0:15];
wire [1:0]      pointA[0:15][0:15];
reg  [1:0]      pointB[0:15][0:15];
//wire [1:0]     pointC[0:15][0:15];
wire [7:0]     row_plus[0:15];
wire [7:0]     ans;
reg  [7:0]GLCM_matrix[0:31][0:31];   
// -----------------------------
// PARAMETER--------------------
reg  [3:0]current_state ;
reg  [3:0]next_state ;

integer i,j,a,b;
parameter IDLE            = 4'd0; 
parameter READ_VALUE1     = 4'd1;   //SEND ADDRESS
parameter READ_VALUE2     = 4'd2;   //STORE VALUE
parameter READ_VALUE3     = 4'd3;   //WAIT
parameter STORE_SRAM      = 4'd4;   //STORE SRAM 
parameter TAKE_SRAM       = 4'd5;   //TAKE SRAM 
parameter COMPUTE         = 4'd6;
parameter WRITE_ADR       = 4'd7; 
parameter STORE_DRAM      = 4'd8; 
parameter TEMP            = 4'd9; 
parameter OUT_STATE       = 4'd10; 
// -----------------------------

// IP---------------------------
assign MEM_cen   = 0 ;
assign MEM_oen   = 0 ;
assign MEM_adr_X = (current_state == TAKE_SRAM) ? cnt_take : cnt_sram; 
RA1SH X_0 (.Q(MEM_out_X[0 ]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X) , .A(MEM_adr_X) , .D(MEM_in_X[0 ]), .OEN(MEM_oen));
RA1SH X_1 (.Q(MEM_out_X[1 ]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X) , .A(MEM_adr_X) , .D(MEM_in_X[1 ]), .OEN(MEM_oen));
RA1SH X_2 (.Q(MEM_out_X[2 ]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X) , .A(MEM_adr_X) , .D(MEM_in_X[2 ]), .OEN(MEM_oen));
RA1SH X_3 (.Q(MEM_out_X[3 ]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X) , .A(MEM_adr_X) , .D(MEM_in_X[3 ]), .OEN(MEM_oen));
RA1SH X_4 (.Q(MEM_out_X[4 ]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X) , .A(MEM_adr_X) , .D(MEM_in_X[4 ]), .OEN(MEM_oen));
RA1SH X_5 (.Q(MEM_out_X[5 ]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X) , .A(MEM_adr_X) , .D(MEM_in_X[5 ]), .OEN(MEM_oen));
RA1SH X_6 (.Q(MEM_out_X[6 ]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X) , .A(MEM_adr_X) , .D(MEM_in_X[6 ]), .OEN(MEM_oen));
RA1SH X_7 (.Q(MEM_out_X[7 ]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X) , .A(MEM_adr_X) , .D(MEM_in_X[7 ]), .OEN(MEM_oen));
RA1SH X_8 (.Q(MEM_out_X[8 ]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X) , .A(MEM_adr_X) , .D(MEM_in_X[8 ]), .OEN(MEM_oen));
RA1SH X_9 (.Q(MEM_out_X[9 ]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X) , .A(MEM_adr_X) , .D(MEM_in_X[9 ]), .OEN(MEM_oen));
RA1SH X_10(.Q(MEM_out_X[10]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X) , .A(MEM_adr_X) , .D(MEM_in_X[10]), .OEN(MEM_oen));
RA1SH X_11(.Q(MEM_out_X[11]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X) , .A(MEM_adr_X) , .D(MEM_in_X[11]), .OEN(MEM_oen));
RA1SH X_12(.Q(MEM_out_X[12]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X) , .A(MEM_adr_X) , .D(MEM_in_X[12]), .OEN(MEM_oen));
RA1SH X_13(.Q(MEM_out_X[13]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X) , .A(MEM_adr_X) , .D(MEM_in_X[13]), .OEN(MEM_oen));
RA1SH X_14(.Q(MEM_out_X[14]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X) , .A(MEM_adr_X) , .D(MEM_in_X[14]), .OEN(MEM_oen));
RA1SH X_15(.Q(MEM_out_X[15]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X) , .A(MEM_adr_X) , .D(MEM_in_X[15]), .OEN(MEM_oen));
// -----------------------------

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)  addr_M <= 0 ;
    else begin
        if(in_valid)    addr_M <= in_addr_M;
        else            addr_M <= addr_M ;
    end    
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)  addr_G <= 0 ;
    else begin
        if(in_valid)    addr_G <= in_addr_G;
        else            addr_G <= addr_G ;
    end    
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)  dir <= 0 ;
    else begin
        if(in_valid)    dir <= in_dir;
        else            dir <= dir ;
    end    
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)  dis <= 0 ;
    else begin
        if(in_valid)    dis <= in_dis;
        else            dis <= dis ;
    end    
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)        cnt_in <= 4'b0000;
    else begin
        if(in_valid)  cnt_in <= cnt_in + 1 ;
        else          cnt_in <= 4'b0000;
    end
end
// FSM--------------------------
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)  current_state <= IDLE;
    else        current_state <= next_state;
end
always@(*)begin
    case(current_state)
        IDLE : begin
            if(!in_valid && cnt_in != 0) next_state = READ_VALUE1 ;
            else                         next_state = IDLE ;
        end
        READ_VALUE1 : begin
            if(arready_m_inf == 1) next_state = READ_VALUE2 ;
            else                   next_state = READ_VALUE1 ;
        end
        READ_VALUE2 : begin
            if(rlast_m_inf == 1)   next_state = READ_VALUE3 ;
            else                   next_state = READ_VALUE2 ;
        end
        READ_VALUE3 : begin
            if(cnt_times == 3)     next_state = STORE_SRAM  ;
            else                   next_state = READ_VALUE1 ;
        end
        STORE_SRAM : begin
            if(cnt_sram == 15)     next_state = TAKE_SRAM  ;
            else                   next_state = STORE_SRAM ;
        end
        TAKE_SRAM : begin
            if(cnt_wait == 15 )     next_state = COMPUTE   ;
            else                    next_state = TAKE_SRAM ;
        end
        COMPUTE : begin
            if(result_col == 31 && result_row == 31 ) next_state = WRITE_ADR;
            else                                      next_state = COMPUTE;                                  
        end
        WRITE_ADR : begin
            if(awready_m_inf == 1)   next_state = STORE_DRAM ;
            else                     next_state = WRITE_ADR ;
        end
        STORE_DRAM : begin
            if(cnt_write_num == 15 )    next_state = TEMP ;
            else                        next_state = STORE_DRAM ;
        end
        TEMP : begin
            if(cnt_times2 == 15)     next_state = OUT_STATE ; 
            else                    next_state = WRITE_ADR ;
        end
        OUT_STATE : begin
            next_state = IDLE ;
        end
        

        default: next_state = current_state;
    endcase
end
// -----------------------------

//AXI_SINGAL--------------------
assign arid_m_inf     = 4'b0000;
assign awid_m_inf     = 4'b0000; 

assign arsize_m_inf   = 3'b010;
assign arburst_m_inf  = 2'b01;


////////////////////////// 
 
 
//////////////////////////
assign awsize_m_inf   = 3'b010; 
assign awburst_m_inf  = 2'b01; 
assign awlen_m_inf    = 4'd15; 





assign arlen_m_inf    = 4'd15; 

always@(*)begin
    case(cnt_times)
        4'b0000 :   araddr_m_inf <= addr_M;
        4'b0001 :   araddr_m_inf <= addr_M + 64  ;
        4'b0010 :   araddr_m_inf <= addr_M + 128 ;
        4'b0011 :   araddr_m_inf <= addr_M + 192 ;
        default :   araddr_m_inf <= 0;
    endcase
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)      arvalid_m_inf <= 1'b0;
    else begin
        case(current_state)
            IDLE : arvalid_m_inf <= 1'b0;
            READ_VALUE1 : begin
                if(arready_m_inf == 1 ) arvalid_m_inf <= 1'b0 ;
                else                    arvalid_m_inf <= 1'b1 ;
            end
            default : arvalid_m_inf <= 1'b0;
        endcase
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)   rready_m_inf <= 1'b0;
    else begin
        case(current_state)
            IDLE :        rready_m_inf <= 1'b0;
            READ_VALUE2 : begin
                if(rlast_m_inf == 1)    rready_m_inf <= 1'b0;
                else                    rready_m_inf <= 1'b1;
            end
            default :     rready_m_inf <= 1'b0;  
        endcase
    end
end

assign  data[0] =  rdata_m_inf[7:0];
assign  data[1] =  rdata_m_inf[15:8];
assign  data[2] =  rdata_m_inf[23:16];
assign  data[3] =  rdata_m_inf[31:24];

//MATRIX_DATA
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(i=0; i<16; i=i+1)begin
            for(j=0; j<16; j=j+1)begin
                data_matrix[i][j] <= 8'b0000_0000;
            end
        end
    end
    else begin
        case(current_state)
        IDLE : begin
            for(i=0; i<16; i=i+1)begin
                for(j=0; j<16; j=j+1)begin
                    data_matrix[i][j] <= 8'b0000_0000;
                end
            end
        end
        READ_VALUE2 : begin
            data_matrix[cnt_row][4*cnt_col    ] <= data[0]; 
            data_matrix[cnt_row][4*cnt_col + 1] <= data[1]; 
            data_matrix[cnt_row][4*cnt_col + 2] <= data[2]; 
            data_matrix[cnt_row][4*cnt_col + 3] <= data[3]; 
        end
        endcase
    end

end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n) cnt_row <= 0;
    else begin
        case(current_state)
            IDLE: cnt_row <= 0 ;
            READ_VALUE2 : begin
                if(rvalid_m_inf)begin
                    if(cnt_col == 3) cnt_row <= cnt_row + 1 ;
                end
            end

            default :  cnt_row <= cnt_row;
        endcase
    end

end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n) cnt_col <= 0;
    else begin
        case(current_state)
            IDLE: cnt_col <= 0 ;
            READ_VALUE2 : begin
                if(rvalid_m_inf)begin
                   if(cnt_col == 3) cnt_col <= 0 ;
                   else             cnt_col <= cnt_col +1 ;
                end
            end
            default :  cnt_col <= 0 ;
        endcase
    end

end

//------------------------------
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)  cnt_times <= 0;
    else begin
        case(current_state)
            IDLE : cnt_times <= 0;
            READ_VALUE3 : cnt_times <= cnt_times + 1 ;
            STORE_SRAM : cnt_times <= 0;
        endcase
    end

end


//SRAM--------------------------
genvar k;
always@(*)begin
    case(current_state)
        IDLE : MEM_wen_X = 1;
        STORE_SRAM : MEM_wen_X = 0;
        default : MEM_wen_X = 1;
    endcase
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)  cnt_sram <= 0;
    else begin
        case(current_state)
            IDLE : cnt_sram <= 0;
            STORE_SRAM : cnt_sram <= cnt_sram + 1 ;
            default : cnt_sram <= 0;
        endcase
    
    end
end

generate
for(k=0; k < 16; k=k+1)begin
    always@(*)begin
        case(current_state)
            IDLE : MEM_in_X[k] = 0;
            STORE_SRAM : MEM_in_X[k] = data_matrix[k][cnt_sram];
    
            default : MEM_in_X[k] = 0;
        endcase
    end
end
endgenerate

// TAKE-------------------------
always@(posedge clk or negedge rst_n)begin
    if(!rst_n) cnt_take <= 0 ;
    else begin
        case(current_state)
        IDLE : cnt_take <= 0 ;
        TAKE_SRAM : begin
            cnt_take <= cnt_take + 1 ;
        end
        default : cnt_take <= 0 ; 
        endcase
    
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n) cnt_wait <= 0 ;
    else begin
        case(current_state)
        IDLE : cnt_wait <= 0 ;
        TAKE_SRAM : begin
            cnt_wait <= cnt_take ;
        end
        default : cnt_wait <= 0 ; 
        endcase
    
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(i=0; i<16 ; i=i+1)begin
            for(j=0;j<16;j=j+1)begin
                take_matrix[i][j] <= 0;
            end
        end
    end
    else begin
        case(current_state)
        IDLE : begin
            for(i=0; i<16 ; i=i+1)begin
                for(j=0;j<16;j=j+1)begin
                    take_matrix[i][j] <= 0;
                end
            end
        end
        TAKE_SRAM : begin
            take_matrix[0 ][cnt_wait] <= MEM_out_X[0 ] ;
            take_matrix[1 ][cnt_wait] <= MEM_out_X[1 ] ;
            take_matrix[2 ][cnt_wait] <= MEM_out_X[2 ] ;
            take_matrix[3 ][cnt_wait] <= MEM_out_X[3 ] ;
            take_matrix[4 ][cnt_wait] <= MEM_out_X[4 ] ;
            take_matrix[5 ][cnt_wait] <= MEM_out_X[5 ] ;
            take_matrix[6 ][cnt_wait] <= MEM_out_X[6 ] ;
            take_matrix[7 ][cnt_wait] <= MEM_out_X[7 ] ;
            take_matrix[8 ][cnt_wait] <= MEM_out_X[8 ] ;
            take_matrix[9 ][cnt_wait] <= MEM_out_X[9 ] ;
            take_matrix[10][cnt_wait] <= MEM_out_X[10] ;
            take_matrix[11][cnt_wait] <= MEM_out_X[11] ;
            take_matrix[12][cnt_wait] <= MEM_out_X[12] ;
            take_matrix[13][cnt_wait] <= MEM_out_X[13] ;
            take_matrix[14][cnt_wait] <= MEM_out_X[14] ;
            take_matrix[15][cnt_wait] <= MEM_out_X[15] ;
           

        end
        default:;
        endcase
    end
end
// -----------------------------
// DESIGN-----------------------
always@(*)begin
    case(dir)
        2'b01 : begin
            offset_row = dis   ;
            offset_col = 0     ;
        end 
        2'b10 : begin
            offset_row = 0     ;
            offset_col = dis   ;
        end
        2'b11 : begin
            offset_row = dis ;
            offset_col = dis ;
        end
        default : begin
            offset_row = 0   ;
            offset_col = 0   ;
        end
    endcase

end

genvar m,n;
genvar o,p;

//RESULT ROW && RESULT COLUMN
always@(posedge clk or negedge rst_n)begin
    if(!rst_n) result_row <= 0;
    else begin
        case(current_state)
        IDLE : result_row <= 0;
        COMPUTE : begin
            if(result_col == 31) result_row <= result_row + 1;
        
            //result_row <= 0;
        end
        default : result_row <= 0;
        endcase
    end

end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n) result_col <= 0;
    else begin
        case(current_state)
        IDLE : result_col <= 0;
        COMPUTE : begin
            result_col <= result_col + 1;
            //result_col <= 1;
        end
        default : result_col <= 0;
        endcase
    end

end
//JUDGE THE RANGE && INITIAL POINT
generate
for(o=0; o < 16; o=o+1)begin
    for(p=0; p < 16; p=p+1)begin
        assign   range[o][p] = ( (o + offset_row) < 16 && (p + offset_col) < 16 ) ? 1 : 0 ;
    end
end
endgenerate

generate
for(m=0; m < 16; m=m+1)begin
    for(n=0; n < 16; n=n+1)begin
        assign   pointA[m][n] = ( take_matrix[m][n] == result_row ) ? 1 : 0 ;
    end
end
endgenerate

generate
for(m=0; m < 16; m=m+1)begin
    for(n=0; n < 16; n=n+1)begin
        always@(*)begin
            if(range[m][n] == 1  && pointA[m][n] == 1)begin
                pointB[m][n] = ( take_matrix[m + offset_row][n + offset_col] == result_col ) ? 1 : 0 ;
            end
            else begin
                pointB[m][n] = 0;
            end
        end
    end
end
endgenerate

// generate
// for(m=0; m < 16; m=m+1)begin
//     for(n=0; n < 16; n=n+1)begin
//         assign pointC[m][n] =  pointA[m][n] & pointB[m][n] ;
//     end
// end
// endgenerate
// -----------------------------

genvar x;
generate
for(x=0 ;x < 16; x=x+1)begin
    assign row_plus[x] = pointB[x][0] + pointB[x][1] + pointB[x][2] + pointB[x][3] + pointB[x][4] + pointB[x][5] + pointB[x][6] + pointB[x][7]
                        + pointB[x][8] + pointB[x][9] + pointB[x][10]+ pointB[x][11]+ pointB[x][12]+ pointB[x][13]+ pointB[x][14]+ pointB[x][15];
end
endgenerate

assign ans = row_plus[0] + row_plus[1] + row_plus[2] + row_plus[3] + row_plus[4] + row_plus[5] + row_plus[6] + row_plus[7]
                        + row_plus[8] + row_plus[9] + row_plus[10]+ row_plus[11]+ row_plus[12]+ row_plus[13]+ row_plus[14]+ row_plus[15];



always@(posedge clk or negedge rst_n)begin
    if(!rst_n) begin
        for(a=0 ; a < 32 ; a=a+1)begin
            for(b=0 ; b < 32 ; b=b+1)begin
                GLCM_matrix[a][b] <= 0 ;

            end
        end
    end    
    else begin
        case(current_state)
            IDLE : begin
                for(a=0 ; a < 32 ; a=a+1)begin
                    for(b=0 ; b < 32 ; b=b+1)begin
                        GLCM_matrix[a][b] <= 0 ;

                    end
                end
            end
            COMPUTE : begin
                GLCM_matrix[result_row][result_col] <= ans;
            end
            default :;
        
        endcase
    
    end 

end
///////////////////////////////////////////

//WRITE------------------------------------
always@(*)begin
    case(cnt_times2)
        4'd0 :      awaddr_m_inf <= addr_G;
        4'd1 :      awaddr_m_inf <= addr_G + 64  ;
        4'd2 :      awaddr_m_inf <= addr_G + 128 ;
        4'd3 :      awaddr_m_inf <= addr_G + 192 ;
        4'd4 :      awaddr_m_inf <= addr_G + 256 ;
        4'd5 :      awaddr_m_inf <= addr_G + 320 ;
        4'd6 :      awaddr_m_inf <= addr_G + 384 ;
        4'd7 :      awaddr_m_inf <= addr_G + 448 ;
        4'd8 :      awaddr_m_inf <= addr_G + 512 ;
        4'd9 :      awaddr_m_inf <= addr_G + 576 ;
        4'd10 :     awaddr_m_inf <= addr_G + 640 ;
        4'd11 :     awaddr_m_inf <= addr_G + 704 ;
        4'd12 :     awaddr_m_inf <= addr_G + 768 ;
        4'd13 :     awaddr_m_inf <= addr_G + 832 ;
        4'd14 :     awaddr_m_inf <= addr_G + 896 ;
        4'd15 :     awaddr_m_inf <= addr_G + 960 ;
        default :   awaddr_m_inf <= 0;
    endcase
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)  cnt_times2 <= 0;
    else begin
        case(current_state)
            IDLE : cnt_times2 <= 0;
            TEMP : cnt_times2 <= cnt_times2 + 1 ;
            default :;
        endcase
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)  cnt_write_num <= 0;
    else begin
        case(current_state)
            IDLE : cnt_write_num <= 0;
            STORE_DRAM : begin
               if(wready_m_inf == 1) cnt_write_num <= cnt_write_num + 1 ;
               else                  cnt_write_num <= 0;
            end
            TEMP : cnt_write_num <= 0;
            default :;
        endcase
    end
end


always@(*)begin
    case(current_state)
    IDLE : begin
        awvalid_m_inf <= 0;
    end
    WRITE_ADR : begin
        awvalid_m_inf <= 1;
    end
    default : awvalid_m_inf <= 0;
    endcase
end

always@(*)begin
    case(current_state)
    IDLE : wdata_m_inf = 0;
    STORE_DRAM : begin
        wdata_m_inf = {GLCM_matrix[cnt_write_row][cnt_write_col + 3], GLCM_matrix[cnt_write_row][cnt_write_col + 2],
                       GLCM_matrix[cnt_write_row][cnt_write_col + 1], GLCM_matrix[cnt_write_row][cnt_write_col ]};
    end
    default : wdata_m_inf = 0;
    endcase
end
///////////////////////////////////////////
assign bready_m_inf = 1 ;
assign wlast_m_inf  = (cnt_write_num == 15) ? 1'b1 : 1'b0;
always@(*)begin
   case(current_state) 
        STORE_DRAM : 
            if(cnt_write_num == 16) wvalid_m_inf = 0 ;
            else                    wvalid_m_inf = 1 ;         
        default : wvalid_m_inf = 0 ;
   endcase
end

///CONTROL cnt_write_row && cnt_write_col
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)  cnt_write_col <= 0;
    else begin
        case(current_state)
        IDLE : cnt_write_col <= 0;
        STORE_DRAM : begin
        if(wready_m_inf == 1) begin
            if(cnt_write_col == 28) cnt_write_col <= 0;
            else                    cnt_write_col <= cnt_write_col + 4 ;
        end
        else begin
            cnt_write_col <= 0;
        end
        end
        default : cnt_write_col <= 0 ;
        endcase
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)  cnt_write_row <= 0;
    else begin
        case(current_state)
        IDLE : cnt_write_row <= 0;
        STORE_DRAM : begin
        if(wready_m_inf == 1) begin
            if(cnt_write_col == 28) cnt_write_row <= cnt_write_row + 1;
        end
        end
        default :;
        endcase
    end
end
/////////////////////////////////////////
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        out_valid <= 0;
    end  
    else begin
        case(current_state)
        IDLE : out_valid <= 0;
        OUT_STATE :  out_valid <= 1;
        default : out_valid <= 0;
        
        
        endcase
    end
end



endmodule








