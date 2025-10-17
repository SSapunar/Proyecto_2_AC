`default_nettype none
module pc(
  input  wire       clk,
  input  wire       load,
  input  wire [7:0] next_pc,
  output reg  [7:0] pc
);
  initial pc = 8'd0;
  always @(posedge clk) begin
    if (load) pc <= next_pc;
    else      pc <= pc + 8'd1;
  end
endmodule
