
`timescale 1ns / 1ps
module rgb_dark(
       input						    pixelclk,
	   input                            reset_n,

  	   input          [23:0]            i_rgb,
	   input						    i_hsync,
	   input							i_vsync,
	   input							i_de,
	   
       output         [23:0]            o_dark,
	   output							o_hsync,
	   output							o_vsync,                                                                                                  
	   output						    o_de                                                                                               
	   );

	
reg                       hsync_r,hsync_r0;
reg                       vsync_r,vsync_r0;
reg                       de_r,de_r0;
wire [7:0]                r;
wire [7:0]                g;
wire [7:0]                b;
reg  [7:0]                b_r;
reg  [7:0]                dark_r;
reg  [7:0]                dark_r1;
       
always @(posedge pixelclk) begin
  hsync_r <= i_hsync;
  vsync_r <= i_vsync;
  de_r    <= i_de;
  
  hsync_r0 <= hsync_r;
  vsync_r0 <= vsync_r;
  de_r0    <= de_r;
  
  b_r     <= b;
end

assign r        = i_rgb[23:16];
assign g        = i_rgb[15:8];
assign b        = i_rgb[7:0];
                
assign o_hsync  = hsync_r0;
assign o_vsync  = vsync_r0;
assign o_de     = de_r0;
assign o_dark   = {dark_r1,dark_r1,dark_r1};  
//-------------------------------------------------------------
// r g b dark
//-------------------------------------------------------------
always @(posedge pixelclk or negedge reset_n) begin
  if(!reset_n) 
    dark_r<= 8'b0;
  else if(i_de==1'b1) begin
    if(r>g) 
	  dark_r<= g; 
    else
      dark_r<= r; 	
  end
  else
    dark_r<= 8'b0;
end

always @(posedge pixelclk or negedge reset_n) begin
  if(!reset_n) 
    dark_r1<= 8'b0;
  else if(de_r==1'b1) begin
    if(b_r>dark_r) 
	  dark_r1<= dark_r; 
    else
      dark_r1<= b_r; 	
  end
  else
    dark_r1<= 8'b0;
end  

endmodule