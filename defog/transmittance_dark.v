
`timescale 1ns / 1ps
module transmittance_dark(
       input						    pixelclk,
	   input                            reset_n,

  	   input          [23:0]            i_rgb,
	   input						    i_hsync,
	   input							i_vsync,
	   input							i_de,
	   output         [7:0]             dark_max,
       output         [23:0]            o_dark,
	   output							o_hsync,
	   output							o_vsync,                                                                                                  
	   output						    o_de                                                                                               
	   );

parameter W0 = 8'd166;//0.65 The multiplication factor is used to retain some fog, and at 1 o'clock, the fog is completely removed.
parameter T0 = 8'd26;//0.1

	
reg                       hsync_r,hsync_r0,hsync_r1;
reg                       vsync_r,vsync_r0,vsync_r1;
reg                       de_r,de_r0,de_r1;
wire  [7:0]               dark_gray;
reg   [7:0]               max_dark;
reg  [7:0]                max_dark_data;
wire                      vsync_pos;//negedge of vsync
wire                      vsync_neg;//negedge of vsync
reg [7:0]                 transmittance_img;
reg [7:0]                 transmittance;
reg [7:0]                 transmittance_result;
       
always @(posedge pixelclk) begin
  hsync_r <= i_hsync;
  vsync_r <= i_vsync;
  de_r    <= i_de;
  
  hsync_r0 <= hsync_r;
  vsync_r0 <= vsync_r;
  de_r0    <= de_r;
  
  hsync_r1 <= hsync_r0;
  vsync_r1 <= vsync_r0;
  de_r1    <= de_r0;
end

assign dark_gray       = i_rgb[23:16];//gray
assign vsync_neg       = ((!i_vsync) & vsync_r)?1'b1:1'b0;
assign vsync_pos      = (i_vsync & (!vsync_r))?1'b1:1'b0;

                
assign o_hsync  = hsync_r1;
assign o_vsync  = vsync_r1;
assign o_de     = de_r1;
assign o_dark   = {transmittance_result,transmittance_result,transmittance_result};  
assign dark_max = max_dark_data;
//-------------------------------------------------------------
// max dark
//-------------------------------------------------------------
always @(posedge pixelclk or negedge reset_n) begin
  if(!reset_n) begin
    max_dark<= 8'b0;
	max_dark_data<= 8'b0;
  end
  else if(vsync_pos==1'b1)
    max_dark <= dark_gray;
  else if(de_r == 1'b1)
    if(dark_gray > max_dark)
	  max_dark<= dark_gray;
	else
	  max_dark <= max_dark;
  else if(vsync_neg == 1'b1) begin
    max_dark_data <= max_dark;
	max_dark<= 8'b0;
  end 
end

//-------------------------------------------------------------
// t1 img
//-------------------------------------------------------------

always @(posedge pixelclk or negedge reset_n) begin
  if(!reset_n) begin
    transmittance_img<=0;
	transmittance <=0;
  end
  else if(max_dark_data>8'd160 && max_dark_data<8'd170) begin
    transmittance<=dark_gray;                     //1
	transmittance_img <= 8'd255 - transmittance;
  end
  else if(max_dark_data>8'd170 && max_dark_data<8'd180) begin
    transmittance<=(dark_gray[7:1]+dark_gray[7:2]+dark_gray[7:3]+dark_gray[7:4]);//0.9375
	transmittance_img <= 8'd255 - transmittance;
  end
  else if(max_dark_data>8'd180 && max_dark_data<8'd190) begin
    transmittance<=(dark_gray[7:1]+dark_gray[7:2]+dark_gray[7:3]);//0.875
	transmittance_img <= 8'd255 - transmittance;
  end
  else if(max_dark_data>8'd190 && max_dark_data<8'd200) begin
    transmittance<=(dark_gray[7:1]+dark_gray[7:2]+dark_gray[7:4]);//0.8125
	transmittance_img <= 8'd255 - transmittance;
  end
  else if(max_dark_data>8'd200 && max_dark_data<8'd210) begin
    transmittance<=(dark_gray[7:1]+dark_gray[7:2]+dark_gray[7:5]);//0.78125
	transmittance_img <= 8'd255 - transmittance;
  end
  else if(max_dark_data>8'd210 && max_dark_data<8'd220) begin
    transmittance<=(dark_gray[7:1]+dark_gray[7:2]);//0.75
	transmittance_img <= 8'd255 - transmittance;
  end
  else if(max_dark_data>8'd220 && max_dark_data<8'd230) begin
    transmittance<=(dark_gray[7:1]+dark_gray[7:3]+dark_gray[7:4]+dark_gray[7:5]);//0.725
	transmittance_img <= 8'd255 - transmittance;
  end
  else if(max_dark_data>8'd230 && max_dark_data<8'd240) begin
    transmittance<=(dark_gray[7:1]+dark_gray[7:3]+dark_gray[7:4]);//0.6875
	transmittance_img <= 8'd255 - transmittance;
  end
  else if(max_dark_data>8'd240) begin
    transmittance<=(dark_gray[7:1]+dark_gray[7:3]+dark_gray[7:6]);//0.65
    //transmittance<=(dark_gray[7:1]+dark_gray[7:5]+dark_gray[7:6]);//0.65
	//transmittance<=(dark_gray[7:1]);//0.65
	//transmittance<=(dark_gray[7:2]+dark_gray[7:3]);//0.65
	transmittance_img <= 8'd255 - transmittance;
  end
  else begin
    transmittance_img<=0;
	transmittance <=0;
  end
end
//-------------------------------------------------------------
// t2 img
//-------------------------------------------------------------
always @(posedge pixelclk or negedge reset_n) begin
  if(!reset_n)
    transmittance_result <=8'b0;
  else if(transmittance_img > T0)
    transmittance_result <=transmittance_img; 
  else
    transmittance_result <=T0; 
end

endmodule