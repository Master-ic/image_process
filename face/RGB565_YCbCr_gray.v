`timescale 1ns/1ps

module RGB565_YCbCr_gray(
	input 				clk,//COMS pixel clk 24Mhz
	input 				rst_n,
	//others	
	input 	[4:0]		cmos_R,
	input	 [5:0]		cmos_G,
	input 	[4:0]		cmos_B,
	input 				per_frame_clken,
	input 				per_frame_vsync,
	input 				per_frame_href,
	output	[0:0]		img_Y,
	output	[7:0]		img_Cb,
	output	[7:0]		img_Cr,
	output				post_frame_clken,
	output 				post_frame_vsync,
	output				post_frame_href
);

//--------------------------------------------
//RGB565 to RGB 888 高位补低位
wire 	[7:0]	cmos_R0;
wire 	[7:0]	cmos_G0;
wire 	[7:0]	cmos_B0;

assign cmos_R0	= 	{cmos_R, cmos_R[4:2]};
assign cmos_G0	= 	{cmos_G, cmos_G[5:4]};
assign cmos_B0	= 	{cmos_B, cmos_B[4:2]};


//--------------------------------------------
/*//Refer to <OV7725 Camera Module Software Applicaton Note> page 5
	Y 	=	(77 *R 	+ 	150*G 	+ 	29 *B)>>8
	Cb 	=	(-43*R	- 	85 *G	+ 	128*B)>>8 + 128
	Cr 	=	(128*R 	-	107*G  	-	21 *B)>>8 + 128
--->
	Y 	=	(77 *R 	+ 	150*G 	+ 	29 *B)>>8
	Cb 	=	(-43*R	- 	85 *G	+ 	128*B + 32768)>>8
	Cr 	=	(128*R 	-	107*G  	-	21 *B + 32768)>>8*/
//--------------------------------------------
//RGB888 to YCrCb
//step1 conmuse 1clk
reg 	[15:0]	cmos_R1, cmos_R2, cmos_R3;
reg 	[15:0]	cmos_G1, cmos_G2, cmos_G3;
reg 	[15:0]	cmos_B1, cmos_B2, cmos_B3;
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)begin
		cmos_R1 <= 16'd0;
         cmos_G1 <= 16'd0;
         cmos_B1 <= 16'd0;
		cmos_R2 <= 16'd0;
         cmos_G2 <= 16'd0;
         cmos_B2 <= 16'd0;
		cmos_R3 <= 16'd0;
         cmos_G3 <= 16'd0;
         cmos_B3 <= 16'd0;
	end
	else begin
		cmos_R1 <= cmos_R0 * 8'd77;
		cmos_G1 <= cmos_G0 * 8'd150;
		cmos_B1 <= cmos_B0 * 8'd29; 
		cmos_R2 <= cmos_R0 * 8'd43; 
		cmos_G2 <= cmos_G0 * 8'd85; 
		cmos_B2 <= cmos_B0 * 8'd128; 
         cmos_R3 <= cmos_R0 * 8'd128;
         cmos_G3 <= cmos_G0 * 8'd107;
         cmos_B3 <= cmos_B0 * 8'd21;
	end
end

//-----------------------------------------------
//step2 consume 1clk
reg		[15:0]	img_Y0;
reg 	[15:0]	img_Cb0;
reg 	[15:0]	img_Cr0;

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)begin
		img_Y0 <= 16'd0;
		img_Cb0 <= 16'd0;
		img_Cr0 <= 16'd0;
	end
	else begin
		img_Y0  <= cmos_R1 + cmos_G1 + cmos_B1;
		img_Cb0 <= cmos_B2 - cmos_R2 - cmos_G2 + 16'd32768;
		img_Cr0 <= cmos_R3 - cmos_G3 - cmos_B3 + 16'd32768;
	end
	
end
//-------------------------------------------
//step3 conmuse 1clk
reg		[7:0]	img_Y1;
reg 	[7:0]	img_Cb1;
reg 	[7:0]	img_Cr1;

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)begin
		img_Y1  <= 8'd0;
		img_Cb1 <= 8'd0;
		img_Cr1 <= 8'd0;
	end
	else begin
		img_Y1  <= img_Y0  [15:8];
		img_Cb1 <= img_Cb0 [15:8];
		img_Cr1 <= img_Cr0 [15:8];
	end
	
end

//------------------------------------------
//step4 consume 1clk
reg 	[0:0]	gray_data_r;
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
		gray_data_r <= 'b0;
		else if( img_Y1 > 150 && img_Y1 < 251 && img_Cb1 > 50 && img_Cb1 < 150 && img_Cr1 > 150 && img_Cr1 < 230)
		gray_data_r <= 1;
	else 
		gray_data_r <= 0;
end


//---------------------------------------------
//pre_frame_clken, pre_frame_href, pre_frame_vsync,lag 3clk

reg 	[4:0] 	per_frame_clken_r;
reg 	[4:0] 	per_frame_href_r;
reg 	[4:0] 	per_frame_vsync_r;

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)begin
		per_frame_clken_r <= 4'b0;
		per_frame_href_r <=  4'b0;
		per_frame_vsync_r <= 4'b0;
	end	
	else begin
		per_frame_clken_r <= {per_frame_clken_r [3:0], per_frame_clken};
		per_frame_href_r  <= {per_frame_href_r  [3:0],per_frame_href};
		per_frame_vsync_r <= {per_frame_vsync_r [3:0],per_frame_vsync};
	end
end

assign post_frame_clken = per_frame_clken_r [4];
assign post_frame_href  = per_frame_href_r  [4];
assign post_frame_vsync = per_frame_vsync_r [3];

assign img_Y  = post_frame_href? gray_data_r: 1'b0;
assign img_Cb = post_frame_href? img_Cb1: 1'b0;
assign img_Cr = post_frame_href? img_Cr1: 1'b0;

endmodule


