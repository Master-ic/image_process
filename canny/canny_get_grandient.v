`timescale 1ns / 1ps
module canny_get_grandient#(
    parameter DATA_WIDTH = 8,
    parameter DATA_DEPTH = 640
)(
	input			       				clk				,
	input			       				rst_s			,
	
	input			       				mediant_hs		,
	input			       				mediant_vs		,
	input			       				mediant_de		,
	input    	[DATA_WIDTH -1 : 0]     mediant_img		,
	
	output		           				grandient_hs	,
	output		           				grandient_vs	,
	output		           				grandient_de	,
	output  reg [15 : 0]	   			gra_path		
);


parameter THRESHOLD_LOW  = 10'd50;
parameter THRESHOLD_HIGH = 10'd100;

reg[9:0] Gx_1;
reg[9:0] Gx_3;
reg[9:0] Gy_1;
reg[9:0] Gy_3;

reg[10:0] Gx;
reg[10:0] Gy;

reg[23:0] sqrt_in;
reg[9:0] sqrt_out;
reg[10:0] sqrt_rem;
wire [23:0] sqrt_in_n;
wire [15:0] sqrt_out_n;
wire [10:0] sqrt_rem_n;
wire [6 :0] angle_out;

wire [7:0]  ma1_1;
wire [7:0]  ma1_2;
wire [7:0]  ma1_3;
wire [7:0]  ma2_1;
wire [7:0]  ma2_2;
wire [7:0]  ma2_3;
wire [7:0]  ma3_1;
wire [7:0]  ma3_2;
wire [7:0]  ma3_3;

reg edge_de_a;
reg edge_de_b;
wire edge_de;
reg [9:0] row_cnt;

reg[1:0] sign;
reg type; 


wire start;

wire    sobel_vsync;
wire    sobel_href;
wire    sobel_clken;

matrix_generate_3x3 #(
	.DATA_WIDTH			(DATA_WIDTH		),
	.DATA_DEPTH			(DATA_DEPTH		)
)u_matrix_generate_3x3(
    .clk        		(clk			), 
    .rst_n      		(rst_s			),
    

    .per_frame_vsync    (mediant_vs		),
    .per_frame_href     (mediant_hs		), 
    .per_frame_clken    (mediant_de		),
    .per_img_y          (mediant_img	),
    

    .matrix_frame_vsync (sobel_vsync	),
    .matrix_frame_href  (sobel_href		),
    .matrix_frame_clken (sobel_clken	),
    .matrix_p11         (ma1_1			),    
    .matrix_p12         (ma1_2			),    
    .matrix_p13         (ma1_3			),
    .matrix_p21         (ma2_1			),    
    .matrix_p22         (ma2_2			),    
    .matrix_p23         (ma2_3			),
    .matrix_p31         (ma3_1			),    
    .matrix_p32         (ma3_2			),    
    .matrix_p33         (ma3_3			)
);

//----------------Sobel Parameter--------------------------------------------
//      Gx             Gy				 Pixel
// [+1  0  -1]   [+1  +2  +1]   [ma1_1  ma1_2  ma1_3]
// [+2  0  -2]   [ 0   0   0]   [ma2_1  ma2_2  ma2_3]
// [+1  0  -1]   [-1  -2  -1]   [ma3_1  ma3_2  ma3_3]
//-------------------------------------------------------------

always @ (posedge clk or negedge rst_s) begin
	if(!rst_s) begin
		Gx_1 	<= 10'd0;
		Gx_3 	<= 10'd0;
	end
	else begin
		Gx_1 	<= {2'b00,ma1_1} + {1'b0,ma2_1,1'b0} + {2'b0,ma3_1};
		Gx_3 	<= {2'b00,ma1_3} + {1'b0,ma2_3,1'b0} + {2'b0,ma3_3};
	end
end

always @ (posedge clk or negedge rst_s) begin
	if(!rst_s) begin
		Gy_1 	<= 10'd0;
		Gy_3 	<= 10'd0;
	end
	else begin
		Gy_1 	<= {2'b00,ma1_1} + {1'b0,ma1_2,1'b0} +{2'b0,ma1_3};
		Gy_3 	<= {2'b00,ma3_1} + {1'b0,ma3_2,1'b0} +{2'b0,ma3_3};
	end
end


always @(posedge clk or negedge rst_s) begin
	if(!rst_s) begin
		Gx 		<= 	11'd0;
		Gy 		<= 	11'd0;
		sign 	<= 	2'b00;
	end
	else begin
		Gx 		<= (Gx_1 >= Gx_3)? Gx_1 - Gx_3 : Gx_3 - Gx_1;
		Gy 		<= (Gy_1 >= Gy_3)? Gy_1 - Gy_3 : Gy_3 - Gy_1;
		sign[0] <= (Gx_1 >= Gx_3)? 1'b1 : 1'b0;
		sign[1] <= (Gy_1 >= Gy_3)? 1'b1 : 1'b0;
	end
end


reg		[8 : 0]		type_d;
always @ (posedge clk or negedge rst_s) begin
	if(!rst_s)
	   type <= 1'b0;
	else if(sign[0]^sign[1])
        type 	<= 	1'b1;
	else	
		type 	<= 	1'b0;
end

always@(posedge clk or negedge rst_s)begin
	if(!rst_s)begin
		type_d	<=	0;
	end
	else begin
		type_d  <=	{type_d[7:0],type};
	end
end


wire        path_fou_f;
wire        path_thr_f;
wire        path_two_f;
wire        path_one_f;
	
cordic_sqrt#(
    .DATA_WIDTH_IN     	(11			),
    .DATA_WIDTH_OUT    	(22			),
    .Pipeline          	(9 			)
)u_cordic_sqrt(	
    .clk				(clk		),
    .rst_n				(rst_s		),
    .sqrt_in_0			(Gx			),
    .sqrt_in_1			(Gy			),

    .sqrt_out			(sqrt_out_n	),
	.angle_out			(angle_out	)
);


assign  start 		= (path_one_f | path_thr_f)	?   1'b0 		: 	1'b1;		

assign 	path_fou_f 	= (start) 					?   type_d[8]	:	1'b0;
assign	path_thr_f 	= (angle_out << 2 ) > 135 	? 	1'b1 		:	1'b0;
assign 	path_two_f 	= (start) 					?   ~type_d[8] 	:	1'b0;
assign	path_one_f 	= (angle_out << 2 ) < 45 	? 	1'b1 		:	1'b0;


always @(posedge clk or negedge rst_s)begin
	if(!rst_s)
		gra_path <= 16'd0;
	else if (sqrt_out_n > THRESHOLD_HIGH)
		gra_path <= {1'b1,1'b0,path_fou_f,path_thr_f,path_two_f,path_one_f,sqrt_out_n[9:0]};
	else if (sqrt_out_n > THRESHOLD_LOW)
		gra_path <= {1'b0,1'b1,path_fou_f,path_thr_f,path_two_f,path_one_f,sqrt_out_n[9:0]};
	else
		gra_path <= 16'd0;
end


reg    [10:0]  sobel_vsync_t     ;
reg    [10:0]  sobel_href_t      ;
reg    [10:0]  sobel_clken_t     ;
always@(posedge clk or negedge rst_s) begin
  if (!rst_s) begin
    sobel_vsync_t   <= 11'd0 ;
    sobel_href_t    <= 11'd0 ;
    sobel_clken_t   <= 11'd0 ;
  end
  else begin
	sobel_vsync_t 	<= {sobel_vsync_t[9:0], sobel_vsync } ;
	sobel_href_t  	<= {sobel_href_t [9:0], sobel_href  } ;
	sobel_clken_t 	<= {sobel_clken_t[9:0], sobel_clken } ;
  end
end

assign grandient_hs = sobel_href_t  [10] ;
assign grandient_vs = sobel_vsync_t [10] ;
assign grandient_de = sobel_clken_t [10] ;

endmodule
