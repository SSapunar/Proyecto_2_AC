`timescale 1ns/1ps
module testbench;
  reg clk;
  wire [7:0] alu_out_bus;         // <-- 8 bits

  computer UUT(.clk(clk), .alu_out_bus(alu_out_bus));

  initial begin
    clk = 0;
    forever #1 clk = ~clk;
  end

  initial begin
    $dumpfile("out/dump.vcd");
    $dumpvars(0, testbench);
  end

  initial begin
    $display(" time | pc  im[8:0]   A    B    ALU");
    $monitor(" %4t |  %h  %b  %02h  %02h  %02h",
      $time, UUT.pc_out_bus, UUT.im_out_bus, UUT.regA_out_bus, UUT.regB_out_bus, alu_out_bus);
  end

  initial begin
    #40 $finish;
  end
endmodule
