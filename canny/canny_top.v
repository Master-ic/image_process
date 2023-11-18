`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/01/02 20:56:56
// Design Name: 
// Module Name: canny_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module canny_top(

input clk, 
input rst_n, 
 
 //准备要进行处理的图像数据
input per_frame_vsync,
input per_frame_href,
input per_frame_clken,

input [23:0] per_frame_data,

 //处理完毕的图像数据
output post_frame_vsync,
output post_frame_href,
output post_frame_clken,
output  post_frame_data

    );
assign post_frame_data={post_frame_data_0};

    wire post0_frame_vsync;
    wire post0_frame_href;
    wire post0_frame_clken;
    wire [7:0]post0_img_Y;
	wire [7:0] post0_img_Cb;
	wire [7:0] post0_img_Cr;

    wire gauss_vsync;
    wire gauss_hsync;
    wire gauss_de;
    wire [7:0]img_gauss;

//rgb 同 ycrcb
    VIP_RGB888_YCbCr444	u_VIP_RGB888_YCbCr444
(

	.clk				(clk),					
	.rst_n				(rst_n),				
	.per_frame_vsync	(per_frame_vsync    ),		
	.per_frame_href		(per_frame_href     ),		
	.per_frame_clken	(per_frame_clken    ),		
	.per_img_red		(per_frame_data[7:0]        ),			
	.per_img_green		(per_frame_data[15:8]   ),		
	.per_img_blue		(per_frame_data[23:16]      ),		

	.post_frame_vsync	(post0_frame_vsync	),	
	.post_frame_href	(post0_frame_href 	),		
	.post_frame_clken	(post0_frame_clken	),	
	.post_img_Y			(post0_img_Y 		),			
	.post_img_Cb		(post0_img_Cb		),			
	.post_img_Cr		(post0_img_Cr		)			
);
//高斯滤波
image_gaussian_filter u_image_gaussian_filter
(
	.clk                (clk),
	.rst_n              (rst_n),
	.per_frame_vsync    (post0_frame_vsync	),
	.per_frame_href     (post0_frame_href 	),	
	.per_frame_clken    (post0_frame_clken	),
	.per_img_gray       (post0_img_Y 		),	

	.post_frame_vsync   (gauss_vsync        ),	
	.post_frame_href    (gauss_hsync        ),	
	.post_frame_clken   (gauss_de           ),		
	.post_img_gray      (img_gauss          )
);
//canny
canny_edge_detect_top u_canny_edge_detect_top(
        .clk                (clk),             
        .rst_n              (rst_n),                   
        .per_frame_vsync    (gauss_vsync    ), 
        .per_frame_href     (gauss_hsync    ),  
        .per_frame_clken    (gauss_de       ), 
        .per_img_y          (img_gauss      ),      

        .post_frame_vsync   (post_frame_vsync    ), 
        .post_frame_href    (post_frame_href    ),  
        .post_frame_clken   (post_frame_clken       ), 
        .post_img_bit       (post_frame_data_0      )
    );
	
endmodule
