//synopsys translate_off
`include "/usr/synthesis/dw/sim_ver/DW_fp_dp2.v"
`include "/usr/synthesis/dw/sim_ver/DW_fp_mac.v"
`include "/usr/synthesis/dw/sim_ver/DW_fp_add.v"
`include "/usr/synthesis/dw/sim_ver/DW_fp_mult.v"
`include "/usr/synthesis/dw/sim_ver/DW_fp_sub.v"
`include "/usr/synthesis/dw/sim_ver/DW_fp_div.v"
`include "/usr/synthesis/dw/sim_ver/DW_fp_cmp.v"
//`include "/usr/synthesis/dw/sim_ver/DW_fp_flt2i.v"
`include "/usr/synthesis/dw/sim_ver/DW_fp_addsub.v"
`include "/usr/synthesis/dw/sim_ver/DW_fp_dp3.v"
//synopsys translate_on

module NN(
	// Input signals
	clk,
	rst_n,
	in_valid,
	weight_u,
	weight_w,
	weight_v,
	data_x,
	data_h,
	// Output signals
	out_valid,
	out
);

//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------

// IEEE floating point paramenters
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch = 2;

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION
//---------------------------------------------------------------------
input  clk, rst_n, in_valid;
input [inst_sig_width+inst_exp_width:0] weight_u, weight_w, weight_v;
input [inst_sig_width+inst_exp_width:0] data_x,data_h;
output reg	out_valid;
output reg [inst_sig_width+inst_exp_width:0] out;

//---------------------------------------------------------------------
//   WIRE AND REG DECLARATION
//---------------------------------------------------------------------
integer i,j,k,l,m,n,o;
//three  3x1 x input
reg		[31:0]x_in[0:8] ;
//h_input is 3x1
reg		[31:0]h_in[0:2] ;
// u,v,m 3x3 array 
reg		[31:0]u_in[0:8] ;
reg 	[31:0]v_in[0:8] ;
reg 	[31:0]w_in[0:8] ;
//input counter
reg		[3:0]in_cnt;

//FSM VARIABLES
reg   [4:0]current_state;
reg   [4:0]next_state;
parameter IDLE = 4'd0;
parameter STATE1 = 4'd1 ; //COMPUTATION
parameter STATE2 = 4'd2 ;
parameter STATE3 = 4'd3 ;
parameter STATE4 = 4'd4 ;
parameter STATE5 = 4'd5 ;
parameter STATE6 = 4'd6 ;
parameter STATE7 = 4'd7 ;
parameter STATE8 = 4'd8 ;
parameter STATE9 = 4'd9 ;
parameter STATE10 = 4'd10 ;
parameter STATE11 = 4'd11 ;
parameter STATE12 = 4'd12 ;

parameter zero_point_one = 32'b0_01111011_10011001100110011001100;
parameter one = 32'b0_01111111_00000000000000000000000;
//IP
wire	[7:0]status[1:10] ;	

//USED COUNTER TO CONTROL DOT-PORDUCT IN THREE CYCLES
reg		[31:0]xx[0:2] ; //control this signal to share the sources
reg		[31:0]hh[0:2] ;
reg		[31:0]uu[0:2] ;
reg		[31:0]ww[0:2] ;
reg		[31:0]vv[0:2] ;
reg		[31:0]hhx[0:2];
reg		[31:0]exp_in;
wire	[31:0]exp_out;
reg		[31:0]div_div;
wire	[31:0]div_ans;

reg		[5:0]count_total_clk;
reg 	[4:0]cont_x ;
reg		[4:0]cont_u ; 
reg		[4:0]cont_v1 ; 
reg		[4:0]cont_v2 ; 
reg		[4:0]cont_v3 ; 
reg 	[2:0]cont_temp ;
reg		[4:0]cont_exp ;
////////////////////////////////////////////////////
wire	[31:0]u_mult_x ;
wire	[31:0]w_mult_h ;
wire	[31:0]v_mult_h;

wire	[31:0]add_out ; 
reg		[31:0]temp_addout[0:2] ;
wire	[31:0]RELU[0:2] ;
wire	[31:0]new_h[0:2] ;
reg		[31:0]hh1[0:2] ;
reg		[31:0]hh2[0:2] ;
reg		[31:0]hh3[0:2] ;
reg     [31:0]mult_hv[0:8] ;
wire	[31:0]div_in;
reg 	[31:0]div_in_store[0:8] ;
////////////////////////////////////////////////////
wire	[31:0]exp_value[0:8] ; 
assign  exp_value[0] = {!mult_hv[0][31],mult_hv[0][30:0]} ;
assign  exp_value[1] = {!mult_hv[1][31],mult_hv[1][30:0]} ;
assign  exp_value[2] = {!mult_hv[2][31],mult_hv[2][30:0]} ;
assign  exp_value[3] = {!mult_hv[3][31],mult_hv[3][30:0]} ;
assign  exp_value[4] = {!mult_hv[4][31],mult_hv[4][30:0]} ;
assign  exp_value[5] = {!mult_hv[5][31],mult_hv[5][30:0]} ;
assign  exp_value[6] = {!mult_hv[6][31],mult_hv[6][30:0]} ;
assign  exp_value[7] = {!mult_hv[7][31],mult_hv[7][30:0]} ;
assign  exp_value[8] = {!mult_hv[8][31],mult_hv[8][30:0]} ;


//RELU
assign  RELU[0] = (temp_addout[0][31] == 1'b1)?  zero_point_one : one;
assign  RELU[1] = (temp_addout[1][31] == 1'b1)?  zero_point_one : one;
assign  RELU[2] = (temp_addout[2][31] == 1'b1)?  zero_point_one : one;
//---------------------------------------------------------------------


//---------------------------EAT INPUT---------------------------------
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		in_cnt <= 4'b0000;
	end
	else if(in_valid)begin
		in_cnt <= in_cnt + 1 ;
	end
	else begin
		in_cnt <= 4'b0000 ;
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		for(i=0; i < 9; i=i+1)begin
			x_in[i] <= 32'h0000_0000 ;
		end
	end 
	else if(in_valid)begin
		x_in[in_cnt] <=  data_x;
	end
	else begin
		for(i=0; i < 9; i=i+1)begin
			x_in[i] <= x_in[i] ;
		end
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		for(j=0; j < 3 ; j=j+1)begin
			h_in[j] <= 32'h0000_0000 ;
		end
	end 
	else if(in_valid && in_cnt < 3)begin
		h_in[in_cnt] <=  data_h;
	end
	else begin
		for(j=0; j < 9; j=j+1)begin
			h_in[j] <= h_in[j] ;
		end
	end
end


always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		for(k=0; k < 9 ; k=k+1)begin
			u_in[k] <= 32'h0000_0000 ;
		end
	end 
	else if(in_valid)begin
		u_in[in_cnt] <=  weight_u;
	end
	else begin
		for(k=0; k < 9; k=k+1)begin
			u_in[k] <= u_in[k] ;
		end
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		for(l=0; l < 9 ; l=l+1)begin
			v_in[l] <= 32'h0000_0000 ;
		end
	end 
	else if(in_valid)begin
		v_in[in_cnt] <=  weight_v;
	end
	else begin
		for(l=0; l < 9; l=l+1)begin
			v_in[l] <= v_in[l] ;
		end
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		for(m=0; m < 9 ; m=m+1)begin
			w_in[m] <= 32'h0000_0000 ;
		end
	end 
	else if(in_valid)begin
		w_in[in_cnt] <=  weight_w;
	end
	else begin
		for(m=0; m < 9; m=m+1)begin
			w_in[m] <= w_in[m] ;
		end
	end
end

//---------------------------------------------------------------------
//------------------------------IP-------------------------------------
// //Used to compute U_matrix multiple x1, x2, x3 ------
DW_fp_dp3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, 0)
	U1 (					.a(xx[0]), 
							.b(uu[0]), 
							.c(xx[1]),
							.d(uu[1]),
							.e(xx[2]), 
							.f(uu[2]), 
							.rnd(3'b000), 
							.z(u_mult_x), 
							.status(status[1]) );

// //Used to compute W_matrix multiple h1, h2, h3
DW_fp_dp3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, 0)
	W1 (					.a(hh[0]), 
							.b(ww[0]), 
							.c(hh[1]),
							.d(ww[1]),
							.e(hh[2]), 
							.f(ww[2]), 
							.rnd(3'b000), 
							.z(w_mult_h), 
							.status(status[2])  );

	

// //add two 3x1 matrix
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) A1 (.a(u_mult_x), .b(w_mult_h), .rnd(3'b000), .z(add_out));

// //RELU-OP
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M1 (.a(temp_addout[0]), .b(RELU[0]), .rnd(3'b000), .z(new_h[0]));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M2 (.a(temp_addout[1]), .b(RELU[1]), .rnd(3'b000), .z(new_h[1]));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M3 (.a(temp_addout[2]), .b(RELU[2]), .rnd(3'b000), .z(new_h[2]));

// //Used to compute V_matrix multiple h1, h2, h3
DW_fp_dp3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, 0)
	V1 (					.a(hhx[0]), 
							.b(vv[0]), 
							.c(hhx[1]),
							.d(vv[1]),
							.e(hhx[2]), 
							.f(vv[2]), 
							.rnd(3'b000), 
							.z(v_mult_h), 
							.status(status[3])  );
//EXP_IP
DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) EX0 (.a(exp_in), .z(exp_out));
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) A2 (.a(exp_out), .b(one), .rnd(3'b000), .z(div_in));
//DIV_TP
DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance, 0) DIV0 (.a(one), .b(div_div), .rnd(3'b000), .z(div_ans));
//----------------------FSM-------------------------------------------
always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)  current_state <= IDLE;
    else current_state <= next_state;
end
always@(*)
begin
    case(current_state)
    IDLE : begin
        if(!in_valid && in_cnt > 8 ) next_state = STATE1;
        else         next_state = IDLE;
    end
    STATE1 :begin
		if(cont_u == 6) next_state = STATE2;
		else		   next_state = STATE1;      
    end
	STATE2 : begin
		next_state = STATE3; 
	end

	STATE3 : begin
		if(cont_u == 6) next_state = STATE4;
		else		   next_state = STATE3;  
	end
	STATE4 : begin
		next_state = STATE5 ; 
	end
	STATE5 : begin
		if(cont_u == 6) next_state = STATE6;
		else		   next_state = STATE5;  
	end
	STATE6 : begin
		next_state = STATE7 ; 
	end
	STATE7 : begin
		if(cont_v1 == 6) next_state = STATE8;
		else		   next_state = STATE7;  
	end
	STATE8 : begin
		if(cont_v2 == 6) next_state = STATE9;
		else		   next_state = STATE8;  
	end
	STATE9 : begin
		if(cont_v3 == 6) next_state = STATE10;
		else		   next_state = STATE9;  
	end
	STATE10 : begin
		if(cont_u == 8) next_state = STATE11;
		else		  	  next_state = STATE10; 
	end
	STATE11 : begin
		if(cont_x == 8 )	next_state = STATE12;
		else		  	  	next_state = STATE11; 
	end
    STATE12 : begin
		next_state = IDLE ;
	end
    default : next_state = current_state;
    endcase
end
//---------------------------------------------------------------------
//count_total clk
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) count_total_clk <= 6'b000000;
	else if(in_valid) count_total_clk <= 6'b000000;
	else begin
		count_total_clk <= count_total_clk + 1 ;
	end
end
//OP1------------------------------------------------------------------
always@(*)begin  //CONTROL XX 
	case(current_state)
	IDLE : begin
		xx[0] = 32'h0000_0000 ;
		xx[1] = 32'h0000_0000 ;
		xx[2] = 32'h0000_0000 ;
	end
	STATE1 : begin
		xx[0] = x_in[cont_x] ; 
		xx[1] = x_in[cont_x + 1] ;
		xx[2] = x_in[cont_x + 2] ;
	end
	
	STATE3 : begin
		xx[0] = x_in[cont_x] ; 
		xx[1] = x_in[cont_x + 1] ;
		xx[2] = x_in[cont_x + 2] ;
	end

	STATE5 : begin
		xx[0] = x_in[cont_x] ; 
		xx[1] = x_in[cont_x + 1] ;
		xx[2] = x_in[cont_x + 2] ;
	end
	

	default : begin
		xx[0] = 32'h0000_0000 ;
		xx[1] = 32'h0000_0000 ;
		xx[2] = 32'h0000_0000 ;
	end
	endcase
end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		cont_x <= 5'b00000;
	end
	else begin
		case(current_state)
		IDLE : begin
			cont_x <= 5'b00000;
		end
		STATE2 : begin
			cont_x <= 5'b00011;
		end
		STATE4 : begin
			cont_x <= 5'b00110;
		end
		STATE6 : begin
			cont_x <= 5'b00000;
		end
		STATE7: begin
			cont_x <= cont_x + 1;
		end
		STATE8: begin
			cont_x <= cont_x + 1;
		end
		STATE9: begin
			cont_x <= cont_x + 1;
		end
		STATE10: begin
			cont_x <= 5'b00000;
		end
		STATE11: begin
			cont_x <= cont_x + 1;
		end
		STATE12 : begin
			cont_x <= 5'b00000;
		end 
		default :;
		endcase
	end
end

always@(*)begin  //CONTROL UU
	case(current_state)
	IDLE : begin
		uu[0] = 32'h0000_0000 ;
		uu[1] = 32'h0000_0000 ;
		uu[2] = 32'h0000_0000 ;
	end
	STATE1 : begin
		uu[0] = u_in[cont_u] ; 
		uu[1] = u_in[cont_u + 1] ;
		uu[2] = u_in[cont_u + 2] ;
	end
	STATE3 : begin
		uu[0] = u_in[cont_u] ; 
		uu[1] = u_in[cont_u + 1] ;
		uu[2] = u_in[cont_u + 2] ;
	end
	STATE5 : begin
		uu[0] = u_in[cont_u] ; 
		uu[1] = u_in[cont_u + 1] ;
		uu[2] = u_in[cont_u + 2] ;
	end

	default : begin
		uu[0] = 32'h0000_0000 ;
		uu[1] = 32'h0000_0000 ;
		uu[2] = 32'h0000_0000 ;
	end
	endcase	
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		cont_u <= 5'b00000;
	end
	else begin
		case(current_state)
		IDLE : begin
			cont_u <= 5'b00000;
		end
		STATE1 : begin
			cont_u <= cont_u + 3 ;
		end
		STATE2 : begin
			cont_u <= 5'b00000;
		end
		STATE3 : begin
			cont_u <= cont_u + 3 ;
		end
		STATE4 : begin
			cont_u <= 5'b00000;
		end
		STATE5 : begin
			cont_u <= cont_u + 3 ;
		end
		STATE6 : begin
			cont_u <= 5'b00000;
		end
		STATE10 : begin
			cont_u <= cont_u + 1 ;
		end
		STATE11 : begin
			cont_u <= 5'b00000 ;
		end
		default:;
		endcase
	end
end

always@(*)begin //CONTROL HH
	case(current_state)
	IDLE : begin
		hh[0] = 32'h0000_0000 ;
		hh[1] = 32'h0000_0000 ;
		hh[2] = 32'h0000_0000 ;
	end
	STATE1 : begin
		hh[0] = h_in[0] ; 
		hh[1] = h_in[1] ;
		hh[2] = h_in[2] ;
	end
	STATE3 : begin
		hh[0] = hh1[0] ; 
		hh[1] = hh1[1] ;
		hh[2] = hh1[2] ;
	end
	STATE5 : begin
		hh[0] = hh2[0] ; 
		hh[1] = hh2[1] ;
		hh[2] = hh2[2] ;
	end
	
	default : begin
		hh[0] = 32'h0000_0000 ;
		hh[1] = 32'h0000_0000 ;
		hh[2] = 32'h0000_0000 ;
		
	end
	endcase
	
end

always@(*)begin //CONTROL WW
	case(current_state)
	IDLE : begin
		ww[0] = 32'h0000_0000 ;
		ww[1] = 32'h0000_0000 ;
		ww[2] = 32'h0000_0000 ;
	end
	STATE1 : begin
		ww[0] = w_in[cont_u] ; 
		ww[1] = w_in[cont_u + 1] ;
		ww[2] = w_in[cont_u + 2] ;
	end
	STATE3 : begin
		ww[0] = w_in[cont_u] ; 
		ww[1] = w_in[cont_u + 1] ;
		ww[2] = w_in[cont_u + 2] ;
	end
	STATE5 : begin
		ww[0] = w_in[cont_u] ; 
		ww[1] = w_in[cont_u + 1] ;
		ww[2] = w_in[cont_u + 2] ;
	end
	
	default : begin
		ww[0] = 32'h0000_0000 ;
		ww[1] = 32'h0000_0000 ;
		ww[2] = 32'h0000_0000 ;
		
	end
	endcase
end
//store add value
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		temp_addout[0] <= 32'h0000_0000 ;
		temp_addout[1] <= 32'h0000_0000 ;
		temp_addout[2] <= 32'h0000_0000 ;
	end
	else begin
		case(current_state) 
		IDLE :begin
			temp_addout[0] <= 32'h0000_0000 ;
			temp_addout[1] <= 32'h0000_0000 ;
			temp_addout[2] <= 32'h0000_0000 ;
		end
		STATE1 : begin
			temp_addout[cont_temp] <= add_out ;
		end
		STATE3 : begin
			temp_addout[cont_temp] <= add_out ;
		end
		STATE5 : begin
			temp_addout[cont_temp] <= add_out ;
		end
		default:;
		endcase
	end
end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		cont_temp <= 5'b00000 ;
	end
	else begin
		case(current_state) 
		IDLE :begin
			cont_temp <= 3'b000 ;
		end
		STATE1 : begin
			cont_temp <= cont_temp + 1;
		end
		STATE2: begin
			cont_temp <= 3'b000 ;
		end
		STATE3 : begin
			cont_temp <= cont_temp + 1;
		end
		STATE4: begin
			cont_temp <= 3'b000 ;
		end
		STATE5 : begin
			cont_temp <= cont_temp + 1;
		end
		STATE6: begin
			cont_temp <= 3'b000 ;
		end
		default:;
		endcase
	end
end
//---------------------------------------------------------------------
//compute hh1, hh2, hh3
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) begin
		hh1[0] <= 32'h00000000;
		hh1[1] <= 32'h00000000;
		hh1[2] <= 32'h00000000;
	end
	else begin
		case(current_state)
		IDLE : begin
			hh1[0] <= 32'h00000000;
			hh1[1] <= 32'h00000000;
			hh1[2] <= 32'h00000000;
		end
		STATE2 : begin
			hh1[0] <= new_h[0];
			hh1[1] <= new_h[1];
			hh1[2] <= new_h[2];
		end
		
		default:;
		endcase
	end

end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) begin
		hh2[0] <= 32'h00000000;
		hh2[1] <= 32'h00000000;
		hh2[2] <= 32'h00000000;
	end
	else begin
		case(current_state)
		IDLE : begin
			hh2[0] <= 32'h00000000;
			hh2[1] <= 32'h00000000;
			hh2[2] <= 32'h00000000;
		end
		STATE4 : begin
			hh2[0] <= new_h[0];
			hh2[1] <= new_h[1];
			hh2[2] <= new_h[2];
		end
		
		default:;
		endcase
	end

end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) begin
		hh3[0] <= 32'h00000000;
		hh3[1] <= 32'h00000000;
		hh3[2] <= 32'h00000000;
	end
	else begin
		case(current_state)
		IDLE : begin
			hh3[0] <= 32'h00000000;
			hh3[1] <= 32'h00000000;
			hh3[2] <= 32'h00000000;
		end
		STATE6 : begin
			hh3[0] <= new_h[0];
			hh3[1] <= new_h[1];
			hh3[2] <= new_h[2];
		end
		
		default:;
		endcase
	end

end
//COMPUTE V_matrix multiple hh1, hh2, hh3-------------------------------------------------------
always@(*)begin
	case(current_state)
	IDLE : begin
		hhx[0] = 32'h0000_0000 ;
		hhx[1] = 32'h0000_0000 ;
		hhx[2] = 32'h0000_0000 ;
	end
	STATE7 : begin
		hhx[0] = hh1[0] ;
		hhx[1] = hh1[1] ;
		hhx[2] = hh1[2] ;
	end
	STATE8 : begin
		hhx[0] = hh2[0] ;
		hhx[1] = hh2[1] ;
		hhx[2] = hh2[2] ;
	end
	STATE9 : begin
		hhx[0] = hh3[0] ;
		hhx[1] = hh3[1] ;
		hhx[2] = hh3[2] ;
	end
	default : begin
		hhx[0] = 32'h0000_0000 ;
		hhx[1] = 32'h0000_0000 ;
		hhx[2] = 32'h0000_0000 ;
	end
	endcase
end
always@(*)begin
	case(current_state)
	IDLE : begin
		vv[0] = 32'h0000_0000 ;
		vv[1] = 32'h0000_0000 ;
		vv[2] = 32'h0000_0000 ;
	end
	STATE7 : begin
		vv[0] = v_in[cont_v1] ;
		vv[1] = v_in[cont_v1 + 1] ;
		vv[2] = v_in[cont_v1 + 2] ;
	end
	STATE8 : begin
		vv[0] = v_in[cont_v2];
		vv[1] = v_in[cont_v2 + 1] ;
		vv[2] = v_in[cont_v2 + 2];
	end
	STATE9 : begin
		vv[0] = v_in[cont_v3];
		vv[1] = v_in[cont_v3 + 1] ;
		vv[2] = v_in[cont_v3 + 2];
	end
	default : begin
		vv[0] = 32'h0000_0000 ;
		vv[1] = 32'h0000_0000 ;
		vv[2] = 32'h0000_0000 ;
	end
	endcase
end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) cont_v1 <= 5'b00000;
	else begin
		case(current_state)
		IDLE : begin
			cont_v1 <= 5'b00000;
		end
		STATE7 : begin
			cont_v1 <= cont_v1 + 3 ;
		end
		default:;
		endcase
	end
end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) cont_v2 <= 5'b00000;
	else begin
		case(current_state)
		IDLE : begin
			cont_v2 <= 5'b00000;
		end
		STATE8 : begin
			cont_v2 <= cont_v2 + 3 ;
		end
		default:;
		endcase
	end
end
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) cont_v3 <= 5'b00000;
	else begin
		case(current_state)
		IDLE : begin
			cont_v3 <= 5'b00000;
		end
		STATE9 : begin
			cont_v3 <= cont_v3 + 3 ;
		end
		default:;
		endcase
	end
end



//STORE V_matrix mult h1,h2,h3
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		mult_hv[0] <= 32'h0000_0000;
		mult_hv[1] <= 32'h0000_0000;
		mult_hv[2] <= 32'h0000_0000;
		mult_hv[3] <= 32'h0000_0000;
		mult_hv[4] <= 32'h0000_0000;
		mult_hv[5] <= 32'h0000_0000;
		mult_hv[6] <= 32'h0000_0000;
		mult_hv[7] <= 32'h0000_0000;
		mult_hv[8] <= 32'h0000_0000;
	end
	else begin
		case(current_state)
		IDLE : begin
			mult_hv[0] <= 32'h0000_0000;
			mult_hv[1] <= 32'h0000_0000;
			mult_hv[2] <= 32'h0000_0000;
			mult_hv[3] <= 32'h0000_0000;
			mult_hv[4] <= 32'h0000_0000;
			mult_hv[5] <= 32'h0000_0000;
			mult_hv[6] <= 32'h0000_0000;
			mult_hv[7] <= 32'h0000_0000;
			mult_hv[8] <= 32'h0000_0000;
		
		end
		STATE7 : begin
			mult_hv[cont_x] <= v_mult_h;
		end
		STATE8 : begin
			mult_hv[cont_x] <= v_mult_h;
		end
		STATE9 : begin
			mult_hv[cont_x] <= v_mult_h;
		end
		default:;
		endcase
	end
end

always@(*)begin
	case(current_state)
	IDLE : begin
		exp_in <= 32'h00000000;
	end
	STATE10 : begin
		exp_in <= exp_value[cont_u];
	end 
	default : begin
		exp_in <= 32'h00000000;
	end
	endcase
end

always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		div_in_store[0] <= 32'h00000000;
		div_in_store[1] <= 32'h00000000;
		div_in_store[2] <= 32'h00000000;
		div_in_store[3] <= 32'h00000000;
		div_in_store[4] <= 32'h00000000;
		div_in_store[5] <= 32'h00000000;
		div_in_store[6] <= 32'h00000000;
		div_in_store[7] <= 32'h00000000;
		div_in_store[8] <= 32'h00000000;

	end
	else begin
		case(current_state)
		IDLE : begin
			div_in_store[0] <= 32'h00000000;
			div_in_store[1] <= 32'h00000000;
			div_in_store[2] <= 32'h00000000;
			div_in_store[3] <= 32'h00000000;
			div_in_store[4] <= 32'h00000000;
			div_in_store[5] <= 32'h00000000;
			div_in_store[6] <= 32'h00000000;
			div_in_store[7] <= 32'h00000000;
			div_in_store[8] <= 32'h00000000;
		end
		STATE10 : begin
			div_in_store[cont_u] <= div_in;
		end
		endcase
	end
end


always@(*)begin
	case(current_state)
	IDLE : begin
		div_div <= 32'h00000000;
	end
	STATE11 : begin
		div_div <= div_in_store[cont_x];
	end
	default: begin
		div_div <= 32'h00000000;
	end
	endcase
end

//STORE THE FINAL ANSWER
// always@(posedge clk or negedge rst_n)begin
// 	if(!rst_n) begin
// 		final_ans[0] <= 32'h00000000;
// 		final_ans[1] <= 32'h00000000;
// 		final_ans[2] <= 32'h00000000;
// 		final_ans[3] <= 32'h00000000;
// 		final_ans[4] <= 32'h00000000;
// 		final_ans[5] <= 32'h00000000;
// 		final_ans[6] <= 32'h00000000;
// 		final_ans[7] <= 32'h00000000;
// 	end
// 	else begin
// 		case(current_state)
// 		IDLE : begin
// 			final_ans[0] <= 32'h00000000;
// 			final_ans[1] <= 32'h00000000;
// 			final_ans[2] <= 32'h00000000;
// 			final_ans[3] <= 32'h00000000;
// 			final_ans[4] <= 32'h00000000;
// 			final_ans[5] <= 32'h00000000;
// 			final_ans[6] <= 32'h00000000;
// 			final_ans[7] <= 32'h00000000;
// 		end
// 		STATE11 : begin
// 			final_ans[co] <= 32'h00000000;
			
// 		end


// 		endcase

// 	end
// end

//Output 
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		out_valid <= 1'b0;
	end
	else begin
		case(current_state)
		IDLE : begin
			out_valid <= 1'b0;
		end
		STATE11 : begin
			 out_valid <= 1'b1;
		end
		STATE12 : begin
			out_valid <= 1'b0;
		end
		default: begin
			out_valid <= 1'b0;
		end
		endcase
	end
	
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		out <= 32'h0000_0000;
	end
	else begin
		case(current_state)
		IDLE : begin
			out <= 32'h0000_0000;
		end
		STATE11 : begin
			out <= div_ans;
			
		end

		default : begin
			out <= 32'h0000_0000;
		end

		endcase
	end
	
end






















endmodule
