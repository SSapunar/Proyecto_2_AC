module alu(a, b, s, out);
   input [3:0] a, b;
   input [1:0] s;
   output [3:0] out;

   wire [3:0]   a, b;
   wire [1:0]   s;
   reg [3:0]    out;

   always @(a, b, s) begin
	   case(s)
		   'b00: out = a + b;
		   'b01: out = a - b;
		   'b10: out = a & b;
		   'b11: out = a | b;
	   endcase
   end
endmodule
