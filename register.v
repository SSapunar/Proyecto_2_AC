// Registro 8-bit con load
module register(clk, data, load, out);
  input        clk;
  input        load;
  input  [7:0] data;
  output [7:0] out;

  reg [7:0] q;
  assign out = q;

  initial q = 8'h00;

  always @(posedge clk) begin
    if (load) q <= data;
  end
endmodule
