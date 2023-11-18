`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/13 21:51:46
// Design Name: 
// Module Name: top_defog
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


module top_defog(
    input sw0,
    input sw1,
    input sw2,
    input						    pixelclk,
    input                            reset_n,

    input          [23:0]           i_rgb,
    input						    i_hsync,
    input							i_vsync,
    input							i_de,

    output      reg [23:0]           o_defogging,
    output		reg					o_hsync,
    output		reg					o_vsync,                                                                                                  
    output		reg				    o_de        

    );

wire [23:0] o_dark_1;
wire o_hsync_1;
wire o_vsync_1;
wire o_de_1;

wire [7:0]             dark_max;
wire o_hsync_2;
wire o_vsync_2;
wire o_de_2;
wire [23:0] o_dark_2;


wire [23:0] o_defogging_3;
wire o_hsync_3    ;
wire o_vsync_3   ; 
wire o_de_3    ;   


    rgb_dark u_rgb_dark(
    .pixelclk ( pixelclk ),
    .reset_n  ( reset_n  ),
    .i_rgb    ( i_rgb    ),
    .i_hsync  ( i_hsync  ),
    .i_vsync  ( i_vsync  ),
    .i_de     ( i_de     ),
    .o_dark   ( o_dark_1   ),
    .o_hsync  ( o_hsync_1  ),
    .o_vsync  ( o_vsync_1  ),
    .o_de     ( o_de_1     )
);

transmittance_dark u_transmittance_dark(
    .pixelclk ( pixelclk ),
    .reset_n  ( reset_n  ),
    .i_rgb    ( o_dark_1    ),
    .i_hsync  ( o_hsync_1  ),
    .i_vsync  ( o_vsync_1  ),
    .i_de     ( o_de_1     ),
    .dark_max ( dark_max ),
    .o_dark   ( o_dark_2   ),
    .o_hsync  ( o_hsync_2  ),
    .o_vsync  ( o_vsync_2  ),
    .o_de     ( o_de_2     )
);

defogging u_defogging(
    .pixelclk        ( pixelclk        ),
    .reset_n         ( reset_n         ),
    .i_rgb           ( i_rgb           ),
    .i_transmittance ( o_dark_2 ),
    .dark_max        ( dark_max        ),
    .i_hsync         ( o_hsync_2         ),
    .i_vsync         ( o_vsync_2         ),
    .i_de            ( o_de_2            ),
    .o_defogging     ( o_defogging_3    ),
    .o_hsync         ( o_hsync_3         ),
    .o_vsync         ( o_vsync_3        ),
    .o_de            ( o_de_3      )
);
wire [2:0] sw={sw2,sw1,sw0};
always @(*) begin
    case(sw)

    3'b001:
    begin
    o_defogging <= o_dark_1;
    o_hsync     <= o_hsync_1;
    o_vsync     <= o_vsync_1;
    o_de        <= o_de_1;
    end

    3'b010:
    begin
        o_defogging <= o_dark_2;
        o_hsync     <= o_hsync_2;
        o_vsync     <= o_vsync_2;
        o_de        <= o_de_2;
    end

    3'b100:
    begin
        o_defogging <= o_defogging_3;
        o_hsync     <= o_hsync_3;
        o_vsync     <= o_vsync_3;
        o_de        <= o_de_3;
    end

    default:
    begin  
    o_defogging <= i_rgb;
    o_hsync<=i_hsync;
    o_vsync     <= i_vsync;
    o_de     <=i_de;
    end   
    
    endcase
    
end
// assign o_de=i_rgb;
endmodule
