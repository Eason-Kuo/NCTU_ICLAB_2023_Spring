module QUEEN(
    //Input Port
    clk,
    rst_n,

    in_valid,
    col,
    row,

    in_valid_num,
    in_num,

    out_valid,
    out,

    );
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION
//---------------------------------------------------------------------
input               clk, rst_n, in_valid,in_valid_num;
input       [3:0]   col,row;
input       [2:0]   in_num;

output reg          out_valid;
output reg  [3:0]   out;
//---------------------------------------------------------------------
//   WIRE AND REG DECLARATION
//---------------------------------------------------------------------
reg [3:0] current_state, next_state;
reg [3:0] input_counter,queen_num;
reg [3:0] row_array[0:11];
reg [3:0] col_array[0:11];
reg [3:0] current_row;
reg [3:0] current_col;
reg row_end_flag;
reg [3:0] array_pointer;
reg [3:0] sort_counter;
reg [3:0] sort_array[0:11];
reg [3:0] out_counter;
reg [11:0]row_empty;
reg row_empty_flag;
reg [11:0]col_empty;
reg col_empty_flag;
reg map[0:11][0:11];
reg [11:0] queen;
reg black;
//---------------------------------------------------------------------
//   PARAMETER DECLARATION
//---------------------------------------------------------------------
integer i,j,r,k,m,n;
parameter IDLE = 4'd0;
parameter Forward_Find = 4'd1;
parameter Forward_Process_Data = 4'd2;
parameter Back_To_Previous = 4'd3;
parameter Sort = 4'd4;
parameter OUT = 4'd5;
//---------------------------------------------------------------------
//	 Design
//---------------------------------------------------------------------

//FSM current state assignment
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)	current_state <= IDLE;
	else 		current_state <= next_state;
end

//FSM next state assignment
always@(*) begin
	case(current_state)
		IDLE: begin
			if ((in_valid==1)||(input_counter<queen_num-1))begin
				next_state = IDLE;
			end
			else begin
				next_state = Forward_Find;
			end
		end
		Forward_Find:begin
			if(current_row==11 && black==1)begin
				next_state = Back_To_Previous;
			end
			else if(black==0)begin
				next_state = Forward_Process_Data;
			end
			else if(queen_num==12)begin
				next_state = Sort;
			end
			else begin
				next_state = Forward_Find;
			end
		end
		Forward_Process_Data: begin
			next_state = Forward_Find;
		end
		
		Back_To_Previous:begin
			next_state = Forward_Find;
		end
		Sort:begin
			if(sort_counter==12)begin
				next_state = OUT;
			end
			else begin
				next_state = Sort;
			end
		end
		OUT:begin
			if(out_counter==11)begin
				next_state = IDLE;
			end
			else begin
				next_state = OUT;
			end
		end
		default: begin
			next_state = IDLE;
		end
	
	endcase
end 
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        input_counter<=0; 
		queen_num<=0;	
    end 	
	else begin
	    case(current_state)
            IDLE: begin
		        if(in_valid==1)begin
					input_counter<=input_counter+1;
				end
				else begin
					input_counter<=input_counter;
				end
				if(in_valid_num==1)begin
					queen_num<=in_num;
				end
				else begin
					queen_num<=queen_num;
				end
		    end
			Forward_Process_Data: begin
				queen_num<=queen_num+1;
			end
			Back_To_Previous:begin
				if(row_end_flag==1)begin
					queen_num<=queen_num-2;
				end
				else begin
					queen_num<=queen_num-1;
				end
				
			end
			OUT:begin
				input_counter<=0; 
				queen_num<=0;
			end
            default:begin
				input_counter<=input_counter; 
				queen_num<=queen_num;
            end		
		endcase
	end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0;i<12;i=i+1)begin
			row_array[i]<=12;
			col_array[i]<=12;
		end
    end 	
	else begin
	    case(current_state)
            IDLE: begin
		        if(in_valid==1)begin
					row_array[input_counter]<=row;
					col_array[input_counter]<=col;
				end
		    end
			Forward_Process_Data: begin
				row_array[queen_num]<=current_row;
				col_array[queen_num]<=current_col;
			end
			Back_To_Previous:begin
				if(row_end_flag==1)begin
					row_array[queen_num-2]<=12;
					col_array[queen_num-2]<=12;
					row_array[queen_num-1]<=12;
					col_array[queen_num-1]<=12;
				end
				else begin
					row_array[queen_num-1]<=12;
					col_array[queen_num-1]<=12;
				end
				
			end
			OUT:begin
				for(i=0;i<12;i=i+1)begin
					row_array[i]<=12;
					col_array[i]<=12;
				end
			end
            default:begin
				for(i=0;i<12;i=i+1)begin
					row_array[i]<=row_array[i];
					col_array[i]<=col_array[i];
				end
            end		
		endcase
	end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
		current_row<=0;
		current_col<=0;
		row_end_flag<=0;
    end 	
	else begin
	    case(current_state)
			Forward_Find:begin
				if(col_empty_flag==1)begin
					current_row<=0;
					current_col<=current_col+1;
				end
				else if(black==1)begin
					
					if(current_row==11)begin
						if(row_array[queen_num-1]+1==12)begin
							current_row<=row_array[queen_num-2]+1;
							current_col<=col_array[queen_num-2];
							row_end_flag<=1;
						end
						else begin
							current_row<=row_array[queen_num-1]+1;
							current_col<=col_array[queen_num-1];
							row_end_flag<=0;
						end
					end
					else begin
						current_row<=current_row+1;
						current_col<=current_col;
					end
				end
				else if(black==0)begin
					current_row<=current_row;
					current_col<=current_col;
				end
				
			end
			Forward_Process_Data: begin
				row_end_flag<=0;
				array_pointer<=0;
				current_row<=0;
				current_col<=current_col+1;
			end
			Back_To_Previous:begin
				// array_pointer<=0;
				// if(row_array[queen_num-1]==11)begin
					
					// row_end_flag<=1;
				// end
				// else begin
					// current_row<=row_array[queen_num-1]+1;
					// current_col<=col_array[queen_num-1];
					// row_end_flag<=0;
				// end
				row_end_flag<=0;
			end
			OUT:begin
				row_end_flag<=0;
				array_pointer<=0;
				current_row<=0;
				current_col<=0;
			end
            default:begin
				row_end_flag<=row_end_flag;
				array_pointer<=array_pointer;
				current_row<=current_row;
				current_col<=current_col;
            end		
		endcase
	end
end

always @(*) begin
	for(k=0;k<12;k=k+1)begin
		if(k<queen_num)	begin
			if(current_col==col_array[k])begin
				queen[k]=1;
			end
			else if(current_row==row_array[k])begin
				
				queen[k]=1;
			end
			else if(current_col>col_array[k] && current_row>row_array[k] && 
					current_col-col_array[k]==current_row-row_array[k])begin
				queen[k]=1;
			end
			else if(current_col>col_array[k] && current_row<row_array[k] &&
					current_col-col_array[k]==row_array[k]-current_row)begin
					
				queen[k]=1;
			end
			else if(current_col<col_array[k] && current_row>row_array[k] &&
					col_array[k]-current_col==current_row-row_array[k])begin
				queen[k]=1;
			end
			else if(current_col<col_array[k] && current_row<row_array[k] &&
					col_array[k]-current_col==row_array[k]-current_row)begin
				queen[k]=1;
			end
			else begin
				queen[k]=0;
			end
		end
		else begin
			queen[k]=0;
		end
	end
	black = |queen;

end
//sort
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0;i<12;i=i+1)begin
			sort_array[i]<=0;
		end
		sort_counter<=0;
    end 	
	else begin
	    case(current_state)
            Sort: begin
		        sort_counter<=sort_counter+1;
				for(i=0;i<12;i=i+1)begin
					if(col_array[i]==sort_counter)
						sort_array[sort_counter]<=row_array[i];
				end
		    end
			IDLE:begin
				sort_counter<=0;
				for(i=0;i<12;i=i+1)begin
					sort_array[i]<=0;
				end
			end
            default:;	
		endcase
	end
end


always@(*)begin
	
	if(0<queen_num)begin
		if(col_array[0]==current_col)	col_empty[0]=1;
		else							col_empty[0]=0;
	end
	else begin
		col_empty[0]=0;
	end
	
	if(1<queen_num)begin
		if(col_array[1]==current_col)	col_empty[1]=1;
		else							col_empty[1]=0;
	end
	else begin
		col_empty[1]=0;
	end
	
	if(2<queen_num)begin
		if(col_array[2]==current_col)	col_empty[2]=1;
		else							col_empty[2]=0;
	end
	else begin
		col_empty[2]=0;
	end
	
	if(3<queen_num)begin
		if(col_array[3]==current_col)	col_empty[3]=1;
		else							col_empty[3]=0;
	end
	else begin
		col_empty[3]=0;
	end
	
	if(4<queen_num)begin
		if(col_array[4]==current_col)	col_empty[4]=1;
		else							col_empty[4]=0;
	end
	else begin
		col_empty[4]=0;
	end
	
	if(5<queen_num)begin
		if(col_array[5]==current_col)	col_empty[5]=1;
		else							col_empty[5]=0;
	end
	else begin
		col_empty[5]=0;
	end
	
	if(6<queen_num)begin
		if(col_array[6]==current_col)	col_empty[6]=1;
		else							col_empty[6]=0;
	end
	else begin
		col_empty[6]=0;
	end
	
	if(7<queen_num)begin
		if(col_array[7]==current_col)	col_empty[7]=1;
		else							col_empty[7]=0;
	end
	else begin
		col_empty[7]=0;
	end
	
	if(8<queen_num)begin
		if(col_array[8]==current_col)	col_empty[8]=1;
		else							col_empty[8]=0;
	end
	else begin
		col_empty[8]=0;
	end
	
	if(9<queen_num)begin
		if(col_array[9]==current_col)	col_empty[9]=1;
		else							col_empty[9]=0;
	end
	else begin
		col_empty[9]=0;
	end
	
	if(10<queen_num)begin
		if(col_array[10]==current_col)	col_empty[10]=1;
		else							col_empty[10]=0;
	end
	else begin
		col_empty[10]=0;
	end
	
	if(11<queen_num)begin
		if(col_array[11]==current_col)	col_empty[11]=1;
		else							col_empty[11]=0;
	end
	else begin
		col_empty[11]=0;
	end
	
	col_empty_flag = |col_empty;
end

//output logic
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_valid<=0; 
		out<=0;	
		out_counter<=0;
    end 	
	else begin
	    case(current_state)
            OUT: begin
		        out_valid<=1;
				out<=sort_array[out_counter];
				out_counter<=out_counter+1;
		    end
            default:begin
				out_valid<=0;
				out<=0;
				out_counter<=0;
            end		
		endcase
	end
end

endmodule 
