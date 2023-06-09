//synopsys translate_off
`include "DW_div.v"
`include "DW_div_seq.v"
`include "DW_div_pipe.v"
//synopsys translate_on

module TRIANGLE(
    clk,
    rst_n,
    in_valid,
    in_length,
    out_cos,
    out_valid,
    out_tri
);
input wire clk, rst_n, in_valid;
input wire [7:0] in_length;

output reg out_valid;
output reg [15:0] out_cos;
output reg [1:0] out_tri;


reg 	      [7:0]length[0:2];
reg		      [3:0]cnt_in;
reg			  [4:0]current_state,next_state;	


//parameter
parameter IDLE = 4'b0000;
parameter COMPUTE  = 4'b0001;
parameter COMPUTE2 = 4'b0010;
parameter COMPUTE3 = 4'b0011;
parameter COMPUTE4 = 4'b0100;

parameter inst_a_width = 31;
parameter inst_b_width = 31;
parameter inst_tc_mode = 1;
parameter inst_rem_mode = 0;
parameter inst_num_stages = 10;
parameter inst_stall_mode = 1;
parameter inst_rst_mode = 1;
parameter inst_op_iso_mode = 0;




integer i;



reg			  [4:0]active ;
wire  signed  [30:0]UP[0:2];
wire          [30:0]DOWN[0:2];
reg   signed  [30:0]a[0:2];
reg		      [30:0]b[0:2];
wire  signed  [30:0]ans[0:2];
wire	[30:0]ans1[0:2];
reg     [30:0]divide[0:2] ;
//reg		[15:0]b[0:2];
wire	c[0:2];
wire    en;
reg		[7:0]cnt_2, cnt_3;
// reg     [3:0]initial_result1[0:6];
// reg     [3:0]initial_result2[0:6];
// reg     [3:0]initial_result3[0:6];

// wire	[99:0]floating_point[0:2];
// wire	[99:0]new_floating_point[0:2];
// reg		[12:0]result[0:2];
wire	[2:0]sign[0:2];
reg 	[1:0]otri;
reg     [3:0]cnt_out,cnt_out2;


assign UP[0] =   length[1]*length[1] + length[2]*length[2] - length[0]*length[0];
assign UP[1] =   length[0]*length[0] + length[2]*length[2] - length[1]*length[1];
assign UP[2] =   length[0]*length[0] + length[1]*length[1] - length[2]*length[2]; 
assign DOWN[0] = 2*length[1]*length[2];
assign DOWN[1] = 2*length[0]*length[2];
assign DOWN[2] = 2*length[0]*length[1];
//DIV
DW_div_pipe #(inst_a_width , inst_b_width, inst_tc_mode , inst_rem_mode , inst_num_stages , inst_stall_mode , inst_rst_mode , inst_op_iso_mode )
	D1(.clk(clk), .rst_n(rst_n), .en(1'b1), .a(a[0]), .b(b[0]), .quotient(ans[0]), .remainder(ans1[0]), .divide_by_0(c[0]));

DW_div_pipe #(inst_a_width , inst_b_width, inst_tc_mode , inst_rem_mode , inst_num_stages , inst_stall_mode , inst_rst_mode , inst_op_iso_mode )
	D2(.clk(clk), .rst_n(rst_n), .en(1'b1), .a(a[1]), .b(b[1]), .quotient(ans[1]), .remainder(ans1[1]), .divide_by_0(c[1]));

DW_div_pipe #(inst_a_width , inst_b_width, inst_tc_mode , inst_rem_mode , inst_num_stages , inst_stall_mode , inst_rst_mode , inst_op_iso_mode )
	D3(.clk(clk), .rst_n(rst_n), .en(1'b1), .a(a[2]), .b(b[2]), .quotient(ans[2]), .remainder(ans1[2]), .divide_by_0(c[2]));

// assign floating_point[0] = divide[0] / 10**9;
// assign floating_point[1] = divide[1] / 10**9;
// assign floating_point[2] = divide[2] / 10**9;

// assign new_floating_point[0] = (floating_point[0] > 8192) ? floating_point[0] /10 : floating_point[0];
// assign new_floating_point[1] = (floating_point[1] > 8192) ? floating_point[1] /10 : floating_point[1];
// assign new_floating_point[2] = (floating_point[2] > 8192) ? floating_point[2] /10 : floating_point[2];

assign sign[0] = (UP[0] < 0 ) ? 3'b100 : 3'b000;
assign sign[1] = (UP[1] < 0 ) ? 3'b100 : 3'b000;
assign sign[2] = (UP[2] < 0 ) ? 3'b100 : 3'b000;

always@(*)begin
	if(UP[0]==0 || UP[1]==0 || UP[2]==0)	otri = 2'b11 ;
	else if(sign[0] == 3'b100 || sign[1] == 3'b100 || sign[2] == 3'b100) otri = 2'b01 ;
	else otri = 2'b00 ;
end


always@(*)begin
	case(current_state)
	IDLE : begin
		a[0] = 0;
		a[1] = 0;
		a[2] = 0;
	end	
	COMPUTE : begin
		a[0] = UP[0] << 13;
		a[1] = UP[1] << 13;
		a[2] = UP[2] << 13;

	end
	// COMPUTE2 : begin
	// 	a[0] = new_floating_point[0];
	// 	a[1] = new_floating_point[1];
	// 	a[2] = new_floating_point[2];
	
	// end 
	// COMPUTE3 : begin
	// 	a[0] = ans[0];
	// 	a[1] = ans[1];
	// 	a[2] = ans[2];
	
	// end
	default : begin
		a[0] = 0;
		a[1] = 0;
		a[2] = 0;
	end
	endcase
end 

always@(*)begin
	case(current_state)
	IDLE : begin
		b[0] = 2;
		b[1] = 2;
		b[2] = 2;
	end
	COMPUTE : begin
		b[0] = DOWN[0];
		b[1] = DOWN[1];
		b[2] = DOWN[2];
	end
	COMPUTE2: begin
		b[0] = 2;
		b[1] = 2;
		b[2] = 2;
	end
	default : begin
		b[0] = 2;
		b[1] = 2;
		b[2] = 2;
	end
	
	endcase
end

always@(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
	   	divide[0] <= 0; 
		divide[1] <= 0;
		divide[2] <= 0;
	end
	else begin
	case(current_state)
	IDLE : begin
	   	divide[0] <= 0; 
		divide[1] <= 0;
		divide[2] <= 0;
	end
	COMPUTE2 : begin
		if(cnt_2 == 2 )begin
			divide[0] <= ans[0]; 
			divide[1] <= ans[1];
			divide[2] <= ans[2];
		end
	end
	
	default:; 
	endcase
	end
end


// always@(posedge clk or negedge rst_n)begin
//  	if(!rst_n)begin
// 		result[0] <= 0;
//  		result[1] <= 0;
//  		result[2] <= 0;
// 	end
// 	else begin
// 		case(current_state)
// 		IDLE : begin
// 			result[0] <= 0;
// 			result[1] <= 0;
// 			result[2] <= 0;
// 		end
// 		COMPUTE2 : begin
// 			result[0] <= new_floating_point[0][12:0];
//  			result[1] <= new_floating_point[1][12:0];
//  			result[2] <= new_floating_point[2][12:0];
// 		end
// 		default:;
// 		endcase
// 	end
//end
///COUNTER///////////////////////////////////
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)   active <= 0;
	else begin
	case(current_state)
	IDLE : active <=0 ;
	COMPUTE : active <= active + 1;
	
	default:; 
	endcase
	end
end


always@(posedge clk or negedge rst_n) begin
	if(!rst_n)   cnt_2 <= 0;
	else begin
	case(current_state)
	IDLE : 	   cnt_2 <=0 ;
	COMPUTE2 : cnt_2 <= cnt_2 + 1;
	
	default:; 
	endcase
	end
end

always@(posedge clk or negedge rst_n) begin
	if(!rst_n)   cnt_3 <= 0;
	else begin
	case(current_state)
	IDLE : 	   cnt_3 <=0 ;
	COMPUTE3 : cnt_3 <= cnt_3 + 1;
	
	default:; 
	endcase
	end
end



// always@(posedge clk or negedge rst_n)begin
// 	if(!rst_n)begin
// 		for(i=0;i<7;i=i+1)begin
// 			initial_result1[i] <= 0;
// 			initial_result2[i] <= 0;
// 			initial_result3[i] <= 0;
// 		end
// 	end
// 	else begin
// 		case(current_state)
// 		IDLE : begin
// 			for(i=0;i<7;i=i+1)begin
// 					initial_result1[i] <= 0;
// 					initial_result2[i] <= 0;
// 					initial_result3[i] <= 0;
// 			end
// 		end
// 		COMPUTE2 : begin
// 			case(cnt_2)
// 				12 : begin
// 					initial_result1[0] <= ans[0];
// 					initial_result2[0] <= ans[1];
// 					initial_result3[0] <= ans[2];
// 				end
// 				22 : begin
// 					initial_result1[1] <= ans[0];
// 					initial_result2[1] <= ans[1];
// 					initial_result3[1] <= ans[2];
// 				end
// 				32 : begin
// 					initial_result1[2] <= ans[0];
// 					initial_result2[2] <= ans[1];
// 					initial_result3[2] <= ans[2];
// 				end
// 				42 : begin
// 					initial_result1[3] <= ans[0];
// 					initial_result2[3] <= ans[1];
// 					initial_result3[3] <= ans[2];
// 				end
// 				52 : begin
// 					initial_result1[4] <= ans[0];
// 					initial_result2[4] <= ans[1];
// 					initial_result3[4] <= ans[2];
// 				end
// 				62 : begin
// 					initial_result1[5] <= ans[0];
// 					initial_result2[5] <= ans[1];
// 					initial_result3[5] <= ans[2];
// 				end
// 				72 : begin
// 					initial_result1[6] <= ans[0];
// 					initial_result2[6] <= ans[1];
// 					initial_result3[6] <= ans[2];
// 				end
// 			default:;
// 			endcase
// 		end
// 		endcase
// 	end
// end

////////////////////////////////////////////////////




always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		length[0] <= 0;
		length[1] <= 0;
		length[2] <= 0;
	end
	else begin
	if(in_valid ) length[cnt_in] <= in_length;
	else begin
		length[0] <= length[0];
		length[1] <= length[1];
		length[2] <= length[2];
	end
	end
end


always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		cnt_in <= 0;
	end
	else begin
	if(in_valid) cnt_in <= cnt_in + 1;
	else         cnt_in <= 0 ;	
	end
end

	

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)  current_state <= IDLE;
	else 	    current_state <= next_state;
end	

always@(*)begin
	case(current_state)
	IDLE : begin
		if(cnt_in == 3 )	next_state = COMPUTE;
		else                next_state = IDLE;
	end
	COMPUTE : begin
		if(active == 9 ) next_state = COMPUTE2 ;
		else			 next_state = COMPUTE ; 
		
	end
	COMPUTE2 : begin
		if(cnt_2 == 3) next_state = COMPUTE3 ;
		else 			next_state = COMPUTE2 ;
	end
	COMPUTE3 : begin
		if(cnt_out2 == 2 )next_state = IDLE;
		else 	next_state = COMPUTE3 ;
	end
	default : next_state = current_state;
	endcase
end

always@(posedge clk or negedge rst_n) begin
	if(!rst_n)   cnt_out <= 0;
	else begin
	case(current_state)
	IDLE : cnt_out <=0 ;
	COMPUTE3 : cnt_out <= cnt_out + 1;
	
	default:; 
	endcase
	end
end

always@(posedge clk or negedge rst_n) begin
	if(!rst_n)   cnt_out2 <= 0;
	else begin
	case(current_state)
	IDLE : cnt_out2 <=0 ;
	COMPUTE3 : cnt_out2 <= cnt_out ;
	
	default:; 
	endcase
	end
end


always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		out_valid <= 0;
	end	
	else begin
		case(current_state)
		IDLE : out_valid <= 0;
		COMPUTE3 : begin
			if(cnt_out < 3 ) out_valid <= 1;
			else 			 out_valid <= 0;
		
		end
		
		
		default :out_valid <= 0;
		endcase
	
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		out_cos   <= 0;
	end	
	else begin
		case(current_state)
		IDLE : out_cos <= 0;
		COMPUTE3 : begin
			if( cnt_out2 < 2) out_cos <= divide[cnt_out];
			else out_cos <= 0;
			//out_cos <= 16'b000_1000_0000_0000_0;
		end
		
		default : out_cos <= 0;
		endcase
	
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		out_tri   <= 0;
	end	
	else begin
		case(current_state)
		IDLE : out_tri <= 0;
		COMPUTE3 : begin
			if(cnt_out == 0) out_tri <= otri;
			else			 out_tri <= 0;
		end
		
		default : out_tri <= 0;
		endcase
	
	end
end




















   

endmodule
