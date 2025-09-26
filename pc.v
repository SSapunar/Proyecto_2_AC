module pc(clk, pc);
   input clk;
   output [3:0] pc;   //  achicamos la montura a 4 bits, pa' 16 instrucciones justitas.

   reg [3:0]     pc;  //  el registro también a 4 bits, que no quede el apero grande pa'l caballo chico.
   // wire clk;       // fuera el 'wire' redundante; el 'input' ya viene ensillao como wire.

   initial begin
	   pc = 0;       // partimos en cero, manso como ternero nuevo.
   end

   always @(posedge clk) begin
	   pc <= pc + 1; // Cada flanco es un pasito más; sin apuro pero sin aflojar.
   end
endmodule
