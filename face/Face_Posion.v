`timescale      1ns/1ns
// *********************************************************************************
// Project Name :       
// Author       : NingHeChuan
// Email        : ninghechuan@foxmail.com
// Blogs        : http://www.ninghechuan.com/
// File Name    : .v
// Module Name  :
// Called By    :
// Abstract     :
//
// CopyRight(c) 2018, NingHeChuan Studio.. 
// All Rights Reserved
//
// *********************************************************************************
// Modification History:
// Date         By              Version                 Change Description
// -----------------------------------------------------------------------
// 2019/3/8    NingHeChuan       1.0                     Original
//  
// *********************************************************************************

module Face_Posion(
    input           clk,
    input           rst_n,
    input           per_frame_vsync,
    input           per_frame_href,
    input           per_frame_clken,
    input           per_img_Bit,
    output          post_frame_vsync,
    output          post_frame_href,
    output          post_frame_clken,
    output  reg [9:0]  x_min,
    output  reg [9:0]  x_max,
    output  reg [9:0]  y_min,
    output  reg [9:0]  y_max,
    input 			[9:0]	lcd_x,
	input 			[9:0]	lcd_y,
    output     [15:0]      post_img
    );

//parameter   ROW_CNT = 16;   //just test
//parameter   COL_CNT = 4;    //just test
parameter   ROW_CNT = 12'd640;
parameter   COL_CNT = 12'd480;

reg     [11:0]  cnt_x;
reg     [11:0]  cnt_y;
wire    row_flag;


wire flag ;//开始本帧数据
assign flag = (cnt_x == 1 && cnt_y == 1)? 1'b1:1'b0;

//-------------------------------------------------------
//cnt_x lag 1clk
always @(posedge clk or negedge rst_n)begin
    if(rst_n == 1'b0)begin
        cnt_x <= 0;
    end
    else if(per_frame_clken && cnt_x == ROW_CNT - 1)
        cnt_x <= 0;
    else if(per_frame_clken)begin
        cnt_x <= cnt_x + 1'b1;
    end
    else 
        cnt_x <= cnt_x;
end
assign  row_flag = (per_frame_clken && cnt_x == ROW_CNT - 1'b1)? 1'b1:1'b0;
//cnt_y
always @(posedge clk or negedge rst_n)begin
    if(rst_n == 1'b0)begin
        cnt_y <= 0;
    end
    else if(row_flag  &&  cnt_y == COL_CNT - 1'b1)
        cnt_y <= 0;
    else if(row_flag)begin
        cnt_y <= cnt_y + 1'b1;
    end
    else 
        cnt_y <= cnt_y;
end

//-------------------------------------------------------
//x_min lag 2clk
always @(posedge clk or negedge rst_n)begin
    if(rst_n == 1'b0)begin
        x_min <= ROW_CNT;
    end
    else if(flag)
        x_min <= ROW_CNT;
    else if(per_frame_clken && per_img_Bit == 1 && x_min > cnt_x)
        x_min <= cnt_x;
    else 
        x_min <= x_min;
end
//x_max
always @(posedge clk or negedge rst_n)begin
    if(rst_n == 1'b0)begin
        x_max <= 0;
    end
    else if(flag)
        x_max <= 0;
    else if(per_frame_clken && per_img_Bit == 1 && x_max < cnt_x)
        x_max <= cnt_x;
    else 
        x_max <= x_max;
end
//y_min
always @(posedge clk or negedge rst_n)begin
    if(rst_n == 1'b0)begin
        y_min <= COL_CNT;
    end
    else if(flag)
        y_min <= COL_CNT;
    else if(per_frame_clken && per_img_Bit == 1 && y_min > cnt_y)
        y_min <= cnt_y;
    else 
        y_min <= y_min;
end
//y_max
always @(posedge clk or negedge rst_n)begin
    if(rst_n == 1'b0)begin
        y_max <= 0;
    end
    else if(flag)
        y_max <= 0;
    else if(per_frame_clken && per_img_Bit == 1 && y_max < cnt_y)
        y_max <= cnt_y;
    else 
        y_max <= y_max;
end

//-------------------------------------------------------
//lag 3clk
/*
reg [15:0]  post_img_r;

*/

//---------------------------------------------
//pre_frame_clken, pre_frame_href, pre_frame_vsync,lag 3clk

reg 	[3:0] 	per_frame_clken_r;
reg 	[3:0] 	per_frame_href_r;
reg 	[3:0] 	per_frame_vsync_r;
reg     [3:0]   per_img_r;

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)begin
		per_frame_clken_r <= 4'b0;
		per_frame_href_r <=  4'b0;
		per_frame_vsync_r <= 4'b0;
        per_img_r <= 0;
	end	
	else begin
		per_frame_clken_r <= {per_frame_clken_r [2:0], per_frame_clken};
		per_frame_href_r  <= {per_frame_href_r  [2:0],per_frame_href};
		per_frame_vsync_r <= {per_frame_vsync_r [2:0],per_frame_vsync};
        per_img_r <= {per_img_r[2:0],per_img_Bit};
	end
end

assign post_frame_clken = per_frame_clken;
assign post_frame_href  = per_frame_href;
assign post_frame_vsync = per_frame_vsync_r [0];

assign post_img  = post_frame_href? {16{per_img_Bit}}: 1'b0;

endmodule 
