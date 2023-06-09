module OS(input clk, INF.OS_inf inf);
import usertype::*;

/*----------------INFO-----------------------*/

/* THE PRICE OF THE ITEMS && REWARD EXP  */ 
//---------------------------------------//
//ITEMS--------------PRICE-------EXP-----//
//LARGR(2'b01)       +300        +60     // 
//MEDIUN(2'b10)      +200        +40     //   
//SMALL (2'b11)      +100        +20     //   
//---------------------------------------//

/* THE DELIVERY FEE                        */ 
//-----------------------------------------//
//USER_LEVELS---------EXP-------DELIVER_FEE//
//PLATINUM(2'b00)     N/A        +10       // 
//GOLD(2'b01)         4000       +30       // 
//SILVER(2'b10)       2500       +50       //   
//COPPER(2'b11)       1000       +70       //   
//-----------------------------------------//

/*-------------------------------------------*/

typedef enum logic  [4:0] { IDLE				    = 5'd0    ,
							ACTION                  = 5'd1    ,
							ITEM             	    = 5'd2    , 
							NUM_ITEM     	        = 5'd3    ,
							SELLER_ID               = 5'd4    ,
                            READ_DRAM_BUYER         = 5'd5    ,
                            READ_DRAM_SELLER        = 5'd6    ,
                            COMPUTE                 = 5'd7    ,
                            WRITE_DRAM_BUYER        = 5'd8    ,
                            WRITE_DRAM_SELLER       = 5'd9    ,
                            OUTPUT                  = 5'd10   ,
                            MONEY                   = 5'd11   ,
							CHECK_BUYER_MONEY       = 5'd12   ,
                            CHECK_SELLER_STOCKS     = 5'd13
							}  state_t ;


logic       [3:0]cur_state,nx_state;
logic       [3:0]cnt_exceed_five;
Action      act_reg;
User_id     buyer_ID_reg;
User_id     seller_ID_reg;
Item_id		item_ID_reg;
Item_num    item_num_reg;
Money       amnt_reg;



Info_64     buyer_Info;
Info_64     seller_Info;

Info_64     temp_buyer;
Info_64     temp_seller;

logic       [5:0]L_I[0:1] ;
logic       [5:0]M_I[0:1] ;
logic       [5:0]S_I[0:1] ;
logic       [1:0]U_L[0:1] ;
logic       [11:0]E[0:1] ;

logic       [15:0]M[0:1] ;
logic       [1:0]I_ID[0:1];
logic       [5:0]I_num[0:1];
logic       [7:0]S_ID[0:1];

logic       success_deal;
logic       success_return;
logic       [7:0]delivery_fee;
logic       [15:0]exper;
Error_Msg   error_message_buy;
Error_Msg   error_return;

integer     i;
logic       [8:0]buyer_seller_record[0:255];
logic       oper_buyer_record[0:255];
logic       oper_seller_record[0:255];
logic       [7:0]cnt_C_in_valid_b ;
logic       [7:0]cnt_C_in_valid_s ;
logic       [1:0]flag_check;
logic       wrong_action,deposit_flag,wrong_action1,wrong_action2;
logic [10:0]b,c;
logic  [10:0]a;
logic       flag_upgrade ;
logic       C_flag ;
//0 is buyer
assign      L_I[0]  = buyer_Info.large_items_info;
assign      M_I[0]  = buyer_Info.medium_items_info;
assign      S_I[0]  = buyer_Info.small_items_info;
assign      U_L[0]  = buyer_Info.user_level_info;
assign        E[0]  = buyer_Info.exp_info;
assign        M[0]  = buyer_Info.money_info;
assign     I_ID[0]  = buyer_Info.item_id_info;
assign     I_num[0] = buyer_Info.item_num_info;
assign     S_ID[0]  = buyer_Info.seller_ID_info;
//1 is seller 
assign      L_I[1] = seller_Info.large_items_info;
assign      M_I[1] = seller_Info.medium_items_info;
assign      S_I[1] = seller_Info.small_items_info;
assign      U_L[1] = seller_Info.user_level_info;
assign        E[1] = seller_Info.exp_info;
assign        M[1] = seller_Info.money_info;
assign     I_ID[1] = seller_Info.item_id_info;
assign     I_num[1] = seller_Info.item_num_info;
assign     S_ID[1] = seller_Info.seller_ID_info;

/*-------------------------------------------*/
/*                DESIGN                     */
/*-------------------------------------------*/
always_ff@(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)      cur_state <= IDLE ;
    else begin
                        cur_state <= nx_state ;
    end
end

always_comb begin
    case(cur_state)
        IDLE : begin
            if(inf.act_valid)  nx_state = ACTION ;
            else nx_state = IDLE ;
        end
        ACTION : begin
            case(act_reg)   
                Buy :     nx_state = ITEM ;
                Check : begin
                    if(inf.id_valid)                nx_state = CHECK_SELLER_STOCKS ;
                    else if(cnt_exceed_five >= 5)   nx_state = CHECK_BUYER_MONEY ;
                    else                            nx_state = ACTION ;
                end

                Deposit : nx_state = MONEY    ;
                Return :  nx_state = ITEM    ;
                default : nx_state = ACTION ;
            endcase                         
        end
        ITEM : begin
            if(inf.item_valid )  nx_state = NUM_ITEM ;
            else                 nx_state = ITEM ;
        end
        NUM_ITEM : begin
            if(inf.num_valid )   nx_state = SELLER_ID ;
            else                 nx_state = NUM_ITEM ;
        end
        SELLER_ID : begin
            if(inf.id_valid )    nx_state = READ_DRAM_BUYER ;
            else                 nx_state = SELLER_ID ;  
        end
        /*----------READ DRAM && WRITE DRAM-----------------*/
        READ_DRAM_BUYER : begin
            if(inf.C_out_valid)  begin
                if(act_reg == Deposit) nx_state = COMPUTE ; 
                else                   nx_state = READ_DRAM_SELLER ;
            end
            else                 nx_state = READ_DRAM_BUYER ;  
        end
        READ_DRAM_SELLER : begin
            if(inf.C_out_valid)  nx_state = COMPUTE ; 
            else                 nx_state = READ_DRAM_SELLER ;  
        end
        COMPUTE : begin //7
            if((wrong_action || error_return != No_Err)&& act_reg == Return  && error_return != No_Err ) nx_state = OUTPUT ;
            else if(deposit_flag == 1  ) nx_state = OUTPUT ;
            else              nx_state = WRITE_DRAM_BUYER ;
        end
        WRITE_DRAM_BUYER : begin
            if(inf.C_out_valid)  begin
                if(act_reg == Deposit) nx_state = OUTPUT ; 
                else                   nx_state = WRITE_DRAM_SELLER ;
            end 
            else                 nx_state = WRITE_DRAM_BUYER ; 
        end
        WRITE_DRAM_SELLER : begin
            if(inf.C_out_valid)  nx_state = OUTPUT ;
            else                 nx_state = WRITE_DRAM_SELLER ; 
        end
        /*--------------------------------------------------*/

        /*--------------------CHECK-------------------------*/
        CHECK_BUYER_MONEY : begin
            if(inf.C_out_valid)  nx_state = OUTPUT ;
            else                 nx_state = CHECK_BUYER_MONEY ; 
        end
        CHECK_SELLER_STOCKS : begin
            if(inf.C_out_valid)  nx_state = OUTPUT ;
            else                 nx_state = CHECK_SELLER_STOCKS ; 
        end
        /*--------------------------------------------------*/

        MONEY : begin
            if(inf.amnt_valid)   nx_state = READ_DRAM_BUYER ;
            else                 nx_state = MONEY ;
        end

        OUTPUT : begin //10
           nx_state = IDLE ;
        end
    
        default : nx_state = cur_state ;
    endcase
end

always_ff@(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)     cnt_exceed_five <= 0;
    else begin
        case(cur_state)
            ACTION : cnt_exceed_five <= cnt_exceed_five + 1;
            default : cnt_exceed_five <= 0;
        endcase
    end 
end

always_comb begin
    if(act_reg == Deposit && M[0] > (16'd65535 - amnt_reg)) deposit_flag = 1 ;
    else                 deposit_flag = 0 ;       
end
/*-------------------------------------------*/
/*            EAT INPUT                      */
/*-------------------------------------------*/
always_ff@(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)     buyer_ID_reg <= 0;
    else begin
        if(inf.id_valid && cur_state == IDLE)  buyer_ID_reg <= inf.D.d_id[0];
        else                                   buyer_ID_reg <= buyer_ID_reg ;
    end
end

always_ff@(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)     seller_ID_reg <= 0;
    else begin
        if(inf.id_valid && (cur_state == SELLER_ID || cur_state == ACTION))  seller_ID_reg <= inf.D.d_id[0];
        else                                        seller_ID_reg <= seller_ID_reg ;
    end
end

always_ff@(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)          act_reg <= 0;
    else begin
        if(inf.act_valid )  act_reg <= inf.D.d_act[0];
        else                act_reg <= act_reg ;
    end
end


always_ff@(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)     item_ID_reg <= 0;
    else begin
        if(inf.item_valid )  item_ID_reg <= inf.D.d_item[0];
        else                 item_ID_reg <= item_ID_reg ;
    end
end
always_ff@(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)     item_num_reg <= 0;
    else begin
        if(inf.num_valid )  item_num_reg <= inf.D.d_item_num;
        else                item_num_reg <= item_num_reg ;
    end
end

always_ff@(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)     amnt_reg <= 0;
    else begin
        if(inf.amnt_valid )  amnt_reg <= inf.D.d_money;
        else                 amnt_reg <= amnt_reg ;
    end
end


always_comb begin
    case(cur_state)
        READ_DRAM_BUYER  :  inf.C_addr = buyer_ID_reg  ;
        READ_DRAM_SELLER :  inf.C_addr = seller_ID_reg ;
        WRITE_DRAM_BUYER :  inf.C_addr = buyer_ID_reg  ;
        WRITE_DRAM_SELLER : inf.C_addr = seller_ID_reg ;
        CHECK_BUYER_MONEY :  inf.C_addr = buyer_ID_reg  ;
        CHECK_SELLER_STOCKS :inf.C_addr = seller_ID_reg ;
        default : inf.C_addr = 0 ;
    endcase
end

always_ff@(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)  buyer_Info <= 0 ;
    else begin
        case(cur_state)
            READ_DRAM_BUYER : begin
                if(inf.C_out_valid) buyer_Info <= inf.C_data_r ; 
            end
            CHECK_BUYER_MONEY : begin
                if(inf.C_out_valid) buyer_Info <= inf.C_data_r ;
            end
            
            default :;  
        endcase
    end
end

always_ff@(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)  seller_Info <= 0 ;
    else begin
        case(cur_state)
            READ_DRAM_SELLER : begin
                if(inf.C_out_valid) seller_Info <= inf.C_data_r ; 
            end
            CHECK_SELLER_STOCKS : begin
                if(inf.C_out_valid) seller_Info <= inf.C_data_r ;
            end
            default :;  
        endcase
    end
end

/*-------------------------------------------*/
/*              COMPUTE_BUYER                */
/*-------------------------------------------*/
//delivery_fee
always_comb begin
    case(U_L[0])
        2'b00 : delivery_fee = 10;
        2'b01 : delivery_fee = 30;
        2'b10 : delivery_fee = 50;
        2'b11 : delivery_fee = 70;
        default : delivery_fee = 0;
    endcase
end

//See it can return or not
always_comb begin
    if(act_reg == Return)begin
        if(buyer_Info.seller_ID_info != seller_ID_reg)    success_return = 0;
        else if(buyer_Info.item_id_info != item_ID_reg)   success_return = 0;
        else if(buyer_Info.item_num_info != item_num_reg) success_return = 0;
        else    success_return = 1;
    end
    else    success_return = 0;
    
end

//large item info
always_comb begin 
    case(act_reg)
        Buy : begin
            if(item_ID_reg == 2'b01)begin
                if(L_I[0] > (63 -item_num_reg))                   temp_buyer.large_items_info = L_I[0] ;
                else if(L_I[1] < item_num_reg)                    temp_buyer.large_items_info = L_I[0] ;
                else if(M[0] < (item_num_reg*300 + delivery_fee)) temp_buyer.large_items_info = L_I[0] ;
                else                                              temp_buyer.large_items_info = L_I[0] + item_num_reg;                                       
            end
            else    temp_buyer.large_items_info = L_I[0] ;
        end
        Return : begin
            if(success_return && wrong_action == 0)begin
                if(item_ID_reg == 2'b01)    temp_buyer.large_items_info = L_I[0] - item_num_reg;
                else                        temp_buyer.large_items_info = L_I[0] ;
            end
            else    temp_buyer.large_items_info = L_I[0] ;
        end
        default : temp_buyer.large_items_info = L_I[0] ;
    endcase
end
//medium item info
always_comb begin
    case(act_reg)
        Buy : begin
            if(item_ID_reg == 2'b10)begin
                if(M_I[0] > (63 -item_num_reg))                  temp_buyer.medium_items_info = M_I[0] ;
                else if(M_I[1] < item_num_reg)                   temp_buyer.medium_items_info = M_I[0] ;
                else if(M[0] < item_num_reg*200 +delivery_fee)   temp_buyer.medium_items_info = M_I[0] ;
                else                                             temp_buyer.medium_items_info = M_I[0] + item_num_reg;                                       
            end
            else    temp_buyer.medium_items_info = M_I[0] ;
        end
        Return : begin
            if(success_return && wrong_action ==0)begin
                if(item_ID_reg == 2'b10)    temp_buyer.medium_items_info = M_I[0] - item_num_reg;
                else                        temp_buyer.medium_items_info = M_I[0] ;
            end
            else    temp_buyer.medium_items_info = M_I[0] ;
        end
        default : temp_buyer.medium_items_info = M_I[0] ;
    endcase
end
//small item info
always_comb begin
    case(act_reg)
        Buy : begin
            if(item_ID_reg == 2'b11)begin
                if(S_I[0] > (63 -item_num_reg))                temp_buyer.small_items_info = S_I[0] ;
                else if(S_I[1] < item_num_reg)                 temp_buyer.small_items_info = S_I[0] ;
                else if(M[0] < item_num_reg*100 +delivery_fee) temp_buyer.small_items_info = S_I[0] ;
                else                                           temp_buyer.small_items_info = S_I[0] + item_num_reg;                                       
            end
            else    temp_buyer.small_items_info = S_I[0] ;
        end
        Return : begin
            if(success_return && wrong_action == 0)begin
                if(item_ID_reg == 2'b11)    temp_buyer.small_items_info = S_I[0] - item_num_reg;
                else                        temp_buyer.small_items_info = S_I[0] ;
            end
            else    temp_buyer.small_items_info = S_I[0] ;
        end
        default : temp_buyer.small_items_info = S_I[0] ;
    endcase
end

//See deal is success or not. 1 is success. 
always_comb begin
    case(item_ID_reg)
        2'b01 : begin
            if((temp_buyer.large_items_info != L_I[0]  || item_num_reg == 0 )&& error_message_buy == No_Err )  success_deal = 1;
            else                                                              success_deal = 0;
        end
        2'b10 : begin
            if((temp_buyer.medium_items_info != M_I[0]  || item_num_reg == 0 )&& error_message_buy == No_Err ) success_deal = 1;
            else                                        success_deal = 0;
        end
        2'b11 : begin
             if((temp_buyer.small_items_info != S_I[0]  || item_num_reg == 0 ) && error_message_buy == No_Err ) success_deal = 1;
            else                                        success_deal = 0;
        end
        default : success_deal = 0;
    endcase
end

// always_ff@(posedge clk or negedge inf.rst_n)begin
//     if(!inf.rst_n)      flag_upgrade <= 0;
//     else begin
//         if(temp_buyer.exp_info == 0 && temp_buyer.exp_info != E[0] )  flag_upgrade <= 1;
//         else                          flag_upgrade <= 0;
//     end
// end
//user level info && exp info

always_comb begin
    if(success_deal) begin
        case(item_ID_reg) 
            2'b01 : exper   = E[0] + 60*item_num_reg ;
            2'b10 : exper   = E[0] + 40*item_num_reg ;
            2'b11 : exper   = E[0] + 20*item_num_reg ;
            default : exper = E[0] ;
        endcase
    end
    else    exper = E[0] ;
end

always_comb begin
    case(act_reg)
        Buy : begin
            if(success_deal) begin
                case(U_L[0])
                    2'b00 : temp_buyer.exp_info = 0;
                    2'b01 : temp_buyer.exp_info = (exper >= 4000) ? 0 : exper;
                    2'b10 : temp_buyer.exp_info = (exper >= 2500) ? 0 : exper;
                    2'b11 : temp_buyer.exp_info = (exper >= 1000) ? 0 : exper;
                    default : temp_buyer.exp_info = E[0];

                endcase
               
            end
            else          temp_buyer.exp_info = E[0];
        end
         default : temp_buyer.exp_info = E[0];
    endcase
end



assign flag_upgrade = (temp_buyer.exp_info != E[0] && temp_buyer.exp_info == 0 && error_message_buy == No_Err) ? 1 : 0 ;
//assign flag_upgrade = (E[0]  != 0 && error_message_buy == No_Err) ? 1 : 0 ;
//assign flag_upgrade = (temp_buyer.exp_info != E[0] && temp_buyer.exp_info == 0 ) ? 1 : 0 ;

always_comb begin
    case(act_reg)
         Buy : begin
            if(success_deal ) begin
                case(U_L[0])
                    2'b00 :   temp_buyer.user_level_info = 2'b00;
                    2'b01 :   temp_buyer.user_level_info = (exper >= 4000 ) ? 2'b00 : 2'b01 ;
                    2'b10 :   temp_buyer.user_level_info = (exper >= 2500 ) ? 2'b01 : 2'b10 ;
                    2'b11 :   temp_buyer.user_level_info = (exper >= 1000 ) ? 2'b10 : 2'b11 ;
                    default : temp_buyer.user_level_info = U_L[0];
                
                endcase
            end
            else temp_buyer.user_level_info = U_L[0];
        end

         default:temp_buyer.user_level_info = U_L[0];
    endcase
end
// always_comb begin
//     case(act_reg)
//         Buy : begin
//             if(flag_upgrade ) begin
//                 case(U_L[0])
//                     2'b00 :   temp_buyer.user_level_info = 2'b00 ;
//                     2'b01 :   temp_buyer.user_level_info = 2'b00 ;
//                     2'b10 :   temp_buyer.user_level_info = 2'b01 ;
//                     2'b11 :   temp_buyer.user_level_info = 2'b10 ;
//                     default : temp_buyer.user_level_info = U_L[0];
                
//                 endcase
//             end
//             else temp_buyer.user_level_info = U_L[0];
//         end
//         default:temp_buyer.user_level_info = U_L[0];
//     endcase
// end
// always_comb begin
//     case(act_reg)
//         Buy : begin
//             if(success_deal) begin
//                 case(U_L[0])
//                     2'b00 :   temp_buyer.user_level_info = 2'b00 ;
//                     2'b01 :   temp_buyer.user_level_info = (temp_buyer.exp_info == 0) ? 2'b00 : 2'b01 ;
//                     2'b10 :   temp_buyer.user_level_info = (temp_buyer.exp_info == 0) ? 2'b01 : 2'b10 ;
//                     2'b11 :   temp_buyer.user_level_info = (temp_buyer.exp_info == 0) ? 2'b10 : 2'b00 ;
//                     default : temp_buyer.user_level_info = U_L[0];
//                 endcase
//             end
//             else begin
//                 if(flag_upgrade == 0 )  begin
//                     case(U_L[0])
//                         2'b00 :   temp_buyer.user_level_info = 2'b00 ;
//                         2'b01 :   temp_buyer.user_level_info = 2'b00 ;
//                         2'b10 :   temp_buyer.user_level_info = 2'b01 ;
//                         2'b11 :   temp_buyer.user_level_info = 2'b10 ;
//                         default : temp_buyer.user_level_info = U_L[0];
//                     endcase
//                 end
//                 else    temp_buyer.user_level_info = U_L[0];  
//             end
//            // else    temp_buyer.user_level_info = U_L[0];
//         end
//         default :  temp_buyer.user_level_info = U_L[0];
//     endcase
// end

//money info
always_comb begin
    case(act_reg)
        Buy : begin
            if(error_message_buy == No_Err)begin
                case(item_ID_reg)
                    2'b01 : temp_buyer.money_info   = M[0] - (300*item_num_reg) - delivery_fee;
                    2'b10 : temp_buyer.money_info   = M[0] - (200*item_num_reg) - delivery_fee;
                    2'b11 : temp_buyer.money_info   = M[0] - (100*item_num_reg) - delivery_fee;
                    default : temp_buyer.money_info = M[0] ;
                endcase
            end
            else    temp_buyer.money_info = M[0];
        end
        Return : begin
            if(success_return && wrong_action == 0)begin
                case(item_ID_reg)
                    2'b01 : temp_buyer.money_info   = M[0] + (300*item_num_reg) ;
                    2'b10 : temp_buyer.money_info   = M[0] + (200*item_num_reg) ;
                    2'b11 : temp_buyer.money_info   = M[0] + (100*item_num_reg) ;
                    default : temp_buyer.money_info = M[0] ;
                endcase
            end
            else    temp_buyer.money_info = M[0] ;
        end

        Deposit : begin
            temp_buyer.money_info = ((M[0]+ amnt_reg) > 16'd65535  ) ? M[0] : (M[0] + amnt_reg);
        end

            
        
        default :   temp_buyer.money_info = M[0] ;
    endcase
end

//shopping history
always_comb begin
    case(act_reg)
        Buy : begin
            if(error_message_buy == No_Err) temp_buyer.item_id_info = item_ID_reg ; 
            else             temp_buyer.item_id_info = I_ID[0] ;
        end 
        default : temp_buyer.item_id_info = I_ID[0] ;
    endcase
end

always_comb begin
    case(act_reg)
        Buy : begin
            if(error_message_buy == No_Err) temp_buyer.item_num_info = item_num_reg ; 
            else             temp_buyer.item_num_info = I_num[0] ;
        end 
        default : temp_buyer.item_num_info = I_num[0] ;
    endcase
end

always_comb begin
    case(act_reg)
        Buy : begin
            if(error_message_buy == No_Err) temp_buyer.seller_ID_info = seller_ID_reg ; 
            else             temp_buyer.seller_ID_info = S_ID[0] ;
        end
        default : temp_buyer.seller_ID_info = S_ID[0] ;
    endcase
end



/*-------------------------------------------*/
/*              COMPUTE_SELLER               */
/*-------------------------------------------*/
//large items
always_comb begin
    case(act_reg)
        Buy : begin
            if(error_message_buy == No_Err && item_ID_reg == 2'b01)begin
                temp_seller.large_items_info = L_I[1] - item_num_reg ;
            end
            else    temp_seller.large_items_info = L_I[1] ;
        end
        Return : begin
            if(success_return && wrong_action == 0)begin
                if(item_ID_reg == 2'b01)    temp_seller.large_items_info = L_I[1] + item_num_reg;
                else                        temp_seller.large_items_info = L_I[1] ;
            end
            else    temp_seller.large_items_info = L_I[1] ;
        end
        default : temp_seller.large_items_info = L_I[1] ;
    endcase
end
//medium items
always_comb begin
    case(act_reg)
        Buy : begin
            if(error_message_buy == No_Err && item_ID_reg == 2'b10)begin
                temp_seller.medium_items_info = M_I[1] - item_num_reg ;
            end
            else    temp_seller.medium_items_info = M_I[1] ;
        end
        Return : begin
            if(success_return && wrong_action == 0)begin
                if(item_ID_reg == 2'b10)    temp_seller.medium_items_info = M_I[1] + item_num_reg;
                else                        temp_seller.medium_items_info = M_I[1] ;
            end
            else    temp_seller.medium_items_info = M_I[1] ;
        end
        default : temp_seller.medium_items_info = M_I[1] ;
    endcase
end

//small items
always_comb begin
    case(act_reg)
        Buy : begin
            if(error_message_buy == No_Err && item_ID_reg == 2'b11)begin
                temp_seller.small_items_info = S_I[1] - item_num_reg ;
            end
            else    temp_seller.small_items_info = S_I[1] ;
        end
        Return : begin
            if(success_return && wrong_action == 0)begin
                if(item_ID_reg == 2'b11)    temp_seller.small_items_info = S_I[1] + item_num_reg;
                else                        temp_seller.small_items_info = S_I[1] ;
            end
            else    temp_seller.small_items_info = S_I[1] ;
        end
        default :   temp_seller.small_items_info = S_I[1] ;
    endcase
end

//user level info && exp info
assign temp_seller.user_level_info = U_L[1] ;
assign temp_seller.exp_info = E[1] ;


//money info
always_comb begin
    case(act_reg)
        Buy : begin
            if(error_message_buy == No_Err) begin
                 case(item_ID_reg)
                    2'b01 : temp_seller.money_info   = (M[1] > 16'd65535 - (300*item_num_reg))?   16'd65535 : (M[1] + (300*item_num_reg));
                    2'b10 : temp_seller.money_info   = (M[1] > 16'd65535 - (200*item_num_reg))?   16'd65535 : (M[1] + (200*item_num_reg));
                    2'b11 : temp_seller.money_info   = (M[1] > 16'd65535 - (100*item_num_reg))?   16'd65535 : (M[1] + (100*item_num_reg));
                    default : temp_seller.money_info = M[1] ;
                endcase
            end
            else    temp_seller.money_info = M[1];
        end
        Return : begin
            if(success_return && wrong_action == 0) begin
                case(item_ID_reg)
                    2'b01 : temp_seller.money_info   = M[1] - (300*item_num_reg) ;
                    2'b10 : temp_seller.money_info   = M[1] - (200*item_num_reg) ;
                    2'b11 : temp_seller.money_info   = M[1] - (100*item_num_reg) ;
                    default : temp_seller.money_info = M[1] ;
                endcase
            end
            else    temp_seller.money_info = M[1];    
        end
        default : temp_seller.money_info = M[1];
    endcase
end

//shopping history

assign temp_seller.item_id_info = I_ID[1];
assign temp_seller.item_num_info = I_num[1];
assign temp_seller.seller_ID_info = S_ID[1];

// always_comb begin
//     case(act_reg)
//         Buy : begin
//             temp_seller.item_id_info = I_ID[1];
//         end
//         default : temp_seller.item_id_info = I_ID[1];
//     endcase
// end

// always_comb begin
//     case(act_reg)
//         Buy : begin
//             temp_seller.item_num_info = I_num[1];
//         end
//         default : temp_seller.item_num_info = I_num[1];
//     endcase
// end

// always_comb begin
//     case(act_reg)
//         Buy : begin
//             temp_seller.seller_ID_info = S_ID[1];
//         end
//         default : temp_seller.seller_ID_info = S_ID[1];
//     endcase
// end


//RECORD
always_ff@(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)begin
        for(i=0; i<256 ; i=i+1)begin
            buyer_seller_record[i] <= 0;
        end
    end
    else begin
        case(act_reg)
            Buy : begin
                if(success_deal && cur_state == OUTPUT)begin
                    buyer_seller_record[seller_ID_reg] <= buyer_ID_reg;
                end
            
            end
            default :;
        endcase
    end
end

genvar m,n ;

always_ff@(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)      flag_check <= 0 ;  //0 for money , 1 for stocks 
    else begin
        case(cur_state)
            IDLE : flag_check <= 0 ;
            CHECK_BUYER_MONEY : flag_check <= 1 ;
            CHECK_SELLER_STOCKS : flag_check <= 2;
            OUTPUT : flag_check <= flag_check ;
            default :;
        endcase
    end
end
//FIRST MAP 
generate
    for(m=0 ; m < 256; m=m+1)begin
        always_ff@(posedge clk or negedge inf.rst_n)begin
            if(!inf.rst_n)begin
                oper_buyer_record[m] <= 0 ;
            end
            else begin
                    if(inf.complete && act_reg == Buy && buyer_ID_reg == m)     
                        oper_buyer_record[m]  <= 1;
                    else if(inf.complete && act_reg == Check && buyer_ID_reg == m )  
                        oper_buyer_record[m]  <= 0;
                    else if(inf.complete  && act_reg == Check && flag_check == 2 && seller_ID_reg == m) 
                        oper_buyer_record[m]  <= 0;
                    else if(inf.complete && act_reg == Deposit && buyer_ID_reg == m) 
                        oper_buyer_record[m]  <= 0;
                    else if( inf.complete && act_reg == Return && buyer_ID_reg == m) 
                        oper_buyer_record[m]  <= 0;
                    else if( inf.complete && act_reg == Return && seller_ID_reg == m) 
                        oper_buyer_record[m]  <= 0;
                    else if(inf.complete && act_reg == Buy && seller_ID_reg == m)
                        oper_buyer_record[m]  <= 0;
                    else  oper_buyer_record[m]  <= oper_buyer_record[m];
                    
            end
        end
    end    
endgenerate
//SECOND MAP 
generate
    for(n=0 ; n < 256; n=n+1)begin
        always_ff@(posedge clk or negedge inf.rst_n)begin
            if(!inf.rst_n)begin
                oper_seller_record[n] <= 0 ;
            end
            else begin
                   if(inf.complete && act_reg == Buy && seller_ID_reg == n)     
                        oper_seller_record[n]  <= 1;
                    else if(inf.complete && act_reg == Check && flag_check == 2 && seller_ID_reg == n )  
                        oper_seller_record[n]  <= 0;
                    else if(inf.complete  && act_reg == Return  && seller_ID_reg == n) 
                        oper_seller_record[n]  <= 0;
                    else if(inf.complete && act_reg == Buy && buyer_ID_reg == n) 
                        oper_seller_record[n]  <= 0;
                    else if( inf.complete && act_reg == Check && buyer_ID_reg == n) 
                        oper_seller_record[n]  <= 0;
                    else if(inf.complete && act_reg == Deposit && buyer_ID_reg == n)
                        oper_seller_record[n]  <= 0;
                    else  oper_seller_record[n]  <= oper_seller_record[n];
            end
        end
    end    
endgenerate
//wrong_action = 0 is uncorrect
assign wrong_action =   wrong_action1 || wrong_action2 ; 

assign wrong_action1 = ((oper_buyer_record[buyer_ID_reg]  == 1) && (oper_seller_record[S_ID[0]]  == 1) ) ? 0 : 1 ;
assign wrong_action2 = (buyer_seller_record[S_ID[0]] != buyer_ID_reg)? 1 : 0 ;

assign a = buyer_seller_record[44] ;
assign b= buyer_seller_record[187] ;
assign c=S_ID[0] ;
// generate
//     for(m=0 ; m < 256; m=m+1)begin
//         always_ff@(posedge clk or negedge inf.rst_n)begin
//             if(!rst_n)begin
//                 oper_seller_record[m] <= 0 ;
//             end
//             else begin
//                 case(cur_state)
//                     OUTPUT : begin
//                         if(complete)  oper_seller_record[seller_ID_reg] <= 1;
//                         else          oper_seller_record[seller_ID_reg] <= 0;
//                     end
//                     default:;
//                 endcase
//             end
//         end
//     end    
// endgenerate
/*-------------------------------------------*/
/*              READ_DRAM                    */
/*-------------------------------------------*/

always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)  C_flag <= 0;
    else            C_flag <= 1; 
end
always_comb begin
    if(!C_flag)  inf.C_r_wb = 0 ; 
    else begin
        case(cur_state) 
            READ_DRAM_BUYER : inf.C_r_wb = 1 ; //1 for read
            READ_DRAM_SELLER : inf.C_r_wb = 1 ; 
            WRITE_DRAM_BUYER : inf.C_r_wb = 0 ; 
            WRITE_DRAM_SELLER : inf.C_r_wb = 0 ; 
            default : inf.C_r_wb = 1 ;
        endcase
    end
end

always_comb begin
    case(cur_state)
        READ_DRAM_BUYER : begin
            if(cnt_C_in_valid_b == 0) inf.C_in_valid = 1 ;
            else       inf.C_in_valid = 0 ;
        end
        READ_DRAM_SELLER : begin
            if(cnt_C_in_valid_s == 0) inf.C_in_valid = 1 ;
            else       inf.C_in_valid = 0 ;
        end
        WRITE_DRAM_BUYER : begin
            if(cnt_C_in_valid_b == 0) inf.C_in_valid = 1 ;
            else       inf.C_in_valid = 0 ;
        end
        WRITE_DRAM_SELLER : begin
            if(cnt_C_in_valid_s == 0) inf.C_in_valid = 1 ;
            else       inf.C_in_valid = 0 ;
        end
        CHECK_BUYER_MONEY : begin
            if(cnt_C_in_valid_b == 0) inf.C_in_valid = 1 ;
            else       inf.C_in_valid = 0 ;
        end
        CHECK_SELLER_STOCKS : begin
            if(cnt_C_in_valid_s == 0) inf.C_in_valid = 1 ;
            else       inf.C_in_valid = 0 ;
        end
        default : inf.C_in_valid = 0;
    endcase
end

always_comb begin
    case(cur_state)
        WRITE_DRAM_BUYER : begin
            inf.C_data_w = temp_buyer ;
        end
        WRITE_DRAM_SELLER : begin
            inf.C_data_w = temp_seller ;
        end
    
        default : inf.C_data_w = 0 ;
    endcase
end

always_ff@(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)      cnt_C_in_valid_b <= 0;
    else begin
        case(cur_state)
            READ_DRAM_BUYER : cnt_C_in_valid_b <= cnt_C_in_valid_b + 1 ;
            WRITE_DRAM_BUYER : cnt_C_in_valid_b <= cnt_C_in_valid_b + 1 ;
            CHECK_BUYER_MONEY : cnt_C_in_valid_b <= cnt_C_in_valid_b + 1 ;
            default : cnt_C_in_valid_b <= 0 ;
        endcase
    end
end

always_ff@(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)      cnt_C_in_valid_s <= 0;
    else begin
        case(cur_state)
            READ_DRAM_SELLER : cnt_C_in_valid_s <= cnt_C_in_valid_s + 1 ;
            WRITE_DRAM_SELLER : cnt_C_in_valid_s <= cnt_C_in_valid_s + 1 ;
            CHECK_SELLER_STOCKS : cnt_C_in_valid_s <= cnt_C_in_valid_s + 1 ;
            default : cnt_C_in_valid_s <= 0 ;
        endcase
    end
end











//OUTPUT
always_ff@(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n) begin
        inf.out_info  <= 0;
    end
    else begin
        if(cur_state == OUTPUT) begin
            case(act_reg)
                Buy : begin
                    if(error_message_buy == No_Err)  inf.out_info  <= temp_buyer[31:0];
                    else                             inf.out_info  <= 0 ;
                end
                Deposit : begin
                    if(M[0] > (65535 - amnt_reg)) inf.out_info  <= 0 ;
                    else                           inf.out_info  <= {16'd0, temp_buyer[31:16] } ;
                end
                Check : begin
                    if(flag_check == 2)      inf.out_info <= {14'd0, temp_seller[63:46]};
                    else                     inf.out_info <= {14'd0, temp_buyer[31:16]};
                end
                Return : begin
                    if(!wrong_action && success_return ) begin
                        inf.out_info  <=  {14'd0, temp_buyer[63:46] } ;;
                    end
                    else    inf.out_info  <= 0 ;
                end
                default : inf.out_info  <= 0 ;
            endcase
        end
        else inf.out_info  <= 0 ;
    end
end

always_ff@(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n) begin
        inf.out_valid  <= 0;
    end
    else begin
        if(cur_state == OUTPUT) inf.out_valid  <= 1;
        else                    inf.out_valid  <= 0;
    end
end
always_ff@(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n) begin
        inf.complete  <= 0;
    end
    else begin
        if(cur_state == OUTPUT)begin
            case(act_reg)
                Buy : begin
                    if(error_message_buy == No_Err )  inf.complete  <= 1 ;
                    else                    inf.complete  <= 0 ;
                end
                Deposit : begin
                    if(M[0] > (16'd65535 - amnt_reg)) inf.complete  <= 0 ;
                    else                              inf.complete  <= 1 ;
                end
                Check : begin
                    inf.complete  <= 1 ;
                end
                Return :begin
                    if(!wrong_action && success_return ) begin
                            inf.complete  <= 1;
                    end
                    else    inf.complete  <= 0;
                end
                default     inf.complete  <= 0;
            endcase
        end
        else    inf.complete  <= 0;

    end
end

always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)  inf.err_msg   <= No_Err;
    else begin
        if(cur_state == OUTPUT) begin
            case(act_reg)
                Buy : begin
                    if(!success_deal)   inf.err_msg   <= error_message_buy;
                end
                Deposit : begin
                    if(M[0] > (65535 - amnt_reg))  inf.err_msg <= Wallet_is_Full ;
                end
                Check : begin
                    inf.err_msg   <= No_Err;
                end
                Return : begin
                    if(wrong_action)    inf.err_msg   <= Wrong_act;
                    else                inf.err_msg   <= error_return;
                end
                default : inf.err_msg   <= No_Err;
            endcase
         end
        else    inf.err_msg  <= No_Err;
    end
end

always_comb begin
    case(item_ID_reg)
        2'b01 : begin
            if(L_I[0] > (63 -item_num_reg))   error_message_buy = INV_Full ;
            else if(L_I[1] < item_num_reg)    error_message_buy = INV_Not_Enough;
            else if(M[0] < (item_num_reg*300 + delivery_fee)) error_message_buy = Out_of_money;
            else                                error_message_buy = No_Err;
        end
        2'b10 : begin
            if(M_I[0] > (63 -item_num_reg))   error_message_buy = INV_Full ;
            else if(M_I[1] < item_num_reg)    error_message_buy = INV_Not_Enough;
            else if(M[0] < (item_num_reg*200 + delivery_fee)) error_message_buy = Out_of_money;
            else                                error_message_buy = No_Err;
        end
        2'b11 : begin
            if(S_I[0] > (63 -item_num_reg))   error_message_buy = INV_Full ;
            else if(S_I[1] < item_num_reg)    error_message_buy = INV_Not_Enough;
            else if(M[0] < (item_num_reg*100 + delivery_fee)) error_message_buy = Out_of_money;
            else                                error_message_buy = No_Err;
        end
        default : error_message_buy = No_Err;
    endcase
end


always_comb begin
    if(temp_buyer.seller_ID_info != seller_ID_reg)       error_return = Wrong_ID ;
    else if(temp_buyer.item_num_info != item_num_reg)    error_return = Wrong_Num ;
    else if(temp_buyer.item_id_info != item_ID_reg)       error_return = Wrong_Item ;
    else  error_return = No_Err ;
end





endmodule
