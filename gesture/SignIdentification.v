module SignIdentification(thumb_status,
			  index_status,
			  middle_status,
			  ring_status,
			  pinky_status,
			  sign_value,
			  rst,clk);
   
   input      thumb_status;//大拇指
   input      index_status;//食
   input      middle_status;//中指
   input      ring_status;//无名指
   input      pinky_status;//小拇指

   output    reg [3:0] sign_value;

   input 	rst, clk;

//    reg 		sign_value;
   reg [4:0] 	finger_db;


   always @(posedge clk) begin
      if(rst) begin
	//  sign_value <= 4'b0000;
	 finger_db<=0;

      end

      else begin
	 finger_db <= {pinky_status, ring_status, middle_status, index_status, thumb_status};
	//  case(finger_db)
	//    5'b00010 : sign_value <= 1;
	//    5'b00110 : sign_value <= 2;
  	//    5'b00111 : sign_value <= 3;
	//    5'b01111 : sign_value <= 4;
	//    5'b11111 : sign_value <= 5;
	//    5'b01110 : sign_value <= 6;
	//    5'b10110 : sign_value <= 7;
	//    5'b11010 : sign_value <= 8;
	//    5'b11100 : sign_value <= 9;
	//    default : sign_value <= 10;
	//  endcase // case (finger_db)
      end // else: !if(rst)
   end // always @ posedge(clk)
   always @ (*)
   begin 
	case(finger_db)
	5'b00010 : sign_value <= 1;
	5'b00110 : sign_value <= 2;
	  5'b00111 : sign_value <= 3;
	5'b01111 : sign_value <= 4;
	5'b11111 : sign_value <= 5;
	5'b01110 : sign_value <= 6;
	5'b10110 : sign_value <= 7;
	5'b11010 : sign_value <= 8;
	5'b11100 : sign_value <= 9;
	default : sign_value <= 10;
  endcase // case (finger_db)
   end // else: !if(rst)

endmodule // FingerIdentification

   
	 
   
   
