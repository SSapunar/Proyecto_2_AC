`default_nettype none
module data_memory(
  input  wire        clk,
  input  wire        we,
  input  wire [7:0]  addr,
  input  wire [7:0]  wdata,
  output reg  [7:0]  rdata
);
  reg [7:0] mem [0:255];

  always @(*) rdata = mem[addr];

  always @(posedge clk) begin
    if (we) mem[addr] <= wdata;
  end
endmodule

