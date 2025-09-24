module computer(clk, alu_out_bus);
  input        clk;
  output [7:0] alu_out_bus;     // <-- ahora 8 bits

  // Señales visibles
  wire [3:0] pc_out_bus;        // PC 4 bits
  wire [8:0] im_out_bus;        // instrucción 9 bits
  wire [7:0] regA_out_bus;
  wire [7:0] regB_out_bus;
  wire [7:0] muxB_out_bus;

  pc PC(.clk(clk), .pc(pc_out_bus));
  instruction_memory IM(.address(pc_out_bus), .out(im_out_bus));

  // Registros A/B cargan salida ALU (8 bits)
  register regA(.clk(clk), .data(alu_out_bus), .load(im_out_bus[6]), .out(regA_out_bus));
  register regB(.clk(clk), .data(alu_out_bus), .load(im_out_bus[7]), .out(regB_out_bus));

  // MuxB: literal de 4 bits zero-extend a 8 bits
  mux2 muxB(.e0(regB_out_bus),
            .e1({4'b0000, im_out_bus[3:0]}),
            .c(im_out_bus[8]),
            .out(muxB_out_bus));

  // ALU 8-bit; usa [5:4] como selector
  alu ALU(.a(regA_out_bus), .b(muxB_out_bus), .s(im_out_bus[5:4]), .out(alu_out_bus));
endmodule
