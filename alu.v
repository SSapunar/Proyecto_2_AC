`default_nettype none
module alu(
  input  wire [7:0] a,
  input  wire [7:0] b,
  input  wire [2:0] s,
  output reg  [7:0] out
);
  always @(*) begin
    case (s)
      3'b000: out = a;           // PASS A
      3'b001: out = a + b;       // ADD
      3'b010: out = a - b;       // SUB
      3'b011: out = a & b;       // AND
      3'b100: out = a | b;       // OR
      3'b101: out = a ^ b;       // XOR
      3'b110: out = b << 1;      // SHL1 (usamos B para SHL (Dir),B)
      3'b111: out = a >> 1;      // SHR1 (usamos A para SHR (B))
      default: out = 8'h00;
    endcase
  end
endmodule
