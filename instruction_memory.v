`default_nettype none
module instruction_memory(
    input  wire [7:0]  address,     // 0..255
    output wire [14:0] out          // [14:8]=opcode (7b), [7:0]=literal
);
    // El TB escribe aquí: $readmemb("im_memory.dat", Comp.IM.mem)
    reg [14:0] mem [0:255];

    initial begin
        // Carga por defecto; el TB la sobreescribe con im_memory.dat
        $readmemb("im.dat", mem);
    end

    assign out = mem[address];
endmodule
