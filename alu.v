// ALU 8-bit básica: s=00 ADD, 01 SUB, 10 AND, 11 OR
module alu(a, b, s, out);
  input  [7:0] a, b;
  input  [1:0] s;
  output [7:0] out;

  reg [7:0] out;
  always @* begin
    case (s)
      2'b00: out = a + b;
      2'b01: out = a - b;
      2'b10: out = a & b;
      2'b11: out = a | b;
    endcase
  end
endmodule
