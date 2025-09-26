module instruction_memory(address, out);
   input  [3:0] address;
   output [8:0] out;

   reg [8:0] mem [0:15];

   initial begin
      $readmemb("im.dat", mem); // carga 16 líneas de 9 bits
   end

   assign out = mem[address];
endmodule
