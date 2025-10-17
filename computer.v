`default_nettype none
module computer(
  input  wire       clk,
  output wire [7:0] alu_out_bus
);

  // =============== PC & IM ===============
  wire [7:0]  pc_out_bus;
  wire        pc_load;
  wire [7:0]  pc_next;

  pc PC(
    .clk    (clk),
    .load   (pc_load),
    .next_pc(pc_next),
    .pc     (pc_out_bus)
  );

  wire [14:0] im_out_bus;              // [14:8]=opcode (7b), [7:0]=literal
  wire [6:0]  opcode  = im_out_bus[14:8];
  wire [7:0]  literal = im_out_bus[7:0];

  instruction_memory IM(
    .address(pc_out_bus),
    .out    (im_out_bus)
  );

  // =============== Registros A/B ===============
  wire [7:0] regA_out_bus, regB_out_bus;
  reg  [7:0] nextA, nextB;
  reg        loadA, loadB;

  register regA(
    .clk (clk),
    .data(nextA),
    .load(loadA),
    .out (regA_out_bus)
  );

  register regB(
    .clk (clk),
    .data(nextB),
    .load(loadB),
    .out (regB_out_bus)
  );

  // =============== Data Memory (DM) ===============
  wire [7:0] dm_rdata;
  reg        dm_we;
  reg  [7:0] dm_addr, dm_wdata;

  data_memory DM(
    .clk  (clk),
    .we   (dm_we),
    .addr (dm_addr),
    .wdata(dm_wdata),
    .rdata(dm_rdata)
  );

  // =============== ALU (visible en waveform) ===============
  reg  [7:0] alu_a, alu_b;
  reg  [2:0] alu_s;

  alu ALU(
    .a  (alu_a),
    .b  (alu_b),
    .s  (alu_s),
    .out(alu_out_bus)
  );

  // =============== FLAGS ===============
  reg Z, N;           // Zero / Negativo (bit 7)
  reg set_flags;
  reg z_next, n_next;

  // =============== Control de PC ===============
  reg        pc_load_r;
  reg [7:0]  pc_next_r;
  assign pc_load = pc_load_r;
  assign pc_next = pc_next_r;

  // =============== Decoder ===============
  always @* begin
    // Defaults
    loadA   = 1'b0;
    loadB   = 1'b0;
    nextA   = regA_out_bus;
    nextB   = regB_out_bus;

    dm_we   = 1'b0;
    dm_addr = 8'd0;
    dm_wdata= 8'd0;

    alu_a   = regA_out_bus;
    alu_b   = regB_out_bus;
    alu_s   = 3'b000; // PASS A

    pc_load_r = 1'b0;
    pc_next_r = 8'd0;

    set_flags = 1'b0;
    z_next    = Z;
    n_next    = N;

    case (opcode)
      // ---------- MOV inmediatos ----------
      7'b0000010: begin // MOV A, Lit
        nextA = literal; loadA = 1'b1;
      end
      7'b0000011: begin // MOV B, Lit
        nextB = literal; loadB = 1'b1;
      end

      // ---------- MOV directa / indirecta ----------
      7'b0100101: begin // MOV A, (Dir)
        dm_addr = literal; nextA = dm_rdata; loadA = 1'b1;
      end
      7'b0100110: begin // MOV B, (Dir)
        dm_addr = literal; nextB = dm_rdata; loadB = 1'b1;
      end
      7'b0100111: begin // MOV (Dir), A
        dm_addr = literal; dm_wdata = regA_out_bus; dm_we = 1'b1;
      end
      7'b0101000: begin // MOV (Dir), B
        dm_addr = literal; dm_wdata = regB_out_bus; dm_we = 1'b1;
      end
      7'b0101001: begin // MOV A, (B)
        dm_addr = regB_out_bus; nextA = dm_rdata; loadA = 1'b1;
      end
      7'b0101011: begin // MOV (B), A
        dm_addr = regB_out_bus; dm_wdata = regA_out_bus; dm_we = 1'b1;
      end

      // ---------- Aritm/Log con memoria (calc directo) ----------
      7'b0101100: begin // ADD A, (Dir)    A <- A + Mem[Lit]
        dm_addr = literal;
        nextA   = regA_out_bus + dm_rdata; loadA = 1'b1;
        set_flags = 1'b1; z_next = (nextA==8'd0); n_next = nextA[7];
      end

      7'b0110011: begin // SUB (Dir)       Mem[Lit] <- A - B
        dm_addr = literal;
        dm_wdata= regA_out_bus - regB_out_bus; dm_we = 1'b1;
        set_flags = 1'b1; z_next = (dm_wdata==8'd0); n_next = dm_wdata[7];
      end

      7'b0110110: begin // AND A, (B)      A <- A & Mem[B]
        dm_addr = regB_out_bus;
        nextA   = regA_out_bus & dm_rdata; loadA = 1'b1;
        set_flags = 1'b1; z_next = (nextA==8'd0); n_next = nextA[7];
      end

      7'b0111001: begin // OR B, (Dir)     B <- B | Mem[Lit]
        dm_addr = literal;
        nextB   = regB_out_bus | dm_rdata; loadB = 1'b1;
        set_flags = 1'b1; z_next = (nextB==8'd0); n_next = nextB[7];
      end

      7'b0111111: begin // XOR A, (Dir)    A <- A ^ Mem[Lit]
        dm_addr = literal;
        nextA   = regA_out_bus ^ dm_rdata; loadA = 1'b1;
        set_flags = 1'b1; z_next = (nextA==8'd0); n_next = nextA[7];
      end

      // ---------- NOT / Shifts / RMW ----------
      7'b0111110: begin // NOT (B)         Mem[B] <- ~A
        dm_addr = regB_out_bus;
        dm_wdata= ~regA_out_bus; dm_we = 1'b1;
        set_flags = 1'b1; z_next = (dm_wdata==8'd0); n_next = dm_wdata[7];
      end

      7'b1000100: begin // SHL (Dir), B    Mem[Lit] <- B << 1
        dm_addr = literal;
        dm_wdata= regB_out_bus << 1; dm_we = 1'b1;
        set_flags = 1'b1; z_next = (dm_wdata==8'd0); n_next = dm_wdata[7];
      end

      7'b1001000: begin // SHR (B)         Mem[B] <- A >> 1
        dm_addr = regB_out_bus;
        dm_wdata= regA_out_bus >> 1; dm_we = 1'b1;
        set_flags = 1'b1; z_next = (dm_wdata==8'd0); n_next = dm_wdata[7];
      end

      7'b1001001: begin // INC (Dir)       Mem[Lit] <- Mem[Lit] + 1
        dm_addr = literal;
        dm_wdata= dm_rdata + 8'd1; dm_we = 1'b1;
        set_flags = 1'b1; z_next = (dm_wdata==8'd0); n_next = dm_wdata[7];
      end

      7'b1001100: begin // RST (B)         Mem[B] <- 0
        dm_addr = regB_out_bus; dm_wdata = 8'd0; dm_we = 1'b1;
        set_flags = 1'b1; z_next = 1'b1; n_next = 1'b0;
      end

      // ---------- Comparacion y Saltos ----------
      7'b1001101: begin // CMP A,B  (solo flags)
        set_flags = 1'b1;
        z_next    = (regA_out_bus == regB_out_bus);
        n_next    = ($signed({1'b0,regA_out_bus}) - $signed({1'b0,regB_out_bus})) < 0;
      end

      7'b1010011: begin // JMP Lit
        pc_load_r = 1'b1; pc_next_r = literal;
      end

      7'b1010100: begin // JEQ Lit  (Z == 1)
        if (Z) begin pc_load_r = 1'b1; pc_next_r = literal; end
      end

      7'b1011000: begin // JGE Lit  (N == 0)
        if (!N) begin pc_load_r = 1'b1; pc_next_r = literal; end
      end

      7'b1011001: begin // JLE Lit  (N == 1) || (Z == 1)
        if (N || Z) begin pc_load_r = 1'b1; pc_next_r = literal; end
      end
            // ---------- Nuevas: SUB B, Lit  y  CMP B, Lit ----------
      7'b0001011: begin // SUB B, Lit      B <- B - Lit
        nextB = regB_out_bus - literal; 
        loadB = 1'b1;
        set_flags = 1'b1; 
        z_next = (nextB == 8'd0); 
        n_next = nextB[7];
      end

      7'b1001111: begin // CMP B, Lit      (solo flags con B - Lit)
        set_flags = 1'b1;
        z_next = (regB_out_bus == literal);
        // "negativo" si (B - Lit) < 0 en 8 bits sin signo:
        n_next = ($signed({1'b0,regB_out_bus}) - $signed({1'b0,literal})) < 0;
      end

      default: begin
        // NOP
      end
    endcase
  end

  // =============== Registro de FLAGS ===============
  always @(posedge clk) begin
    if (set_flags) begin
      Z <= z_next;
      N <= n_next;
    end
  end

endmodule
