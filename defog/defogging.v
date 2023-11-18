

`timescale 1ns / 1ps
module defogging(
       input						    pixelclk,
	   input                            reset_n,

  	   input          [23:0]            i_rgb,
	   input          [23:0]            i_transmittance,
	   input          [7:0]             dark_max,
	   input						    i_hsync,
	   input							i_vsync,
	   input							i_de,
	   
       output         [23:0]            o_defogging,
	   output							o_hsync,
	   output							o_vsync,                                                                                                  
	   output						    o_de                                                                                               
	   );
parameter DEVIDER = 255*16;
	   
reg                       hsync_r,hsync_r0;
reg                       vsync_r,vsync_r0;
reg                       de_r,de_r0;
reg         [23:0]        rgb_r0,rgb_r1,rgb_r2,rgb_r3;//delay 4 clock
wire [7:0]                r;
wire [7:0]                g;
wire [7:0]                b;
wire [7:0]                transmittance_gray;
reg [19:0]                r_r;
reg [19:0]                r_g;
reg [19:0]                r_b;

wire                      r_flag;
wire                      g_flag;
wire                      b_flag;

reg [11:0]                mult1;
reg [15:0]                mult2;
reg [15:0]                mult_r;
reg [15:0]                mult_g;
reg [15:0]                mult_b;

assign                    r_flag = (i_de == 1'b1 && mult2>mult_r)?1'b1:1'b0;
assign                    g_flag = (i_de == 1'b1 && mult2>mult_g)?1'b1:1'b0;
assign                    b_flag = (i_de == 1'b1 && mult2>mult_b)?1'b1:1'b0;
      
always @(posedge pixelclk) begin
  hsync_r <= i_hsync;
  vsync_r <= i_vsync;
  de_r    <= i_de;
  
  hsync_r0 <= hsync_r;
  vsync_r0 <= vsync_r;
  de_r0    <= de_r;
  
  rgb_r0 <=i_rgb;
  rgb_r1 <=rgb_r0;
  rgb_r2 <=rgb_r1;
  rgb_r3 <=rgb_r2;
  
end

assign r        = rgb_r3[23:16];
assign g        = rgb_r3[15:8];
assign b        = rgb_r3[7:0];

assign transmittance_gray      = i_transmittance[23:16];//transmittance gray
              
assign o_hsync  = hsync_r0;
assign o_vsync  = vsync_r0;
assign o_de     = de_r0;
assign o_defogging   = {r_r[19:12],r_g[19:12],r_b[19:12]};  

/*
always @(posedge pixelclk or negedge reset_n) begin
  if(!reset_n) begin
   r_r <= 24'b0;
   r_g <= 24'b0;
   r_b <= 24'b0;
  end
  else begin
    r_r <= (r*255-(255-transmittance_gray)*dark_max)*(255/transmittance_gray);
	r_g <= (g*255-(255-transmittance_gray)*dark_max)*(255/transmittance_gray);
	r_b <= (b*255-(255-transmittance_gray)*dark_max)*(255/transmittance_gray);
  end
end
*/

always @(posedge pixelclk or negedge reset_n) begin
  if(!reset_n) begin
   r_r <= 20'b0;
   r_g <= 20'b0;
   r_b <= 20'b0;
   mult1 <= 12'b0;
   mult_r <= 16'b0;
   mult_g <= 16'b0;
   mult_b <= 16'b0;
  end
  else begin
    mult1 <= DEVIDER/transmittance_gray;
	mult2 <= (255-transmittance_gray)*dark_max;
    mult_r <= r*255;
	mult_g <= g*255;
	mult_b <= b*255;
	//r_r <= (mult_r-mult2)*mult1;
    //r_g <= (mult_g-mult2)*mult1;
    //r_b <= (mult_b-mult2)*mult1;
    r_r <= (r_flag == 1'b1)?{r,12'b0}:(mult_r-mult2)*mult1;
    r_g <= (g_flag == 1'b1)?{g,12'b0}:(mult_g-mult2)*mult1;
    r_b <= (b_flag == 1'b1)?{b,12'b0}:(mult_b-mult2)*mult1;
  end
end

endmodule