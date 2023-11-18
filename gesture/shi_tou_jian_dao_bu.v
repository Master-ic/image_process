`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:23:08 04/14/2023 
// Design Name: 
// Module Name:    shi_tou_jian_dao_bu 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module shi_tou_jian_dao_bu(

    input clk,
    input rst_n,
    input per_frame_clken,
    input per_img_Bit,
   
    input [9:0] xpos,
    input [9:0] ypos,

    output reg [2:0]led
  
    );

    reg [15:0] hand_cnt;   
    wire flag ;//开始本帧数据y
    assign flag = (xpos == 1 && ypos == 1)? 1'b1:1'b0;
    //计数
always @(posedge clk or negedge rst_n)begin
    if(rst_n == 1'b0)begin
        hand_cnt <= 0;
    end
    else if(flag)
        hand_cnt <= 0;
    else if(per_frame_clken && per_img_Bit == 1 )
        hand_cnt <= hand_cnt+'d1;
    else 
        hand_cnt <= hand_cnt;
end

always @(posedge clk or negedge rst_n)begin
    if(rst_n == 1'b0)
    begin
        led<=0;
    end
    else if(xpos == 600 && ypos == 400)
        begin
    if(hand_cnt<=100)
    led<=0;
   else if(hand_cnt>=5000&&hand_cnt<1_0000)
        led<=3'b111;//有手
       if(hand_cnt>=10000&&hand_cnt<2_0000)
        led<=3'b001;//1
         if(hand_cnt>=2_0000&&hand_cnt<3_0000)
         led<=3'b010;//2
         if(hand_cnt>=3_0000&&hand_cnt<4_0000)
         led<=3'b011;//3
         if(hand_cnt>=4_0000&&hand_cnt<5_0000)
         led<=3'b100;//4
         if(hand_cnt>=5_0000&&hand_cnt<6_0000)
         led<=3'b101;//5
         
        end
end
// else if(xpos == 600 && ypos == 400)
//     begin
//     if(hand_cnt>0&&hand_cnt<=3500)
//     led<=3'b001;//石头
//     else 

//         if(hand_cnt<17000&&hand_cnt>3400)
//         led<=3'b010;//剪刀 识别拳头还行
//     else
//         led<=3'b100;//布
//     end
//

//*****************判断有无手***********//
//傻逼verilog狗都不写草泥吗的狗比

// else if(xpos == 600 && ypos == 400)
//     begin
// if(hand_cnt<=100)
// led<=0;
// else if(hand_cnt>=500)
//     led<=3'b001;
//     end
//*****************判断有无手***********//
//傻逼verilog狗都不写草泥吗的狗比



//     reg [10:0] cnt ;
//     always@(posedge clk)
//     begin
//      if(xpos==638&&ypos==478)
//             cnt<=0;
//       else
//          if(de_i&&rgb_data_out==23'b0000_0000_0000_0000_0000_0000)
//            cnt<=cnt+1'b1;
//          else
//            cnt<=cnt;
//     end
//     always@(posedge clk or negedge rst_n)
//     begin
//         if(!rst_n) 
//         led<=0;
//         else if(xpos == 600 && ypos == 400)
//           begin
//          if(cnt>=0&&cnt<=350)//石头
//          begin
//               led<=3'b001;
//         end  
//          else if (cnt>340&&cnt<1700)//布
//          begin
//                led<=3'b010;
//         end  
//          else if (cnt>=1700)//剪刀1250
//          begin
//                  led<=3'b100;
//         end     
//         else 
//              led<=led;
//     end
// end
     
// assign vs_o = vs_i;
// assign hs_o = hs_i;
// assign de_o = de_i;
// assign rgb_data_out = (ypos==265&&rgb_data==23'b0000_0000_0100_1000_1000_1111)?23'b0000_0000_0000_0000_0000_0000:rgb_data;
endmodule
