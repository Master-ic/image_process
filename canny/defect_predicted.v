`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:42:29 04/02/2023 
// Design Name: 
// Module Name:    defect_predicted 
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
module defect_predicted(
    input clk,
    input rst_n,
// input per_frame_vsync,
// input per_frame_href,
input per_frame_clken,
input [9:0]x_pos,
input [9:0]y_pos,

input  per_img_Bit,
output reg [2:0] classification
    );
reg [15:0] class_cnt;
// localparam  threshold=3600 ;//2
localparam  threshold=13600 ;//2
wire flag ;//开始本帧数据
assign flag = (x_pos == 1 && y_pos == 1)? 1'b1:1'b0;
//计数
always @(posedge clk or negedge rst_n)begin
    if(rst_n == 1'b0)begin
        class_cnt <= 0;
    end
    else if(flag)
        class_cnt <= 0;
    else if(per_frame_clken && per_img_Bit == 1 )
        class_cnt <= class_cnt+'d1;
    else 
        class_cnt <= class_cnt;
end

// always @(posedge clk or negedge rst_n)begin
//     if(rst_n == 1'b0)
//     begin
//         classification<=0;
//     end
//     else if(x_pos == 600 && y_pos == 400)
//         if(class_cnt>=512)
//         classification<=2'b01;//patches
//         else
//             classification<=2'b10;//scraches
   
// end
always @(posedge clk or negedge rst_n)begin
    if(rst_n == 1'b0)
    begin
        classification<=0;
    end
    else if(x_pos == 600 && y_pos == 400)
        begin
        if(class_cnt>threshold)
        classification<=3'b001;//patches
        else 
        //  if((class_cnt<512)&&(class_cnt>250))
            if(class_cnt<threshold&&class_cnt>2000)
        classification<=3'b010;//scraches
        else
            classification<=3'b100;//nice
        end
   
end

    // always @(posedge clk or negedge rst_n)begin
    //     if(rst_n == 1'b0)begin
    //         max_line_up <= COL_CNT;
    //     end
    //     else if(flag)
    //         max_line_up <= COL_CNT;
    //     else if(per_frame_clken && per_img_Bit == 1 && max_line_up > y_cnt)
    //         max_line_up <= y_cnt;
    //     else 
    //         max_line_up <= max_line_up;
    // end
    // //max_line_down
    // always @(posedge clk or negedge rst_n)begin
    //     if(rst_n == 1'b0)begin
    //         max_line_down <= 0;
    //     end
    //     else if(flag)
    //         max_line_down <= 0;
    //     else if(per_frame_clken && per_img_Bit == 1 && max_line_down < y_cnt)
    //         max_line_down <= y_cnt;
    //     else 
    //         max_line_down <= max_line_down;
    // end





endmodule
