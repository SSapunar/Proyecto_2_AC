module test;
   reg cl = 0;
   wire [7:0] alu_out_bus;

   computer Comp(.clk(cl), .alu_out_bus(alu_out_bus));

   // A LO HUASO: alias pa’ ver control sin pelear con slices en el wave
   wire       MuxB   = Comp.im_out_bus[8];   // 1 = Literal, 0 = RegB
   wire       LB     = Comp.im_out_bus[7];   // carga B
   wire       LA     = Comp.im_out_bus[6];   // carga A
   wire [2:0] ALU_op = Comp.im_out_bus[5:3]; // 000 add ... 111 shr

   initial begin
     $dumpfile("out/dump.vcd");
     $dumpvars(0, test);

     // CAMBIO (a lo huaso): no cargamos im.dat aquí; la IM se ensilla sola por dentro.

     // Igual mostramos lo que hay en memoria, pa' que el capataz quede conforme.
     $display("mem[0] = %h", Comp.IM.mem[0]);
     $display("mem[1] = %h", Comp.IM.mem[1]);
     $display("mem[2] = %h", Comp.IM.mem[2]);
     $display("mem[3] = %h", Comp.IM.mem[3]);

     $monitor("At time %t, pc=0x%h, im=b%b, MuxB=%b LA=%b LB=%b ALUop=%b, A=0x%h, B=0x%h, ALU=0x%h",
              $time, Comp.pc_out_bus, Comp.im_out_bus, MuxB, LA, LB, ALU_op,
              Comp.regA_out_bus, Comp.regB_out_bus, alu_out_bus);

     // CAMBIO (a lo huaso): en vez de cortar en 3, nos vamos hasta el final del corral (0xF).
     wait (Comp.PC.pc == 4'hF);
     #2;
     $finish;
   end

   // Reloj firme, cada #1 pega un latigazo pa’ avanzar.
   always #1 cl = ~cl;
endmodule
