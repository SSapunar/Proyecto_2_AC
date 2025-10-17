module test;
    reg           clk = 0;
    wire [7:0]    regA_out;
    wire [7:0]    regB_out;
    wire [7:0]    alu_out;
    wire [14:0]   im_out;

    reg mem_sequence_test_failed = 1'b0;
    reg add_a_dir_test_failed    = 1'b0;
    reg jeq_test_1_failed        = 1'b0;

    // ------------------------------------------------------------
    // IMPORTANTE!! Editar con el modulo de su computador
    // ------------------------------------------------------------
    computer Comp (
        .clk(clk)
    );
    // ------------------------------------------------------------

    // ------------------------------------------------------------
    // IMPORTANTE!! Editar para que la variable apunte a la salida
    // de los registros de su computador.
    // ------------------------------------------------------------
    assign regA_out = Comp.regA.out;
    assign regB_out = Comp.regB.out;
    // ------------------------------------------------------------

    initial begin
        $dumpfile("out/dump.vcd");
        $dumpvars(0, test);

        // Deja que el módulo lea su IM en t=0; luego (si NO defines NO_TB_LOAD) lo recargamos aquí.
        #1;
        `ifndef NO_TB_LOAD
          $readmemb("im_memory.dat", Comp.IM.mem);
        `endif

        // --- Test: Full & Expanded Memory Sequence ---
        $display("\n----- STARTING TEST: Full Memory Sequence -----");

        // --- Part 1: RegB -> Mem -> RegA ---
        $display("\n--- Part 1: Testing RegB -> Memory -> RegA ---");
        #2;
        $display("CHECK @ t=%0t: After MOV B, 99 -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd99) begin
            $error("FAIL [Part 1]: regB expected 99, got %d", regB_out);
            mem_sequence_test_failed = 1'b1;
        end

        #2;
        $display("CHECK @ t=%0t: After MOV (50), B -> DM[50] = %d", $time, Comp.DM.mem[50]);
        if (Comp.DM.mem[50] !== 8'd99) begin
            $error("FAIL [Part 1]: DM[50] expected 99, got %d", Comp.DM.mem[50]);
            mem_sequence_test_failed = 1'b1;
        end

        #2;
        $display("CHECK @ t=%0t: After MOV A, (50) -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd99) begin
            $error("FAIL [Part 1]: regA expected 99, got %d", regA_out);
            mem_sequence_test_failed = 1'b1;
        end

        // --- Part 2: RegA -> Mem -> RegB ---
        $display("\n--- Part 2: Testing RegA -> Memory -> RegB ---");
        #2;
        $display("CHECK @ t=%0t: After MOV A, 123 -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd123) begin
            $error("FAIL [Part 2]: regA expected 123, got %d", regA_out);
            mem_sequence_test_failed = 1'b1;
        end

        #2;
        $display("CHECK @ t=%0t: After MOV (51), A -> DM[51] = %d", $time, Comp.DM.mem[51]);
        if (Comp.DM.mem[51] !== 8'd123) begin
            $error("FAIL [Part 2]: DM[51] expected 123, got %d", Comp.DM.mem[51]);
            mem_sequence_test_failed = 1'b1;
        end

        #2;
        $display("CHECK @ t=%0t: After MOV B, (51) -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd123) begin
            $error("FAIL [Part 2]: regB expected 123, got %d", regB_out);
            mem_sequence_test_failed = 1'b1;
        end

        // --- Part 3: Overwrite y bordes ---
        $display("\n--- Part 3: Testing Overwrite and Edge Cases ---");
        #2;
        $display("CHECK @ t=%0t: After MOV A, 255 -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd255) begin
            $error("FAIL [Part 3]: regA expected 255, got %d", regA_out);
            mem_sequence_test_failed = 1'b1;
        end

        #2;
        $display("CHECK @ t=%0t: After MOV (50), A [Overwrite] -> DM[50] = %d", $time, Comp.DM.mem[50]);
        if (Comp.DM.mem[50] !== 8'd255) begin
            $error("FAIL [Part 3]: DM[50] expected 255 after overwrite, got %d", Comp.DM.mem[50]);
            mem_sequence_test_failed = 1'b1;
        end

        #2;
        $display("CHECK @ t=%0t: After MOV A, 0 -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd0) begin
            $error("FAIL [Part 3]: regA expected 0, got %d", regA_out);
            mem_sequence_test_failed = 1'b1;
        end

        #2;
        $display("CHECK @ t=%0t: After MOV A, (50) [Read Overwritten Value] -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd255) begin
            $error("FAIL [Part 3]: Expected 255 from DM[50], got %d", regA_out);
            mem_sequence_test_failed = 1'b1;
        end

        if (!mem_sequence_test_failed) $display(">>>>> ALL MEMORY SEQUENCE TESTS PASSED! <<<<< ");
        else                           $display(">>>>> MEMORY SEQUENCE TEST FAILED! <<<<< ");

        // --- Test: ADD A, (Dir) ---
        $display("\n----- STARTING TEST: ADD A, (Dir) -----");
        #2;
        $display("CHECK @ t=%0t: After MOV A, 100 -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd100) begin
            $error("FAIL [ADD A, Dir]: regA expected 100, got %d", regA_out);
            add_a_dir_test_failed = 1'b1;
        end

        #2;
        $display("CHECK @ t=%0t: After MOV B, 50 -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd50) begin
            $error("FAIL [ADD A, Dir]: regB expected 50, got %d", regB_out);
            add_a_dir_test_failed = 1'b1;
        end

        #2;
        $display("CHECK @ t=%0t: After MOV (120), B -> DM[120] = %d", $time, Comp.DM.mem[120]);
        if (Comp.DM.mem[120] !== 8'd50) begin
            $error("FAIL [ADD A, Dir]: DM[120] expected 50, got %d", Comp.DM.mem[120]);
            add_a_dir_test_failed = 1'b1;
        end

        #2;
        $display("CHECK @ t=%0t: After ADD A, (120) -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd150) begin
            $error("FAIL [ADD A, Dir]: regA expected 150, got %d", regA_out);
            add_a_dir_test_failed = 1'b1;
        end

        if (!add_a_dir_test_failed) $display(">>>>> ADD A, (Dir) TEST PASSED! <<<<< ");
        else                        $display(">>>>> ADD A, (Dir) TEST FAILED! <<<<< ");

        // --- Test: JEQ (IF/ELSE) - A == B ---
        $display("\n----- STARTING TEST: JEQ - Case 1 (A == B) -----");
        #16; // 8 instrucciones * 2 ciclos por instrucción
        $display("CHECK @ t=%0t: After IF/ELSE program (A==B) -> DM[100] = %d", $time, Comp.DM.mem[100]);
        if (Comp.DM.mem[100] !== 8'd1) begin
            $error("FAIL [JEQ Case 1]: DM[100] expected 1, got %d. The jump was likely not taken.", Comp.DM.mem[100]);
            jeq_test_1_failed = 1'b1;
        end

        if (!jeq_test_1_failed) $display(">>>>> JEQ (A == B) TEST PASSED! <<<<< ");
        else                    $display(">>>>> JEQ (A == B) TEST FAILED! <<<<< ");

        #2;
        $finish;
    end

    // Clock
    always #1 clk = ~clk;
endmodule
