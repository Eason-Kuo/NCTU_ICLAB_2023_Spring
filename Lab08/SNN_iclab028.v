// synopsys translate_off
`ifdef RTL
	`include "GATED_OR.v"
`else
	`include "Netlist/GATED_OR_SYN.v"
`endif
// synopsys translate_on

module SNN(
	// Input signals
	clk,
	rst_n,
	cg_en,
	in_valid,
	img,
	ker,
	weight,

	// Output signals
	out_valid,
	out_data
);

input clk;
input rst_n;
input in_valid;
input cg_en;
input [7:0] img;
input [7:0] ker;
input [7:0] weight;

output reg out_valid;
output reg [9:0] out_data;

//==============================================//
//       parameter & integer declaration        //
//==============================================//
integer i,j,k,l;
integer m,n,o,p;
integer a,b,c,d;
parameter IDLE    = 4'd0;
parameter COMPUTE = 4'd1; 
//==============================================//
//           reg & wire declaration             //
//==============================================//
reg		[4:0]current_state,next_state;
reg 	[7:0]img1_reg[0:5][0:5], img2_reg[0:5][0:5];
reg 	[7:0]ker_reg[0:2][0:2];
reg 	[7:0]weight_reg[0:1][0:1];
reg		[7:0]cnt_in, cnt_col, cnt_row;
wire	[20:0]conv_image1[0:15];
wire	[20:0]conv_image2[0:15];
reg		[20:0]feature_map1[0:3][0:3];
reg		[20:0]feature_map2[0:3][0:3];

reg		[20:0]quantization_map1[0:3][0:3];
reg		[20:0]quantization_map2[0:3][0:3];

wire	[10:0]red1[0:2];
wire	[10:0]yellow1[0:2];
wire	[10:0]blue1[0:2];
wire	[10:0]green1[0:2];

wire 	[10:0]red2[0:2];
wire 	[10:0]yellow2[0:2];
wire 	[10:0]blue2[0:2];
wire 	[10:0]green2[0:2];

wire	[10:0]max_pooling1[0:1][0:1];
wire 	[10:0]max_pooling2[0:1][0:1];

wire	[18:0]fully_connected1[0:1][0:1];
wire	[18:0]fully_connected2[0:1][0:1];
reg		[18:0]flatten1[0:3];
reg		[18:0]flatten2[0:3];
wire	[18:0]flatten1_quant[0:3];
wire	[18:0]flatten2_quant[0:3];
reg		[18:0]flatten1_quant_reg[0:3];
reg		[18:0]flatten2_quant_reg[0:3];

wire 	[15:0]L1_distance[0:3] ;
wire 	[15:0]L1_distance_sum  ;
reg		[9:0]L1_distance_reg  ;
wire	[9:0]activation_function;
reg		[5:0]cnt_latency ;

wire 	invalid_sleep ;
wire 	outvalid_sleep ;
wire	gclk_invalid, gclk_outvalid ;
//==============================================//
//                  DESIGN                      //
//==============================================//

assign invalid_sleep  =  cg_en && (!(current_state == IDLE));
assign outvalid_sleep =  cg_en && (!(current_state == COMPUTE));

GATED_OR GATED_INVALID( .CLOCK(clk) , .SLEEP_CTRL(invalid_sleep) , .RST_N(rst_n) , .CLOCK_GATED(gclk_invalid) );
GATED_OR GATED_OUTVALID( .CLOCK(clk) , .SLEEP_CTRL(outvalid_sleep) , .RST_N(rst_n) , .CLOCK_GATED(gclk_outvalid) );

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)		current_state <= IDLE ;
	else 			current_state <= next_state ;
end
always@(*)begin
	case(current_state)
		IDLE : begin
			if(!in_valid && cnt_in != 0)  next_state = COMPUTE;
			else						 next_state = IDLE;
		end
		COMPUTE : begin
			if(cnt_latency == 7)		 next_state = IDLE;
			else						 next_state = COMPUTE;
		end
		default : next_state = current_state ;
	endcase
end

//EAT INPUT
always@(posedge gclk_invalid or negedge rst_n)begin
	if(!rst_n) begin
		    img1_reg[0][0] <= 0 ;
			img1_reg[0][1] <= 0 ;
			img1_reg[0][2] <= 0 ;
			img1_reg[0][3] <= 0 ;
			img1_reg[0][4] <= 0 ;
			img1_reg[0][5] <= 0 ;

			img1_reg[1][0] <= 0 ;
			img1_reg[1][1] <= 0 ;
			img1_reg[1][2] <= 0 ;
			img1_reg[1][3] <= 0 ;
			img1_reg[1][4] <= 0 ;
			img1_reg[1][5] <= 0 ;

			img1_reg[2][0] <= 0 ;
			img1_reg[2][1] <= 0 ;
			img1_reg[2][2] <= 0 ;
			img1_reg[2][3] <= 0 ;
			img1_reg[2][4] <= 0 ;
			img1_reg[2][5] <= 0 ;
			
			img1_reg[3][0] <= 0 ;
			img1_reg[3][1] <= 0 ;
			img1_reg[3][2] <= 0 ;
			img1_reg[3][3] <= 0 ;
			img1_reg[3][4] <= 0 ;
			img1_reg[3][5] <= 0 ;
			
			img1_reg[4][0] <= 0 ;
			img1_reg[4][1] <= 0 ;
			img1_reg[4][2] <= 0 ;
			img1_reg[4][3] <= 0 ;
			img1_reg[4][4] <= 0 ;
			img1_reg[4][5] <= 0 ;
			
			img1_reg[5][0] <= 0 ;
			img1_reg[5][1] <= 0 ;
			img1_reg[5][2] <= 0 ;
			img1_reg[5][3] <= 0 ;
			img1_reg[5][4] <= 0 ;
			img1_reg[5][5] <= 0 ;
	end
	else if(in_valid && cnt_in < 36 && current_state == IDLE) begin
		case(cnt_in)
			'd0 : img1_reg[0][0] <= img ;
			'd1 : img1_reg[0][1] <= img ;
			'd2 : img1_reg[0][2] <= img ;
			'd3 : img1_reg[0][3] <= img ;
			'd4 : img1_reg[0][4] <= img ;
			'd5 : img1_reg[0][5] <= img ;

			'd6 : img1_reg[1][0] <= img ;
			'd7 : img1_reg[1][1] <= img ;
			'd8 : img1_reg[1][2] <= img ;
			'd9 : img1_reg[1][3] <= img ;
			'd10 : img1_reg[1][4] <= img ;
			'd11 : img1_reg[1][5] <= img ;

			'd12 : img1_reg[2][0] <= img ;
			'd13 : img1_reg[2][1] <= img ;
			'd14 : img1_reg[2][2] <= img ;
			'd15 : img1_reg[2][3] <= img ;
			'd16 : img1_reg[2][4] <= img ;
			'd17 : img1_reg[2][5] <= img ;

			'd18 : img1_reg[3][0] <= img ;
			'd19 : img1_reg[3][1] <= img ;
			'd20 : img1_reg[3][2] <= img ;
			'd21 : img1_reg[3][3] <= img ;
			'd22 : img1_reg[3][4] <= img ;
			'd23 : img1_reg[3][5] <= img ;

			'd24 : img1_reg[4][0] <= img ;
			'd25 : img1_reg[4][1] <= img ;
			'd26 : img1_reg[4][2] <= img ;
			'd27 : img1_reg[4][3] <= img ;
			'd28 : img1_reg[4][4] <= img ;
			'd29 : img1_reg[4][5] <= img ;

			'd30 : img1_reg[5][0] <= img ;
			'd31 : img1_reg[5][1] <= img ;
			'd32 : img1_reg[5][2] <= img ;
			'd33 : img1_reg[5][3] <= img ;
			'd34 : img1_reg[5][4] <= img ;
			'd35 : img1_reg[5][5] <= img ;


			default:;
		endcase
	end
	else begin
		img1_reg[0][0] <= img1_reg[0][0] ;
		img1_reg[0][1] <= img1_reg[0][1] ;
		img1_reg[0][2] <= img1_reg[0][2] ;
		img1_reg[0][3] <= img1_reg[0][3] ;
		img1_reg[0][4] <= img1_reg[0][4] ;
		img1_reg[0][5] <= img1_reg[0][5] ;
		
		img1_reg[1][0] <= img1_reg[1][0] ;
		img1_reg[1][1] <= img1_reg[1][1] ;
		img1_reg[1][2] <= img1_reg[1][2] ;
		img1_reg[1][3] <= img1_reg[1][3] ;
		img1_reg[1][4] <= img1_reg[1][4] ;
		img1_reg[1][5] <= img1_reg[1][5] ;
		
		img1_reg[2][0] <= img1_reg[2][0] ;
		img1_reg[2][1] <= img1_reg[2][1] ;
		img1_reg[2][2] <= img1_reg[2][2] ;
		img1_reg[2][3] <= img1_reg[2][3] ;
		img1_reg[2][4] <= img1_reg[2][4] ;
		img1_reg[2][5] <= img1_reg[2][5] ;

		img1_reg[3][0] <= img1_reg[3][0] ;
		img1_reg[3][1] <= img1_reg[3][1] ;
		img1_reg[3][2] <= img1_reg[3][2] ;
		img1_reg[3][3] <= img1_reg[3][3] ;
		img1_reg[3][4] <= img1_reg[3][4] ;
		img1_reg[3][5] <= img1_reg[3][5] ;

		img1_reg[4][0] <= img1_reg[4][0] ;
		img1_reg[4][1] <= img1_reg[4][1] ;
		img1_reg[4][2] <= img1_reg[4][2] ;
		img1_reg[4][3] <= img1_reg[4][3] ;
		img1_reg[4][4] <= img1_reg[4][4] ;
		img1_reg[4][5] <= img1_reg[4][5] ;

		img1_reg[5][0] <= img1_reg[5][0] ;
		img1_reg[5][1] <= img1_reg[5][1] ;
		img1_reg[5][2] <= img1_reg[5][2] ;
		img1_reg[5][3] <= img1_reg[5][3] ;
		img1_reg[5][4] <= img1_reg[5][4] ;
		img1_reg[5][5] <= img1_reg[5][5] ;
	
	end	
end

always@(posedge gclk_invalid or negedge rst_n)begin
	if(!rst_n) begin
		    img2_reg[0][0] <= 0 ;
			img2_reg[0][1] <= 0 ;
			img2_reg[0][2] <= 0 ;
			img2_reg[0][3] <= 0 ;
			img2_reg[0][4] <= 0 ;
			img2_reg[0][5] <= 0 ;

			img2_reg[1][0] <= 0 ;
			img2_reg[1][1] <= 0 ;
			img2_reg[1][2] <= 0 ;
			img2_reg[1][3] <= 0 ;
			img2_reg[1][4] <= 0 ;
			img2_reg[1][5] <= 0 ;

			img2_reg[2][0] <= 0 ;
			img2_reg[2][1] <= 0 ;
			img2_reg[2][2] <= 0 ;
			img2_reg[2][3] <= 0 ;
			img2_reg[2][4] <= 0 ;
			img2_reg[2][5] <= 0 ;
			
			img2_reg[3][0] <= 0 ;
			img2_reg[3][1] <= 0 ;
			img2_reg[3][2] <= 0 ;
			img2_reg[3][3] <= 0 ;
			img2_reg[3][4] <= 0 ;
			img2_reg[3][5] <= 0 ;
		
			img2_reg[4][0] <= 0 ;
			img2_reg[4][1] <= 0 ;
			img2_reg[4][2] <= 0 ;
			img2_reg[4][3] <= 0 ;
			img2_reg[4][4] <= 0 ;
			img2_reg[4][5] <= 0 ;
			
			img2_reg[5][0] <= 0 ;
			img2_reg[5][1] <= 0 ;
			img2_reg[5][2] <= 0 ;
			img2_reg[5][3] <= 0 ;
			img2_reg[5][4] <= 0 ;
			img2_reg[5][5] <= 0 ;
	end
	else if(in_valid && cnt_in > 35 && current_state == IDLE) begin
		case(cnt_in)
			'd36 : img2_reg[0][0] <= img ;
			'd37 : img2_reg[0][1] <= img ;
			'd38 : img2_reg[0][2] <= img ;
			'd39 : img2_reg[0][3] <= img ;
			'd40 : img2_reg[0][4] <= img ;
			'd41 : img2_reg[0][5] <= img ;

			'd42 : img2_reg[1][0] <= img ;
			'd43 : img2_reg[1][1] <= img ;
			'd44 : img2_reg[1][2] <= img ;
			'd45 : img2_reg[1][3] <= img ;
			'd46 : img2_reg[1][4] <= img ;
			'd47 : img2_reg[1][5] <= img ;

			'd48 : img2_reg[2][0] <= img ;
			'd49 : img2_reg[2][1] <= img ;
			'd50 : img2_reg[2][2] <= img ;
			'd51 : img2_reg[2][3] <= img ;
			'd52 : img2_reg[2][4] <= img ;
			'd53 : img2_reg[2][5] <= img ;

			'd54 : img2_reg[3][0] <= img ;
			'd55 : img2_reg[3][1] <= img ;
			'd56 : img2_reg[3][2] <= img ;
			'd57 : img2_reg[3][3] <= img ;
			'd58 : img2_reg[3][4] <= img ;
			'd59 : img2_reg[3][5] <= img ;

			'd60 : img2_reg[4][0] <= img ;
			'd61 : img2_reg[4][1] <= img ;
			'd62 : img2_reg[4][2] <= img ;
			'd63 : img2_reg[4][3] <= img ;
			'd64 : img2_reg[4][4] <= img ;
			'd65 : img2_reg[4][5] <= img ;

			'd66 : img2_reg[5][0] <= img ;
			'd67 : img2_reg[5][1] <= img ;
			'd68 : img2_reg[5][2] <= img ;
			'd69 : img2_reg[5][3] <= img ;
			'd70 : img2_reg[5][4] <= img ;
			'd71 : img2_reg[5][5] <= img ;


			default:;
		endcase
	end
	else begin
		img2_reg[0][0] <= img2_reg[0][0] ;
		img2_reg[0][1] <= img2_reg[0][1] ;
		img2_reg[0][2] <= img2_reg[0][2] ;
		img2_reg[0][3] <= img2_reg[0][3] ;
		img2_reg[0][4] <= img2_reg[0][4] ;
		img2_reg[0][5] <= img2_reg[0][5] ;
		
		img2_reg[1][0] <= img2_reg[1][0] ;
		img2_reg[1][1] <= img2_reg[1][1] ;
		img2_reg[1][2] <= img2_reg[1][2] ;
		img2_reg[1][3] <= img2_reg[1][3] ;
		img2_reg[1][4] <= img2_reg[1][4] ;
		img2_reg[1][5] <= img2_reg[1][5] ;
		
		img2_reg[2][0] <= img2_reg[2][0] ;
		img2_reg[2][1] <= img2_reg[2][1] ;
		img2_reg[2][2] <= img2_reg[2][2] ;
		img2_reg[2][3] <= img2_reg[2][3] ;
		img2_reg[2][4] <= img2_reg[2][4] ;
		img2_reg[2][5] <= img2_reg[2][5] ;

		img2_reg[3][0] <= img2_reg[3][0] ;
		img2_reg[3][1] <= img2_reg[3][1] ;
		img2_reg[3][2] <= img2_reg[3][2] ;
		img2_reg[3][3] <= img2_reg[3][3] ;
		img2_reg[3][4] <= img2_reg[3][4] ;
		img2_reg[3][5] <= img2_reg[3][5] ;

		img2_reg[4][0] <= img2_reg[4][0] ;
		img2_reg[4][1] <= img2_reg[4][1] ;
		img2_reg[4][2] <= img2_reg[4][2] ;
		img2_reg[4][3] <= img2_reg[4][3] ;
		img2_reg[4][4] <= img2_reg[4][4] ;
		img2_reg[4][5] <= img2_reg[4][5] ;

		img2_reg[5][0] <= img2_reg[5][0] ;
		img2_reg[5][1] <= img2_reg[5][1] ;
		img2_reg[5][2] <= img2_reg[5][2] ;
		img2_reg[5][3] <= img2_reg[5][3] ;
		img2_reg[5][4] <= img2_reg[5][4] ;
		img2_reg[5][5] <= img2_reg[5][5] ;
	
	end	
end

always@(posedge gclk_invalid or negedge rst_n)begin
	if(!rst_n) begin
		for(m=0; m<3; m=m+1)begin
			for(n=0; n<3; n=n+1)begin
				ker_reg[m][n] <= 0;
			end
		end
	end
	else if(in_valid && current_state == IDLE) begin
		case(cnt_in)
			'd0 : ker_reg[0][0] <= ker ;
			'd1 : ker_reg[0][1] <= ker ;
			'd2 : ker_reg[0][2] <= ker ;
			'd3 : ker_reg[1][0] <= ker ;
			'd4 : ker_reg[1][1] <= ker ;
			'd5 : ker_reg[1][2] <= ker ;
			'd6 : ker_reg[2][0] <= ker ;
			'd7 : ker_reg[2][1] <= ker ;
			'd8 : ker_reg[2][2] <= ker ;

		default :;
		endcase
	end
	else begin
		for(o=0; o<3; o=o+1)begin
			for(p=0; p<3; p=p+1)begin
				ker_reg[o][p] <= ker_reg[o][p];
			end
		end
	end
end

always@(posedge gclk_invalid or negedge rst_n)begin
	if(!rst_n)	begin
		for(a=0; a<2; a=a+1)begin
			for(b=0;b<2; b=b+1) begin
				weight_reg[a][b] <= 0;
			end
		end
	end
	else if(in_valid && current_state == IDLE) begin
		case(cnt_in)
			'd0 : weight_reg[0][0] <= weight;
			'd1 : weight_reg[0][1] <= weight;
			'd2 : weight_reg[1][0] <= weight;
			'd3 : weight_reg[1][1] <= weight;
			default :;
		endcase
	end
	else begin
		for(c=0; c<2; c=c+1)begin
			for(d=0; d<2; d=d+1) begin
				weight_reg[c][d] <= weight_reg[c][d];
			end
		end

	end

end
// always@(posedge gclk_invalid or negedge rst_n)begin
// 	if(!rst_n)				cnt_row <= 0;
// 	else if(in_valid) begin
// 		if(cnt_row == 5 && cnt_col == 5)	cnt_row <= 0;
// 		else if(cnt_col == 5)  				cnt_row <= cnt_row + 1;
// 	end
// 	else				 	cnt_row <= 0;
// end

// always@(posedge gclk_invalid or negedge rst_n)begin
// 	if(!rst_n)				cnt_col <= 0;
// 	else if(in_valid)begin
// 		if(cnt_col == 5)    cnt_col <= 0;
// 		else				cnt_col <= cnt_col + 1;
// 	end
// 	else				 	cnt_col <= 0;
// end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)			cnt_in <= 0;
	else if(in_valid && current_state == IDLE)	cnt_in <= cnt_in + 1;
	else				cnt_in <= 0;
end

////CONVOLUTION1
assign conv_image1[0] = (img1_reg[0][0]*ker_reg[0][0]) + (img1_reg[0][1]*ker_reg[0][1]) + (img1_reg[0][2]*ker_reg[0][2]) + 
						(img1_reg[1][0]*ker_reg[1][0]) + (img1_reg[1][1]*ker_reg[1][1]) + (img1_reg[1][2]*ker_reg[1][2]) + 
						(img1_reg[2][0]*ker_reg[2][0]) + (img1_reg[2][1]*ker_reg[2][1]) + (img1_reg[2][2]*ker_reg[2][2]) ; 

assign conv_image1[1] = (img1_reg[0][1]*ker_reg[0][0]) + (img1_reg[0][2]*ker_reg[0][1]) + (img1_reg[0][3]*ker_reg[0][2]) + 
						(img1_reg[1][1]*ker_reg[1][0]) + (img1_reg[1][2]*ker_reg[1][1]) + (img1_reg[1][3]*ker_reg[1][2]) + 
						(img1_reg[2][1]*ker_reg[2][0]) + (img1_reg[2][2]*ker_reg[2][1]) + (img1_reg[2][3]*ker_reg[2][2]) ; 

assign conv_image1[2] = (img1_reg[0][2]*ker_reg[0][0]) + (img1_reg[0][3]*ker_reg[0][1]) + (img1_reg[0][4]*ker_reg[0][2]) + 
						(img1_reg[1][2]*ker_reg[1][0]) + (img1_reg[1][3]*ker_reg[1][1]) + (img1_reg[1][4]*ker_reg[1][2]) + 
						(img1_reg[2][2]*ker_reg[2][0]) + (img1_reg[2][3]*ker_reg[2][1]) + (img1_reg[2][4]*ker_reg[2][2]) ; 

assign conv_image1[3] = (img1_reg[0][3]*ker_reg[0][0]) + (img1_reg[0][4]*ker_reg[0][1]) + (img1_reg[0][5]*ker_reg[0][2]) + 
						(img1_reg[1][3]*ker_reg[1][0]) + (img1_reg[1][4]*ker_reg[1][1]) + (img1_reg[1][5]*ker_reg[1][2]) + 
						(img1_reg[2][3]*ker_reg[2][0]) + (img1_reg[2][4]*ker_reg[2][1]) + (img1_reg[2][5]*ker_reg[2][2]) ;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
assign conv_image1[4] = (img1_reg[1][0]*ker_reg[0][0]) + (img1_reg[1][1]*ker_reg[0][1]) + (img1_reg[1][2]*ker_reg[0][2]) + 
						(img1_reg[2][0]*ker_reg[1][0]) + (img1_reg[2][1]*ker_reg[1][1]) + (img1_reg[2][2]*ker_reg[1][2]) + 
						(img1_reg[3][0]*ker_reg[2][0]) + (img1_reg[3][1]*ker_reg[2][1]) + (img1_reg[3][2]*ker_reg[2][2]) ;

assign conv_image1[5] = (img1_reg[1][1]*ker_reg[0][0]) + (img1_reg[1][2]*ker_reg[0][1]) + (img1_reg[1][3]*ker_reg[0][2]) + 
						(img1_reg[2][1]*ker_reg[1][0]) + (img1_reg[2][2]*ker_reg[1][1]) + (img1_reg[2][3]*ker_reg[1][2]) + 
						(img1_reg[3][1]*ker_reg[2][0]) + (img1_reg[3][2]*ker_reg[2][1]) + (img1_reg[3][3]*ker_reg[2][2]) ;

assign conv_image1[6] = (img1_reg[1][2]*ker_reg[0][0]) + (img1_reg[1][3]*ker_reg[0][1]) + (img1_reg[1][4]*ker_reg[0][2]) + 
						(img1_reg[2][2]*ker_reg[1][0]) + (img1_reg[2][3]*ker_reg[1][1]) + (img1_reg[2][4]*ker_reg[1][2]) + 
						(img1_reg[3][2]*ker_reg[2][0]) + (img1_reg[3][3]*ker_reg[2][1]) + (img1_reg[3][4]*ker_reg[2][2]) ;

assign conv_image1[7] = (img1_reg[1][3]*ker_reg[0][0]) + (img1_reg[1][4]*ker_reg[0][1]) + (img1_reg[1][5]*ker_reg[0][2]) + 
						(img1_reg[2][3]*ker_reg[1][0]) + (img1_reg[2][4]*ker_reg[1][1]) + (img1_reg[2][5]*ker_reg[1][2]) + 
						(img1_reg[3][3]*ker_reg[2][0]) + (img1_reg[3][4]*ker_reg[2][1]) + (img1_reg[3][5]*ker_reg[2][2]) ;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
assign conv_image1[8] = (img1_reg[2][0]*ker_reg[0][0]) + (img1_reg[2][1]*ker_reg[0][1]) + (img1_reg[2][2]*ker_reg[0][2]) + 
						(img1_reg[3][0]*ker_reg[1][0]) + (img1_reg[3][1]*ker_reg[1][1]) + (img1_reg[3][2]*ker_reg[1][2]) + 
						(img1_reg[4][0]*ker_reg[2][0]) + (img1_reg[4][1]*ker_reg[2][1]) + (img1_reg[4][2]*ker_reg[2][2]) ;

assign conv_image1[9] = (img1_reg[2][1]*ker_reg[0][0]) + (img1_reg[2][2]*ker_reg[0][1]) + (img1_reg[2][3]*ker_reg[0][2]) + 
						(img1_reg[3][1]*ker_reg[1][0]) + (img1_reg[3][2]*ker_reg[1][1]) + (img1_reg[3][3]*ker_reg[1][2]) + 
						(img1_reg[4][1]*ker_reg[2][0]) + (img1_reg[4][2]*ker_reg[2][1]) + (img1_reg[4][3]*ker_reg[2][2]) ;

assign conv_image1[10] = (img1_reg[2][2]*ker_reg[0][0]) + (img1_reg[2][3]*ker_reg[0][1]) + (img1_reg[2][4]*ker_reg[0][2]) + 
						 (img1_reg[3][2]*ker_reg[1][0]) + (img1_reg[3][3]*ker_reg[1][1]) + (img1_reg[3][4]*ker_reg[1][2]) + 
						 (img1_reg[4][2]*ker_reg[2][0]) + (img1_reg[4][3]*ker_reg[2][1]) + (img1_reg[4][4]*ker_reg[2][2]) ;

assign conv_image1[11] = (img1_reg[2][3]*ker_reg[0][0]) + (img1_reg[2][4]*ker_reg[0][1]) + (img1_reg[2][5]*ker_reg[0][2]) + 
						 (img1_reg[3][3]*ker_reg[1][0]) + (img1_reg[3][4]*ker_reg[1][1]) + (img1_reg[3][5]*ker_reg[1][2]) + 
						 (img1_reg[4][3]*ker_reg[2][0]) + (img1_reg[4][4]*ker_reg[2][1]) + (img1_reg[4][5]*ker_reg[2][2]) ;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
assign conv_image1[12] = (img1_reg[3][0]*ker_reg[0][0]) + (img1_reg[3][1]*ker_reg[0][1]) + (img1_reg[3][2]*ker_reg[0][2]) + 
						 (img1_reg[4][0]*ker_reg[1][0]) + (img1_reg[4][1]*ker_reg[1][1]) + (img1_reg[4][2]*ker_reg[1][2]) + 
						 (img1_reg[5][0]*ker_reg[2][0]) + (img1_reg[5][1]*ker_reg[2][1]) + (img1_reg[5][2]*ker_reg[2][2]) ;

assign conv_image1[13] = (img1_reg[3][1]*ker_reg[0][0]) + (img1_reg[3][2]*ker_reg[0][1]) + (img1_reg[3][3]*ker_reg[0][2]) + 
						 (img1_reg[4][1]*ker_reg[1][0]) + (img1_reg[4][2]*ker_reg[1][1]) + (img1_reg[4][3]*ker_reg[1][2]) +  
						 (img1_reg[5][1]*ker_reg[2][0]) + (img1_reg[5][2]*ker_reg[2][1]) + (img1_reg[5][3]*ker_reg[2][2]) ;

assign conv_image1[14] = (img1_reg[3][2]*ker_reg[0][0]) + (img1_reg[3][3]*ker_reg[0][1]) + (img1_reg[3][4]*ker_reg[0][2]) + 
						 (img1_reg[4][2]*ker_reg[1][0]) + (img1_reg[4][3]*ker_reg[1][1]) + (img1_reg[4][4]*ker_reg[1][2]) + 
						 (img1_reg[5][2]*ker_reg[2][0]) + (img1_reg[5][3]*ker_reg[2][1]) + (img1_reg[5][4]*ker_reg[2][2]) ;

assign conv_image1[15] = (img1_reg[3][3]*ker_reg[0][0]) + (img1_reg[3][4]*ker_reg[0][1]) + (img1_reg[3][5]*ker_reg[0][2]) + 
						 (img1_reg[4][3]*ker_reg[1][0]) + (img1_reg[4][4]*ker_reg[1][1]) + (img1_reg[4][5]*ker_reg[1][2]) + 
						 (img1_reg[5][3]*ker_reg[2][0]) + (img1_reg[5][4]*ker_reg[2][1]) + (img1_reg[5][5]*ker_reg[2][2]) ;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
always@(posedge gclk_outvalid or negedge rst_n) begin
	if(!rst_n) begin
		feature_map1[0][0] <= 0 ;
		feature_map1[0][1] <= 0 ;
		feature_map1[0][2] <= 0 ;
		feature_map1[0][3] <= 0 ;

		feature_map1[1][0] <= 0 ;
		feature_map1[1][1] <= 0 ;
		feature_map1[1][2] <= 0 ;
		feature_map1[1][3] <= 0 ;

		feature_map1[2][0] <= 0 ;
		feature_map1[2][1] <= 0 ;
		feature_map1[2][2] <= 0 ;
		feature_map1[2][3] <= 0 ;

		feature_map1[3][0] <= 0 ;
		feature_map1[3][1] <= 0 ;
		feature_map1[3][2] <= 0 ;
		feature_map1[3][3] <= 0 ;
	end
	else begin
		case(current_state)
		IDLE : begin
			feature_map1[0][0] <= 0 ;
			feature_map1[0][1] <= 0 ;
			feature_map1[0][2] <= 0 ;
			feature_map1[0][3] <= 0 ;

			feature_map1[1][0] <= 0 ;
			feature_map1[1][1] <= 0 ;
			feature_map1[1][2] <= 0 ;
			feature_map1[1][3] <= 0 ;

			feature_map1[2][0] <= 0 ;
			feature_map1[2][1] <= 0 ;
			feature_map1[2][2] <= 0 ;
			feature_map1[2][3] <= 0 ;

			feature_map1[3][0] <= 0 ;
			feature_map1[3][1] <= 0 ;
			feature_map1[3][2] <= 0 ;
			feature_map1[3][3] <= 0 ;
		end
		COMPUTE : begin
			feature_map1[0][0] <= conv_image1[0] ;
			feature_map1[0][1] <= conv_image1[1] ;
			feature_map1[0][2] <= conv_image1[2] ;
			feature_map1[0][3] <= conv_image1[3] ;

			feature_map1[1][0] <= conv_image1[4] ;
			feature_map1[1][1] <= conv_image1[5] ;
			feature_map1[1][2] <= conv_image1[6] ;
			feature_map1[1][3] <= conv_image1[7] ;

			feature_map1[2][0] <= conv_image1[8] ;
			feature_map1[2][1] <= conv_image1[9] ;
			feature_map1[2][2] <= conv_image1[10] ;
			feature_map1[2][3] <= conv_image1[11] ;

			feature_map1[3][0] <= conv_image1[12] ;
			feature_map1[3][1] <= conv_image1[13] ;
			feature_map1[3][2] <= conv_image1[14] ;
			feature_map1[3][3] <= conv_image1[15] ;
		end
		default:;
		endcase
	end
end

////CONVOLUTION2
assign conv_image2[0] = (img2_reg[0][0]*ker_reg[0][0]) + (img2_reg[0][1]*ker_reg[0][1]) + (img2_reg[0][2]*ker_reg[0][2]) + 
						(img2_reg[1][0]*ker_reg[1][0]) + (img2_reg[1][1]*ker_reg[1][1]) + (img2_reg[1][2]*ker_reg[1][2]) + 
						(img2_reg[2][0]*ker_reg[2][0]) + (img2_reg[2][1]*ker_reg[2][1]) + (img2_reg[2][2]*ker_reg[2][2]) ; 

assign conv_image2[1] = (img2_reg[0][1]*ker_reg[0][0]) + (img2_reg[0][2]*ker_reg[0][1]) + (img2_reg[0][3]*ker_reg[0][2]) + 
						(img2_reg[1][1]*ker_reg[1][0]) + (img2_reg[1][2]*ker_reg[1][1]) + (img2_reg[1][3]*ker_reg[1][2]) + 
						(img2_reg[2][1]*ker_reg[2][0]) + (img2_reg[2][2]*ker_reg[2][1]) + (img2_reg[2][3]*ker_reg[2][2]) ; 

assign conv_image2[2] = (img2_reg[0][2]*ker_reg[0][0]) + (img2_reg[0][3]*ker_reg[0][1]) + (img2_reg[0][4]*ker_reg[0][2]) + 
						(img2_reg[1][2]*ker_reg[1][0]) + (img2_reg[1][3]*ker_reg[1][1]) + (img2_reg[1][4]*ker_reg[1][2]) + 
						(img2_reg[2][2]*ker_reg[2][0]) + (img2_reg[2][3]*ker_reg[2][1]) + (img2_reg[2][4]*ker_reg[2][2]) ; 

assign conv_image2[3] = (img2_reg[0][3]*ker_reg[0][0]) + (img2_reg[0][4]*ker_reg[0][1]) + (img2_reg[0][5]*ker_reg[0][2]) + 
						(img2_reg[1][3]*ker_reg[1][0]) + (img2_reg[1][4]*ker_reg[1][1]) + (img2_reg[1][5]*ker_reg[1][2]) + 
						(img2_reg[2][3]*ker_reg[2][0]) + (img2_reg[2][4]*ker_reg[2][1]) + (img2_reg[2][5]*ker_reg[2][2]) ;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
assign conv_image2[4] = (img2_reg[1][0]*ker_reg[0][0]) + (img2_reg[1][1]*ker_reg[0][1]) + (img2_reg[1][2]*ker_reg[0][2]) + 
						(img2_reg[2][0]*ker_reg[1][0]) + (img2_reg[2][1]*ker_reg[1][1]) + (img2_reg[2][2]*ker_reg[1][2]) + 
						(img2_reg[3][0]*ker_reg[2][0]) + (img2_reg[3][1]*ker_reg[2][1]) + (img2_reg[3][2]*ker_reg[2][2]) ;

assign conv_image2[5] = (img2_reg[1][1]*ker_reg[0][0]) + (img2_reg[1][2]*ker_reg[0][1]) + (img2_reg[1][3]*ker_reg[0][2]) + 
						(img2_reg[2][1]*ker_reg[1][0]) + (img2_reg[2][2]*ker_reg[1][1]) + (img2_reg[2][3]*ker_reg[1][2]) + 
						(img2_reg[3][1]*ker_reg[2][0]) + (img2_reg[3][2]*ker_reg[2][1]) + (img2_reg[3][3]*ker_reg[2][2]) ;

assign conv_image2[6] = (img2_reg[1][2]*ker_reg[0][0]) + (img2_reg[1][3]*ker_reg[0][1]) + (img2_reg[1][4]*ker_reg[0][2]) + 
						(img2_reg[2][2]*ker_reg[1][0]) + (img2_reg[2][3]*ker_reg[1][1]) + (img2_reg[2][4]*ker_reg[1][2]) + 
						(img2_reg[3][2]*ker_reg[2][0]) + (img2_reg[3][3]*ker_reg[2][1]) + (img2_reg[3][4]*ker_reg[2][2]) ;

assign conv_image2[7] = (img2_reg[1][3]*ker_reg[0][0]) + (img2_reg[1][4]*ker_reg[0][1]) + (img2_reg[1][5]*ker_reg[0][2]) + 
						(img2_reg[2][3]*ker_reg[1][0]) + (img2_reg[2][4]*ker_reg[1][1]) + (img2_reg[2][5]*ker_reg[1][2]) + 
						(img2_reg[3][3]*ker_reg[2][0]) + (img2_reg[3][4]*ker_reg[2][1]) + (img2_reg[3][5]*ker_reg[2][2]) ;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
assign conv_image2[8] = (img2_reg[2][0]*ker_reg[0][0]) + (img2_reg[2][1]*ker_reg[0][1]) + (img2_reg[2][2]*ker_reg[0][2]) + 
						(img2_reg[3][0]*ker_reg[1][0]) + (img2_reg[3][1]*ker_reg[1][1]) + (img2_reg[3][2]*ker_reg[1][2]) + 
						(img2_reg[4][0]*ker_reg[2][0]) + (img2_reg[4][1]*ker_reg[2][1]) + (img2_reg[4][2]*ker_reg[2][2]) ;

assign conv_image2[9] = (img2_reg[2][1]*ker_reg[0][0]) + (img2_reg[2][2]*ker_reg[0][1]) + (img2_reg[2][3]*ker_reg[0][2]) + 
						(img2_reg[3][1]*ker_reg[1][0]) + (img2_reg[3][2]*ker_reg[1][1]) + (img2_reg[3][3]*ker_reg[1][2]) + 
						(img2_reg[4][1]*ker_reg[2][0]) + (img2_reg[4][2]*ker_reg[2][1]) + (img2_reg[4][3]*ker_reg[2][2]) ;

assign conv_image2[10] = (img2_reg[2][2]*ker_reg[0][0]) + (img2_reg[2][3]*ker_reg[0][1]) + (img2_reg[2][4]*ker_reg[0][2]) + 
						 (img2_reg[3][2]*ker_reg[1][0]) + (img2_reg[3][3]*ker_reg[1][1]) + (img2_reg[3][4]*ker_reg[1][2]) + 
						 (img2_reg[4][2]*ker_reg[2][0]) + (img2_reg[4][3]*ker_reg[2][1]) + (img2_reg[4][4]*ker_reg[2][2]) ;

assign conv_image2[11] = (img2_reg[2][3]*ker_reg[0][0]) + (img2_reg[2][4]*ker_reg[0][1]) + (img2_reg[2][5]*ker_reg[0][2]) + 
						 (img2_reg[3][3]*ker_reg[1][0]) + (img2_reg[3][4]*ker_reg[1][1]) + (img2_reg[3][5]*ker_reg[1][2]) + 
						 (img2_reg[4][3]*ker_reg[2][0]) + (img2_reg[4][4]*ker_reg[2][1]) + (img2_reg[4][5]*ker_reg[2][2]) ;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
assign conv_image2[12] = (img2_reg[3][0]*ker_reg[0][0]) + (img2_reg[3][1]*ker_reg[0][1]) + (img2_reg[3][2]*ker_reg[0][2]) + 
						 (img2_reg[4][0]*ker_reg[1][0]) + (img2_reg[4][1]*ker_reg[1][1]) + (img2_reg[4][2]*ker_reg[1][2]) + 
						 (img2_reg[5][0]*ker_reg[2][0]) + (img2_reg[5][1]*ker_reg[2][1]) + (img2_reg[5][2]*ker_reg[2][2]) ;

assign conv_image2[13] = (img2_reg[3][1]*ker_reg[0][0]) + (img2_reg[3][2]*ker_reg[0][1]) + (img2_reg[3][3]*ker_reg[0][2]) + 
						 (img2_reg[4][1]*ker_reg[1][0]) + (img2_reg[4][2]*ker_reg[1][1]) + (img2_reg[4][3]*ker_reg[1][2]) +  
						 (img2_reg[5][1]*ker_reg[2][0]) + (img2_reg[5][2]*ker_reg[2][1]) + (img2_reg[5][3]*ker_reg[2][2]) ;

assign conv_image2[14] = (img2_reg[3][2]*ker_reg[0][0]) + (img2_reg[3][3]*ker_reg[0][1]) + (img2_reg[3][4]*ker_reg[0][2]) + 
						 (img2_reg[4][2]*ker_reg[1][0]) + (img2_reg[4][3]*ker_reg[1][1]) + (img2_reg[4][4]*ker_reg[1][2]) + 
						 (img2_reg[5][2]*ker_reg[2][0]) + (img2_reg[5][3]*ker_reg[2][1]) + (img2_reg[5][4]*ker_reg[2][2]) ;

assign conv_image2[15] = (img2_reg[3][3]*ker_reg[0][0]) + (img2_reg[3][4]*ker_reg[0][1]) + (img2_reg[3][5]*ker_reg[0][2]) + 
						 (img2_reg[4][3]*ker_reg[1][0]) + (img2_reg[4][4]*ker_reg[1][1]) + (img2_reg[4][5]*ker_reg[1][2]) + 
						 (img2_reg[5][3]*ker_reg[2][0]) + (img2_reg[5][4]*ker_reg[2][1]) + (img2_reg[5][5]*ker_reg[2][2]) ;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
always@(posedge gclk_outvalid or negedge rst_n) begin
	if(!rst_n) begin
		feature_map2[0][0] <= 0 ;
		feature_map2[0][1] <= 0 ;
		feature_map2[0][2] <= 0 ;
		feature_map2[0][3] <= 0 ;

		feature_map2[1][0] <= 0 ;
		feature_map2[1][1] <= 0 ;
		feature_map2[1][2] <= 0 ;
		feature_map2[1][3] <= 0 ;

		feature_map2[2][0] <= 0 ;
		feature_map2[2][1] <= 0 ;
		feature_map2[2][2] <= 0 ;
		feature_map2[2][3] <= 0 ;

		feature_map2[3][0] <= 0 ;
		feature_map2[3][1] <= 0 ;
		feature_map2[3][2] <= 0 ;
		feature_map2[3][3] <= 0 ;
	end
	else begin
		case(current_state)
		IDLE : begin
			feature_map2[0][0] <= 0 ;
			feature_map2[0][1] <= 0 ;
			feature_map2[0][2] <= 0 ;
			feature_map2[0][3] <= 0 ;

			feature_map2[1][0] <= 0 ;
			feature_map2[1][1] <= 0 ;
			feature_map2[1][2] <= 0 ;
			feature_map2[1][3] <= 0 ;

			feature_map2[2][0] <= 0 ;
			feature_map2[2][1] <= 0 ;
			feature_map2[2][2] <= 0 ;
			feature_map2[2][3] <= 0 ;

			feature_map2[3][0] <= 0 ;
			feature_map2[3][1] <= 0 ;
			feature_map2[3][2] <= 0 ;
			feature_map2[3][3] <= 0 ;
		end
		COMPUTE : begin
			feature_map2[0][0] <= conv_image2[0] ;
			feature_map2[0][1] <= conv_image2[1] ;
			feature_map2[0][2] <= conv_image2[2] ;
			feature_map2[0][3] <= conv_image2[3] ;

			feature_map2[1][0] <= conv_image2[4] ;
			feature_map2[1][1] <= conv_image2[5] ;
			feature_map2[1][2] <= conv_image2[6] ;
			feature_map2[1][3] <= conv_image2[7] ;

			feature_map2[2][0] <= conv_image2[8] ;
			feature_map2[2][1] <= conv_image2[9] ;
			feature_map2[2][2] <= conv_image2[10] ;
			feature_map2[2][3] <= conv_image2[11] ;

			feature_map2[3][0] <= conv_image2[12] ;
			feature_map2[3][1] <= conv_image2[13] ;
			feature_map2[3][2] <= conv_image2[14] ;
			feature_map2[3][3] <= conv_image2[15] ;
		end
		default :;
		endcase
	end
end

//QUANTIZATION
genvar r,s;

generate
	for(r=0; r<4; r=r+1)begin
		for(s=0; s<4; s=s+1) begin
			always@(posedge gclk_outvalid or negedge rst_n)begin
				if(!rst_n)		quantization_map1[r][s] <= 0;
				else begin
					case(current_state)
					IDLE : 		quantization_map1[r][s] <= 0;
					COMPUTE :	quantization_map1[r][s] <= feature_map1[r][s] /2295;
					default :;
				endcase
				end
			end
		end
	end
endgenerate

generate
	for(r=0; r<4; r=r+1)begin
		for(s=0; s<4; s=s+1) begin
			always@(posedge gclk_outvalid or negedge rst_n)begin
				if(!rst_n)		quantization_map2[r][s] <= 0;
				else begin
					case(current_state)
					IDLE : 		quantization_map2[r][s] <= 0;
					COMPUTE :	quantization_map2[r][s] <= feature_map2[r][s] /2295;
					default :;
					endcase
				end
			end
		end
	end
endgenerate

//MAX-POLLING
assign red1[0] = (quantization_map1[0][0] > quantization_map1[0][1]) ? quantization_map1[0][0] : quantization_map1[0][1];
assign red1[1] = (quantization_map1[1][0] > quantization_map1[1][1]) ? quantization_map1[1][0] : quantization_map1[1][1];
assign red1[2] = ( red1[0] > red1[1]) ? red1[0] : red1[1];

assign yellow1[0] = (quantization_map1[0][2] > quantization_map1[0][3]) ? quantization_map1[0][2] : quantization_map1[0][3];
assign yellow1[1] = (quantization_map1[1][2] > quantization_map1[1][3]) ? quantization_map1[1][2] : quantization_map1[1][3];
assign yellow1[2] = ( yellow1[0] > yellow1[1]) ? yellow1[0] : yellow1[1];

assign blue1[0] = (quantization_map1[2][0] > quantization_map1[2][1]) ? quantization_map1[2][0] : quantization_map1[2][1];
assign blue1[1] = (quantization_map1[3][0] > quantization_map1[3][1]) ? quantization_map1[3][0] : quantization_map1[3][1];
assign blue1[2] = ( blue1[0] > blue1[1]) ? blue1[0] : blue1[1];

assign green1[0] = (quantization_map1[2][2] > quantization_map1[2][3]) ? quantization_map1[2][2] :quantization_map1[2][3];
assign green1[1] = (quantization_map1[3][2] > quantization_map1[3][3]) ? quantization_map1[3][2] :quantization_map1[3][3];
assign green1[2] = ( green1[0] > green1[1]) ? green1[0] : green1[1];

assign red2[0] = (quantization_map2[0][0] > quantization_map2[0][1]) ? quantization_map2[0][0] : quantization_map2[0][1];
assign red2[1] = (quantization_map2[1][0] > quantization_map2[1][1]) ? quantization_map2[1][0] : quantization_map2[1][1];
assign red2[2] = ( red2[0] > red2[1]) ? red2[0] : red2[1];

assign yellow2[0] = (quantization_map2[0][2] > quantization_map2[0][3]) ? quantization_map2[0][2] : quantization_map2[0][3];
assign yellow2[1] = (quantization_map2[1][2] > quantization_map2[1][3]) ? quantization_map2[1][2] : quantization_map2[1][3];
assign yellow2[2] = ( yellow2[0] > yellow2[1]) ? yellow2[0] : yellow2[1];

assign blue2[0] = (quantization_map2[2][0] > quantization_map2[2][1]) ? quantization_map2[2][0] : quantization_map2[2][1];
assign blue2[1] = (quantization_map2[3][0] > quantization_map2[3][1]) ? quantization_map2[3][0] : quantization_map2[3][1];
assign blue2[2] = ( blue2[0] > blue2[1]) ? blue2[0] : blue2[1];

assign green2[0] = (quantization_map2[2][2] > quantization_map2[2][3]) ? quantization_map2[2][2] :quantization_map2[2][3];
assign green2[1] = (quantization_map2[3][2] > quantization_map2[3][3]) ? quantization_map2[3][2] :quantization_map2[3][3];
assign green2[2] = ( green2[0] > green2[1]) ? green2[0] : green2[1];


assign 	max_pooling1[0][0] = red1[2];
assign 	max_pooling1[0][1] = yellow1[2];
assign 	max_pooling1[1][0] = blue1[2];
assign 	max_pooling1[1][1] = green1[2];

assign 	max_pooling2[0][0] = red2[2];
assign 	max_pooling2[0][1] = yellow2[2];
assign 	max_pooling2[1][0] = blue2[2];
assign 	max_pooling2[1][1] = green2[2];

///FULLY_CONNECTED
assign	fully_connected1[0][0] = (max_pooling1[0][0]*weight_reg[0][0]) + (max_pooling1[0][1]*weight_reg[1][0]) ;
assign	fully_connected1[0][1] = (max_pooling1[0][0]*weight_reg[0][1]) + (max_pooling1[0][1]*weight_reg[1][1]) ;
assign	fully_connected1[1][0] = (max_pooling1[1][0]*weight_reg[0][0]) + (max_pooling1[1][1]*weight_reg[1][0]) ;
assign	fully_connected1[1][1] = (max_pooling1[1][0]*weight_reg[0][1]) + (max_pooling1[1][1]*weight_reg[1][1]) ;

assign	fully_connected2[0][0] = (max_pooling2[0][0]*weight_reg[0][0]) + (max_pooling2[0][1]*weight_reg[1][0]) ;
assign	fully_connected2[0][1] = (max_pooling2[0][0]*weight_reg[0][1]) + (max_pooling2[0][1]*weight_reg[1][1]) ;
assign	fully_connected2[1][0] = (max_pooling2[1][0]*weight_reg[0][0]) + (max_pooling2[1][1]*weight_reg[1][0]) ;
assign	fully_connected2[1][1] = (max_pooling2[1][0]*weight_reg[0][1]) + (max_pooling2[1][1]*weight_reg[1][1]) ;

always@(posedge gclk_outvalid or negedge rst_n)begin
	if(!rst_n)begin
		flatten1[0] <= 0;
		flatten1[1] <= 0;
		flatten1[2] <= 0;
		flatten1[3] <= 0;
	end
	else begin
		case(current_state)
		IDLE : begin
			flatten1[0] <= 0;
			flatten1[1] <= 0;
			flatten1[2] <= 0;
			flatten1[3] <= 0;

		end
		COMPUTE : begin
			flatten1[0] <= fully_connected1[0][0] ;
			flatten1[1] <= fully_connected1[0][1] ;
			flatten1[2] <= fully_connected1[1][0] ;
			flatten1[3] <= fully_connected1[1][1] ;
		end
		default:;
		endcase
	end

end

always@(posedge gclk_outvalid or negedge rst_n)begin
	if(!rst_n)begin
		flatten2[0] <= 0;
		flatten2[1] <= 0;
		flatten2[2] <= 0;
		flatten2[3] <= 0;
	end
	else begin
		case(current_state)
		IDLE : begin
			flatten2[0] <= 0;
			flatten2[1] <= 0;
			flatten2[2] <= 0;
			flatten2[3] <= 0;

		end
		COMPUTE : begin
			flatten2[0] <= fully_connected2[0][0] ;
			flatten2[1] <= fully_connected2[0][1] ;
			flatten2[2] <= fully_connected2[1][0] ;
			flatten2[3] <= fully_connected2[1][1] ;
		end
		default:;
		endcase
	end

end

assign	flatten1_quant[0] = flatten1[0] / 510 ;
assign	flatten1_quant[1] = flatten1[1] / 510 ;
assign	flatten1_quant[2] = flatten1[2] / 510 ;
assign	flatten1_quant[3] = flatten1[3] / 510 ;

assign	flatten2_quant[0] = flatten2[0] / 510 ;
assign	flatten2_quant[1] = flatten2[1] / 510 ;
assign	flatten2_quant[2] = flatten2[2] / 510 ;
assign	flatten2_quant[3] = flatten2[3] / 510 ;

always@(posedge gclk_outvalid or negedge rst_n)begin
	if(!rst_n) begin
		flatten1_quant_reg[0] <= 0;
		flatten1_quant_reg[1] <= 0;
		flatten1_quant_reg[2] <= 0;
		flatten1_quant_reg[3] <= 0;
	end
	else begin
		case(current_state)
		IDLE : begin
			flatten1_quant_reg[0] <= 0;
			flatten1_quant_reg[1] <= 0;
			flatten1_quant_reg[2] <= 0;
			flatten1_quant_reg[3] <= 0;
		end
		COMPUTE : begin
			flatten1_quant_reg[0] <= flatten1_quant[0];
			flatten1_quant_reg[1] <= flatten1_quant[1];
			flatten1_quant_reg[2] <= flatten1_quant[2];
			flatten1_quant_reg[3] <= flatten1_quant[3];
		end
		default :;
		endcase
	end

end
always@(posedge gclk_outvalid or negedge rst_n)begin
	if(!rst_n) begin
		flatten2_quant_reg[0] <= 0;
		flatten2_quant_reg[1] <= 0;
		flatten2_quant_reg[2] <= 0;
		flatten2_quant_reg[3] <= 0;
	end
	else begin
		case(current_state)
		IDLE : begin
			flatten2_quant_reg[0] <= 0;
			flatten2_quant_reg[1] <= 0;
			flatten2_quant_reg[2] <= 0;
			flatten2_quant_reg[3] <= 0;
		end
		COMPUTE : begin
			flatten2_quant_reg[0] <= flatten2_quant[0];
			flatten2_quant_reg[1] <= flatten2_quant[1];
			flatten2_quant_reg[2] <= flatten2_quant[2];
			flatten2_quant_reg[3] <= flatten2_quant[3];
		end
		default :;
		endcase
	end

end

///L1_DISTANCE
assign  L1_distance[0] = (flatten1_quant_reg[0] > flatten2_quant_reg[0]) ? (flatten1_quant_reg[0] - flatten2_quant_reg[0]) : (flatten2_quant_reg[0] - flatten1_quant_reg[0]);
assign  L1_distance[1] = (flatten1_quant_reg[1] > flatten2_quant_reg[1]) ? (flatten1_quant_reg[1] - flatten2_quant_reg[1]) : (flatten2_quant_reg[1] - flatten1_quant_reg[1]);
assign  L1_distance[2] = (flatten1_quant_reg[2] > flatten2_quant_reg[2]) ? (flatten1_quant_reg[2] - flatten2_quant_reg[2]) : (flatten2_quant_reg[2] - flatten1_quant_reg[2]);
assign  L1_distance[3] = (flatten1_quant_reg[3] > flatten2_quant_reg[3]) ? (flatten1_quant_reg[3] - flatten2_quant_reg[3]) : (flatten2_quant_reg[3] - flatten1_quant_reg[3]);

assign  L1_distance_sum =  L1_distance[0] + L1_distance[1] + L1_distance[2] + L1_distance[3] ;

always@(posedge gclk_outvalid or negedge rst_n)begin
	if(!rst_n) begin
		L1_distance_reg <= 0;
	end
	else begin
		case(current_state)
		IDLE :    L1_distance_reg <= 0;
		COMPUTE : L1_distance_reg <= L1_distance_sum;
		default :;
		endcase
	end
end

///ACTIVATION_FUNCTION
assign	activation_function = (L1_distance_reg < 16 )? 0 : L1_distance_reg;

//==============================================//
//                  OUTPUT                      //
//==============================================//

always@(posedge gclk_outvalid or negedge rst_n) begin
	if(!rst_n)		cnt_latency <= 0 ;
	else begin
		case(current_state)
		 	IDLE :	  cnt_latency <= 0 ;
		 	COMPUTE : begin
				if(cnt_latency == 7 )  cnt_latency <= 0 ;
				else				cnt_latency <= cnt_latency + 1 ;
			end	
			default :;
		endcase
		
	end
end
always @(posedge gclk_outvalid or negedge rst_n) begin
	if(!rst_n) begin
		out_valid <= 0;
	end
	else begin
		case(current_state)
		IDLE :  out_valid <= 0;
		COMPUTE : begin
			if(cnt_latency == 6)  out_valid <= 1;
			else				  out_valid <= 0;
		end
		default :  out_valid <= 0;
		endcase
	end
end

always @(posedge gclk_outvalid or negedge rst_n) begin
	if(!rst_n) begin
		out_data <= 0;
	end
	else begin
		case(current_state)
		IDLE :  out_data <= 0;
		COMPUTE : begin
			if(cnt_latency == 6)  out_data <= activation_function;
			else				  out_data <= 0;
		end
		default :  out_data <= 0;
		endcase
	end
end


endmodule
