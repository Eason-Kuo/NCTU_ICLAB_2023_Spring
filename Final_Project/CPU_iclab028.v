//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2023 Final Project: Customized ISA Processor 
//   Author              : Hsi-Hao Huang
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : CPU.v
//   Module Name : CPU.v
//   Release version : V1.0 (Release Date: 2023-May)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module CPU(

				clk,
			  rst_n,
  
		   IO_stall,

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
// Input port
input  wire clk, rst_n;
// Output port
output reg  IO_stall;

parameter ID_WIDTH = 4 , ADDR_WIDTH = 32, DATA_WIDTH = 16, DRAM_NUMBER=2, WRIT_NUMBER=1;

// AXI Interface wire connecttion for pseudo DRAM read/write
/* Hint:
  your AXI-4 interface could be designed as convertor in submodule(which used reg for output signal),
  therefore I declared output of AXI as wire in CPU
*/



// axi write address channel 
output  wire [WRIT_NUMBER * ID_WIDTH-1:0]        awid_m_inf;
output  wire [WRIT_NUMBER * ADDR_WIDTH-1:0]    awaddr_m_inf;
output  wire [WRIT_NUMBER * 3 -1:0]            awsize_m_inf;
output  wire [WRIT_NUMBER * 2 -1:0]           awburst_m_inf;
output  wire [WRIT_NUMBER * 7 -1:0]             awlen_m_inf;
output  wire [WRIT_NUMBER-1:0]                awvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                awready_m_inf;
// axi write data channel 
output  wire [WRIT_NUMBER * DATA_WIDTH-1:0]     wdata_m_inf;
output  wire [WRIT_NUMBER-1:0]                  wlast_m_inf;
output  wire [WRIT_NUMBER-1:0]                 wvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                 wready_m_inf;
// axi write response channel
input   wire [WRIT_NUMBER * ID_WIDTH-1:0]         bid_m_inf;
input   wire [WRIT_NUMBER * 2 -1:0]             bresp_m_inf;
input   wire [WRIT_NUMBER-1:0]             	   bvalid_m_inf;
output  wire [WRIT_NUMBER-1:0]                 bready_m_inf;
// -----------------------------
// axi read address channel 
output  wire [DRAM_NUMBER * ID_WIDTH-1:0]       arid_m_inf;
output  wire [DRAM_NUMBER * ADDR_WIDTH-1:0]   araddr_m_inf;
output  wire [DRAM_NUMBER * 7 -1:0]            arlen_m_inf;
output  wire [DRAM_NUMBER * 3 -1:0]           arsize_m_inf;
output  wire [DRAM_NUMBER * 2 -1:0]          arburst_m_inf;
output  wire [DRAM_NUMBER-1:0]               arvalid_m_inf;
input   wire [DRAM_NUMBER-1:0]               arready_m_inf;
// -----------------------------
// axi read data channel 
input   wire [DRAM_NUMBER * ID_WIDTH-1:0]         rid_m_inf;
input   wire [DRAM_NUMBER * DATA_WIDTH-1:0]     rdata_m_inf;
input   wire [DRAM_NUMBER * 2 -1:0]             rresp_m_inf;
input   wire [DRAM_NUMBER-1:0]                  rlast_m_inf;
input   wire [DRAM_NUMBER-1:0]                 rvalid_m_inf;
output  wire [DRAM_NUMBER-1:0]                 rready_m_inf;
// -----------------------------

//
//
// 
/* Register in each core:
  There are sixteen registers in your CPU. You should not change the name of those registers.
  TA will check the value in each register when your core is not busy.
  If you change the name of registers below, you must get the fail in this lab.
*/

//####################################################
//               reg & wire
//####################################################
reg  [3:0]current_state ;
reg  [3:0]next_state ;
reg signed [15:0] core_r0 , core_r1 , core_r2 , core_r3 ;
reg signed [15:0] core_r4 , core_r5 , core_r6 , core_r7 ;
reg signed [15:0] core_r8 , core_r9 , core_r10, core_r11;
reg signed [15:0] core_r12, core_r13, core_r14, core_r15;


//SRAM
wire  MEM_cen, MEM_oen;
reg   MEM_wen;
wire  [3:0]MEM_adr;
reg   [15:0]MEM_in ;
wire  [15:0] MEM_out;

wire  [2:0]opcode;
wire  [3:0]rs,rt,rd;
wire  func;
wire  signed[4:0]imm;
wire  [15:0]address;
wire  [15:0]inst;
reg   [15:0]inst_reg1, inst_reg2;

reg   signed [15:0]rs_data,rt_data,rd_data;

//wire signed [15:0]a;

reg   in_valid_inst ;
wire  out_valid_inst ;
reg   signed [12:0] pc ;
reg   [4:0]inst_mode ; 

//write_data_signal
wire  signed [15:0]data_addr;
wire  out_finish_data;
reg   in_valid_data_write ;

//load 
reg   in_valid_data_read;
wire  out_valid_data ;
wire  signed[15:0]load_data ;

parameter EMPTY         = 5'd0 ;
parameter ADD           = 5'd1 ;
parameter SUB           = 5'd2 ;
parameter SLT           = 5'd3 ;
parameter MUL           = 5'd4 ;
parameter LOAD          = 5'd5 ;
parameter STORE         = 5'd6 ;
parameter BRANCH        = 5'd7 ;
parameter JUMP          = 5'd8 ;


parameter IDLE              = 4'd0  ;
parameter INST_FETCH_1      = 4'd1  ;
parameter INST_FETCH_2      = 4'd2  ;
parameter SRAM_STORE        = 4'd3  ;
parameter SRAM_TAKE         = 4'd4  ;
parameter INST_DECODE       = 4'd5  ;
parameter EXECUTE           = 4'd6  ;
parameter DATA_LOAD         = 4'd7  ;
parameter DATA_STORE        = 4'd8  ;
parameter WAIT_OUT_FINISH   = 4'd9  ;
parameter WAIT_OUT_VALID_DATA = 4'd10 ;
parameter WRITE_BACK        = 4'd11 ;
parameter CHECK_REG         = 4'd12 ;
//###########################################
//
// Wrtie down your design below
//
//###########################################
assign opcode = inst_reg2[15:13] ;
assign rs     = inst_reg2[12: 9] ;
assign rt     = inst_reg2[ 8: 5] ;
assign rd     = inst_reg2[ 4: 1] ;
assign func   = inst_reg2[0] ;
assign imm    = inst_reg2[ 4: 0] ;
assign address = { 3'b000 , inst_reg2[12:0] } ;

// wire  signed [15:0]aaa;
//assign aaa = ((rs_data + imm) * 2 ) + 16'h1000;
assign data_addr = {4'b0001, ((rs_data + imm) * 2 )} ; //(rs_data + imm) << 1 is 12 bit
//assign a    =(rs_data + imm) << 1 ;
 


always@(posedge clk or negedge rst_n)begin
  if(!rst_n)  current_state <= IDLE ;
  else        current_state <= next_state ;
end

always@(*)begin
    case(current_state)
        IDLE : begin
            next_state = INST_FETCH_1 ;
        end
        INST_FETCH_1 : begin
            next_state = INST_FETCH_2 ;
        end
        INST_FETCH_2 : begin
            if(out_valid_inst)  next_state = SRAM_STORE  ;
            else                next_state = INST_FETCH_2 ;
        end
        SRAM_STORE : begin
            next_state = SRAM_TAKE;
        end
        SRAM_TAKE : begin
            next_state = INST_DECODE;
        end
        INST_DECODE : begin
            next_state = EXECUTE ;
        end
        EXECUTE : begin
            if(opcode[2:1] == 2'b00)      next_state = WRITE_BACK  ; //r-type
            else if(opcode == 3'b011)     next_state = DATA_LOAD   ; //load
            else if(opcode == 3'b010)     next_state = DATA_STORE  ; //store
            else                          next_state = CHECK_REG   ; //jump, slt
        end
        WRITE_BACK : begin
            next_state = CHECK_REG ;
        end

        DATA_LOAD : begin
            next_state = WAIT_OUT_VALID_DATA;
        end

        DATA_STORE : begin
            next_state = WAIT_OUT_FINISH;
        end
        WAIT_OUT_VALID_DATA :begin
            if(out_valid_data)      next_state = CHECK_REG ;
            else                    next_state = WAIT_OUT_VALID_DATA ;
        end
        WAIT_OUT_FINISH : begin
            if(out_finish_data)  next_state = CHECK_REG;
            else                 next_state = WAIT_OUT_FINISH ;
        end

        CHECK_REG : begin
            next_state = IDLE ;
        end
        default: next_state = current_state ;
    endcase
end



always@(posedge clk or negedge rst_n)begin
    if(!rst_n)    pc <= 13'b0;
    else begin
        if(current_state == CHECK_REG) begin
            if(opcode == 3'b101 &&  (rs_data== rt_data) )    pc  <= pc + 2 + (imm << 1)  ;  //predict correct
            else if(opcode == 3'b100 )                       pc  <= address;
            else pc <= pc + 2 ;
        end
    end 
end

always@(*)begin
    case(current_state)
        INST_FETCH_1 : in_valid_inst = 1 ;
        default :      in_valid_inst = 0;
    endcase
end

always@(*)begin
    case(current_state)
        DATA_LOAD : in_valid_data_read = 1 ;
        default :      in_valid_data_read = 0;
    endcase
end

always@(*)begin
    case(current_state)
        SRAM_STORE : MEM_wen = 0 ;
        default :    MEM_wen = 1 ;
    endcase
end

always@(*)begin
    case(current_state)
        SRAM_STORE : MEM_in = inst_reg1;
        default :    MEM_in = 0;
    endcase
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)      inst_reg1 <= 0;
    else if(out_valid_inst)  inst_reg1 <= inst;
 end

 always@(posedge clk or negedge rst_n)begin
    if(!rst_n)      inst_reg2 <= 0;
    else if(current_state == SRAM_TAKE) inst_reg2 <= MEM_out;
 end





//####################################################
//              DECODE
//####################################################
always@(*)begin
    case(opcode)
        3'b000 : begin
            if(func)    inst_mode = ADD ;
            else        inst_mode = SUB ;
        end 
        3'b001 : begin
            if(func)    inst_mode = SLT ;
            else        inst_mode = MUL ;
        end
        3'b011 :        inst_mode = LOAD    ;
        3'b010 :        inst_mode = STORE   ;
        3'b101 :        inst_mode = BRANCH  ;      
        3'b100 :        inst_mode = JUMP    ;
        default : inst_mode = EMPTY ;
    endcase
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)     rs_data <= 0 ;
    else begin
        if (current_state == INST_DECODE) begin
            case(rs)
                0:      rs_data <= core_r0  ;
                1:      rs_data <= core_r1  ;
                2:      rs_data <= core_r2  ;
                3:      rs_data <= core_r3  ;
                4:      rs_data <= core_r4  ;
                5:      rs_data <= core_r5  ;
                6:      rs_data <= core_r6  ;
                7:      rs_data <= core_r7  ;
                8:      rs_data <= core_r8  ;
                9:      rs_data <= core_r9  ;
                10:     rs_data <= core_r10 ; 
                11:     rs_data <= core_r11 ; 
                12:     rs_data <= core_r12 ; 
                13:     rs_data <= core_r13 ; 
                14:     rs_data <= core_r14 ; 
                15:     rs_data <= core_r15 ; 
            endcase
        end         
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)     rt_data <= 0 ;
    else begin
        if (current_state == INST_DECODE) begin
            case(rt)
                0:      rt_data <= core_r0  ;
                1:      rt_data <= core_r1  ;
                2:      rt_data <= core_r2  ;
                3:      rt_data <= core_r3  ;
                4:      rt_data <= core_r4  ;
                5:      rt_data <= core_r5  ;
                6:      rt_data <= core_r6  ;
                7:      rt_data <= core_r7  ;
                8:      rt_data <= core_r8  ;
                9:      rt_data <= core_r9  ;
                10:     rt_data <= core_r10 ; 
                11:     rt_data <= core_r11 ; 
                12:     rt_data <= core_r12 ; 
                13:     rt_data <= core_r13 ; 
                14:     rt_data <= core_r14 ; 
                15:     rt_data <= core_r15 ; 
            endcase
        end         
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)      rd_data <= 0 ;
    else begin
        if(current_state == EXECUTE) begin
            case(inst_mode)
                ADD : rd_data <= rs_data + rt_data ;
                SUB : rd_data <= rs_data - rt_data ;
                SLT : begin
                    if(rt_data > rs_data)   rd_data <= 1'b1 ;
                    else                    rd_data <= 1'b0;
                end 
                MUL : rd_data <= rs_data * rt_data ;

                default : rd_data <= 0 ;
            endcase
        end
    end
end


//####################################################
//                  LOAD_INST
//####################################################
always@(*)begin
    case(current_state)
        //DATA_LOAD :           in_valid_data_write = 1'b1;
        DATA_STORE :          in_valid_data_write = 1'b1;
        default :             in_valid_data_write = 1'b0;
    endcase
end

//####################################################
//              OUTPUT
//####################################################
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        IO_stall <= 1;
    end
    else begin
        case(current_state)
            CHECK_REG : IO_stall <= 0;
            default: IO_stall <= 1 ;
        endcase
  
    end

end

//####################################################
//              CORE_REGISTER
//####################################################
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        core_r0  <= 0;
    end
    else begin
        if(current_state == WRITE_BACK && rd == 0) core_r0 <= rd_data ;
        else if (out_valid_data==1     && rt == 0) core_r0 <= load_data ;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        core_r1  <= 0;
    end
    else begin
        if(current_state == WRITE_BACK && rd == 1) core_r1 <= rd_data ;
        else if (out_valid_data==1     && rt == 1) core_r1 <= load_data ;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        core_r2  <= 0;
    end
    else begin
        if(current_state == WRITE_BACK && rd == 2) core_r2 <= rd_data ;
        else if (out_valid_data==1     && rt == 2) core_r2 <= load_data ;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        core_r3  <= 0;
    end
    else begin
        if(current_state == WRITE_BACK && rd == 3) core_r3 <= rd_data ;
        else if (out_valid_data==1     && rt == 3) core_r3 <= load_data ;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        core_r4  <= 0;
    end
    else begin
        if(current_state == WRITE_BACK && rd == 4) core_r4 <= rd_data ;
        else if (out_valid_data==1     && rt == 4) core_r4 <= load_data ;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        core_r5  <= 0;
    end
    else begin
        if(current_state == WRITE_BACK && rd == 5) core_r5 <= rd_data ;
        else if (out_valid_data==1     && rt == 5) core_r5 <= load_data ;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        core_r6  <= 0;
    end
    else begin
        if(current_state == WRITE_BACK && rd == 6) core_r6 <= rd_data ;
        else if (out_valid_data==1     && rt == 6) core_r6 <= load_data ;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        core_r7  <= 0;
    end
    else begin
        if(current_state == WRITE_BACK && rd == 7) core_r7 <= rd_data ;
        else if (out_valid_data==1     && rt == 7) core_r7 <= load_data ;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        core_r8  <= 0;
    end
    else begin
        if(current_state == WRITE_BACK && rd == 8) core_r8 <= rd_data ;
        else if (out_valid_data==1     && rt == 8) core_r8 <= load_data ;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        core_r9  <= 0;
    end
    else begin
        if(current_state == WRITE_BACK && rd == 9) core_r9 <= rd_data ;
        else if (out_valid_data==1     && rt == 9) core_r9 <= load_data ;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        core_r10  <= 0;
    end
    else begin
        if(current_state == WRITE_BACK && rd == 10) core_r10 <= rd_data ;
        else if (out_valid_data==1     && rt == 10) core_r10 <= load_data ;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        core_r11  <= 0;
    end
    else begin
        if(current_state == WRITE_BACK && rd == 11) core_r11 <= rd_data ;
        else if (out_valid_data==1     && rt == 11) core_r11 <= load_data ;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        core_r12  <= 0;
    end
    else begin
        if(current_state == WRITE_BACK && rd == 12) core_r12 <= rd_data ;
        else if (out_valid_data==1     && rt == 12) core_r12 <= load_data ;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        core_r13  <= 0;
    end
    else begin
        if(current_state == WRITE_BACK && rd == 13) core_r13 <= rd_data ;
        else if (out_valid_data==1     && rt == 13) core_r13 <= load_data ;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        core_r14  <= 0;
    end
    else begin
        if(current_state == WRITE_BACK && rd == 14) core_r14 <= rd_data ;
        else if (out_valid_data==1     && rt == 14) core_r14 <= load_data ;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        core_r15  <= 0;
    end
    else begin
        if(current_state == WRITE_BACK && rd == 15) core_r15 <= rd_data ;
        else if (out_valid_data==1     && rt == 15) core_r15 <= load_data ;
    end
end


//##########################################
//                SRAM
//##########################################

assign MEM_cen = 0 ;
assign MEM_oen = 0 ;
assign MEM_adr = 0 ;
//SRAM 
RA1SH X_0 (.Q(MEM_out) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen) , .A(MEM_adr) , .D(MEM_in), .OEN(MEM_oen));


read_DRAM_instruction Read_Inst(
// global signals 
                .clk(clk),
              .rst_n(rst_n),
// input/output signals 
           .in_valid(in_valid_inst),
            .in_addr(pc),
          .out_valid(out_valid_inst),
           .out_inst(inst),
// axi read address channel                     
         .arid_m_inf(arid_m_inf[DRAM_NUMBER * ID_WIDTH-1:ID_WIDTH]),
       .araddr_m_inf(araddr_m_inf[DRAM_NUMBER * ADDR_WIDTH-1:ADDR_WIDTH]),
        .arlen_m_inf(arlen_m_inf[DRAM_NUMBER * 7 -1:7]),
       .arsize_m_inf(arsize_m_inf[DRAM_NUMBER * 3 -1:3]),
      .arburst_m_inf(arburst_m_inf[DRAM_NUMBER * 2 -1:2]),
      .arvalid_m_inf(arvalid_m_inf[1]),
      .arready_m_inf(arready_m_inf[1]), 
// axi read data channel                    
          .rid_m_inf(rid_m_inf[DRAM_NUMBER * ID_WIDTH-1:ID_WIDTH]),

        .rdata_m_inf(rdata_m_inf[DRAM_NUMBER * DATA_WIDTH-1:DATA_WIDTH]),
        .rresp_m_inf(rresp_m_inf[DRAM_NUMBER * 2 -1:2]),
        .rlast_m_inf(rlast_m_inf[1]),
       .rvalid_m_inf(rvalid_m_inf[1]),
       .rready_m_inf(rready_m_inf[1]) 
);

read_DRAM_data read_DRAM_data(
// global signals 
                .clk(clk),
              .rst_n(rst_n),
// input/output signals 
           .in_valid(in_valid_data_read),
            .in_addr(data_addr[11:0]),
          .out_valid(out_valid_data),
           .out_data(load_data),
// axi read address channel                     
         .arid_m_inf(arid_m_inf[ID_WIDTH-1:0]),
       .araddr_m_inf(araddr_m_inf[ADDR_WIDTH-1:0]),
        .arlen_m_inf(arlen_m_inf[7 -1:0]),
       .arsize_m_inf(arsize_m_inf[3 -1:0]),
      .arburst_m_inf(arburst_m_inf[2 -1:0]),
      .arvalid_m_inf(arvalid_m_inf[0]),
      .arready_m_inf(arready_m_inf[0]), 
// axi read data channel                    
          .rid_m_inf(rid_m_inf[ID_WIDTH-1:0]),
        .rdata_m_inf(rdata_m_inf[DATA_WIDTH-1:0]),
        .rresp_m_inf(rresp_m_inf[2 -1:0]),
        .rlast_m_inf(rlast_m_inf[0]),
       .rvalid_m_inf(rvalid_m_inf[0]),
       .rready_m_inf(rready_m_inf[0]) 
);


write_DRAM_data WRITE_DATA(
// global signals 
                .clk(clk),
              .rst_n(rst_n),
// input/output signals 
           .in_valid(in_valid_data_write),
            .in_addr(data_addr[11:0]),
            .in_data(rt_data),
         .out_finish(out_finish_data),
// axi write address channel 
         .awid_m_inf(awid_m_inf),
       .awaddr_m_inf(awaddr_m_inf),
       .awsize_m_inf(awsize_m_inf),
      .awburst_m_inf(awburst_m_inf),
        .awlen_m_inf(awlen_m_inf),
      .awvalid_m_inf(awvalid_m_inf),
      .awready_m_inf(awready_m_inf),
// axi write data channel                     
        .wdata_m_inf(wdata_m_inf),
        .wlast_m_inf(wlast_m_inf),
       .wvalid_m_inf(wvalid_m_inf),
       .wready_m_inf(wready_m_inf),
// axi write response channel
          .bid_m_inf(bid_m_inf),
        .bresp_m_inf(bresp_m_inf),
       .bvalid_m_inf(bvalid_m_inf),
       .bready_m_inf(bready_m_inf)
);

//###############################################
//assign awid_m_inf = 0;
//assign awaddr_m_inf = 0;
//assign awsize_m_inf[2:0] = 3'b001;
//assign awburst_m_inf = 2'b01;
//assign awlen_m_inf = 0;
//assign awvalid_m_inf = 0;

// assign wdata_m_inf = 0;
// assign wlast_m_inf = 0;
// assign wvalid_m_inf = 0;

//assign bready_m_inf = 0;
//assign arid_m_inf[3:0] = 0;
//assign araddr_m_inf[31:0] = 0;
//assign arlen_m_inf[6:0]=0;
//assign arlen_m_inf[2:0]=0;
//assign arburst_m_inf[1:0]=0;
//assign arvalid_m_inf[0]=0;
//assign rready_m_inf[0]=0;

//assign arsize_m_inf[2:0]= 3'b001;


//###############################################

endmodule







//################################################
//              SUBMODULE
//################################################


module read_DRAM_instruction(
// global signals 
                clk,
              rst_n,
// input/output signals 
           in_valid,
            in_addr,
          out_valid,
           out_inst,
// axi read address channel                     
         arid_m_inf,
       araddr_m_inf,
        arlen_m_inf,
       arsize_m_inf,
      arburst_m_inf,
      arvalid_m_inf,
      arready_m_inf, 
// axi read data channel                    
          rid_m_inf,
        rdata_m_inf,
        rresp_m_inf,
        rlast_m_inf,
       rvalid_m_inf,
       rready_m_inf 
);
//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================
parameter ID_WIDTH = 4 , ADDR_WIDTH = 32, DATA_WIDTH = 16, DRAM_NUMBER=2, WRIT_NUMBER=1;
// ---------------------------------------------------------------
// global signals
input  wire clk, rst_n;
// ---------------------------------------------------------------
// input/output signals 
input  in_valid;
input  [12:0] in_addr; //used to connect PC
output reg out_valid;
output reg [15:0] out_inst;
// ---------------------------------------------------------------
// axi read address channel 
output  wire [ID_WIDTH-1:0]       arid_m_inf;
output  wire [ADDR_WIDTH-1:0]   araddr_m_inf;
output  wire [7 -1:0]            arlen_m_inf;
output  wire [3 -1:0]           arsize_m_inf;
output  wire [2 -1:0]          arburst_m_inf;
output  reg                    arvalid_m_inf;
input   wire                   arready_m_inf;
// ---------------------------------------------------------------
// axi read data channel
input   wire [ID_WIDTH-1:0]         rid_m_inf;
input   wire [DATA_WIDTH-1:0]     rdata_m_inf;
input   wire [2 -1:0]             rresp_m_inf;
input   wire                      rlast_m_inf;
input   wire                     rvalid_m_inf;
output  reg                      rready_m_inf;
// ---------------------------------------------------------------
reg     [1:0]current_state,next_state;
reg     [15:0]out_reg;
assign arid_m_inf = 0 ;
assign arlen_m_inf = 7'b0 ;
assign arsize_m_inf = 3'b001 ;
assign arburst_m_inf = 2'b01 ;
assign araddr_m_inf = {16'd0, 4'b0001, in_addr[11:0] };


parameter   IDLE = 2'd0;
parameter   SEND = 2'd1;
parameter   WAIT = 2'd2;
parameter   OUT  = 2'd3;


//FSM
always@(posedge clk or negedge rst_n)begin
  if(!rst_n)  current_state <= 0;
  else current_state <= next_state;
end

always@(*)begin
    case(current_state)
        IDLE : begin
            if(in_valid)    next_state = SEND ;
            else            next_state = IDLE ;
        end
        SEND : begin
            if(arready_m_inf) next_state = WAIT ;
            else              next_state = SEND ;
        end
        WAIT : begin
            if(rlast_m_inf)  next_state = OUT ;
            else             next_state = WAIT;
        end
        OUT: begin
            next_state = IDLE;
        end


        default : next_state = current_state;
    endcase
end

always@(*)begin
    case(current_state)
        SEND : arvalid_m_inf = 1 ;
        default : arvalid_m_inf = 0;
    endcase
end

always@(*)begin
    case(current_state)
        WAIT : rready_m_inf = 1;
        default : rready_m_inf = 0;
    endcase
end

always@(*)begin
    case(current_state)
        OUT :     out_valid = 1;
        default : out_valid = 0;
    endcase
end

always@(posedge clk or negedge rst_n)begin
  if(!rst_n)            out_reg <= 0;
  else if(rlast_m_inf)  out_reg <= rdata_m_inf;
end

always@(*)begin
    case(current_state)
        OUT :     out_inst = out_reg ;  
        default : out_inst = 0 ; 
    endcase
end

endmodule



module read_DRAM_data(
// global signals 
                clk,
              rst_n,
// input/output signals 
           in_valid,
            in_addr,
            in_data,
          out_valid,
           out_data,
// axi read address channel                     
         arid_m_inf,
       araddr_m_inf,
        arlen_m_inf,
       arsize_m_inf,
      arburst_m_inf,
      arvalid_m_inf,
// axi read data channel                    
      arready_m_inf, 
          rid_m_inf,
        rdata_m_inf,
        rresp_m_inf,
        rlast_m_inf,
       rvalid_m_inf,
       rready_m_inf 
);
//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================
parameter ID_WIDTH = 4 , ADDR_WIDTH = 32, DATA_WIDTH = 16, DRAM_NUMBER=2, WRIT_NUMBER=1;
// ---------------------------------------------------------------
// global signals
input  wire clk, rst_n;
// ---------------------------------------------------------------
// input/output signals 
input  in_valid;
input  [11:0] in_addr;
input  [15:0] in_data;
output reg out_valid;
output reg [15:0] out_data;
// ---------------------------------------------------------------
// axi read address channel 
output  wire [ID_WIDTH-1:0]       arid_m_inf;
output  wire [ADDR_WIDTH-1:0]   araddr_m_inf;
output  wire [7 -1:0]            arlen_m_inf;
output  wire [3 -1:0]           arsize_m_inf;
output  wire [2 -1:0]          arburst_m_inf;
output  reg                    arvalid_m_inf;
input   wire                   arready_m_inf;
// ---------------------------------------------------------------
// axi read data channel
input   wire [ID_WIDTH-1:0]         rid_m_inf;
input   wire [DATA_WIDTH-1:0]     rdata_m_inf;
input   wire [2 -1:0]             rresp_m_inf;
input   wire                      rlast_m_inf;
input   wire                     rvalid_m_inf;
output  reg                      rready_m_inf;
// ---------------------------------------------------------------
//================================================================
//  integer / genvar / parameter
//================================================================
//  FSM
parameter IDLE  = 2'd0 ;
parameter SEND  = 2'd1 ;
parameter WAIT  = 2'd2 ;
parameter OUT   = 2'd3 ;

//================================================================
//  Wire & Reg
//================================================================
reg      [1:0] current_state, next_state;
reg      [15:0]out_reg;
assign   arid_m_inf = 0 ;
assign   arlen_m_inf = 7'b0 ;
assign   arsize_m_inf = 3'b001 ;
assign   arburst_m_inf = 2'b01 ;
//  
assign   araddr_m_inf = { 16'd0 , 4'b001 , in_addr } ;
//================================================================
//  FSM
//================================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)     current_state <= IDLE ;
    else            current_state <= next_state ;
end
always @(*)begin
    case(current_state)
        IDLE : begin
            if(in_valid)    next_state = SEND ;
            else            next_state = IDLE ;
        end
        SEND : begin
            if(arready_m_inf) next_state = WAIT ;
            else              next_state = SEND ; 
        end
        WAIT : begin
            if(rlast_m_inf)  next_state = OUT ;
            else             next_state = WAIT;
        end
        OUT : begin
            next_state = IDLE;
        end
        default : next_state = current_state ;
    endcase
end
 
always@(*)begin
    case(current_state)
        SEND : arvalid_m_inf = 1 ;
        default : arvalid_m_inf = 0;
    endcase
end

always@(*)begin
    case(current_state)
        WAIT :    rready_m_inf = 1;
        default : rready_m_inf = 0;
    endcase
end

always@(*)begin
    case(current_state)
        OUT :     out_valid = 1;
        default : out_valid = 0;
    endcase
end

always@(posedge clk or negedge rst_n)begin
  if(!rst_n)            out_reg <= 0;
  else if(rlast_m_inf)  out_reg <= rdata_m_inf;
end

always@(*)begin
    case(current_state)
        OUT :     out_data = out_reg ;  
        default : out_data = 0 ; 
    endcase
end


endmodule


module write_DRAM_data(
// global signals 
                clk,
              rst_n,
// input/output signals 
           in_valid,
            in_addr,
            in_data,
         out_finish,
// axi write address channel 
         awid_m_inf,
       awaddr_m_inf,
       awsize_m_inf,
      awburst_m_inf,
        awlen_m_inf,
      awvalid_m_inf,
      awready_m_inf,
// axi write data channel                     
        wdata_m_inf,
        wlast_m_inf,
       wvalid_m_inf,
       wready_m_inf,
// axi write response channel
          bid_m_inf,
        bresp_m_inf,
       bvalid_m_inf,
       bready_m_inf
);
//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================
parameter ID_WIDTH = 4 , ADDR_WIDTH = 32, DATA_WIDTH = 16, DRAM_NUMBER=2, WRIT_NUMBER=1;
// ---------------------------------------------------------------
// global signals
input  wire clk, rst_n;
// ---------------------------------------------------------------
// input/output signals 
input  in_valid;
input  [11:0] in_addr; //sent address = {16'd0, 4'b0001, in_addr, 1'b0} due to multiple 2
input  [15:0] in_data;
output reg out_finish;
// ---------------------------------------------------------------
// axi write address channel 
output  wire [ID_WIDTH-1:0]        awid_m_inf;
output  wire [ADDR_WIDTH-1:0]    awaddr_m_inf;
output  wire [3 -1:0]            awsize_m_inf;
output  wire [2 -1:0]           awburst_m_inf;
output  wire [7 -1:0]             awlen_m_inf;
output  reg                     awvalid_m_inf;
input   wire                    awready_m_inf;
// ---------------------------------------------------------------
// axi write data channel 
output  reg  [DATA_WIDTH-1:0]     wdata_m_inf;
output  reg                       wlast_m_inf;
output  reg                      wvalid_m_inf;
input   wire                     wready_m_inf;
// ---------------------------------------------------------------
// axi write response channel
input   wire [ID_WIDTH-1:0]         bid_m_inf;
input   wire [2 -1:0]             bresp_m_inf;
input   wire                     bvalid_m_inf;
output  wire                     bready_m_inf;
// ---------------------------------------------------------------
//================================================================
//  integer / genvar / parameter
//================================================================
//  FSM
parameter IDLE = 3'd0 ;
parameter SEND = 3'd1 ;
parameter WAIT = 3'd2 ;
parameter OUT  = 3'd3 ;
parameter RESPONSE = 3'd4;
//================================================================
//  Wire & Reg
//================================================================
//  FSM
reg  [2:0] current_state, next_state;
//================================================================
//  FSM
//================================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)     current_state <= IDLE ;
    else            current_state <= next_state ;
end
always @(*) begin
    case(current_state)
        IDLE : begin
            if(in_valid)        next_state = SEND ;
            else                next_state = IDLE ;
        end
        SEND : begin
            if(awready_m_inf)   next_state = WAIT ;
            else                next_state = SEND ;
        end
        WAIT : begin
            if(wready_m_inf)    next_state = OUT ;
            else                next_state = WAIT;
        end
        OUT : begin
            next_state = RESPONSE ;
        end
        RESPONSE : begin
            if(bvalid_m_inf) next_state = IDLE ;
            else             next_state = RESPONSE ;
        end

        default : next_state = current_state ;
    endcase
end
//================================================================
//  AXI 4
//================================================================
// constant AXI 4 signals
assign awid_m_inf = 0 ;
assign awlen_m_inf = 7'd0 ;
assign awsize_m_inf = 3'b001 ;
assign awburst_m_inf = 2'b01 ;
//
assign awaddr_m_inf = { 16'd0 , 4'b0001, in_addr } ;
assign bready_m_inf = (current_state == RESPONSE) ? 1 : 0 ;
// 
always @(*) begin
    case(current_state)
        SEND :    awvalid_m_inf = 1 ;
        default : awvalid_m_inf = 0 ;
    endcase
end



always@(*)begin
    case(current_state)
        WAIT :    wvalid_m_inf = 1;
        default : wvalid_m_inf = 0;
    endcase
end

always@(*)begin
    case(current_state)
        WAIT :    wdata_m_inf = in_data ;
        default : wdata_m_inf = 0 ;
    endcase
end

always@(*)begin
    case(current_state)
        WAIT :    wlast_m_inf = 1;
        default : wlast_m_inf = 0;
    endcase
end

//================================================================
//  OUTPUT
//================================================================


always@(*)begin
    case(current_state)
        OUT :     out_finish = 1;
        default : out_finish = 0;
    endcase
end

endmodule












