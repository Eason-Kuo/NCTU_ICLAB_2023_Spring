module CC(
  in_s0,
  in_s1,
  in_s2,
  in_s3,
  in_s4,
  in_s5,
  in_s6,
  opt,
  a,
  b,
  s_id0,
  s_id1,
  s_id2,
  s_id3,
  s_id4,
  s_id5,
  s_id6,
  out

);
input [3:0]in_s0;
input [3:0]in_s1;
input [3:0]in_s2;
input [3:0]in_s3;
input [3:0]in_s4;
input [3:0]in_s5;
input [3:0]in_s6;
input [2:0]opt;
input [1:0]a;
input [2:0]b;
output [2:0] s_id0;
output [2:0] s_id1;
output [2:0] s_id2;
output [2:0] s_id3;
output [2:0] s_id4;
output [2:0] s_id5;
output [2:0] s_id6;
output [2:0] out; 
//==================================================================
// reg & wire
//==================================================================
//signed
reg signed [3:0]s0_s;
reg signed [3:0]s1_s;
reg signed [3:0]s2_s;
reg signed [3:0]s3_s;
reg signed [3:0]s4_s;
reg signed [3:0]s5_s;
reg signed [3:0]s6_s;
//unsigned variables
reg        [3:0]s0_ns;
reg        [3:0]s1_ns;
reg        [3:0]s2_ns;
reg        [3:0]s3_ns;
reg        [3:0]s4_ns;
reg        [3:0]s5_ns;
reg        [3:0]s6_ns;
//sort variables (signed)
reg signed [3:0]rank_s0[0:6];
reg signed [3:0]rank_s1[0:6];
reg signed [3:0]rank_s2[0:6];
reg signed [3:0]rank_s3[0:6];
reg signed [3:0]rank_s4[0:6];
reg signed [3:0]rank_s5[0:6];
reg signed [3:0]rank_s6[0:6];
//sort ID 
reg        [2:0]rank0_ID[0:6];
reg        [2:0]rank1_ID[0:6];
reg        [2:0]rank2_ID[0:6];
reg        [2:0]rank3_ID[0:6];
reg        [2:0]rank4_ID[0:6];
reg        [2:0]rank5_ID[0:6];
reg        [2:0]rank6_ID[0:6];


assign     s_id0 = rank6_ID[0];
assign     s_id1 = rank6_ID[1];
assign     s_id2 = rank6_ID[2];
assign     s_id3 = rank6_ID[3];
assign     s_id4 = rank6_ID[4];
assign     s_id5 = rank6_ID[5];
assign     s_id6 = rank6_ID[6];
//sort variables (unsigned)
reg    [3:0]rank_ns0[0:6];
reg    [3:0]rank_ns1[0:6];
reg    [3:0]rank_ns2[0:6];
reg    [3:0]rank_ns3[0:6];
reg    [3:0]rank_ns4[0:6];
reg    [3:0]rank_ns5[0:6];
reg    [3:0]rank_ns6[0:6];
//average
reg  signed  [4:0]average_s;
reg          [4:0]average_ns;
//Passing Score
wire signed  [4:0]pas_score;
wire         [4:0]pas_score_ns;

//New_Score by Linera-Transformation
reg  signed  [7:0]A_score;
reg  signed  [7:0]B_score;
reg  signed  [7:0]C_score;
reg  signed  [7:0]D_score;
reg  signed  [7:0]E_score;
reg  signed  [7:0]F_score;
reg  signed  [7:0]G_score;

wire    [7:0]A_score_ns;
wire    [7:0]B_score_ns;
wire    [7:0]C_score_ns;
wire    [7:0]D_score_ns;
wire    [7:0]E_score_ns;
wire    [7:0]F_score_ns;
wire    [7:0]G_score_ns;

wire signed   [3:0]a_sign;
wire signed   [3:0]b_sign;
assign    a_sign = a+1;
assign    b_sign = b  ;

reg     cpr0;
reg     cpr1;
reg     cpr2;
reg     cpr3;
reg     cpr4;
reg     cpr5;
reg     cpr6;
wire    [2:0]outp;
wire    [2:0]outf;
//==================================================================
// design
//==================================================================


always @(*) begin
    if(opt[0]==1'b1) //signed
    begin
        s0_s = in_s0;
        s1_s = in_s1;
        s2_s = in_s2;
        s3_s = in_s3;
        s4_s = in_s4;
        s5_s = in_s5;
        s6_s = in_s6;
    end
    else
    begin
        s0_s = 4'b0000;
        s1_s = 4'b0000;
        s2_s = 4'b0000;
        s3_s = 4'b0000;
        s4_s = 4'b0000;
        s5_s = 4'b0000;
        s6_s = 4'b0000;
       
    
    end
end

always @(*) begin
    if(opt[0]==1'b0) //signed
    begin
        s0_ns = in_s0;
        s1_ns = in_s1;
        s2_ns = in_s2;
        s3_ns = in_s3;
        s4_ns = in_s4;
        s5_ns = in_s5;
        s6_ns = in_s6;
    end
    else
    begin
        s0_ns = 4'b0000;
        s1_ns = 4'b0000;
        s2_ns = 4'b0000;
        s3_ns = 4'b0000;
        s4_ns = 4'b0000;
        s5_ns = 4'b0000;
        s6_ns = 4'b0000;
    
    end
end
always@(*)
begin
    if(opt[0] == 1'b1) //signed sort (big~small)
    begin
        if(opt[1]==1'b1)
        begin
            /*---------------First sort (ID+score)--------------*/
            rank_s0[0] = (s0_s > s1_s)? s0_s:s1_s;
            rank_s0[1] = (s0_s > s1_s)? s1_s:s0_s;
            rank_s0[2] = (s2_s > s3_s)? s2_s:s3_s;
            rank_s0[3] = (s2_s > s3_s)? s3_s:s2_s;
            rank_s0[4] = (s4_s > s5_s)? s4_s:s5_s;
            rank_s0[5] = (s4_s > s5_s)? s5_s:s4_s;
            rank_s0[6] = s6_s;

            rank0_ID[0] = (s0_s >= s1_s)? 3'b000 : 3'b001;
            rank0_ID[1] = (s0_s >= s1_s)? 3'b001 : 3'b000;
            rank0_ID[2] = (s2_s >= s3_s)? 3'b010 : 3'b011;
            rank0_ID[3] = (s2_s >= s3_s)? 3'b011 : 3'b010; 
            rank0_ID[4] = (s4_s >= s5_s)? 3'b100 : 3'b101;
            rank0_ID[5] = (s4_s >= s5_s)? 3'b101 : 3'b100;
            rank0_ID[6] = 3'b110;

            /*---------------Second sort (ID+score)--------------*/

            rank_s1[0] = rank_s0[0];
            rank_s1[1] = (rank_s0[1] > rank_s0[2] )? rank_s0[1] : rank_s0[2];
            rank_s1[2] = (rank_s0[1] > rank_s0[2] )? rank_s0[2] : rank_s0[1];
            rank_s1[3] = (rank_s0[3] > rank_s0[4] )? rank_s0[3] : rank_s0[4];
            rank_s1[4] = (rank_s0[3] > rank_s0[4] )? rank_s0[4] : rank_s0[3];
            rank_s1[5] = (rank_s0[5] > rank_s0[6] )? rank_s0[5] : rank_s0[6];
            rank_s1[6] = (rank_s0[5] > rank_s0[6] )? rank_s0[6] : rank_s0[5];

            rank1_ID[0] = rank0_ID[0];
            rank1_ID[1] = (rank_s0[1] >= rank_s0[2] )? rank0_ID[1] : rank0_ID[2];
            rank1_ID[2] = (rank_s0[1] >= rank_s0[2] )? rank0_ID[2] : rank0_ID[1];
            rank1_ID[3] = (rank_s0[3] >= rank_s0[4] )? rank0_ID[3] : rank0_ID[4];
            rank1_ID[4] = (rank_s0[3] >= rank_s0[4] )? rank0_ID[4] : rank0_ID[3];
            rank1_ID[5] = (rank_s0[5] >= rank_s0[6] )? rank0_ID[5] : rank0_ID[6];
            rank1_ID[6] = (rank_s0[5] >= rank_s0[6] )? rank0_ID[6] : rank0_ID[5];

           /*---------------Third sort (ID+score)--------------*/

            rank_s2[0] = (rank_s1[0] > rank_s1[1] )? rank_s1[0] : rank_s1[1];
            rank_s2[1] = (rank_s1[0] > rank_s1[1] )? rank_s1[1] : rank_s1[0]; 
            rank_s2[2] = (rank_s1[2] > rank_s1[3] )? rank_s1[2] : rank_s1[3]; 
            rank_s2[3] = (rank_s1[2] > rank_s1[3] )? rank_s1[3] : rank_s1[2];
            rank_s2[4] = (rank_s1[4] > rank_s1[5] )? rank_s1[4] : rank_s1[5];
            rank_s2[5] = (rank_s1[4] > rank_s1[5] )? rank_s1[5] : rank_s1[4]; 
            rank_s2[6] = rank_s1[6];

            rank2_ID[0] = (rank_s1[0] >= rank_s1[1])? rank1_ID[0] : rank1_ID[1];
            rank2_ID[1] = (rank_s1[0] >= rank_s1[1])? rank1_ID[1] : rank1_ID[0];
            rank2_ID[2] = (rank_s1[2] >= rank_s1[3])? rank1_ID[2] : rank1_ID[3];
            rank2_ID[3] = (rank_s1[2] >= rank_s1[3])? rank1_ID[3] : rank1_ID[2]; 
            rank2_ID[4] = (rank_s1[4] >= rank_s1[5])? rank1_ID[4] : rank1_ID[5];
            rank2_ID[5] = (rank_s1[4] >= rank_s1[5])? rank1_ID[5] : rank1_ID[4];
            rank2_ID[6] = rank1_ID[6];

            /*---------------Forth sort (ID+score)--------------*/

            rank_s3[0] = rank_s2[0];
            rank_s3[1] = (rank_s2[1] > rank_s2[2] )? rank_s2[1] : rank_s2[2]; 
            rank_s3[2] = (rank_s2[1] > rank_s2[2] )? rank_s2[2] : rank_s2[1]; 
            rank_s3[3] = (rank_s2[3] > rank_s2[4] )? rank_s2[3] : rank_s2[4];
            rank_s3[4] = (rank_s2[3] > rank_s2[4] )? rank_s2[4] : rank_s2[3]; 
            rank_s3[5] = (rank_s2[5] > rank_s2[6] )? rank_s2[5] : rank_s2[6]; 
            rank_s3[6] = (rank_s2[5] > rank_s2[6] )? rank_s2[6] : rank_s2[5]; 

            rank3_ID[0] = rank2_ID[0];
            rank3_ID[1] = (rank_s2[1] >=  rank_s2[2] )? rank2_ID[1] : rank2_ID[2];
            rank3_ID[2] = (rank_s2[1] >=  rank_s2[2] )? rank2_ID[2] : rank2_ID[1];
            rank3_ID[3] = (rank_s2[3] >=  rank_s2[4] )? rank2_ID[3] : rank2_ID[4];
            rank3_ID[4] = (rank_s2[3] >=  rank_s2[4] )? rank2_ID[4] : rank2_ID[3];
            rank3_ID[5] = (rank_s2[5] >=  rank_s2[6] )? rank2_ID[5] : rank2_ID[6];
            rank3_ID[6] = (rank_s2[5] >=  rank_s2[6] )? rank2_ID[6] : rank2_ID[5];

            /*---------------Fifth sort (ID+score)--------------*/

            rank_s4[0] = (rank_s3[0] > rank_s3[1] )? rank_s3[0] : rank_s3[1];
            rank_s4[1] = (rank_s3[0] > rank_s3[1] )? rank_s3[1] : rank_s3[0]; 
            rank_s4[2] = (rank_s3[2] > rank_s3[3] )? rank_s3[2] : rank_s3[3]; 
            rank_s4[3] = (rank_s3[2] > rank_s3[3] )? rank_s3[3] : rank_s3[2];
            rank_s4[4] = (rank_s3[4] > rank_s3[5] )? rank_s3[4] : rank_s3[5];
            rank_s4[5] = (rank_s3[4] > rank_s3[5] )? rank_s3[5] : rank_s3[4]; 
            rank_s4[6] = rank_s3[6];

            rank4_ID[0] = (rank_s3[0] >= rank_s3[1])? rank3_ID[0] : rank3_ID[1];
            rank4_ID[1] = (rank_s3[0] >= rank_s3[1])? rank3_ID[1] : rank3_ID[0];
            rank4_ID[2] = (rank_s3[2] >= rank_s3[3])? rank3_ID[2] : rank3_ID[3];
            rank4_ID[3] = (rank_s3[2] >= rank_s3[3])? rank3_ID[3] : rank3_ID[2]; 
            rank4_ID[4] = (rank_s3[4] >= rank_s3[5])? rank3_ID[4] : rank3_ID[5];
            rank4_ID[5] = (rank_s3[4] >= rank_s3[5])? rank3_ID[5] : rank3_ID[4];
            rank4_ID[6] = rank3_ID[6];

            /*---------------Sixth sort (ID+score)--------------*/
            rank_s5[0] = rank_s4[0];
            rank_s5[1] = (rank_s4[1] > rank_s4[2] )? rank_s4[1] : rank_s4[2]; 
            rank_s5[2] = (rank_s4[1] > rank_s4[2] )? rank_s4[2] : rank_s4[1]; 
            rank_s5[3] = (rank_s4[3] > rank_s4[4] )? rank_s4[3] : rank_s4[4];
            rank_s5[4] = (rank_s4[3] > rank_s4[4] )? rank_s4[4] : rank_s4[3]; 
            rank_s5[5] = (rank_s4[5] > rank_s4[6] )? rank_s4[5] : rank_s4[6]; 
            rank_s5[6] = (rank_s4[5] > rank_s4[6] )? rank_s4[6] : rank_s4[5]; 

            rank5_ID[0] = rank4_ID[0];
            rank5_ID[1] = (rank_s4[1] >= rank_s4[2] )? rank4_ID[1] : rank4_ID[2];
            rank5_ID[2] = (rank_s4[1] >= rank_s4[2] )? rank4_ID[2] : rank4_ID[1];
            rank5_ID[3] = (rank_s4[3] >= rank_s4[4] )? rank4_ID[3] : rank4_ID[4];
            rank5_ID[4] = (rank_s4[3] >= rank_s4[4] )? rank4_ID[4] : rank4_ID[3];
            rank5_ID[5] = (rank_s4[5] >= rank_s4[6] )? rank4_ID[5] : rank4_ID[6];
            rank5_ID[6] = (rank_s4[5] >= rank_s4[6] )? rank4_ID[6] : rank4_ID[5];

             /*---------------Seventh sort (ID+score)--------------*/
            rank_s6[0] = (rank_s5[0] > rank_s5[1] )? rank_s5[0] : rank_s5[1];
            rank_s6[1] = (rank_s5[0] > rank_s5[1] )? rank_s5[1] : rank_s5[0]; 
            rank_s6[2] = (rank_s5[2] > rank_s5[3] )? rank_s5[2] : rank_s5[3]; 
            rank_s6[3] = (rank_s5[2] > rank_s5[3] )? rank_s5[3] : rank_s5[2];
            rank_s6[4] = (rank_s5[4] > rank_s5[5] )? rank_s5[4] : rank_s5[5];
            rank_s6[5] = (rank_s5[4] > rank_s5[5] )? rank_s5[5] : rank_s5[4]; 
            rank_s6[6] = rank_s5[6];

            rank6_ID[0] = (rank_s5[0] >=  rank_s5[1])? rank5_ID[0] : rank5_ID[1];
            rank6_ID[1] = (rank_s5[0] >=  rank_s5[1])? rank5_ID[1] : rank5_ID[0];
            rank6_ID[2] = (rank_s5[2] >=  rank_s5[3])? rank5_ID[2] : rank5_ID[3];
            rank6_ID[3] = (rank_s5[2] >=  rank_s5[3])? rank5_ID[3] : rank5_ID[2]; 
            rank6_ID[4] = (rank_s5[4] >=  rank_s5[5])? rank5_ID[4] : rank5_ID[5];
            rank6_ID[5] = (rank_s5[4] >=  rank_s5[5])? rank5_ID[5] : rank5_ID[4];
            rank6_ID[6] = rank5_ID[6];
        end
        else
        begin
            /*-------------------first--------------------*/
            rank_s0[0] = (s0_s < s1_s)? s0_s:s1_s;
            rank_s0[1] = (s0_s < s1_s)? s1_s:s0_s;
            rank_s0[2] = (s2_s < s3_s)? s2_s:s3_s;
            rank_s0[3] = (s2_s < s3_s)? s3_s:s2_s;
            rank_s0[4] = (s4_s < s5_s)? s4_s:s5_s;
            rank_s0[5] = (s4_s < s5_s)? s5_s:s4_s;
            rank_s0[6] = s6_s;

            rank0_ID[0] = (s0_s <= s1_s)? 3'b000 : 3'b001;
            rank0_ID[1] = (s0_s <= s1_s)? 3'b001 : 3'b000;
            rank0_ID[2] = (s2_s <= s3_s)? 3'b010 : 3'b011;
            rank0_ID[3] = (s2_s <= s3_s)? 3'b011 : 3'b010; 
            rank0_ID[4] = (s4_s <= s5_s)? 3'b100 : 3'b101;
            rank0_ID[5] = (s4_s <= s5_s)? 3'b101 : 3'b100;
            rank0_ID[6] = 3'b110;

            /*-------------------Second--------------------*/
            rank_s1[0] = rank_s0[0];
            rank_s1[1] = (rank_s0[1] < rank_s0[2] )? rank_s0[1] : rank_s0[2];
            rank_s1[2] = (rank_s0[1] < rank_s0[2] )? rank_s0[2] : rank_s0[1];
            rank_s1[3] = (rank_s0[3] < rank_s0[4] )? rank_s0[3] : rank_s0[4];
            rank_s1[4] = (rank_s0[3] < rank_s0[4] )? rank_s0[4] : rank_s0[3];
            rank_s1[5] = (rank_s0[5] < rank_s0[6] )? rank_s0[5] : rank_s0[6];
            rank_s1[6] = (rank_s0[5] < rank_s0[6] )? rank_s0[6] : rank_s0[5];

            rank1_ID[0] = rank0_ID[0];
            rank1_ID[1] = (rank_s0[1] <= rank_s0[2])? rank0_ID[1] : rank0_ID[2];
            rank1_ID[2] = (rank_s0[1] <= rank_s0[2])? rank0_ID[2] : rank0_ID[1];
            rank1_ID[3] = (rank_s0[3] <= rank_s0[4])? rank0_ID[3] : rank0_ID[4]; 
            rank1_ID[4] = (rank_s0[3] <= rank_s0[4])? rank0_ID[4] : rank0_ID[3];
            rank1_ID[5] = (rank_s0[5] <= rank_s0[6])? rank0_ID[5] : rank0_ID[6];
            rank1_ID[6] = (rank_s0[5] <= rank_s0[6])? rank0_ID[6] : rank0_ID[5];


            /*--------------------Third-----------------*/
            rank_s2[0] = (rank_s1[0] < rank_s1[1] )? rank_s1[0] : rank_s1[1];
            rank_s2[1] = (rank_s1[0] < rank_s1[1] )? rank_s1[1] : rank_s1[0]; 
            rank_s2[2] = (rank_s1[2] < rank_s1[3] )? rank_s1[2] : rank_s1[3]; 
            rank_s2[3] = (rank_s1[2] < rank_s1[3] )? rank_s1[3] : rank_s1[2];
            rank_s2[4] = (rank_s1[4] < rank_s1[5] )? rank_s1[4] : rank_s1[5];
            rank_s2[5] = (rank_s1[4] < rank_s1[5] )? rank_s1[5] : rank_s1[4]; 
            rank_s2[6] = rank_s1[6];

            rank2_ID[0] = (rank_s1[0] <= rank_s1[1])? rank1_ID[0] : rank1_ID[1];
            rank2_ID[1] = (rank_s1[0] <= rank_s1[1])? rank1_ID[1] : rank1_ID[0];
            rank2_ID[2] = (rank_s1[2] <= rank_s1[3])? rank1_ID[2] : rank1_ID[3];
            rank2_ID[3] = (rank_s1[2] <= rank_s1[3])? rank1_ID[3] : rank1_ID[2]; 
            rank2_ID[4] = (rank_s1[4] <= rank_s1[5])? rank1_ID[4] : rank1_ID[5];
            rank2_ID[5] = (rank_s1[4] <= rank_s1[5])? rank1_ID[5] : rank1_ID[4];
            rank2_ID[6] = rank1_ID[6];

            /*---------------Forth sort (ID+score)--------------*/
            rank_s3[0] = rank_s2[0];
            rank_s3[1] = (rank_s2[1] < rank_s2[2] )? rank_s2[1] : rank_s2[2]; 
            rank_s3[2] = (rank_s2[1] < rank_s2[2] )? rank_s2[2] : rank_s2[1]; 
            rank_s3[3] = (rank_s2[3] < rank_s2[4] )? rank_s2[3] : rank_s2[4];
            rank_s3[4] = (rank_s2[3] < rank_s2[4] )? rank_s2[4] : rank_s2[3]; 
            rank_s3[5] = (rank_s2[5] < rank_s2[6] )? rank_s2[5] : rank_s2[6]; 
            rank_s3[6] = (rank_s2[5] < rank_s2[6] )? rank_s2[6] : rank_s2[5]; 

            rank3_ID[0] = rank2_ID[0];
            rank3_ID[1] = (rank_s2[1] <= rank_s2[2])? rank2_ID[1] : rank2_ID[2];
            rank3_ID[2] = (rank_s2[1] <= rank_s2[2])? rank2_ID[2] : rank2_ID[1];
            rank3_ID[3] = (rank_s2[3] <= rank_s2[4])? rank2_ID[3] : rank2_ID[4]; 
            rank3_ID[4] = (rank_s2[3] <= rank_s2[4])? rank2_ID[4] : rank2_ID[3];
            rank3_ID[5] = (rank_s2[5] <= rank_s2[6])? rank2_ID[5] : rank2_ID[6];
            rank3_ID[6] = (rank_s2[5] <= rank_s2[6])? rank2_ID[6] : rank2_ID[5];

            /*---------------Fifth sort (ID+score)--------------*/

            rank_s4[0] = (rank_s3[0] < rank_s3[1] )? rank_s3[0] : rank_s3[1];
            rank_s4[1] = (rank_s3[0] < rank_s3[1] )? rank_s3[1] : rank_s3[0]; 
            rank_s4[2] = (rank_s3[2] < rank_s3[3] )? rank_s3[2] : rank_s3[3]; 
            rank_s4[3] = (rank_s3[2] < rank_s3[3] )? rank_s3[3] : rank_s3[2];
            rank_s4[4] = (rank_s3[4] < rank_s3[5] )? rank_s3[4] : rank_s3[5];
            rank_s4[5] = (rank_s3[4] < rank_s3[5] )? rank_s3[5] : rank_s3[4]; 
            rank_s4[6] = rank_s3[6];

            rank4_ID[0] = (rank_s3[0] <= rank_s3[1])? rank3_ID[0] : rank3_ID[1];
            rank4_ID[1] = (rank_s3[0] <= rank_s3[1])? rank3_ID[1] : rank3_ID[0];
            rank4_ID[2] = (rank_s3[2] <= rank_s3[3])? rank3_ID[2] : rank3_ID[3];
            rank4_ID[3] = (rank_s3[2] <= rank_s3[3])? rank3_ID[3] : rank3_ID[2]; 
            rank4_ID[4] = (rank_s3[4] <= rank_s3[5])? rank3_ID[4] : rank3_ID[5];
            rank4_ID[5] = (rank_s3[4] <= rank_s3[5])? rank3_ID[5] : rank3_ID[4];
            rank4_ID[6] = rank3_ID[6];
            /*---------------Sixth sort (ID+score)--------------*/
            rank_s5[0] = rank_s4[0];
            rank_s5[1] = (rank_s4[1] < rank_s4[2] )? rank_s4[1] : rank_s4[2]; 
            rank_s5[2] = (rank_s4[1] < rank_s4[2] )? rank_s4[2] : rank_s4[1]; 
            rank_s5[3] = (rank_s4[3] < rank_s4[4] )? rank_s4[3] : rank_s4[4];
            rank_s5[4] = (rank_s4[3] < rank_s4[4] )? rank_s4[4] : rank_s4[3]; 
            rank_s5[5] = (rank_s4[5] < rank_s4[6] )? rank_s4[5] : rank_s4[6]; 
            rank_s5[6] = (rank_s4[5] < rank_s4[6] )? rank_s4[6] : rank_s4[5];

            rank5_ID[0] = rank4_ID[0];
            rank5_ID[1] = (rank_s4[1] <= rank_s4[2] )? rank4_ID[1] : rank4_ID[2];
            rank5_ID[2] = (rank_s4[1] <= rank_s4[2] )? rank4_ID[2] : rank4_ID[1];
            rank5_ID[3] = (rank_s4[3] <= rank_s4[4] )? rank4_ID[3] : rank4_ID[4];
            rank5_ID[4] = (rank_s4[3] <= rank_s4[4] )? rank4_ID[4] : rank4_ID[3];
            rank5_ID[5] = (rank_s4[5] <= rank_s4[6] )? rank4_ID[5] : rank4_ID[6];
            rank5_ID[6] = (rank_s4[5] <= rank_s4[6] )? rank4_ID[6] : rank4_ID[5]; 

            /*---------------Seventh sort (ID+score)--------------*/
            rank_s6[0] = (rank_s5[0] < rank_s5[1] )? rank_s5[0] : rank_s5[1];
            rank_s6[1] = (rank_s5[0] < rank_s5[1] )? rank_s5[1] : rank_s5[0]; 
            rank_s6[2] = (rank_s5[2] < rank_s5[3] )? rank_s5[2] : rank_s5[3]; 
            rank_s6[3] = (rank_s5[2] < rank_s5[3] )? rank_s5[3] : rank_s5[2];
            rank_s6[4] = (rank_s5[4] < rank_s5[5] )? rank_s5[4] : rank_s5[5];
            rank_s6[5] = (rank_s5[4] < rank_s5[5] )? rank_s5[5] : rank_s5[4]; 
            rank_s6[6] = rank_s5[6];

            rank6_ID[0] = (rank_s5[0] <=  rank_s5[1])? rank5_ID[0] : rank5_ID[1];
            rank6_ID[1] = (rank_s5[0] <=  rank_s5[1])? rank5_ID[1] : rank5_ID[0];
            rank6_ID[2] = (rank_s5[2] <=  rank_s5[3])? rank5_ID[2] : rank5_ID[3];
            rank6_ID[3] = (rank_s5[2] <=  rank_s5[3])? rank5_ID[3] : rank5_ID[2]; 
            rank6_ID[4] = (rank_s5[4] <=  rank_s5[5])? rank5_ID[4] : rank5_ID[5];
            rank6_ID[5] = (rank_s5[4] <=  rank_s5[5])? rank5_ID[5] : rank5_ID[4];
            rank6_ID[6] = rank5_ID[6];
        end
    end
    else
    begin
        if(opt[1]==1'b1)
        begin
            /*-----------------------------*/
            rank_ns0[0] = (s0_ns > s1_ns)? s0_ns:s1_ns;
            rank_ns0[1] = (s0_ns > s1_ns)? s1_ns:s0_ns;
            rank_ns0[2] = (s2_ns > s3_ns)? s2_ns:s3_ns;
            rank_ns0[3] = (s2_ns > s3_ns)? s3_ns:s2_ns;
            rank_ns0[4] = (s4_ns > s5_ns)? s4_ns:s5_ns;
            rank_ns0[5] = (s4_ns > s5_ns)? s5_ns:s4_ns;
            rank_ns0[6] = s6_ns;

            rank0_ID[0] = (s0_ns >= s1_ns)? 3'b000 : 3'b001;
            rank0_ID[1] = (s0_ns >= s1_ns)? 3'b001 : 3'b000;
            rank0_ID[2] = (s2_ns >= s3_ns)? 3'b010 : 3'b011;
            rank0_ID[3] = (s2_ns >= s3_ns)? 3'b011 : 3'b010; 
            rank0_ID[4] = (s4_ns >= s5_ns)? 3'b100 : 3'b101;
            rank0_ID[5] = (s4_ns >= s5_ns)? 3'b101 : 3'b100;
            rank0_ID[6] = 3'b110;
            /*----------------------------------*/
            rank_ns1[0] = rank_ns0[0];
            rank_ns1[1] = (rank_ns0[1] > rank_ns0[2] )? rank_ns0[1] : rank_ns0[2];
            rank_ns1[2] = (rank_ns0[1] > rank_ns0[2] )? rank_ns0[2] : rank_ns0[1];
            rank_ns1[3] = (rank_ns0[3] > rank_ns0[4] )? rank_ns0[3] : rank_ns0[4];
            rank_ns1[4] = (rank_ns0[3] > rank_ns0[4] )? rank_ns0[4] : rank_ns0[3];
            rank_ns1[5] = (rank_ns0[5] > rank_ns0[6] )? rank_ns0[5] : rank_ns0[6];
            rank_ns1[6] = (rank_ns0[5] > rank_ns0[6] )? rank_ns0[6] : rank_ns0[5];

            rank1_ID[0] = rank0_ID[0];
            rank1_ID[1] = (rank_ns0[1] >= rank_ns0[2] )? rank0_ID[1] : rank0_ID[2];
            rank1_ID[2] = (rank_ns0[1] >= rank_ns0[2] )? rank0_ID[2] : rank0_ID[1];
            rank1_ID[3] = (rank_ns0[3] >= rank_ns0[4] )? rank0_ID[3] : rank0_ID[4];
            rank1_ID[4] = (rank_ns0[3] >= rank_ns0[4] )? rank0_ID[4] : rank0_ID[3];
            rank1_ID[5] = (rank_ns0[5] >= rank_ns0[6] )? rank0_ID[5] : rank0_ID[6];
            rank1_ID[6] = (rank_ns0[5] >= rank_ns0[6] )? rank0_ID[6] : rank0_ID[5];
            /*-------------------------------------*/
            rank_ns2[0] = (rank_ns1[0] > rank_ns1[1] )? rank_ns1[0] : rank_ns1[1];
            rank_ns2[1] = (rank_ns1[0] > rank_ns1[1] )? rank_ns1[1] : rank_ns1[0]; 
            rank_ns2[2] = (rank_ns1[2] > rank_ns1[3] )? rank_ns1[2] : rank_ns1[3]; 
            rank_ns2[3] = (rank_ns1[2] > rank_ns1[3] )? rank_ns1[3] : rank_ns1[2];
            rank_ns2[4] = (rank_ns1[4] > rank_ns1[5] )? rank_ns1[4] : rank_ns1[5];
            rank_ns2[5] = (rank_ns1[4] > rank_ns1[5] )? rank_ns1[5] : rank_ns1[4]; 
            rank_ns2[6] = rank_ns1[6];

            rank2_ID[0] = (rank_ns1[0] >= rank_ns1[1])? rank1_ID[0] : rank1_ID[1];
            rank2_ID[1] = (rank_ns1[0] >= rank_ns1[1])? rank1_ID[1] : rank1_ID[0];
            rank2_ID[2] = (rank_ns1[2] >= rank_ns1[3])? rank1_ID[2] : rank1_ID[3];
            rank2_ID[3] = (rank_ns1[2] >= rank_ns1[3])? rank1_ID[3] : rank1_ID[2]; 
            rank2_ID[4] = (rank_ns1[4] >= rank_ns1[5])? rank1_ID[4] : rank1_ID[5];
            rank2_ID[5] = (rank_ns1[4] >= rank_ns1[5])? rank1_ID[5] : rank1_ID[4];
            rank2_ID[6] = rank1_ID[6];
            /*-------------------------------------*/
            rank_ns3[0] = rank_ns2[0];
            rank_ns3[1] = (rank_ns2[1] > rank_ns2[2] )? rank_ns2[1] : rank_ns2[2]; 
            rank_ns3[2] = (rank_ns2[1] > rank_ns2[2] )? rank_ns2[2] : rank_ns2[1]; 
            rank_ns3[3] = (rank_ns2[3] > rank_ns2[4] )? rank_ns2[3] : rank_ns2[4];
            rank_ns3[4] = (rank_ns2[3] > rank_ns2[4] )? rank_ns2[4] : rank_ns2[3]; 
            rank_ns3[5] = (rank_ns2[5] > rank_ns2[6] )? rank_ns2[5] : rank_ns2[6]; 
            rank_ns3[6] = (rank_ns2[5] > rank_ns2[6] )? rank_ns2[6] : rank_ns2[5]; 

            rank3_ID[0] = rank2_ID[0];
            rank3_ID[1] = (rank_ns2[1] >=  rank_ns2[2] )? rank2_ID[1] : rank2_ID[2];
            rank3_ID[2] = (rank_ns2[1] >=  rank_ns2[2] )? rank2_ID[2] : rank2_ID[1];
            rank3_ID[3] = (rank_ns2[3] >=  rank_ns2[4] )? rank2_ID[3] : rank2_ID[4];
            rank3_ID[4] = (rank_ns2[3] >=  rank_ns2[4] )? rank2_ID[4] : rank2_ID[3];
            rank3_ID[5] = (rank_ns2[5] >=  rank_ns2[6] )? rank2_ID[5] : rank2_ID[6];
            rank3_ID[6] = (rank_ns2[5] >=  rank_ns2[6] )? rank2_ID[6] : rank2_ID[5];
            /*-------------------------------------*/
            rank_ns4[0] = (rank_ns3[0] > rank_ns3[1] )? rank_ns3[0] : rank_ns3[1];
            rank_ns4[1] = (rank_ns3[0] > rank_ns3[1] )? rank_ns3[1] : rank_ns3[0]; 
            rank_ns4[2] = (rank_ns3[2] > rank_ns3[3] )? rank_ns3[2] : rank_ns3[3]; 
            rank_ns4[3] = (rank_ns3[2] > rank_ns3[3] )? rank_ns3[3] : rank_ns3[2];
            rank_ns4[4] = (rank_ns3[4] > rank_ns3[5] )? rank_ns3[4] : rank_ns3[5];
            rank_ns4[5] = (rank_ns3[4] > rank_ns3[5] )? rank_ns3[5] : rank_ns3[4]; 
            rank_ns4[6] = rank_ns3[6];


            rank4_ID[0] = (rank_ns3[0] >= rank_ns3[1])? rank3_ID[0] : rank3_ID[1];
            rank4_ID[1] = (rank_ns3[0] >= rank_ns3[1])? rank3_ID[1] : rank3_ID[0];
            rank4_ID[2] = (rank_ns3[2] >= rank_ns3[3])? rank3_ID[2] : rank3_ID[3];
            rank4_ID[3] = (rank_ns3[2] >= rank_ns3[3])? rank3_ID[3] : rank3_ID[2]; 
            rank4_ID[4] = (rank_ns3[4] >= rank_ns3[5])? rank3_ID[4] : rank3_ID[5];
            rank4_ID[5] = (rank_ns3[4] >= rank_ns3[5])? rank3_ID[5] : rank3_ID[4];
            rank4_ID[6] = rank3_ID[6];
             /*-------------------------------------*/
            rank_ns5[0] = rank_ns4[0];
            rank_ns5[1] = (rank_ns4[1] > rank_ns4[2] )? rank_ns4[1] : rank_ns4[2]; 
            rank_ns5[2] = (rank_ns4[1] > rank_ns4[2] )? rank_ns4[2] : rank_ns4[1]; 
            rank_ns5[3] = (rank_ns4[3] > rank_ns4[4] )? rank_ns4[3] : rank_ns4[4];
            rank_ns5[4] = (rank_ns4[3] > rank_ns4[4] )? rank_ns4[4] : rank_ns4[3]; 
            rank_ns5[5] = (rank_ns4[5] > rank_ns4[6] )? rank_ns4[5] : rank_ns4[6]; 
            rank_ns5[6] = (rank_ns4[5] > rank_ns4[6] )? rank_ns4[6] : rank_ns4[5]; 

            rank5_ID[0] = rank4_ID[0];
            rank5_ID[1] = (rank_ns4[1] >= rank_ns4[2] )? rank4_ID[1] : rank4_ID[2];
            rank5_ID[2] = (rank_ns4[1] >= rank_ns4[2] )? rank4_ID[2] : rank4_ID[1];
            rank5_ID[3] = (rank_ns4[3] >= rank_ns4[4] )? rank4_ID[3] : rank4_ID[4];
            rank5_ID[4] = (rank_ns4[3] >= rank_ns4[4] )? rank4_ID[4] : rank4_ID[3];
            rank5_ID[5] = (rank_ns4[5] >= rank_ns4[6] )? rank4_ID[5] : rank4_ID[6];
            rank5_ID[6] = (rank_ns4[5] >= rank_ns4[6] )? rank4_ID[6] : rank4_ID[5];

            /*-----------------------------------------*/
            rank_ns6[0] = (rank_ns5[0] > rank_ns5[1] )? rank_ns5[0] : rank_ns5[1];
            rank_ns6[1] = (rank_ns5[0] > rank_ns5[1] )? rank_ns5[1] : rank_ns5[0]; 
            rank_ns6[2] = (rank_ns5[2] > rank_ns5[3] )? rank_ns5[2] : rank_ns5[3]; 
            rank_ns6[3] = (rank_ns5[2] > rank_ns5[3] )? rank_ns5[3] : rank_ns5[2];
            rank_ns6[4] = (rank_ns5[4] > rank_ns5[5] )? rank_ns5[4] : rank_ns5[5];
            rank_ns6[5] = (rank_ns5[4] > rank_ns5[5] )? rank_ns5[5] : rank_ns5[4]; 
            rank_ns6[6] = rank_ns5[6];

            rank6_ID[0] = (rank_ns5[0] >=  rank_ns5[1])? rank5_ID[0] : rank5_ID[1];
            rank6_ID[1] = (rank_ns5[0] >=  rank_ns5[1])? rank5_ID[1] : rank5_ID[0];
            rank6_ID[2] = (rank_ns5[2] >=  rank_ns5[3])? rank5_ID[2] : rank5_ID[3];
            rank6_ID[3] = (rank_ns5[2] >=  rank_ns5[3])? rank5_ID[3] : rank5_ID[2]; 
            rank6_ID[4] = (rank_ns5[4] >=  rank_ns5[5])? rank5_ID[4] : rank5_ID[5];
            rank6_ID[5] = (rank_ns5[4] >=  rank_ns5[5])? rank5_ID[5] : rank5_ID[4];
            rank6_ID[6] = rank5_ID[6];
        end
        else
        begin
        /*--------------------------first---------------------------*/
            rank_ns0[0] = (s0_ns < s1_ns)? s0_ns:s1_ns;
            rank_ns0[1] = (s0_ns < s1_ns)? s1_ns:s0_ns;
            rank_ns0[2] = (s2_ns < s3_ns)? s2_ns:s3_ns;
            rank_ns0[3] = (s2_ns < s3_ns)? s3_ns:s2_ns;
            rank_ns0[4] = (s4_ns < s5_ns)? s4_ns:s5_ns;
            rank_ns0[5] = (s4_ns < s5_ns)? s5_ns:s4_ns;
            rank_ns0[6] = s6_ns;

            rank0_ID[0] = (s0_ns <= s1_ns)? 3'b000 : 3'b001;
            rank0_ID[1] = (s0_ns <= s1_ns)? 3'b001 : 3'b000;
            rank0_ID[2] = (s2_ns <= s3_ns)? 3'b010 : 3'b011;
            rank0_ID[3] = (s2_ns <= s3_ns)? 3'b011 : 3'b010; 
            rank0_ID[4] = (s4_ns <= s5_ns)? 3'b100 : 3'b101;
            rank0_ID[5] = (s4_ns <= s5_ns)? 3'b101 : 3'b100;
            rank0_ID[6] = 3'b110;
        /*------------------------------second------------------------*/
            rank_ns1[0] =  rank_ns0[0];
            rank_ns1[1] = (rank_ns0[1] < rank_ns0[2] )? rank_ns0[1] : rank_ns0[2];
            rank_ns1[2] = (rank_ns0[1] < rank_ns0[2] )? rank_ns0[2] : rank_ns0[1];
            rank_ns1[3] = (rank_ns0[3] < rank_ns0[4] )? rank_ns0[3] : rank_ns0[4];
            rank_ns1[4] = (rank_ns0[3] < rank_ns0[4] )? rank_ns0[4] : rank_ns0[3];
            rank_ns1[5] = (rank_ns0[5] < rank_ns0[6] )? rank_ns0[5] : rank_ns0[6];
            rank_ns1[6] = (rank_ns0[5] < rank_ns0[6] )? rank_ns0[6] : rank_ns0[5];

            rank1_ID[0] = rank0_ID[0];
            rank1_ID[1] = (rank_ns0[1] <= rank_ns0[2])? rank0_ID[1] : rank0_ID[2];
            rank1_ID[2] = (rank_ns0[1] <= rank_ns0[2])? rank0_ID[2] : rank0_ID[1];
            rank1_ID[3] = (rank_ns0[3] <= rank_ns0[4])? rank0_ID[3] : rank0_ID[4]; 
            rank1_ID[4] = (rank_ns0[3] <= rank_ns0[4])? rank0_ID[4] : rank0_ID[3];
            rank1_ID[5] = (rank_ns0[5] <= rank_ns0[6])? rank0_ID[5] : rank0_ID[6];
            rank1_ID[6] = (rank_ns0[5] <= rank_ns0[6])? rank0_ID[6] : rank0_ID[5];
        /*---------------------------Third-------------------------------*/
            rank_ns2[0] = (rank_ns1[0] < rank_ns1[1] )? rank_ns1[0] : rank_ns1[1];
            rank_ns2[1] = (rank_ns1[0] < rank_ns1[1] )? rank_ns1[1] : rank_ns1[0]; 
            rank_ns2[2] = (rank_ns1[2] < rank_ns1[3] )? rank_ns1[2] : rank_ns1[3]; 
            rank_ns2[3] = (rank_ns1[2] < rank_ns1[3] )? rank_ns1[3] : rank_ns1[2];
            rank_ns2[4] = (rank_ns1[4] < rank_ns1[5] )? rank_ns1[4] : rank_ns1[5];
            rank_ns2[5] = (rank_ns1[4] < rank_ns1[5] )? rank_ns1[5] : rank_ns1[4]; 
            rank_ns2[6] = rank_ns1[6];

            rank2_ID[0] = (rank_ns1[0] <= rank_ns1[1])? rank1_ID[0] : rank1_ID[1];
            rank2_ID[1] = (rank_ns1[0] <= rank_ns1[1])? rank1_ID[1] : rank1_ID[0];
            rank2_ID[2] = (rank_ns1[2] <= rank_ns1[3])? rank1_ID[2] : rank1_ID[3];
            rank2_ID[3] = (rank_ns1[2] <= rank_ns1[3])? rank1_ID[3] : rank1_ID[2]; 
            rank2_ID[4] = (rank_ns1[4] <= rank_ns1[5])? rank1_ID[4] : rank1_ID[5];
            rank2_ID[5] = (rank_ns1[4] <= rank_ns1[5])? rank1_ID[5] : rank1_ID[4];
            rank2_ID[6] = rank1_ID[6];
         /*---------------------------Forth-------------------------------*/
            rank_ns3[0] = rank_ns2[0];
            rank_ns3[1] = (rank_ns2[1] < rank_ns2[2] )? rank_ns2[1] : rank_ns2[2]; 
            rank_ns3[2] = (rank_ns2[1] < rank_ns2[2] )? rank_ns2[2] : rank_ns2[1]; 
            rank_ns3[3] = (rank_ns2[3] < rank_ns2[4] )? rank_ns2[3] : rank_ns2[4];
            rank_ns3[4] = (rank_ns2[3] < rank_ns2[4] )? rank_ns2[4] : rank_ns2[3]; 
            rank_ns3[5] = (rank_ns2[5] < rank_ns2[6] )? rank_ns2[5] : rank_ns2[6]; 
            rank_ns3[6] = (rank_ns2[5] < rank_ns2[6] )? rank_ns2[6] : rank_ns2[5]; 

            rank3_ID[0] = rank2_ID[0];
            rank3_ID[1] = (rank_ns2[1] <= rank_ns2[2])? rank2_ID[1] : rank2_ID[2];
            rank3_ID[2] = (rank_ns2[1] <= rank_ns2[2])? rank2_ID[2] : rank2_ID[1];
            rank3_ID[3] = (rank_ns2[3] <= rank_ns2[4])? rank2_ID[3] : rank2_ID[4]; 
            rank3_ID[4] = (rank_ns2[3] <= rank_ns2[4])? rank2_ID[4] : rank2_ID[3];
            rank3_ID[5] = (rank_ns2[5] <= rank_ns2[6])? rank2_ID[5] : rank2_ID[6];
            rank3_ID[6] = (rank_ns2[5] <= rank_ns2[6])? rank2_ID[6] : rank2_ID[5];
        /*---------------------------Fifth-------------------------------*/
            rank_ns4[0] = (rank_ns3[0] < rank_ns3[1] )? rank_ns3[0] : rank_ns3[1];
            rank_ns4[1] = (rank_ns3[0] < rank_ns3[1] )? rank_ns3[1] : rank_ns3[0]; 
            rank_ns4[2] = (rank_ns3[2] < rank_ns3[3] )? rank_ns3[2] : rank_ns3[3]; 
            rank_ns4[3] = (rank_ns3[2] < rank_ns3[3] )? rank_ns3[3] : rank_ns3[2];
            rank_ns4[4] = (rank_ns3[4] < rank_ns3[5] )? rank_ns3[4] : rank_ns3[5];
            rank_ns4[5] = (rank_ns3[4] < rank_ns3[5] )? rank_ns3[5] : rank_ns3[4]; 
            rank_ns4[6] = rank_ns3[6];
         
            rank4_ID[0] = (rank_ns3[0] <= rank_ns3[1])? rank3_ID[0] : rank3_ID[1];
            rank4_ID[1] = (rank_ns3[0] <= rank_ns3[1])? rank3_ID[1] : rank3_ID[0];
            rank4_ID[2] = (rank_ns3[2] <= rank_ns3[3])? rank3_ID[2] : rank3_ID[3];
            rank4_ID[3] = (rank_ns3[2] <= rank_ns3[3])? rank3_ID[3] : rank3_ID[2]; 
            rank4_ID[4] = (rank_ns3[4] <= rank_ns3[5])? rank3_ID[4] : rank3_ID[5];
            rank4_ID[5] = (rank_ns3[4] <= rank_ns3[5])? rank3_ID[5] : rank3_ID[4];
            rank4_ID[6] = rank3_ID[6];
        /*---------------------------Sixth-------------------------------*/
            rank_ns5[0] = rank_ns4[0];
            rank_ns5[1] = (rank_ns4[1] < rank_ns4[2] )? rank_ns4[1] : rank_ns4[2]; 
            rank_ns5[2] = (rank_ns4[1] < rank_ns4[2] )? rank_ns4[2] : rank_ns4[1]; 
            rank_ns5[3] = (rank_ns4[3] < rank_ns4[4] )? rank_ns4[3] : rank_ns4[4];
            rank_ns5[4] = (rank_ns4[3] < rank_ns4[4] )? rank_ns4[4] : rank_ns4[3]; 
            rank_ns5[5] = (rank_ns4[5] < rank_ns4[6] )? rank_ns4[5] : rank_ns4[6]; 
            rank_ns5[6] = (rank_ns4[5] < rank_ns4[6] )? rank_ns4[6] : rank_ns4[5]; 
        
            rank5_ID[0] = rank4_ID[0];
            rank5_ID[1] = (rank_ns4[1] <= rank_ns4[2] )? rank4_ID[1] : rank4_ID[2];
            rank5_ID[2] = (rank_ns4[1] <= rank_ns4[2] )? rank4_ID[2] : rank4_ID[1];
            rank5_ID[3] = (rank_ns4[3] <= rank_ns4[4] )? rank4_ID[3] : rank4_ID[4];
            rank5_ID[4] = (rank_ns4[3] <= rank_ns4[4] )? rank4_ID[4] : rank4_ID[3];
            rank5_ID[5] = (rank_ns4[5] <= rank_ns4[6] )? rank4_ID[5] : rank4_ID[6];
            rank5_ID[6] = (rank_ns4[5] <= rank_ns4[6] )? rank4_ID[6] : rank4_ID[5]; 

            rank_ns6[0] = (rank_ns5[0] < rank_ns5[1] )? rank_ns5[0] : rank_ns5[1];
            rank_ns6[1] = (rank_ns5[0] < rank_ns5[1] )? rank_ns5[1] : rank_ns5[0]; 
            rank_ns6[2] = (rank_ns5[2] < rank_ns5[3] )? rank_ns5[2] : rank_ns5[3]; 
            rank_ns6[3] = (rank_ns5[2] < rank_ns5[3] )? rank_ns5[3] : rank_ns5[2];
            rank_ns6[4] = (rank_ns5[4] < rank_ns5[5] )? rank_ns5[4] : rank_ns5[5];
            rank_ns6[5] = (rank_ns5[4] < rank_ns5[5] )? rank_ns5[5] : rank_ns5[4]; 
            rank_ns6[6] = rank_ns5[6];

            rank6_ID[0] = (rank_ns5[0] <=  rank_ns5[1])? rank5_ID[0] : rank5_ID[1];
            rank6_ID[1] = (rank_ns5[0] <=  rank_ns5[1])? rank5_ID[1] : rank5_ID[0];
            rank6_ID[2] = (rank_ns5[2] <=  rank_ns5[3])? rank5_ID[2] : rank5_ID[3];
            rank6_ID[3] = (rank_ns5[2] <=  rank_ns5[3])? rank5_ID[3] : rank5_ID[2]; 
            rank6_ID[4] = (rank_ns5[4] <=  rank_ns5[5])? rank5_ID[4] : rank5_ID[5];
            rank6_ID[5] = (rank_ns5[4] <=  rank_ns5[5])? rank5_ID[5] : rank5_ID[4];
            rank6_ID[6] = rank5_ID[6];
        end
    end
    
end
/*-----------------Calculate Average && Pass_Score----------------*/
always@(*)
begin 
    if(opt[0]==1'b1) //signed to calculate average
    begin   
        average_s = (s0_s + s1_s + s2_s +s3_s + s4_s + s5_s + s6_s )/7;
    end
    else
    begin
        average_s = 4'b0000;

    end
end

always@(*)
begin 
    if(opt[0]==1'b0) //unsigned to calculate average
    begin   
        average_ns = (s0_ns + s1_ns + s2_ns +s3_ns + s4_ns + s5_ns + s6_ns )/7;
    end
    else
    begin
        average_ns = 4'b0000;

    end
end

assign pas_score =  average_s - a ; 
assign pas_score_ns = ( a > average_ns) ? 0 : average_ns - a ; 

/*----------------Calculate New Score ----------------------------*/
assign A_score_ns = (opt[0]==1'b0)? s0_ns *(a+1) +b : 4'b0000;
assign B_score_ns = (opt[0]==1'b0)? s1_ns *(a+1) +b : 4'b0000;
assign C_score_ns = (opt[0]==1'b0)? s2_ns *(a+1) +b : 4'b0000;
assign D_score_ns = (opt[0]==1'b0)? s3_ns *(a+1) +b : 4'b0000;
assign E_score_ns = (opt[0]==1'b0)? s4_ns *(a+1) +b : 4'b0000;
assign F_score_ns = (opt[0]==1'b0)? s5_ns *(a+1) +b : 4'b0000;
assign G_score_ns = (opt[0]==1'b0)? s6_ns *(a+1) +b : 4'b0000;

always@(*)
begin
    if(opt[0]==1'b1)
    begin
        if(s0_s > 0) A_score = s0_s *a_sign +b_sign ;
        else               A_score  = s0_s / a_sign +b_sign; 
    end
    else
    begin 
        A_score = 4'b0000;
    end
   
end

always@(*)
begin
    if(opt[0]==1'b1)
    begin
        if(s1_s > 0) B_score = s1_s *a_sign +b_sign ;
        else               B_score  = s1_s / a_sign +b_sign; 
    end
    else
    begin 
        B_score = 4'b0000;
    end
   
end

always@(*)
begin
    if(opt[0]==1'b1)
    begin
        if(s2_s > 0) C_score = s2_s *a_sign +b_sign ;
        else               C_score  = s2_s / a_sign +b_sign; 
    end
    else
    begin 
        C_score = 4'b0000;
    end
   
end

always@(*)
begin
    if(opt[0]==1'b1)
    begin
        if(s3_s > 0) D_score = s3_s *a_sign + b_sign ;
        else               D_score  = s3_s / a_sign + b_sign; 
    end
    else
    begin 
        D_score = 4'b0000;
    end
   
end

always@(*)
begin
    if(opt[0]==1'b1)
    begin
        if(s4_s > 0) E_score = s4_s *a_sign +b_sign ;
        else               E_score  = s4_s / a_sign +b_sign; 
    end
    else
    begin 
        E_score = 4'b0000;
    end
   
end

always@(*)
begin
    if(opt[0]==1'b1)
    begin
        if(s5_s > 0) F_score =  s5_s *a_sign  + b_sign ;
        else               F_score  = s5_s / a_sign + b_sign; 
    end
    else
    begin 
        F_score = 4'b0000;
    end
   
end

always@(*)
begin
    if(opt[0]==1'b1)
    begin
        if(s6_s > 0) G_score  = s6_s *a_sign + b_sign ;
        else         G_score  = s6_s / a_sign + b_sign; 
    end
    else
    begin 
        G_score= 4'b0000;
    end
   
end

/*------------------------Count---------------------------*/
always@(*)
begin
    if(opt[0]==1'b1)
    begin
        if(A_score >= pas_score) cpr0 = 1'b1;
        else  cpr0 = 1'b0;
    end
    else
    begin
        if(A_score_ns >= pas_score_ns) cpr0=1'b1;
        else cpr0=1'b0;
    end
end

always@(*)
begin
    if(opt[0]==1'b1)
    begin
        if(B_score >= pas_score) cpr1 = 1'b1;
        else  cpr1 = 1'b0;
    end
    else
    begin
        if(B_score_ns >= pas_score_ns) cpr1 = 1'b1;
        else cpr1 = 1'b0;
    end
end
always@(*)
begin
    if(opt[0]==1'b1)
    begin
        if(C_score >= pas_score) cpr2 = 1'b1;
        else  cpr2 = 1'b0;
    end
    else
    begin
        if(C_score_ns >= pas_score_ns) cpr2 = 1'b1;
        else cpr2 = 1'b0;
    end
end
always@(*)
begin
    if(opt[0]==1'b1)
    begin
        if(D_score >= pas_score) cpr3 = 1'b1;
        else  cpr3 = 1'b0;
    end
    else
    begin
        if(D_score_ns >= pas_score_ns) cpr3=1'b1;
        else cpr3=1'b0;
    end
end
always@(*)
begin
    if(opt[0]==1'b1)
    begin
        if(E_score >= pas_score) cpr4 = 1'b1;
        else  cpr4 = 1'b0;
    end
    else
    begin
        if(E_score_ns >= pas_score_ns) cpr4=1'b1;
        else cpr4=1'b0;
    end
end
always@(*)
begin
    if(opt[0]==1'b1)
    begin
        if(F_score >= pas_score) cpr5 = 1'b1;
        else  cpr5 = 1'b0;
    end
    else
    begin
        if(F_score_ns >= pas_score_ns) cpr5 = 1'b1;
        else cpr5 = 1'b0;
    end
end
always@(*)
begin
    if(opt[0]==1'b1)
    begin
        if(G_score >= pas_score) cpr6 = 1'b1;
        else  cpr6 = 1'b0;
    end
    else
    begin
        if(G_score_ns >= pas_score_ns) cpr6 = 1'b1;
        else cpr6 = 1'b0;
    end
end
assign outp = cpr0 + cpr1 + cpr2 + cpr3 + cpr4 + cpr5 + cpr6;
assign outf = 7 - outp;
assign out=(opt[2]==1'b0)? outp : outf ;

/*----------------------ID Rank-------------------------*/


endmodule
