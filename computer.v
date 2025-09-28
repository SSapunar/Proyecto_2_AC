module computer(clk, alu_out_bus);
   input clk;
   output [7:0] alu_out_bus;   // <-- era [3:0], ahora 8 bits

   // señales hacia afuera para verlas en la waveform
   wire [3:0]   pc_out_bus;    // <-- PC a 4 bits si tu IM es de 16
   wire [8:0]   im_out_bus;    // opcode+literal
   wire [7:0]   regA_out_bus;
   wire [7:0]   regB_out_bus;
   wire [7:0]   muxB_out_bus;
   //wire [7:0] alu_out_bus;

   pc PC(.clk(clk),
         .pc(pc_out_bus));

   instruction_memory IM(.address(pc_out_bus),
                         .out(im_out_bus));

   register regA(.clk(clk),
                 .data(alu_out_bus),
                 .load(im_out_bus[6]),
                 .out(regA_out_bus));

   register regB(.clk(clk),
                 .data(alu_out_bus),
                 .load(im_out_bus[7]),
                 .out(regB_out_bus));

   mux2 muxB(.e0(regB_out_bus), 
             .e1(im_out_bus[7:0]),  // <-- literal de 8 bits
             .c(im_out_bus[8]),
             .out(muxB_out_bus));

   alu ALU(.a(regA_out_bus),
           .b(muxB_out_bus),
           .s(im_out_bus[5:3]),     // abrimos la cancha a 3 bits pa’ meter las 8 maniobras.
           .out(alu_out_bus));
endmodule
