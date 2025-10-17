module test;
    reg           clk = 0;
    wire [7:0]    regA_out;
    wire [7:0]    regB_out;
    wire [7:0]    alu_out;
    wire [14:0]   im_out;

    reg mem_sequence_test_failed = 1'b0;
    reg add_a_dir_test_failed    = 1'b0;
    reg sub_dir_test_failed      = 1'b0;
    reg and_a_b_ind_test_failed  = 1'b0;
    reg or_b_dir_test_failed     = 1'b0;
    reg not_b_ind_test_failed    = 1'b0;
    reg xor_a_dir_test_failed    = 1'b0;
    reg shl_dir_b_test_failed    = 1'b0;
    reg shr_b_ind_test_failed    = 1'b0;
    reg inc_dir_test_failed      = 1'b0;
    reg rst_b_ind_test_failed    = 1'b0;
    reg jle_equal_test_failed    = 1'b0;
    reg for_loop_test_failed     = 1'b0;

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

        // Dejamos que instruction_memory cargue im.dat en t=0;
        // luego, si NO defines NO_TB_LOAD, lo recargamos desde aquí también.
        #1;
        `ifndef NO_TB_LOAD
          $readmemb("im.dat", Comp.IM.mem);
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

        // --- Test: SUB (Dir) ---
        $display("\n----- STARTING TEST: SUB (Dir) -----");
        #2;
        $display("CHECK @ t=%0t: After MOV A, 100 -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd100) begin
            $error("FAIL [SUB (Dir)]: regA expected 100, got %d", regA_out);
            sub_dir_test_failed = 1'b1;
        end

        #2;
        $display("CHECK @ t=%0t: After MOV B, 40 -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd40) begin
            $error("FAIL [SUB (Dir)]: regB expected 40, got %d", regB_out);
            sub_dir_test_failed = 1'b1;
        end

        #2;
        $display("CHECK @ t=%0t: After SUB (200) -> DM[200] = %d", $time, Comp.DM.mem[200]);
        if (Comp.DM.mem[200] !== 8'd60) begin
            $error("FAIL [SUB (Dir)]: DM[200] expected 60, got %d", Comp.DM.mem[200]);
            sub_dir_test_failed = 1'b1;
        end

        if (!sub_dir_test_failed) $display(">>>>> SUB (Dir) TEST PASSED! <<<<< ");
        else                      $display(">>>>> SUB (Dir) TEST FAILED! <<<<< ");

        // --- Test: AND A, (B) ---
        $display("\n----- STARTING TEST: AND A, (B) [Indirect Addressing] -----");
        #2;
        $display("CHECK @ t=%0t: After MOV A, 170 -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd170) begin
            $error("FAIL [AND A, (B)]: regA expected 170, got %d", regA_out);
            and_a_b_ind_test_failed = 1'b1;
        end

        #2;
        $display("CHECK @ t=%0t: After MOV (150), A -> DM[150] = %d", $time, Comp.DM.mem[150]);
        if (Comp.DM.mem[150] !== 8'd170) begin
            $error("FAIL [AND A, (B)]: DM[150] expected 170, got %d", Comp.DM.mem[150]);
            and_a_b_ind_test_failed = 1'b1;
        end

        #2;
        $display("CHECK @ t=%0t: After MOV A, 204 -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd204) begin
            $error("FAIL [AND A, (B)]: regA expected 204, got %d", regA_out);
            and_a_b_ind_test_failed = 1'b1;
        end

        #2;
        $display("CHECK @ t=%0t: After MOV B, 150 -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd150) begin
            $error("FAIL [AND A, (B)]: regB expected 150, got %d", regB_out);
            and_a_b_ind_test_failed = 1'b1;
        end

        #2;
        $display("CHECK @ t=%0t: After AND A, (B) -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd136) begin
            $error("FAIL [AND A, (B)]: regA expected 136, got %d", regA_out);
            and_a_b_ind_test_failed = 1'b1;
        end

        if (!and_a_b_ind_test_failed) $display(">>>>> AND A, (B) TEST PASSED! <<<<< ");
        else                          $display(">>>>> AND A, (B) TEST FAILED! <<<<< ");

        // --- Test: OR B, (Dir) ---
        $display("\n----- STARTING TEST: OR B, (0x10) [Direct Addressing] -----");
        #2;
        $display("CHECK @ t=%0t: After MOV B, 195 -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd195) begin
            $error("FAIL [OR B, Dir]: regB expected 195, got %d", regB_out);
            or_b_dir_test_failed = 1'b1;
        end

        #2;
        $display("CHECK @ t=%0t: After MOV A, 85 -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd85) begin
            $error("FAIL [OR B, Dir]: regA expected 85, got %d", regA_out);
            or_b_dir_test_failed = 1'b1;
        end

        #2;
        $display("CHECK @ t=%0t: After MOV (16), A -> DM[16] = %d", $time, Comp.DM.mem[16]);
        if (Comp.DM.mem[16] !== 8'd85) begin
            $error("FAIL [OR B, Dir]: DM[16] expected 85, got %d", Comp.DM.mem[16]);
            or_b_dir_test_failed = 1'b1;
        end

        #2;
        $display("CHECK @ t=%0t: After OR B, (16) -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd215) begin
            $error("FAIL [OR B, Dir]: regB expected 215, got %d", regB_out);
            or_b_dir_test_failed = 1'b1;
        end

        if (!or_b_dir_test_failed) $display(">>>>> OR B, (Dir) TEST PASSED! <<<<< ");
        else                       $display(">>>>> OR B, (Dir) TEST FAILED! <<<<< ");

        // --- Test: NOT (B) ---
        $display("\n----- STARTING TEST: NOT (B) [Indirect Addressing] -----");
        #2;
        $display("CHECK @ t=%0t: After MOV A, 165 -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd165) begin
            $error("FAIL [NOT (B)]: regA expected 165, got %d", regA_out);
            not_b_ind_test_failed = 1'b1;
        end

        #2;
        $display("CHECK @ t=%0t: After MOV B, 210 -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd210) begin
            $error("FAIL [NOT (B)]: regB expected 210, got %d", regB_out);
            not_b_ind_test_failed = 1'b1;
        end

        #2;
        $display("CHECK @ t=%0t: After NOT (B) -> DM[210] = %d", $time, Comp.DM.mem[210]);
        if (Comp.DM.mem[210] !== 8'd90) begin
            $error("FAIL [NOT (B)]: DM[210] expected 90, got %d", Comp.DM.mem[210]);
            not_b_ind_test_failed = 1'b1;
        end

        if (!not_b_ind_test_failed) $display(">>>>> NOT (B) TEST PASSED! <<<<< ");
        else                        $display(">>>>> NOT (B) TEST FAILED! <<<<< ");

        // --- Test: XOR A, (Dir) ---
        $display("\n----- STARTING TEST: XOR A, (Dir) [Direct Addressing] -----");
        #2;
        $display("CHECK @ t=%0t: After MOV A, 202 -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd202) begin
            $error("FAIL [XOR A, Dir]: regA expected 202, got %d", regA_out);
            xor_a_dir_test_failed = 1'b1;
        end

        #2;
        $display("CHECK @ t=%0t: After MOV B, 172 -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd172) begin
            $error("FAIL [XOR A, Dir]: regB expected 172, got %d", regB_out);
            xor_a_dir_test_failed = 1'b1;
        end

        #2;
        $display("CHECK @ t=%0t: After MOV (220), B -> DM[220] = %d", $time, Comp.DM.mem[220]);
        if (Comp.DM.mem[220] !== 8'd172) begin
            $error("FAIL [XOR A, Dir]: DM[220] expected 172, got %d", Comp.DM.mem[220]);
            xor_a_dir_test_failed = 1'b1;
        end

        #2;
        $display("CHECK @ t=%0t: After XOR A, (220) -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd102) begin
            $error("FAIL [XOR A, Dir]: regA expected 102, got %d", regA_out);
            xor_a_dir_test_failed = 1'b1;
        end

        if (!xor_a_dir_test_failed) $display(">>>>> XOR A, (Dir) TEST PASSED! <<<<< ");
        else                        $display(">>>>> XOR A, (Dir) TEST FAILED! <<<<< ");

        // --- Test: SHL (Dir), B ---
        $display("\n----- STARTING TEST: SHL (Dir), B [Direct Addressing] -----");
        #2;
        $display("CHECK @ t=%0t: After MOV B, 85 -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd85) begin
            $error("FAIL [SHL (Dir),B]: regB expected 85, got %d", regB_out);
            shl_dir_b_test_failed = 1'b1;
        end

        #2;
        $display("CHECK @ t=%0t: After SHL (230), B -> DM[230] = %d", $time, Comp.DM.mem[230]);
        if (Comp.DM.mem[230] !== 8'd170) begin
            $error("FAIL [SHL (Dir),B]: DM[230] expected 170, got %d", Comp.DM.mem[230]);
            shl_dir_b_test_failed = 1'b1;
        end

        if (!shl_dir_b_test_failed) $display(">>>>> SHL (Dir), B TEST PASSED! <<<<< ");
        else                        $display(">>>>> SHL (Dir), B TEST FAILED! <<<<< ");

        // --- Test: SHR (B) ---
        $display("\n----- STARTING TEST: SHR (B) [Indirect Addressing] -----");
        #2;
        $display("CHECK @ t=%0t: After MOV A, 212 -> regA = %d", $time, regA_out);
        if (regA_out !== 8'd212) begin
            $error("FAIL [SHR (B)]: regA expected 212, got %d", regA_out);
            shr_b_ind_test_failed = 1'b1;
        end

        #2;
        $display("CHECK @ t=%0t: After MOV B, 240 -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd240) begin
            $error("FAIL [SHR (B)]: regB expected 240, got %d", regB_out);
            shr_b_ind_test_failed = 1'b1;
        end

        #2;
        $display("CHECK @ t=%0t: After SHR (B) -> DM[240] = %d", $time, Comp.DM.mem[240]);
        if (Comp.DM.mem[240] !== 8'd106) begin
            $error("FAIL [SHR (B)]: DM[240] expected 106, got %d", Comp.DM.mem[240]);
            shr_b_ind_test_failed = 1'b1;
        end

        if (!shr_b_ind_test_failed) $display(">>>>> SHR (B) TEST PASSED! <<<<< ");
        else                        $display(">>>>> SHR (B) TEST FAILED! <<<<< ");

        // --- Test: INC (Dir) ---
        $display("\n----- STARTING TEST: INC (Dir) [Read-Modify-Write] -----");
        #4;
        $display("CHECK @ t=%0t: After Setup 1 -> DM[250] = %d", $time, Comp.DM.mem[250]);
        if (Comp.DM.mem[250] !== 8'd77) begin
            $error("FAIL [INC (Dir)]: Setup failed, DM[250] expected 77, got %d", Comp.DM.mem[250]);
            inc_dir_test_failed = 1'b1;
        end

        #2;
        $display("CHECK @ t=%0t: After INC (250) -> DM[250] = %d", $time, Comp.DM.mem[250]);
        if (Comp.DM.mem[250] !== 8'd78) begin
            $error("FAIL [INC (Dir)]: DM[250] expected 78, got %d", Comp.DM.mem[250]);
            inc_dir_test_failed = 1'b1;
        end

        #4;
        $display("CHECK @ t=%0t: After Setup 2 -> DM[251] = %d", $time, Comp.DM.mem[251]);
        if (Comp.DM.mem[251] !== 8'd255) begin
            $error("FAIL [INC (Dir)]: Setup failed, DM[251] expected 255, got %d", Comp.DM.mem[251]);
            inc_dir_test_failed = 1'b1;
        end

        #2;
        $display("CHECK @ t=%0t: After INC (251) [Overflow] -> DM[251] = %d", $time, Comp.DM.mem[251]);
        if (Comp.DM.mem[251] !== 8'd0) begin
            $error("FAIL [INC (Dir)]: DM[251] expected 0 after overflow, got %d", Comp.DM.mem[251]);
            inc_dir_test_failed = 1'b1;
        end

        if (!inc_dir_test_failed) $display(">>>>> INC (Dir) TEST PASSED! <<<<< ");
        else                      $display(">>>>> INC (Dir) TEST FAILED! <<<<< ");

        // --- Test: RST (B) ---
        $display("\n----- STARTING TEST: RST (B) [Indirect Addressing] -----");
        #4;
        $display("CHECK @ t=%0t: After Setup -> DM[255] = %d", $time, Comp.DM.mem[255]);
        if (Comp.DM.mem[255] !== 8'd123) begin
            $error("FAIL [RST (B)]: Setup failed, DM[255] expected 123, got %d", Comp.DM.mem[255]);
            rst_b_ind_test_failed = 1'b1;
        end

        #2;
        $display("CHECK @ t=%0t: After MOV B, 255 -> regB = %d", $time, regB_out);
        if (regB_out !== 8'd255) begin
            $error("FAIL [RST (B)]: regB expected 255, got %d", regB_out);
            rst_b_ind_test_failed = 1'b1;
        end

        #2;
        $display("CHECK @ t=%0t: After RST (B) -> DM[255] = %d", $time, Comp.DM.mem[255]);
        if (Comp.DM.mem[255] !== 8'd0) begin
            $error("FAIL [RST (B)]: DM[255] expected 0, got %d", Comp.DM.mem[255]);
            rst_b_ind_test_failed = 1'b1;
        end

        if (!rst_b_ind_test_failed) $display(">>>>> RST (B) TEST PASSED! <<<<< ");
        else                        $display(">>>>> RST (B) TEST FAILED! <<<<< ");

        // --- Test: JLE - Case 2: A == Mem[B] ---
        $display("\n----- STARTING TEST: JLE - Case 2 (A == Mem[B]) -----");
        #20;
        $display("CHECK @ t=%0t: After JLE program (A == Mem[B]) -> DM[100] = %d", $time, Comp.DM.mem[100]);
        if (Comp.DM.mem[100] !== 8'd1) begin
            $error("FAIL [JLE Case 2]: DM[100] expected 1, got %d. Jump was not taken.", Comp.DM.mem[100]);
            jle_equal_test_failed = 1'b1;
        end
        if (!jle_equal_test_failed) $display(">>>>> JLE (A == Mem[B]) TEST PASSED! <<<<< ");
        else                        $display(">>>>> JLE (A == Mem[B]) TEST FAILED! <<<<< ");

        // --- Test: FOR Loop (JGE, JMP) ---
        $display("\n----- STARTING TEST: FOR Loop (JGE, JMP) -----");
        // 2 setup + 4*5 loop + 3 check fallido + 1 NOP = 26 instrucciones → 52 ciclos
        #52;

        $display("CHECK @ t=%0t: After FOR loop, verifying memory...", $time);
        if (Comp.DM.mem[3] !== 8'd99) begin
            $error("FAIL [FOR Loop]: DM[3] expected 99, got %d", Comp.DM.mem[3]);
            for_loop_test_failed = 1'b1;
        end
        if (Comp.DM.mem[2] !== 8'd99) begin
            $error("FAIL [FOR Loop]: DM[2] expected 99, got %d", Comp.DM.mem[2]);
            for_loop_test_failed = 1'b1;
        end
        if (Comp.DM.mem[1] !== 8'd99) begin
            $error("FAIL [FOR Loop]: DM[1] expected 99, got %d", Comp.DM.mem[1]);
            for_loop_test_failed = 1'b1;
        end
        if (Comp.DM.mem[0] !== 8'd99) begin
            $error("FAIL [FOR Loop]: DM[0] expected 99, got %d", Comp.DM.mem[0]);
            for_loop_test_failed = 1'b1;
        end
        if (Comp.DM.mem[4] !== 8'hx) begin
            $error("FAIL [FOR Loop]: DM[4] should be unwritten, but has value %h.", Comp.DM.mem[4]);
            for_loop_test_failed = 1'b1;
        end

        if (!for_loop_test_failed) $display(">>>>> FOR Loop TEST PASSED! <<<<< ");
        else                       $display(">>>>> FOR Loop TEST FAILED! <<<<< ");

        #2;
        $finish;
    end

    // Clock
    always #1 clk = ~clk;
endmodule
