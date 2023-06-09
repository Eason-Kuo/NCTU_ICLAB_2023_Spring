module MMT(
// input signals
    clk,
    rst_n,
    in_valid,
	in_valid2,
    matrix,
	matrix_size,
    matrix_idx,
    mode,
	
// output signals
    out_valid,
    out_value
);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION
//---------------------------------------------------------------------
input        clk, rst_n, in_valid, in_valid2;
input [7:0] matrix;
input [1:0]  matrix_size,mode;
input [4:0]  matrix_idx;

output reg       	     out_valid;
output reg signed [49:0] out_value;
//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------
parameter IDLE    = 4'd0; 
parameter STORE   = 4'd1; 
parameter WAIT_IN_VALID2 = 4'd2;
parameter TAKE_VALUE = 4'd3;
parameter COMPUTE = 4'd4; 
parameter COMPUTE2 = 4'd5;
parameter FIND_TRACE = 4'd6;

//---------------------------------------------------------------------
//   WIRE AND REG DECLARATION
//---------------------------------------------------------------------
wire    MEM_cen, MEM_oen;
wire  signed [7:0]MEM_out_X[0:31];
reg     	[7:0]MEM_in_X[0:31];
reg     	[7:0]MEM_adr_X[0:31];
wire    	MEM_wen_X[0:31];

reg 	[3:0]current_state ;
reg		[3:0]next_state;

//INPUT
reg 		[1:0]size ;
reg 		[15:0]cnt_in ;
reg 		[8:0]mem_words_max; 
wire 		[8:0]mem_minus_one; 
reg  signed [7:0]matrix_temp;
reg			[7:0]pointer, addr_cnt;
//WAIT_IN_VALID2
reg			[4:0]idx_a[0:2] ;
reg			[1:0]mode_a;
reg			[3:0]cnt_in2;
//TAKE_VALUE && TRANSPOSE
reg signed	[8:0]matrix_A[0:15][0:15];
reg signed	[8:0]matrix_B[0:15][0:15];
reg signed	[8:0]matrix_C[0:15][0:15];
integer     i,j;		
reg			[8:0]cnt_take; 
reg			[8:0]pointer2;
wire		[4:0]row;
wire		[4:0]column;
reg			[4:0]number_of_row;
assign		column = pointer2 % number_of_row;
assign		row = pointer2 / number_of_row;
//COMPUTE
reg	signed	[20:0]mx[0:15];
reg	signed	[20:0]my0[0:15];
reg	signed	[20:0]my1[0:15];
reg	signed	[20:0]my2[0:15];
reg	signed	[20:0]my3[0:15];
reg	signed	[20:0]my4[0:15];
reg	signed	[20:0]my5[0:15];
reg	signed	[20:0]my6[0:15];
reg	signed	[20:0]my7[0:15];
reg	signed	[20:0]my8[0:15];
reg	signed	[20:0]my9[0:15];
reg	signed	[20:0]my10[0:15];
reg	signed	[20:0]my11[0:15];
reg	signed	[20:0]my12[0:15];
reg	signed	[20:0]my13[0:15];
reg	signed	[20:0]my14[0:15];
reg	signed	[20:0]my15[0:15];
wire signed	[40:0]dot_out[0:15];
reg signed	[25:0]matrix_temp1[0:15][0:15];
reg signed	[40:0]matrix_temp2[0:15][0:15];
integer		k,l;
reg 	    [3:0]cnt_compute, cnt_compute2;
reg 	  	[4:0]cnt_cycle, cnt_cycle2; 
//FIND_THE_TRACE
wire signed	[49:0]out,out1,out2;
reg			[3:0]cnt_round;
integer		m,n;
//---------------------------------------------------------------------
//   DESIGN
//---------------------------------------------------------------------
assign MEM_cen = 0 ;
assign MEM_oen = 0 ;
assign mem_minus_one = mem_words_max - 1 ; 

RA1SH X_0 (.Q(MEM_out_X[0 ]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X[0 ]) , .A(MEM_adr_X[0 ]) , .D(MEM_in_X[0 ]), .OEN(MEM_oen));
RA1SH X_1 (.Q(MEM_out_X[1 ]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X[1 ]) , .A(MEM_adr_X[1 ]) , .D(MEM_in_X[1 ]), .OEN(MEM_oen));
RA1SH X_2 (.Q(MEM_out_X[2 ]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X[2 ]) , .A(MEM_adr_X[2 ]) , .D(MEM_in_X[2 ]), .OEN(MEM_oen));
RA1SH X_3 (.Q(MEM_out_X[3 ]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X[3 ]) , .A(MEM_adr_X[3 ]) , .D(MEM_in_X[3 ]), .OEN(MEM_oen));
RA1SH X_4 (.Q(MEM_out_X[4 ]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X[4 ]) , .A(MEM_adr_X[4 ]) , .D(MEM_in_X[4 ]), .OEN(MEM_oen));
RA1SH X_5 (.Q(MEM_out_X[5 ]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X[5 ]) , .A(MEM_adr_X[5 ]) , .D(MEM_in_X[5 ]), .OEN(MEM_oen));
RA1SH X_6 (.Q(MEM_out_X[6 ]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X[6 ]) , .A(MEM_adr_X[6 ]) , .D(MEM_in_X[6 ]), .OEN(MEM_oen));
RA1SH X_7 (.Q(MEM_out_X[7 ]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X[7 ]) , .A(MEM_adr_X[7 ]) , .D(MEM_in_X[7 ]), .OEN(MEM_oen));
RA1SH X_8 (.Q(MEM_out_X[8 ]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X[8 ]) , .A(MEM_adr_X[8 ]) , .D(MEM_in_X[8 ]), .OEN(MEM_oen));
RA1SH X_9 (.Q(MEM_out_X[9 ]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X[9 ]) , .A(MEM_adr_X[9 ]) , .D(MEM_in_X[9 ]), .OEN(MEM_oen));
RA1SH X_10(.Q(MEM_out_X[10]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X[10]) , .A(MEM_adr_X[10]) , .D(MEM_in_X[10]), .OEN(MEM_oen));
RA1SH X_11(.Q(MEM_out_X[11]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X[11]) , .A(MEM_adr_X[11]) , .D(MEM_in_X[11]), .OEN(MEM_oen));
RA1SH X_12(.Q(MEM_out_X[12]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X[12]) , .A(MEM_adr_X[12]) , .D(MEM_in_X[12]), .OEN(MEM_oen));
RA1SH X_13(.Q(MEM_out_X[13]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X[13]) , .A(MEM_adr_X[13]) , .D(MEM_in_X[13]), .OEN(MEM_oen));
RA1SH X_14(.Q(MEM_out_X[14]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X[14]) , .A(MEM_adr_X[14]) , .D(MEM_in_X[14]), .OEN(MEM_oen));
RA1SH X_15(.Q(MEM_out_X[15]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X[15]) , .A(MEM_adr_X[15]) , .D(MEM_in_X[15]), .OEN(MEM_oen));

RA1SH X_16 (.Q(MEM_out_X[16]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X[16]) , .A(MEM_adr_X[16]) , .D(MEM_in_X[16]), .OEN(MEM_oen));
RA1SH X_17 (.Q(MEM_out_X[17]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X[17]) , .A(MEM_adr_X[17]) , .D(MEM_in_X[17]), .OEN(MEM_oen));
RA1SH X_18 (.Q(MEM_out_X[18]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X[18]) , .A(MEM_adr_X[18]) , .D(MEM_in_X[18]), .OEN(MEM_oen));
RA1SH X_19 (.Q(MEM_out_X[19]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X[19]) , .A(MEM_adr_X[19]) , .D(MEM_in_X[19]), .OEN(MEM_oen));
RA1SH X_20 (.Q(MEM_out_X[20]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X[20]) , .A(MEM_adr_X[20]) , .D(MEM_in_X[20]), .OEN(MEM_oen));
RA1SH X_21 (.Q(MEM_out_X[21]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X[21]) , .A(MEM_adr_X[21]) , .D(MEM_in_X[21]), .OEN(MEM_oen));
RA1SH X_22 (.Q(MEM_out_X[22]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X[22]) , .A(MEM_adr_X[22]) , .D(MEM_in_X[22]), .OEN(MEM_oen));
RA1SH X_23 (.Q(MEM_out_X[23]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X[23]) , .A(MEM_adr_X[23]) , .D(MEM_in_X[23]), .OEN(MEM_oen));
RA1SH X_24 (.Q(MEM_out_X[24]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X[24]) , .A(MEM_adr_X[24]) , .D(MEM_in_X[24]), .OEN(MEM_oen));
RA1SH X_25 (.Q(MEM_out_X[25]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X[25]) , .A(MEM_adr_X[25]) , .D(MEM_in_X[25]), .OEN(MEM_oen));
RA1SH X_26 (.Q(MEM_out_X[26]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X[26]) , .A(MEM_adr_X[26]) , .D(MEM_in_X[26]), .OEN(MEM_oen));
RA1SH X_27 (.Q(MEM_out_X[27]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X[27]) , .A(MEM_adr_X[27]) , .D(MEM_in_X[27]), .OEN(MEM_oen));
RA1SH X_28 (.Q(MEM_out_X[28]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X[28]) , .A(MEM_adr_X[28]) , .D(MEM_in_X[28]), .OEN(MEM_oen));
RA1SH X_29 (.Q(MEM_out_X[29]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X[29]) , .A(MEM_adr_X[29]) , .D(MEM_in_X[29]), .OEN(MEM_oen));
RA1SH X_30 (.Q(MEM_out_X[30]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X[30]) , .A(MEM_adr_X[30]) , .D(MEM_in_X[30]), .OEN(MEM_oen));
RA1SH X_31 (.Q(MEM_out_X[31]) , .CLK(clk), .CEN(MEM_cen), .WEN(MEM_wen_X[31]) , .A(MEM_adr_X[31]) , .D(MEM_in_X[31]), .OEN(MEM_oen));
//DOT_16
dot_16 M0(.x_0(mx[0]), .x_1(mx[1]), .x_2(mx[2]), .x_3(mx[3]), .x_4(mx[4]), .x_5(mx[5]), .x_6(mx[6]), .x_7(mx[7]), .x_8(mx[8]), .x_9(mx[9]), .x_10(mx[10]), .x_11(mx[11]), .x_12(mx[12]), .x_13(mx[13]), .x_14(mx[14]), .x_15(mx[15]),
		  .y_0(my0[0]), .y_1(my0[1]), .y_2(my0[2]), .y_3(my0[3]), .y_4(my0[4]), .y_5(my0[5]), .y_6(my0[6]), .y_7(my0[7]), .y_8(my0[8]), .y_9(my0[9]), .y_10(my0[10]), .y_11(my0[11]), .y_12(my0[12]), .y_13(my0[13]), .y_14(my0[14]), .y_15(my0[15]),
		  .clk(clk), .dot_out(dot_out[0]));

dot_16 M1(.x_0(mx[0]), .x_1(mx[1]), .x_2(mx[2]), .x_3(mx[3]), .x_4(mx[4]), .x_5(mx[5]), .x_6(mx[6]), .x_7(mx[7]), .x_8(mx[8]), .x_9(mx[9]), .x_10(mx[10]), .x_11(mx[11]), .x_12(mx[12]), .x_13(mx[13]), .x_14(mx[14]), .x_15(mx[15]),
		  .y_0(my1[0]), .y_1(my1[1]), .y_2(my1[2]), .y_3(my1[3]), .y_4(my1[4]), .y_5(my1[5]), .y_6(my1[6]), .y_7(my1[7]), .y_8(my1[8]), .y_9(my1[9]), .y_10(my1[10]), .y_11(my1[11]), .y_12(my1[12]), .y_13(my1[13]), .y_14(my1[14]), .y_15(my1[15]),
		  .clk(clk), .dot_out(dot_out[1]));

dot_16 M2(.x_0(mx[0]), .x_1(mx[1]), .x_2(mx[2]), .x_3(mx[3]), .x_4(mx[4]), .x_5(mx[5]), .x_6(mx[6]), .x_7(mx[7]), .x_8(mx[8]), .x_9(mx[9]), .x_10(mx[10]), .x_11(mx[11]), .x_12(mx[12]), .x_13(mx[13]), .x_14(mx[14]), .x_15(mx[15]),
		  .y_0(my2[0]), .y_1(my2[1]), .y_2(my2[2]), .y_3(my2[3]), .y_4(my2[4]), .y_5(my2[5]), .y_6(my2[6]), .y_7(my2[7]), .y_8(my2[8]), .y_9(my2[9]), .y_10(my2[10]), .y_11(my2[11]), .y_12(my2[12]), .y_13(my2[13]), .y_14(my2[14]), .y_15(my2[15]),
		  .clk(clk), .dot_out(dot_out[2]));

dot_16 M3(.x_0(mx[0]), .x_1(mx[1]), .x_2(mx[2]), .x_3(mx[3]), .x_4(mx[4]), .x_5(mx[5]), .x_6(mx[6]), .x_7(mx[7]), .x_8(mx[8]), .x_9(mx[9]), .x_10(mx[10]), .x_11(mx[11]), .x_12(mx[12]), .x_13(mx[13]), .x_14(mx[14]), .x_15(mx[15]),
		  .y_0(my3[0]), .y_1(my3[1]), .y_2(my3[2]), .y_3(my3[3]), .y_4(my3[4]), .y_5(my3[5]), .y_6(my3[6]), .y_7(my3[7]), .y_8(my3[8]), .y_9(my3[9]), .y_10(my3[10]), .y_11(my3[11]), .y_12(my3[12]), .y_13(my3[13]), .y_14(my3[14]), .y_15(my3[15]),
		  .clk(clk), .dot_out(dot_out[3]));

dot_16 M4(.x_0(mx[0]), .x_1(mx[1]), .x_2(mx[2]), .x_3(mx[3]), .x_4(mx[4]), .x_5(mx[5]), .x_6(mx[6]), .x_7(mx[7]), .x_8(mx[8]), .x_9(mx[9]), .x_10(mx[10]), .x_11(mx[11]), .x_12(mx[12]), .x_13(mx[13]), .x_14(mx[14]), .x_15(mx[15]),
		  .y_0(my4[0]), .y_1(my4[1]), .y_2(my4[2]), .y_3(my4[3]), .y_4(my4[4]), .y_5(my4[5]), .y_6(my4[6]), .y_7(my4[7]), .y_8(my4[8]), .y_9(my4[9]), .y_10(my4[10]), .y_11(my4[11]), .y_12(my4[12]), .y_13(my4[13]), .y_14(my4[14]), .y_15(my4[15]),
		  .clk(clk), .dot_out(dot_out[4]));

dot_16 M5(.x_0(mx[0]), .x_1(mx[1]), .x_2(mx[2]), .x_3(mx[3]), .x_4(mx[4]), .x_5(mx[5]), .x_6(mx[6]), .x_7(mx[7]), .x_8(mx[8]), .x_9(mx[9]), .x_10(mx[10]), .x_11(mx[11]), .x_12(mx[12]), .x_13(mx[13]), .x_14(mx[14]), .x_15(mx[15]),
		  .y_0(my5[0]), .y_1(my5[1]), .y_2(my5[2]), .y_3(my5[3]), .y_4(my5[4]), .y_5(my5[5]), .y_6(my5[6]), .y_7(my5[7]), .y_8(my5[8]), .y_9(my5[9]), .y_10(my5[10]), .y_11(my5[11]), .y_12(my5[12]), .y_13(my5[13]), .y_14(my5[14]), .y_15(my5[15]),
		  .clk(clk), .dot_out(dot_out[5]));

dot_16 M6(.x_0(mx[0]), .x_1(mx[1]), .x_2(mx[2]), .x_3(mx[3]), .x_4(mx[4]), .x_5(mx[5]), .x_6(mx[6]), .x_7(mx[7]), .x_8(mx[8]), .x_9(mx[9]), .x_10(mx[10]), .x_11(mx[11]), .x_12(mx[12]), .x_13(mx[13]), .x_14(mx[14]), .x_15(mx[15]),
		  .y_0(my6[0]), .y_1(my6[1]), .y_2(my6[2]), .y_3(my6[3]), .y_4(my6[4]), .y_5(my6[5]), .y_6(my6[6]), .y_7(my6[7]), .y_8(my6[8]), .y_9(my6[9]), .y_10(my6[10]), .y_11(my6[11]), .y_12(my6[12]), .y_13(my6[13]), .y_14(my6[14]), .y_15(my6[15]),
		  .clk(clk), .dot_out(dot_out[6]));

dot_16 M7(.x_0(mx[0]), .x_1(mx[1]), .x_2(mx[2]), .x_3(mx[3]), .x_4(mx[4]), .x_5(mx[5]), .x_6(mx[6]), .x_7(mx[7]), .x_8(mx[8]), .x_9(mx[9]), .x_10(mx[10]), .x_11(mx[11]), .x_12(mx[12]), .x_13(mx[13]), .x_14(mx[14]), .x_15(mx[15]),
		  .y_0(my7[0]), .y_1(my7[1]), .y_2(my7[2]), .y_3(my7[3]), .y_4(my7[4]), .y_5(my7[5]), .y_6(my7[6]), .y_7(my7[7]), .y_8(my7[8]), .y_9(my7[9]), .y_10(my7[10]), .y_11(my7[11]), .y_12(my7[12]), .y_13(my7[13]), .y_14(my7[14]), .y_15(my7[15]),
		  .clk(clk), .dot_out(dot_out[7]));

dot_16 M8(.x_0(mx[0]), .x_1(mx[1]), .x_2(mx[2]), .x_3(mx[3]), .x_4(mx[4]), .x_5(mx[5]), .x_6(mx[6]), .x_7(mx[7]), .x_8(mx[8]), .x_9(mx[9]), .x_10(mx[10]), .x_11(mx[11]), .x_12(mx[12]), .x_13(mx[13]), .x_14(mx[14]), .x_15(mx[15]),
		  .y_0(my8[0]), .y_1(my8[1]), .y_2(my8[2]), .y_3(my8[3]), .y_4(my8[4]), .y_5(my8[5]), .y_6(my8[6]), .y_7(my8[7]), .y_8(my8[8]), .y_9(my8[9]), .y_10(my8[10]), .y_11(my8[11]), .y_12(my8[12]), .y_13(my8[13]), .y_14(my8[14]), .y_15(my8[15]),
		  .clk(clk), .dot_out(dot_out[8]));

dot_16 M9(.x_0(mx[0]), .x_1(mx[1]), .x_2(mx[2]), .x_3(mx[3]), .x_4(mx[4]), .x_5(mx[5]), .x_6(mx[6]), .x_7(mx[7]), .x_8(mx[8]), .x_9(mx[9]), .x_10(mx[10]), .x_11(mx[11]), .x_12(mx[12]), .x_13(mx[13]), .x_14(mx[14]), .x_15(mx[15]),
		  .y_0(my9[0]), .y_1(my9[1]), .y_2(my9[2]), .y_3(my9[3]), .y_4(my9[4]), .y_5(my9[5]), .y_6(my9[6]), .y_7(my9[7]), .y_8(my9[8]), .y_9(my9[9]), .y_10(my9[10]), .y_11(my9[11]), .y_12(my9[12]), .y_13(my9[13]), .y_14(my9[14]), .y_15(my9[15]),
		  .clk(clk), .dot_out(dot_out[9]));

dot_16 M10(.x_0(mx[0]), .x_1(mx[1]), .x_2(mx[2]), .x_3(mx[3]), .x_4(mx[4]), .x_5(mx[5]), .x_6(mx[6]), .x_7(mx[7]), .x_8(mx[8]), .x_9(mx[9]), .x_10(mx[10]), .x_11(mx[11]), .x_12(mx[12]), .x_13(mx[13]), .x_14(mx[14]), .x_15(mx[15]),
		  .y_0(my10[0]), .y_1(my10[1]), .y_2(my10[2]), .y_3(my10[3]), .y_4(my10[4]), .y_5(my10[5]), .y_6(my10[6]), .y_7(my10[7]), .y_8(my10[8]), .y_9(my10[9]), .y_10(my10[10]), .y_11(my10[11]), .y_12(my10[12]), .y_13(my10[13]), .y_14(my10[14]), .y_15(my10[15]),
		  .clk(clk), .dot_out(dot_out[10]));

dot_16 M11(.x_0(mx[0]), .x_1(mx[1]), .x_2(mx[2]), .x_3(mx[3]), .x_4(mx[4]), .x_5(mx[5]), .x_6(mx[6]), .x_7(mx[7]), .x_8(mx[8]), .x_9(mx[9]), .x_10(mx[10]), .x_11(mx[11]), .x_12(mx[12]), .x_13(mx[13]), .x_14(mx[14]), .x_15(mx[15]),
		  .y_0(my11[0]), .y_1(my11[1]), .y_2(my11[2]), .y_3(my11[3]), .y_4(my11[4]), .y_5(my11[5]), .y_6(my11[6]), .y_7(my11[7]), .y_8(my11[8]), .y_9(my11[9]), .y_10(my11[10]), .y_11(my11[11]), .y_12(my11[12]), .y_13(my11[13]), .y_14(my11[14]), .y_15(my11[15]),
		  .clk(clk), .dot_out(dot_out[11]));

dot_16 M12(.x_0(mx[0]), .x_1(mx[1]), .x_2(mx[2]), .x_3(mx[3]), .x_4(mx[4]), .x_5(mx[5]), .x_6(mx[6]), .x_7(mx[7]), .x_8(mx[8]), .x_9(mx[9]), .x_10(mx[10]), .x_11(mx[11]), .x_12(mx[12]), .x_13(mx[13]), .x_14(mx[14]), .x_15(mx[15]),
		  .y_0(my12[0]), .y_1(my12[1]), .y_2(my12[2]), .y_3(my12[3]), .y_4(my12[4]), .y_5(my12[5]), .y_6(my12[6]), .y_7(my12[7]), .y_8(my12[8]), .y_9(my12[9]), .y_10(my12[10]), .y_11(my12[11]), .y_12(my12[12]), .y_13(my12[13]), .y_14(my12[14]), .y_15(my12[15]),
		  .clk(clk), .dot_out(dot_out[12]));

dot_16 M13(.x_0(mx[0]), .x_1(mx[1]), .x_2(mx[2]), .x_3(mx[3]), .x_4(mx[4]), .x_5(mx[5]), .x_6(mx[6]), .x_7(mx[7]), .x_8(mx[8]), .x_9(mx[9]), .x_10(mx[10]), .x_11(mx[11]), .x_12(mx[12]), .x_13(mx[13]), .x_14(mx[14]), .x_15(mx[15]),
		  .y_0(my13[0]), .y_1(my13[1]), .y_2(my13[2]), .y_3(my13[3]), .y_4(my13[4]), .y_5(my13[5]), .y_6(my13[6]), .y_7(my13[7]), .y_8(my13[8]), .y_9(my13[9]), .y_10(my13[10]), .y_11(my13[11]), .y_12(my13[12]), .y_13(my13[13]), .y_14(my13[14]), .y_15(my13[15]),
		  .clk(clk), .dot_out(dot_out[13]));

dot_16 M14(.x_0(mx[0]), .x_1(mx[1]), .x_2(mx[2]), .x_3(mx[3]), .x_4(mx[4]), .x_5(mx[5]), .x_6(mx[6]), .x_7(mx[7]), .x_8(mx[8]), .x_9(mx[9]), .x_10(mx[10]), .x_11(mx[11]), .x_12(mx[12]), .x_13(mx[13]), .x_14(mx[14]), .x_15(mx[15]),
		  .y_0(my14[0]), .y_1(my14[1]), .y_2(my14[2]), .y_3(my14[3]), .y_4(my14[4]), .y_5(my14[5]), .y_6(my14[6]), .y_7(my14[7]), .y_8(my14[8]), .y_9(my14[9]), .y_10(my14[10]), .y_11(my14[11]), .y_12(my14[12]), .y_13(my14[13]), .y_14(my14[14]), .y_15(my14[15]),
		  .clk(clk), .dot_out(dot_out[14]));

dot_16 M15(.x_0(mx[0]), .x_1(mx[1]), .x_2(mx[2]), .x_3(mx[3]), .x_4(mx[4]), .x_5(mx[5]), .x_6(mx[6]), .x_7(mx[7]), .x_8(mx[8]), .x_9(mx[9]), .x_10(mx[10]), .x_11(mx[11]), .x_12(mx[12]), .x_13(mx[13]), .x_14(mx[14]), .x_15(mx[15]),
		  .y_0(my15[0]), .y_1(my15[1]), .y_2(my15[2]), .y_3(my15[3]), .y_4(my15[4]), .y_5(my15[5]), .y_6(my15[6]), .y_7(my15[7]), .y_8(my15[8]), .y_9(my15[9]), .y_10(my15[10]), .y_11(my15[11]), .y_12(my15[12]), .y_13(my15[13]), .y_14(my15[14]), .y_15(my15[15]),
		  .clk(clk), .dot_out(dot_out[15]));
////FSM
always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)  current_state <= IDLE;
    else current_state <= next_state;
end
always @ (*)
begin
	case(current_state)
	IDLE : begin
		next_state = STORE;
	end
	STORE : begin
		if(!in_valid && cnt_in != 0) next_state = WAIT_IN_VALID2;
		else		  				next_state = STORE;
	end
	WAIT_IN_VALID2 : begin
		if(cnt_in2 == 3 && !in_valid2) next_state = TAKE_VALUE;
		else						next_state = WAIT_IN_VALID2;
	end
	TAKE_VALUE : begin
		if(pointer2 == mem_minus_one) next_state = COMPUTE;
		else					next_state = TAKE_VALUE;
	end
	COMPUTE : begin
		if(cnt_cycle == number_of_row - 1 && cnt_compute == 2 ) next_state = COMPUTE2;
		else 									next_state = COMPUTE;
	end
	COMPUTE2 : begin
		if(cnt_cycle2 == number_of_row - 1 && cnt_compute2 == 2 ) next_state = FIND_TRACE;
		else 									next_state = COMPUTE2;
	end
	FIND_TRACE : begin
		if(cnt_round == 9)   next_state = IDLE;
		else  next_state = WAIT_IN_VALID2;
		//next_state = IDLE;
		
	end

	default: next_state = current_state;
	endcase

end
/////////////////////////////////////////////////////

//EAT INPUT
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)	size <= 2'b00;
	else if(in_valid && cnt_in == 0)	size <= matrix_size;
	else		size <= size ;
end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) cnt_in <= 2'b00;
	else if(in_valid) cnt_in <= cnt_in + 1 ;
	else 	cnt_in <= 2'b00; 
end
/////////////////////////////////////////////////////

always@(*)begin
	case(size)
		2'b00: 	mem_words_max <= 9'b0_0000_0100; //4
		2'b01: 	mem_words_max <= 9'b0_0001_0000; // 16
		2'b10: 	mem_words_max <= 9'b0_0100_0000; //64
		2'b11: 	mem_words_max <= 9'b1_0000_0000; //256
		default : mem_words_max <= 9'b0_0000_0000;
	endcase
end
always@(*)begin
	case(size)
		2'b00: 	number_of_row <= 5'b00010; //2
		2'b01: 	number_of_row <= 5'b00100; //4
		2'b10: 	number_of_row <= 5'b01000; //8
		2'b11: 	number_of_row <= 5'b10000; //16
		default : number_of_row <= 5'b00000;
	endcase
end

//MEM_WEN LOW WHEN STORE STATE
assign MEM_wen_X[0 ] = (current_state == STORE) ? ((addr_cnt == 0 ) ? 0 : 1) : 1 ;
assign MEM_wen_X[1 ] = (current_state == STORE) ? ((addr_cnt == 1 ) ? 0 : 1) : 1 ;
assign MEM_wen_X[2 ] = (current_state == STORE) ? ((addr_cnt == 2 ) ? 0 : 1) : 1 ;
assign MEM_wen_X[3 ] = (current_state == STORE) ? ((addr_cnt == 3 ) ? 0 : 1) : 1 ;
assign MEM_wen_X[4 ] = (current_state == STORE) ? ((addr_cnt == 4 ) ? 0 : 1) : 1 ;
assign MEM_wen_X[5 ] = (current_state == STORE) ? ((addr_cnt == 5 ) ? 0 : 1) : 1 ;
assign MEM_wen_X[6 ] = (current_state == STORE) ? ((addr_cnt == 6 ) ? 0 : 1) : 1 ;
assign MEM_wen_X[7 ] = (current_state == STORE) ? ((addr_cnt == 7 ) ? 0 : 1) : 1 ;
assign MEM_wen_X[8 ] = (current_state == STORE) ? ((addr_cnt == 8 ) ? 0 : 1) : 1 ;
assign MEM_wen_X[9 ] = (current_state == STORE) ? ((addr_cnt == 9 ) ? 0 : 1) : 1 ;
assign MEM_wen_X[10] = (current_state == STORE) ? ((addr_cnt == 10) ? 0 : 1) : 1 ;
assign MEM_wen_X[11] = (current_state == STORE) ? ((addr_cnt == 11) ? 0 : 1) : 1 ;
assign MEM_wen_X[12] = (current_state == STORE) ? ((addr_cnt == 12) ? 0 : 1) : 1 ;
assign MEM_wen_X[13] = (current_state == STORE) ? ((addr_cnt == 13) ? 0 : 1) : 1 ;
assign MEM_wen_X[14] = (current_state == STORE) ? ((addr_cnt == 14) ? 0 : 1) : 1 ;
assign MEM_wen_X[15] = (current_state == STORE) ? ((addr_cnt == 15) ? 0 : 1) : 1 ;
assign MEM_wen_X[16] = (current_state == STORE) ? ((addr_cnt == 16) ? 0 : 1) : 1 ;
assign MEM_wen_X[17] = (current_state == STORE) ? ((addr_cnt == 17) ? 0 : 1) : 1 ;
assign MEM_wen_X[18] = (current_state == STORE) ? ((addr_cnt == 18) ? 0 : 1) : 1 ;
assign MEM_wen_X[19] = (current_state == STORE) ? ((addr_cnt == 19) ? 0 : 1) : 1 ;
assign MEM_wen_X[20] = (current_state == STORE) ? ((addr_cnt == 20) ? 0 : 1) : 1 ;
assign MEM_wen_X[21] = (current_state == STORE) ? ((addr_cnt == 21) ? 0 : 1) : 1 ;
assign MEM_wen_X[22] = (current_state == STORE) ? ((addr_cnt == 22) ? 0 : 1) : 1 ;
assign MEM_wen_X[23] = (current_state == STORE) ? ((addr_cnt == 23) ? 0 : 1) : 1 ;
assign MEM_wen_X[24] = (current_state == STORE) ? ((addr_cnt == 24) ? 0 : 1) : 1 ;
assign MEM_wen_X[25] = (current_state == STORE) ? ((addr_cnt == 25) ? 0 : 1) : 1 ;
assign MEM_wen_X[26] = (current_state == STORE) ? ((addr_cnt == 26) ? 0 : 1) : 1 ;
assign MEM_wen_X[27] = (current_state == STORE) ? ((addr_cnt == 27) ? 0 : 1) : 1 ;
assign MEM_wen_X[28] = (current_state == STORE) ? ((addr_cnt == 28) ? 0 : 1) : 1 ;
assign MEM_wen_X[29] = (current_state == STORE) ? ((addr_cnt == 29) ? 0 : 1) : 1 ;
assign MEM_wen_X[30] = (current_state == STORE) ? ((addr_cnt == 30) ? 0 : 1) : 1 ;
assign MEM_wen_X[31] = (current_state == STORE) ? ((addr_cnt == 31) ? 0 : 1) : 1 ;



// always@(*)begin
// 	case(current_state)
// 	STORE : begin
// 		MEM_wen_X[1 ] = 0 ;
// 		MEM_wen_X[2 ] = 0 ;
// 		MEM_wen_X[3 ] = 0 ;
// 		MEM_wen_X[4 ] = 0 ;
// 		MEM_wen_X[5 ] = 0 ;
// 		MEM_wen_X[6 ] = 0 ;
// 		MEM_wen_X[7 ] = 0 ;
// 		MEM_wen_X[8 ] = 0 ;
// 		MEM_wen_X[9 ] = 0 ;
// 		MEM_wen_X[10] = 0 ;
// 		MEM_wen_X[11] = 0 ;
// 		MEM_wen_X[12] = 0 ;
// 		MEM_wen_X[13] = 0 ;
// 		MEM_wen_X[14] = 0 ;
// 		MEM_wen_X[15] = 0 ;
// 		MEM_wen_X[16] = 0 ;
//  		MEM_wen_X[17] = 0 ;
//  		MEM_wen_X[18] = 0 ;
//  		MEM_wen_X[19] = 0 ;
//  		MEM_wen_X[20] = 0 ;
//  		MEM_wen_X[21] = 0 ;
//  		MEM_wen_X[22] = 0 ;
//  		MEM_wen_X[23] = 0 ;
//  		MEM_wen_X[24] = 0 ;
//  		MEM_wen_X[25] = 0 ;
//  		MEM_wen_X[26] = 0 ;
//  		MEM_wen_X[27] = 0 ;
//  		MEM_wen_X[28] = 0 ;
//  		MEM_wen_X[29] = 0 ;
//  		MEM_wen_X[30] = 0 ;
//  		MEM_wen_X[31] = 0 ;
// 	end
// 	default : begin
// 		MEM_wen_X[1 ] = 1 ;
// 		MEM_wen_X[2 ] = 1 ;
// 		MEM_wen_X[3 ] = 1 ;
// 		MEM_wen_X[4 ] = 1 ;
// 		MEM_wen_X[5 ] = 1 ;
// 		MEM_wen_X[6 ] = 1 ;
// 		MEM_wen_X[7 ] = 1 ;
// 		MEM_wen_X[8 ] = 1 ;
// 		MEM_wen_X[9 ] = 1 ;
// 		MEM_wen_X[10] = 1 ;
// 		MEM_wen_X[11] = 1 ;
// 		MEM_wen_X[12] = 1 ;
// 		MEM_wen_X[13] = 1 ;
// 		MEM_wen_X[14] = 1 ;
// 		MEM_wen_X[15] = 1 ;
// 		MEM_wen_X[16] = 1 ;
// 		MEM_wen_X[17] = 1 ;
// 		MEM_wen_X[18] = 1 ;
// 		MEM_wen_X[19] = 1 ;
// 		MEM_wen_X[20] = 1 ;
// 		MEM_wen_X[21] = 1 ;
// 		MEM_wen_X[22] = 1 ;
// 		MEM_wen_X[23] = 1 ;
// 		MEM_wen_X[24] = 1 ;
// 		MEM_wen_X[25] = 1 ;
// 		MEM_wen_X[26] = 1 ;
// 		MEM_wen_X[27] = 1 ;
// 		MEM_wen_X[28] = 1 ;
// 		MEM_wen_X[29] = 1 ;
// 		MEM_wen_X[30] = 1 ;
// 		MEM_wen_X[31] = 1 ;
// 	end
// 	endcase
//end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)			matrix_temp <= 8'b0000_0000;
	else if(in_valid) 	matrix_temp <= matrix;
	else 				matrix_temp <= matrix_temp;
end
/////////////////////////////////////////////////////

//POINTER && ADDR_CNT

always@(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		pointer <= 6'b000000;
	end
	else begin
		case(current_state)
		IDLE : pointer <= 6'b000000;
		STORE : begin
			if(in_valid && cnt_in != 0)begin
				if(pointer == mem_minus_one) begin
					pointer <= 6'b000000;
				end	
				else begin
					pointer <= pointer + 1 ;
				end
			end
		end
		TAKE_VALUE : begin
			if(pointer == mem_minus_one) begin
					pointer <= 6'b000000;
				end	
			else begin
				pointer <= pointer + 1 ;
			end
			
		end


		default:	pointer <= 6'b000000;
		endcase
	end
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		addr_cnt <= 6'b000000;
	end
	else begin
		case(current_state)
		IDLE : addr_cnt <= 6'b000000;
		STORE : begin
				if(pointer == mem_minus_one) begin
					addr_cnt <= addr_cnt + 1;
				end	
		end
		WAIT_IN_VALID2 : addr_cnt <= 6'b000000;
		

		default:;
		endcase
	end
end
/////////////////////////////////////////////////////

//MEM_IN && MEM_ADDR
always@(*) begin
	case(current_state)
	STORE : begin
		for(m = 0; m < 32; m = m + 1) begin
			if(m == addr_cnt )   MEM_adr_X[m] = pointer ;
			else				 MEM_adr_X[m] = 0 ;
		end
	end
	TAKE_VALUE : begin
		for(n = 0; n < 32 ; n=n+1)begin
			if(n == idx_a[0] || n == idx_a[1] || n == idx_a[2]) begin
				MEM_adr_X[n] = pointer;
				
			end
			else begin
				MEM_adr_X[n] = 0 ;
			end
		end

	end
	default : begin
		MEM_adr_X[0 ] = 0 ;
		MEM_adr_X[1 ] = 0 ;
		MEM_adr_X[2 ] = 0 ;
		MEM_adr_X[3 ] = 0 ;
		MEM_adr_X[4 ] = 0 ;
		MEM_adr_X[5 ] = 0 ;
		MEM_adr_X[6 ] = 0 ;
		MEM_adr_X[7 ] = 0 ;
		MEM_adr_X[8 ] = 0 ;
		MEM_adr_X[9 ] = 0 ;
		MEM_adr_X[10] = 0 ;
		MEM_adr_X[11] = 0 ;
		MEM_adr_X[12] = 0 ;
		MEM_adr_X[13] = 0 ;
		MEM_adr_X[14] = 0 ;
		MEM_adr_X[15] = 0 ;
		MEM_adr_X[16] = 0 ;
		MEM_adr_X[17] = 0 ;
		MEM_adr_X[18] = 0 ;
		MEM_adr_X[19] = 0 ;
		MEM_adr_X[20] = 0 ;
		MEM_adr_X[21] = 0 ;
		MEM_adr_X[22] = 0 ;
		MEM_adr_X[23] = 0 ;
		MEM_adr_X[24] = 0 ;
		MEM_adr_X[25] = 0 ;
		MEM_adr_X[26] = 0 ;
		MEM_adr_X[27] = 0 ;
		MEM_adr_X[28] = 0 ;
		MEM_adr_X[29] = 0 ;
		MEM_adr_X[30] = 0 ;
		MEM_adr_X[31] = 0 ;
	end

	endcase
end

always@(*) begin
	case(current_state)
	STORE : begin
		for(m = 0; m < 32; m = m + 1) begin
			if(m == addr_cnt)   MEM_in_X[m] = matrix_temp ;
			else				MEM_in_X[m] = 0 ;
		end
		//MEM_in_X[addr_cnt] = matrix_temp ;
	end
	default : begin
		MEM_in_X[0 ] = 0 ;
		MEM_in_X[1 ] = 0 ;
		MEM_in_X[2 ] = 0 ;
		MEM_in_X[3 ] = 0 ;
		MEM_in_X[4 ] = 0 ;
		MEM_in_X[5 ] = 0 ;
		MEM_in_X[6 ] = 0 ;
		MEM_in_X[7 ] = 0 ;
		MEM_in_X[8 ] = 0 ;
		MEM_in_X[9 ] = 0 ;
		MEM_in_X[10] = 0 ;
		MEM_in_X[11] = 0 ;
		MEM_in_X[12] = 0 ;
		MEM_in_X[13] = 0 ;
		MEM_in_X[14] = 0 ;
		MEM_in_X[15] = 0 ;
		MEM_in_X[16] = 0 ;
		MEM_in_X[17] = 0 ;
		MEM_in_X[18] = 0 ;
		MEM_in_X[19] = 0 ;
		MEM_in_X[20] = 0 ;
		MEM_in_X[21] = 0 ;
		MEM_in_X[22] = 0 ;
		MEM_in_X[23] = 0 ;
		MEM_in_X[24] = 0 ;
		MEM_in_X[25] = 0 ;
		MEM_in_X[26] = 0 ;
		MEM_in_X[27] = 0 ;
		MEM_in_X[28] = 0 ;
		MEM_in_X[29] = 0 ;
		MEM_in_X[30] = 0 ;
		MEM_in_X[31] = 0 ;
	end

	endcase
end
/////////////////////////////////////////////////////


//WAIT_IN_VALID2 && EAT INPUT2
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)		cnt_in2 <= 0;
	else begin
		case(current_state)
		IDLE : begin
			cnt_in2 <= 0;
		end
		WAIT_IN_VALID2 : begin
			if(in_valid2) begin
				cnt_in2 <= cnt_in2 + 1 ;
			end
		end
		default:cnt_in2 <= 0;
		endcase
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)	begin
			idx_a[0] <= 0;
			idx_a[1] <= 0;
			idx_a[2] <= 0;
	end
	else begin
		case(current_state)
		IDLE : begin
			idx_a[0] <= 0;
			idx_a[1] <= 0;
			idx_a[2] <= 0;
		end
		WAIT_IN_VALID2 : begin
			if(in_valid2) begin
				idx_a[cnt_in2] <= matrix_idx; 
			end
			else begin
				idx_a[0] <= idx_a[0];
				idx_a[1] <= idx_a[1];
				idx_a[2] <= idx_a[2];
			end
		end

		default:;
		endcase
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)	begin
			mode_a <= 2'b00;
	end
	else begin
		case(current_state)
		IDLE : begin
			mode_a <= 2'b00;
		end
		WAIT_IN_VALID2 : begin
			if(in_valid2 && cnt_in2 == 0) begin
				mode_a <= mode; 
			end
			else begin
				mode_a <= mode_a;
			end
		end

		default:;
		endcase
	end
end
/////////////////////////////////////////////////////


//TAKE_VALUE
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) begin
		pointer2 <= 0;
	end
	else begin
		case(current_state)
		IDLE : pointer2 <= 0;
		TAKE_VALUE : pointer2 <= pointer;
		default: pointer2 <= 0;
		endcase
	end
end
//MATRIX_A
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) begin
		for(i = 0; i < 16; i=i+1)begin
			for(j=0; j < 16; j=j+1)begin
				matrix_A[i][j] <= 0;
			end
		end
	end
	else begin
		case(current_state)
		IDLE : begin
			for(i = 0; i < 16; i=i+1)begin
				for(j=0; j < 16; j=j+1)begin
					matrix_A[i][j] <= 0;
				end
			end
		end
		TAKE_VALUE : begin
			if(mode_a == 2'b01) matrix_A[column][row] <= MEM_out_X[idx_a[0]];
			else 				matrix_A[row][column] <= MEM_out_X[idx_a[0]];
		end
		default:;
		endcase
	end
end

//MATRIX_B
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) begin
		for(i = 0; i < 16; i=i+1)begin
			for(j=0; j < 16; j=j+1)begin
				matrix_B[i][j] <= 0;
			end
		end
	end
	else begin
		case(current_state)
		IDLE : begin
			for(i = 0; i < 16; i=i+1)begin
				for(j=0; j < 16; j=j+1)begin
					matrix_B[i][j] <= 0;
				end
			end
		end
		TAKE_VALUE : begin
			if(mode_a == 2'b10)	matrix_B[column][row] <= MEM_out_X[idx_a[1]];
			else				matrix_B[row][column] <= MEM_out_X[idx_a[1]];
		end
		default:;
		endcase
	end
end
//MATRIX_C
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) begin
		for(i = 0; i < 16; i=i+1)begin
			for(j=0; j < 16; j=j+1)begin
				matrix_C[i][j] <= 0;
			end
		end
	end
	else begin
		case(current_state)
		IDLE : begin
			for(i = 0; i < 16; i=i+1)begin
				for(j=0; j < 16; j=j+1)begin
					matrix_C[i][j] <= 0;
				end
			end
		end
		TAKE_VALUE : begin
			if(mode_a == 2'b11)	matrix_C[column][row] <= MEM_out_X[idx_a[2]];
			else				matrix_C[row][column] <= MEM_out_X[idx_a[2]];
		end
		default:;
		endcase
	end
end
/////////////////////////////////////////////////////

//COMPUTE
genvar s;
generate
	for(s=0; s<16; s=s+1)begin
		always@(*)begin
			case(current_state)
				COMPUTE : begin

						my0 [s] = matrix_B[s][0 ];
						my1 [s] = matrix_B[s][1 ];
						my2 [s] = matrix_B[s][2 ];
						my3 [s] = matrix_B[s][3 ];
						my4 [s] = matrix_B[s][4 ];
						my5 [s] = matrix_B[s][5 ];
						my6 [s] = matrix_B[s][6 ];
						my7 [s] = matrix_B[s][7 ];
						my8 [s] = matrix_B[s][8 ];
						my9 [s] = matrix_B[s][9 ];
						my10[s] = matrix_B[s][10];
						my11[s] = matrix_B[s][11];
						my12[s] = matrix_B[s][12];
						my13[s] = matrix_B[s][13];
						my14[s] = matrix_B[s][14];
						my15[s] = matrix_B[s][15];
				end
				COMPUTE2: begin
						my0 [s] = matrix_C[s][0 ];
						my1 [s] = matrix_C[s][1 ];
						my2 [s] = matrix_C[s][2 ];
						my3 [s] = matrix_C[s][3 ];
						my4 [s] = matrix_C[s][4 ];
						my5 [s] = matrix_C[s][5 ];
						my6 [s] = matrix_C[s][6 ];
						my7 [s] = matrix_C[s][7 ];
						my8 [s] = matrix_C[s][8 ];
						my9 [s] = matrix_C[s][9 ];
						my10[s] = matrix_C[s][10];
						my11[s] = matrix_C[s][11];
						my12[s] = matrix_C[s][12];
						my13[s] = matrix_C[s][13];
						my14[s] = matrix_C[s][14];
						my15[s] = matrix_C[s][15];
				end

				default: begin
						my0 [s] = 0 ;
						my1 [s] = 0 ;
						my2 [s] = 0 ;
						my3 [s] = 0 ;
						my4 [s] = 0 ;
						my5 [s] = 0 ;
						my6 [s] = 0 ;
						my7 [s] = 0 ;
						my8 [s] = 0 ;
						my9 [s] = 0 ;
						my10[s] = 0 ;
						my11[s] = 0 ;
						my12[s] = 0 ;
						my13[s] = 0 ;
						my14[s] = 0 ;
						my15[s] = 0 ;
				end
			endcase
		end
	end
endgenerate
// always@(*)begin
// 	case(current_state)
// 	COMPUTE : begin
// 		for(k=0 ; k<16 ; k=k+1) begin
// 			my0 [k] = matrix_B[k][0 ];
// 			my1 [k] = matrix_B[k][1 ];
// 			my2 [k] = matrix_B[k][2 ];
// 			my3 [k] = matrix_B[k][3 ];
// 			my4 [k] = matrix_B[k][4 ];
// 			my5 [k] = matrix_B[k][5 ];
// 			my6 [k] = matrix_B[k][6 ];
// 			my7 [k] = matrix_B[k][7 ];
// 			my8 [k] = matrix_B[k][8 ];
// 			my9 [k] = matrix_B[k][9 ];
// 			my10[k] = matrix_B[k][10];
// 			my11[k] = matrix_B[k][11];
// 			my12[k] = matrix_B[k][12];
// 			my13[k] = matrix_B[k][13];
// 			my14[k] = matrix_B[k][14];
// 			my15[k] = matrix_B[k][15];
// 		end
// 	end
// 	COMPUTE2:
// 	for(k=0 ; k<16 ; k=k+1) begin
// 			my0 [k] = matrix_C[k][0 ];
// 			my1 [k] = matrix_C[k][1 ];
// 			my2 [k] = matrix_C[k][2 ];
// 			my3 [k] = matrix_C[k][3 ];
// 			my4 [k] = matrix_C[k][4 ];
// 			my5 [k] = matrix_C[k][5 ];
// 			my6 [k] = matrix_C[k][6 ];
// 			my7 [k] = matrix_C[k][7 ];
// 			my8 [k] = matrix_C[k][8 ];
// 			my9 [k] = matrix_C[k][9 ];
// 			my10[k] = matrix_C[k][10];
// 			my11[k] = matrix_C[k][11];
// 			my12[k] = matrix_C[k][12];
// 			my13[k] = matrix_C[k][13];
// 			my14[k] = matrix_C[k][14];
// 			my15[k] = matrix_C[k][15];
// 		end

// 	default: begin
// 		for(k=0 ; k<16 ; k=k+1) begin
// 			my0 [k] = 0 ;
// 			my1 [k] = 0 ;
// 			my2 [k] = 0 ;
// 			my3 [k] = 0 ;
// 			my4 [k] = 0 ;
// 			my5 [k] = 0 ;
// 			my6 [k] = 0 ;
// 			my7 [k] = 0 ;
// 			my8 [k] = 0 ;
// 			my9 [k] = 0 ;
// 			my10[k] = 0 ;
// 			my11[k] = 0 ;
// 			my12[k] = 0 ;
// 			my13[k] = 0 ;
// 			my14[k] = 0 ;
// 			my15[k] = 0 ;
// 		end
// 	end
// 	endcase
// end

genvar  p;
generate
	for(p=0;p < 16; p=p+1)begin
		always@(*)begin
			case(current_state)
			COMPUTE : begin
				mx[p] = matrix_A[cnt_cycle][p];
			end
			COMPUTE2 : begin
				mx[p] = matrix_temp1[cnt_cycle2][p];
			end

			default: begin
				mx[p] = 0;
			end

			endcase
		end
	end
endgenerate

// always@(*)begin
// 	case(current_state)
// 	COMPUTE : begin
// 		for(l=0 ; l < 16; l=l+1)begin
// 			mx[l] = matrix_A[cnt_cycle][l];
// 		end
// 	end
// 	COMPUTE2 : begin
// 		for(l=0 ; l < 16; l=l+1)begin
// 			mx[l] = matrix_temp1[cnt_cycle2][l];
// 		end
// 	end

// 	default: begin
// 		for(l=0 ; l < 16; l=l+1)begin
// 			mx[l] = 0;
// 		end
// 	end
// 	endcase
// end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n) begin
		cnt_compute <= 0;
	end
	else begin
		case(current_state)
			IDLE : cnt_compute <= 0 ;

			COMPUTE : if(cnt_compute == 2) cnt_compute <= 0;
					  else                 cnt_compute <= cnt_compute + 1;
			default:;
		endcase
	end
end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) begin
		cnt_cycle <= 0;
	end
	else begin
		case(current_state)
			IDLE : cnt_cycle <= 0 ;

			COMPUTE : if(cnt_compute == 2) cnt_cycle <= cnt_cycle + 1;
					  else                 cnt_cycle <= cnt_cycle;
			default: cnt_cycle <= 0 ;
		endcase
	end
end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		for(i = 0; i < 16; i=i+1)begin
			for(j=0; j < 16; j=j+1)begin
				matrix_temp1[i][j] <= 0;
			end
		end
	end
	else begin
		case(current_state)
		IDLE : begin
			for(i = 0; i < 16; i=i+1)begin
				for(j=0; j < 16; j=j+1)begin
					matrix_temp1[i][j] <= 0;
				end
			end
		end
		COMPUTE : begin
			if(cnt_compute == 2)begin
				matrix_temp1[cnt_cycle][0 ] <= dot_out[0 ];
				matrix_temp1[cnt_cycle][1 ] <= dot_out[1 ];
				matrix_temp1[cnt_cycle][2 ] <= dot_out[2 ];
				matrix_temp1[cnt_cycle][3 ] <= dot_out[3 ];
				matrix_temp1[cnt_cycle][4 ] <= dot_out[4 ];
				matrix_temp1[cnt_cycle][5 ] <= dot_out[5 ];
				matrix_temp1[cnt_cycle][6 ] <= dot_out[6 ];
				matrix_temp1[cnt_cycle][7 ] <= dot_out[7 ];
				matrix_temp1[cnt_cycle][8 ] <= dot_out[8 ];
				matrix_temp1[cnt_cycle][9 ] <= dot_out[9 ];
				matrix_temp1[cnt_cycle][10] <= dot_out[10];
				matrix_temp1[cnt_cycle][11] <= dot_out[11];
				matrix_temp1[cnt_cycle][12] <= dot_out[12];
				matrix_temp1[cnt_cycle][13] <= dot_out[13];
				matrix_temp1[cnt_cycle][14] <= dot_out[14];
				matrix_temp1[cnt_cycle][15] <= dot_out[15];
			end
		end
		default:;
		endcase
	end

end
/////////////////////////////////////////////////////

//COMPUTE2
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) begin
		cnt_compute2 <= 0;
	end
	else begin
		case(current_state)
			IDLE : cnt_compute2 <= 0 ;

			COMPUTE2 : if(cnt_compute2 == 2) cnt_compute2 <= 0;
					  else                 cnt_compute2 <= cnt_compute2 + 1;
			default:;
		endcase
	end
end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) begin
		cnt_cycle2 <= 0;
	end
	else begin
		case(current_state)
			IDLE : cnt_cycle2 <= 0 ;

			COMPUTE2 : if(cnt_compute2 == 2) cnt_cycle2 <= cnt_cycle2 + 1;
					   else                 cnt_cycle2 <= cnt_cycle2;
			default: cnt_cycle2 <= 0;
		endcase
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		for(i = 0; i < 16; i=i+1)begin
			for(j=0; j < 16; j=j+1)begin
				matrix_temp2[i][j] <= 0;
			end
		end
	end
	else begin
		case(current_state)
		IDLE : begin
			for(i = 0; i < 16; i=i+1)begin
				for(j=0; j < 16; j=j+1)begin
					matrix_temp2[i][j] <= 0;
				end
			end
		end
		COMPUTE2 : begin
			if(cnt_compute2 == 2)begin
				matrix_temp2[cnt_cycle2][0 ] <= dot_out[0 ];
				matrix_temp2[cnt_cycle2][1 ] <= dot_out[1 ];
				matrix_temp2[cnt_cycle2][2 ] <= dot_out[2 ];
				matrix_temp2[cnt_cycle2][3 ] <= dot_out[3 ];
				matrix_temp2[cnt_cycle2][4 ] <= dot_out[4 ];
				matrix_temp2[cnt_cycle2][5 ] <= dot_out[5 ];
				matrix_temp2[cnt_cycle2][6 ] <= dot_out[6 ];
				matrix_temp2[cnt_cycle2][7 ] <= dot_out[7 ];
				matrix_temp2[cnt_cycle2][8 ] <= dot_out[8 ];
				matrix_temp2[cnt_cycle2][9 ] <= dot_out[9 ];
				matrix_temp2[cnt_cycle2][10] <= dot_out[10];
				matrix_temp2[cnt_cycle2][11] <= dot_out[11];
				matrix_temp2[cnt_cycle2][12] <= dot_out[12];
				matrix_temp2[cnt_cycle2][13] <= dot_out[13];
				matrix_temp2[cnt_cycle2][14] <= dot_out[14];
				matrix_temp2[cnt_cycle2][15] <= dot_out[15];
			end
		end
		default:;
		endcase
	end
end
/////////////////////////////////////////////////////

//FIND_THE_TRACE
assign out1 = matrix_temp2[0][0]+ matrix_temp2[1][1]+ matrix_temp2[2][2]+ matrix_temp2[3][3]+ matrix_temp2[4][4]+ matrix_temp2[5][5]+ matrix_temp2[6][6]+ matrix_temp2[7][7];
assign out2 = matrix_temp2[8][8]+ matrix_temp2[9][9]+ matrix_temp2[10][10]+ matrix_temp2[11][11]+ matrix_temp2[12][12]+ matrix_temp2[13][13]+ matrix_temp2[14][14]+ matrix_temp2[15][15];
assign out =  out1 + out2;

always@(posedge clk or negedge rst_n) begin
	if(!rst_n)	cnt_round <= 0;
	else begin
		case(current_state)
			IDLE: cnt_round <= 0;
			FIND_TRACE : cnt_round <= cnt_round + 1 ;
		default:;
		endcase
	end
end

//TEST_OUTPUT
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) begin
		out_valid <= 0 ;
		out_value <= 0 ;
	end
	else begin
		case(current_state)
		FIND_TRACE : begin
			out_valid <= 1 ;
			out_value <= out ;
		end 
		default : begin
			out_valid <= 0 ;
			out_value <= 0 ;
		end
		endcase
	end
end

endmodule

module dot_16 (x_0,x_1,x_2,x_3,x_4,x_5,x_6,x_7,x_8,x_9,x_10,x_11,x_12,x_13,x_14,x_15,
			   y_0,y_1,y_2,y_3,y_4,y_5,y_6,y_7,y_8,y_9,y_10,y_11,y_12,y_13,y_14,y_15,
			   clk, dot_out);

input clk;
input signed  [20:0] x_0,x_1,x_2,x_3,x_4,x_5,x_6,x_7,x_8,x_9,x_10,x_11,x_12,x_13,x_14,x_15;
input signed  [20:0] y_0,y_1,y_2,y_3,y_4,y_5,y_6,y_7,y_8,y_9,y_10,y_11,y_12,y_13,y_14,y_15;
output        [40:0] dot_out;

reg signed [20:0]xt_0,xt_1,xt_2,xt_3,xt_4,xt_5,xt_6,xt_7,xt_8,xt_9,xt_10,xt_11,xt_12,xt_13,xt_14,xt_15;
reg signed [20:0]yt_0,yt_1,yt_2,yt_3,yt_4,yt_5,yt_6,yt_7,yt_8,yt_9,yt_10,yt_11,yt_12,yt_13,yt_14,yt_15;
wire signed [32:0] x_w_0, x_w_1, x_w_2, x_w_3, x_w_4, x_w_5, x_w_6, x_w_7;                             
wire signed [32:0] x_w_8, x_w_9, x_w_10, x_w_11, x_w_12, x_w_13, x_w_14,x_w_15;
//PIPELINE
reg	 signed [40:0] x_w_a0, x_w_a1, x_w_a2, x_w_a3, x_w_a4, x_w_a5, x_w_a6, x_w_a7,     
				   x_w_a8, x_w_a9, x_w_a10, x_w_a11, x_w_a12, x_w_a13, x_w_a14, x_w_a15;	
always@(posedge clk)begin
    	xt_0   <= x_0 ;
		xt_1   <= x_1 ;
		xt_2   <= x_2 ;
		xt_3   <= x_3 ;
		xt_4   <= x_4 ;
		xt_5   <= x_5 ;
		xt_6   <= x_6 ;
		xt_7   <= x_7 ;
		xt_8   <= x_8 ;
		xt_9   <= x_9 ;
		xt_10  <= x_10;
		xt_11  <= x_11;
		xt_12  <= x_12;
		xt_13  <= x_13;
		xt_14  <= x_14;
		xt_15  <= x_15;
end
always@(posedge clk)begin
    	yt_0   <= y_0 ;
		yt_1   <= y_1 ;
		yt_2   <= y_2 ;
		yt_3   <= y_3 ;
		yt_4   <= y_4 ;
		yt_5   <= y_5 ;
		yt_6   <= y_6 ;
		yt_7   <= y_7 ;
		yt_8   <= y_8 ;
		yt_9   <= y_9 ;
		yt_10  <= y_10;
		yt_11  <= y_11;
		yt_12  <= y_12;
		yt_13  <= y_13;
		yt_14  <= y_14;
		yt_15  <= y_15;
end

//Multiple
assign x_w_0  = xt_0  * yt_0  ;
assign x_w_1  = xt_1  * yt_1  ;
assign x_w_2  = xt_2  * yt_2  ;
assign x_w_3  = xt_3  * yt_3  ;
assign x_w_4  = xt_4  * yt_4  ;
assign x_w_5  = xt_5  * yt_5  ;
assign x_w_6  = xt_6  * yt_6  ;
assign x_w_7  = xt_7  * yt_7  ;
assign x_w_8  = xt_8  * yt_8  ;
assign x_w_9  = xt_9  * yt_9  ;
assign x_w_10 = xt_10 * yt_10 ;
assign x_w_11 = xt_11 * yt_11 ;
assign x_w_12 = xt_12 * yt_12 ;
assign x_w_13 = xt_13 * yt_13 ;
assign x_w_14 = xt_14 * yt_14 ;
assign x_w_15 = xt_15 * yt_15 ;

always @(posedge clk)
begin
	x_w_a0      <=   x_w_0  ;
	x_w_a1      <=   x_w_1  ;
	x_w_a2      <=   x_w_2  ;
	x_w_a3      <=   x_w_3  ;
	x_w_a4      <=   x_w_4  ;
	x_w_a5      <=   x_w_5  ;
	x_w_a6      <=   x_w_6  ;
	x_w_a7      <=   x_w_7  ;
	x_w_a8      <=   x_w_8  ;
	x_w_a9      <=   x_w_9  ;
	x_w_a10     <=   x_w_10 ;
	x_w_a11     <=   x_w_11 ;
	x_w_a12     <=   x_w_12 ;
	x_w_a13     <=   x_w_13 ;
	x_w_a14 	<=   x_w_14 ;   
	x_w_a15 	<=   x_w_15 ;	   
				   				   
end	

assign dot_out = x_w_a0 + x_w_a1 + x_w_a2 + x_w_a3 + x_w_a4 + x_w_a5 + x_w_a6 + x_w_a7 + x_w_a8 + x_w_a9 + x_w_a10 + x_w_a11 + x_w_a12 + x_w_a13 + x_w_a14 + x_w_a15 ; 


endmodule
