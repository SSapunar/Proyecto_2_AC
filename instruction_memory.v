// IM de 16 palabras x 9 bits, lee im.dat
module instruction_memory(address, out);
  input  [3:0] address;   // 0..15
  output [8:0] out;       // instrucción (9 bits)

  reg [8:0] mem [0:15];
  assign out = mem[address];

  initial begin
    $readmemb("im.dat", mem); // 16 líneas de 9 bits
  end
endmodule
