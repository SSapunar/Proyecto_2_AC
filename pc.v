// PC 4-bit (0..15) auto-incrementa
module pc(clk, pc);
  input        clk;
  output [3:0] pc;

  reg [3:0] r = 4'h0;
  assign pc = r;

  always @(posedge clk) begin
    r <= r + 1'b1;
  end
endmodule
