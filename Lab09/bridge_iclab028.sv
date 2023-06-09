module bridge(input clk, INF.bridge_inf inf);

//================================================================
// logic 
//================================================================

//================================================================
// cur_state 
//================================================================
typedef enum logic  [2:0] { IDLE	    	= 3'd0 ,
                            INPUT	        = 3'd1 ,
							READ_DRAM_addr	= 3'd2 ,
							READ_DRAM_dt	= 3'd3 , 
							WRITE_DRAM_addr	= 3'd4 ,
							WRITE_DRAM_dt	= 3'd5 ,
							WRITE_DRAM_ok   = 3'd6 ,
							OUTPUT		    = 3'd7 
							}  state_t ;

//================================================================
//   FSM
//================================================================

//================================================================
// logic 
//================================================================
state_t current_state, next_state;
logic mode_reg,C_r_wb;
logic [7:0]  addr_reg;
logic [63:0] data_reg_read,data_reg_write;
logic [63:0] data_reg;
//================================================================
// DESIGN 
//================================================================
//FSM


always_ff@(negedge inf.rst_n or posedge clk)begin
	if(!inf.rst_n) 
		current_state <= IDLE;
	else 
		current_state <= next_state;
end
always_comb begin
	case(current_state)
		IDLE : begin
			if(inf.C_in_valid)	next_state = INPUT;
			else				next_state = IDLE;
		end
		INPUT:begin
			if(mode_reg) next_state = READ_DRAM_addr;
			else         next_state = WRITE_DRAM_addr;
		end
		READ_DRAM_addr:begin
			if(inf.AR_READY) next_state = READ_DRAM_dt;
			else			 next_state = READ_DRAM_addr;
		end
		WRITE_DRAM_addr:begin
			if(inf.AW_READY) next_state = WRITE_DRAM_dt;
			else			 next_state = WRITE_DRAM_addr;
		end
		READ_DRAM_dt:begin
			if(inf.R_VALID) next_state = OUTPUT;
			else			 next_state = READ_DRAM_dt;
		end
		WRITE_DRAM_dt:begin
			if(inf.W_READY) next_state = WRITE_DRAM_ok;
			else			 next_state = WRITE_DRAM_dt;
		end
		WRITE_DRAM_ok:begin
			if(inf.B_VALID && (inf.B_RESP == 2'b00)) next_state = OUTPUT;
			else								     next_state = WRITE_DRAM_ok;
		end
		OUTPUT: next_state = IDLE;
		
		default : next_state = current_state ;
	endcase
	
end
//================================================================
// Eat Input 
//================================================================

always_ff@(posedge clk or negedge inf.rst_n)begin
	if(!inf.rst_n)      mode_reg <= 0;
	else begin
		if(inf.C_in_valid) mode_reg <= inf.C_r_wb;   // 1 is read , 0 is write
		else			   mode_reg <= mode_reg;
	end
end

always_ff@(posedge clk or negedge inf.rst_n) begin
	if(!inf.rst_n)	   addr_reg <= 0;
	else begin
		if(inf.C_in_valid) addr_reg <= inf.C_addr;
		else			   addr_reg <= addr_reg;
	end
end

always_ff @(posedge clk or negedge inf.rst_n)begin
	if(!inf.rst_n)	C_r_wb <= 0 ;
	else begin
		if(inf.C_in_valid) C_r_wb <= inf.C_r_wb ;
		else			   C_r_wb <= inf.C_r_wb ;
	end	
end

always_ff@(posedge clk or negedge inf.rst_n ) begin
	if(!inf.rst_n)      data_reg_write <= 0;
	else begin
		if(inf.C_in_valid )begin  //WRITE
			data_reg_write[7 :0]  <= inf.C_data_w[63:56];
			data_reg_write[15:8]  <= inf.C_data_w[55:48];
			data_reg_write[23:16] <= inf.C_data_w[47:40];
			data_reg_write[31:24] <= inf.C_data_w[39:32];
			data_reg_write[39:32] <= inf.C_data_w[31:24];
			data_reg_write[47:40] <= inf.C_data_w[23:16];
			data_reg_write[55:48] <= inf.C_data_w[15:8];
			data_reg_write[63:56] <= inf.C_data_w[7:0];
		end
	end
end
always_ff@(posedge clk or negedge inf.rst_n)begin
	if(!inf.rst_n)      data_reg_read <= 0;
	else begin
		if((current_state == READ_DRAM_dt) && inf.R_VALID)begin
			data_reg_read[63:56] <= inf.R_DATA[7:0];
			data_reg_read[55:48] <= inf.R_DATA[15:8];
			data_reg_read[47:40] <= inf.R_DATA[23:16];
			data_reg_read[39:32] <= inf.R_DATA[31:24];
			data_reg_read[31:24] <= inf.R_DATA[39:32];
			data_reg_read[23:16] <= inf.R_DATA[47:40];
			data_reg_read[15:8]  <= inf.R_DATA[55:48];
			data_reg_read[7:0]   <= inf.R_DATA[63:56];
		end
	end
end

// always_ff@(posedge clk or negedge inf.rst_n)begin
// 	if(!inf.rst_n)      data_reg <= 0;
// 	else begin
// 		if(!inf.C_r_wb) data_reg <= data_reg_write ;
// 		else			data_reg <= data_reg_read ;
// 	end
// end

assign data_reg = (C_r_wb == 1'b1)?  data_reg_read : data_reg_write;

always_ff@(posedge clk or negedge inf.rst_n ) begin
	if(!inf.rst_n) inf.C_out_valid <= 1'b0;
	else begin
		if(inf.C_out_valid == 1) inf.C_out_valid <= 1'b0;
		if(next_state == OUTPUT) inf.C_out_valid <= 1'b1;
	end
end

assign inf.C_data_r = data_reg;	
assign inf.W_DATA = data_reg;

always_comb begin
	if(current_state == READ_DRAM_addr) inf.AR_VALID = 1'b1;
	else								inf.AR_VALID = 1'b0;
end

always_comb begin
	if(current_state == READ_DRAM_dt)	inf.R_READY = 1'b1;
	else								inf.R_READY = 1'b0;
end	

always_comb begin
	if(current_state == WRITE_DRAM_addr) inf.AW_VALID = 1'b1;
	else								 inf.AW_VALID = 1'b0;
end

always_comb begin
	if(current_state == WRITE_DRAM_dt)	inf.W_VALID = 1'b1;
	else								inf.W_VALID = 1'b0;	
end

always_comb begin
	if(current_state == WRITE_DRAM_ok) inf.B_READY = 1'b1;
	else  						       inf.B_READY = 1'b0;
end

always_ff@(posedge clk or negedge inf.rst_n )begin
	if(!inf.rst_n)begin
		inf.AR_ADDR <= 0;
	end
	else if(next_state == READ_DRAM_addr) inf.AR_ADDR <= {6'b100000,addr_reg,3'b000};
end
always_ff@(posedge clk or negedge inf.rst_n )begin
	if(!inf.rst_n)begin
		inf.AW_ADDR <= 0;
	end
	else if(next_state == WRITE_DRAM_addr) inf.AW_ADDR <= {6'b100000,addr_reg,3'b000};
end


endmodule
