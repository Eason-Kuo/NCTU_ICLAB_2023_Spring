//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright Optimum Application-Specific Integrated System Laboratory
//    All Right Reserved
//		Date		: 2023/03
//		Version		: v1.0
//   	File Name   : INV_IP.v
//   	Module Name : INV_IP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module INV_IP #(parameter IP_WIDTH = 6) (
    // Input signals
    IN_1, IN_2,
    // Output signals
    OUT_INV
);

// ===============================================================
// Declaration
// ===============================================================
input      [IP_WIDTH-1:0] IN_1, IN_2;
output reg [IP_WIDTH-1:0] OUT_INV;

wire  [1:128] out;

wire  [IP_WIDTH-1:0]prime;
wire  [IP_WIDTH-1:0]x;


assign prime = (IN_1 > IN_2 ) ? IN_1 : IN_2 ;
assign x     = (IN_1 > IN_2 ) ? IN_2 : IN_1 ;
genvar i ;

generate
    for(i=1; i < 128; i= i+1)begin
        assign out[i] = (i*x % prime ==1) ? 1 : 0 ;     
    end
endgenerate

always@(*)begin
    if(x == 1) OUT_INV = 1;
    

    else if(out[1  ] == 1)  OUT_INV = 1  ;
    else if(out[2  ] == 1)  OUT_INV = 2  ;
    else if(out[3  ] == 1)  OUT_INV = 3  ;
    else if(out[4  ] == 1)  OUT_INV = 4  ;
    else if(out[5  ] == 1)  OUT_INV = 5  ;
    else if(out[6  ] == 1)  OUT_INV = 6  ;
    else if(out[7  ] == 1)  OUT_INV = 7  ;
    else if(out[8  ] == 1)  OUT_INV = 8  ;
    else if(out[9  ] == 1)  OUT_INV = 9  ;
    else if(out[10 ] == 1)  OUT_INV = 10 ;

    else if(out[11 ] == 1)  OUT_INV = 11 ;
    else if(out[12 ] == 1)  OUT_INV = 12 ;
    else if(out[13 ] == 1)  OUT_INV = 13 ;
    else if(out[14 ] == 1)  OUT_INV = 14 ;
    else if(out[15 ] == 1)  OUT_INV = 15 ;
    else if(out[16 ] == 1)  OUT_INV = 16 ;
    else if(out[17 ] == 1)  OUT_INV = 17 ;
    else if(out[18 ] == 1)  OUT_INV = 18 ;
    else if(out[19 ] == 1)  OUT_INV = 19 ;
    else if(out[20 ] == 1)  OUT_INV = 20 ;

    else if(out[21 ] == 1)  OUT_INV = 21 ;
    else if(out[22 ] == 1)  OUT_INV = 22 ;
    else if(out[23 ] == 1)  OUT_INV = 23 ;
    else if(out[24 ] == 1)  OUT_INV = 24 ;
    else if(out[25 ] == 1)  OUT_INV = 25 ;
    else if(out[26 ] == 1)  OUT_INV = 26 ;
    else if(out[27 ] == 1)  OUT_INV = 27 ;
    else if(out[28 ] == 1)  OUT_INV = 28 ;
    else if(out[29 ] == 1)  OUT_INV = 29 ;
    else if(out[30 ] == 1)  OUT_INV = 30 ;

    else if(out[31 ] == 1)  OUT_INV = 31 ;
    else if(out[32 ] == 1)  OUT_INV = 32 ;
    else if(out[33 ] == 1)  OUT_INV = 33 ;
    else if(out[34 ] == 1)  OUT_INV = 34 ;
    else if(out[35 ] == 1)  OUT_INV = 35 ;
    else if(out[36 ] == 1)  OUT_INV = 36 ;
    else if(out[37 ] == 1)  OUT_INV = 37 ;
    else if(out[38 ] == 1)  OUT_INV = 38 ;
    else if(out[39 ] == 1)  OUT_INV = 39 ;
    else if(out[40 ] == 1)  OUT_INV = 40 ;

    else if(out[41 ] == 1)  OUT_INV = 41 ;
    else if(out[42 ] == 1)  OUT_INV = 42 ;
    else if(out[43 ] == 1)  OUT_INV = 43 ;
    else if(out[44 ] == 1)  OUT_INV = 44 ;
    else if(out[45 ] == 1)  OUT_INV = 45 ;
    else if(out[46 ] == 1)  OUT_INV = 46 ;
    else if(out[47 ] == 1)  OUT_INV = 47 ;
    else if(out[48 ] == 1)  OUT_INV = 48 ;
    else if(out[49 ] == 1)  OUT_INV = 49 ;
    else if(out[50 ] == 1)  OUT_INV = 50 ;

    else if(out[51 ] == 1)  OUT_INV = 51 ;
    else if(out[52 ] == 1)  OUT_INV = 52 ;
    else if(out[53 ] == 1)  OUT_INV = 53 ;
    else if(out[54 ] == 1)  OUT_INV = 54 ;
    else if(out[55 ] == 1)  OUT_INV = 55 ;
    else if(out[56 ] == 1)  OUT_INV = 56 ;
    else if(out[57 ] == 1)  OUT_INV = 57 ;
    else if(out[58 ] == 1)  OUT_INV = 58 ;
    else if(out[59 ] == 1)  OUT_INV = 59 ;
    else if(out[60 ] == 1)  OUT_INV = 60 ;

    else if(out[61 ] == 1)  OUT_INV = 61 ;
    else if(out[62 ] == 1)  OUT_INV = 62 ;
    else if(out[63 ] == 1)  OUT_INV = 63 ;
    else if(out[64 ] == 1)  OUT_INV = 64 ;
    else if(out[65 ] == 1)  OUT_INV = 65 ;
    else if(out[66 ] == 1)  OUT_INV = 66 ;
    else if(out[67 ] == 1)  OUT_INV = 67 ;
    else if(out[68 ] == 1)  OUT_INV = 68 ;
    else if(out[69 ] == 1)  OUT_INV = 69 ;
    else if(out[70 ] == 1)  OUT_INV = 70 ;

    else if(out[71] == 1)  OUT_INV =  71;
    else if(out[72] == 1)  OUT_INV =  72;
    else if(out[73] == 1)  OUT_INV =  73;
    else if(out[74] == 1)  OUT_INV =  74;
    else if(out[75] == 1)  OUT_INV =  75;
    else if(out[76] == 1)  OUT_INV =  76;
    else if(out[77] == 1)  OUT_INV =  77;
    else if(out[78] == 1)  OUT_INV =  78;
    else if(out[79] == 1)  OUT_INV =  79;
    else if(out[80] == 1)  OUT_INV =  80;

    else if(out[81] == 1)  OUT_INV =  81;
    else if(out[82] == 1)  OUT_INV =  82;
    else if(out[83] == 1)  OUT_INV =  83;
    else if(out[84] == 1)  OUT_INV =  84;
    else if(out[85] == 1)  OUT_INV =  85;
    else if(out[86] == 1)  OUT_INV =  86;
    else if(out[87] == 1)  OUT_INV =  87;
    else if(out[88] == 1)  OUT_INV =  88;
    else if(out[89] == 1)  OUT_INV =  89;
    else if(out[90] == 1)  OUT_INV =  90;

    else if(out[91 ] == 1)  OUT_INV =  91 ;
    else if(out[92 ] == 1)  OUT_INV =  92 ;
    else if(out[93 ] == 1)  OUT_INV =  93 ;
    else if(out[94 ] == 1)  OUT_INV =  94 ;
    else if(out[95 ] == 1)  OUT_INV =  95 ;
    else if(out[96 ] == 1)  OUT_INV =  96 ;
    else if(out[97 ] == 1)  OUT_INV =  97 ;
    else if(out[98 ] == 1)  OUT_INV =  98 ;
    else if(out[99 ] == 1)  OUT_INV =  99 ;
    else if(out[100] == 1)  OUT_INV =  100;

    else if(out[101] == 1)  OUT_INV =  101;
    else if(out[102] == 1)  OUT_INV =  102;
    else if(out[103] == 1)  OUT_INV =  103;
    else if(out[104] == 1)  OUT_INV =  104;
    else if(out[105] == 1)  OUT_INV =  105;
    else if(out[106] == 1)  OUT_INV =  106;
    else if(out[107] == 1)  OUT_INV =  107;
    else if(out[108] == 1)  OUT_INV =  108;
    else if(out[109] == 1)  OUT_INV =  109;
    else if(out[110] == 1)  OUT_INV =  110;

    else if(out[111] == 1)  OUT_INV = 111 ;
    else if(out[112] == 1)  OUT_INV = 112 ;
    else if(out[113] == 1)  OUT_INV = 113 ;
    else if(out[114] == 1)  OUT_INV = 114 ;
    else if(out[115] == 1)  OUT_INV = 115 ;
    else if(out[116] == 1)  OUT_INV = 116 ;
    else if(out[117] == 1)  OUT_INV = 117 ;
    else if(out[118] == 1)  OUT_INV = 118 ;
    else if(out[119] == 1)  OUT_INV = 119 ;
    else if(out[120] == 1)  OUT_INV = 120 ;

    else if(out[121] == 1)  OUT_INV =  121;
    else if(out[122] == 1)  OUT_INV =  122;
    else if(out[123] == 1)  OUT_INV =  123;
    else if(out[124] == 1)  OUT_INV =  124;
    else if(out[125] == 1)  OUT_INV =  125;
    else if(out[126] == 1)  OUT_INV =  126;
    else if(out[127] == 1)  OUT_INV =  127;
    else  OUT_INV =  0;


end


endmodule

