import riscv_defines::*;

module core_tb;

  parameter MEM_SIZE  = 256;

  localparam XZERO    = 5'b00000;
  localparam XRA      = 5'b00001;
  localparam XSP      = 5'b00010;
  localparam XGP      = 5'b00011;
  localparam XTP      = 5'b00100;
  localparam XT0      = 5'b00101;
  localparam XT1      = 5'b00110;
  localparam XT2      = 5'b00111;
  localparam XS0      = 5'b01000;
  localparam XS1      = 5'b01001;
  localparam XA0      = 5'b01010;
  localparam XA1      = 5'b01011;
  localparam XA2      = 5'b01100;
  localparam XA3      = 5'b01101;
  localparam XA4      = 5'b01110;
  localparam XA5      = 5'b01111;
  localparam XA6      = 5'b10000;
  localparam XA7      = 5'b10001;
  localparam XS2      = 5'b10010;
  localparam XS3      = 5'b10011;
  localparam XS4      = 5'b10100;
  localparam XS5      = 5'b10101;
  localparam XS6      = 5'b10110;
  localparam XS7      = 5'b10111;
  localparam XS8      = 5'b11000;
  localparam XS9      = 5'b11001;
  localparam XS10     = 5'b11010;
  localparam XS11     = 5'b11011;
  localparam XT3      = 5'b11100;
  localparam XT4      = 5'b11101;
  localparam XT5      = 5'b11110;
  localparam XT6      = 5'b11111;

  logic clk, rst_n;

  // Instaciação de array de memória
  logic [7:0] virtual_mem [MEM_SIZE-1:0];

  // Instaciação do Core
  core core_da_massa
    (
      .clk                      (clk),
      .rst_n                    (rst_n),

      // Interface de memória de instruções
      .instr_req_o              (),
      .instr_addr_o             (),
      .instr_rdata_i            (),
      .instr_rvalid_i           (),
      .instr_gnt_i              (),

      // Interface de memória de dados
      .data_req_o               (),
      .data_addr_o              (),
      .data_we_o                (),
      .data_be_o                (),
      .data_wdata_o             (),
      .data_rdata_i             (),
      .data_rvalid_i            (),
      .data_gnt_i               (),

      // Interface de SocControl
      .fetch_en_i               (),
      .pc_start_addr_i          (),
      .irq_id_i                 (),
      .irq_event_i              (),
      .socctrl_mmc_exception_i  ()
    );


  localparam COUNT = XS0;
  localparam REVERSE_FLAG = XS1;
  localparam FIFTEEN  = XT0;

  initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    initiate_memory();
    toggle_clk();
  end

  task toggle_clk();
    #10 clk = !clk;
    #10 clk = !clk;
  endtask

  task initiate_memory();
    virtual_mem[3:0]    = ADD(COUNT, XZERO, XZERO); // Start of Main
    virtual_mem[7:4]    = ADD(REVERSE_FLAG, XZERO, XZERO);
    virtual_mem[11:8]   = ADDI(FIFTEEN, XZERO, 12'd15);
    virtual_mem[15:12]  = BEQ(REVERSE_FLAG, XZERO, 13'd24); // Start of Loop
    virtual_mem[19:16]  = ADDI(COUNT, COUNT, -1);
    virtual_mem[23:20]  = BEQ(XZERO, XZERO, 13'd28);
    virtual_mem[27:24]  = ADDI(COUNT, COUNT, 1);
    virtual_mem[31:28]  = BNE(COUNT, XZERO, 13'd36);
    virtual_mem[35:32]  = ADDI(REVERSE_FLAG, XZERO, 1);
    virtual_mem[39:36]  = BNE(COUNT, FIFTEEN, 13'd44);
    virtual_mem[43:40]  = ADD(REVERSE_FLAG, XZERO, XZERO);
    virtual_mem[47:44]  = BEQ(XZERO, XZERO, 12);
  endtask;

  function logic [31:0] ADD(logic [4:0] rd, logic [4:0] rs1, logic [4:0] rs2);
    return {7'b0000000, rs2, rs1, 3'b000, rd, OPCODE_COMP}  
  endfunction

  function logic [31:0] ADDI(logic [4:0] rd, logic [4:0] rs1, logic [11:0] imm);
    return {imm, rs1, 3'b000, rd, OPCODE_COMP_IMM}  
  endfunction

  function logic [31:0] BEQ(logic [4:0] rs1, logic [4:0] rs2, logic [12:1] imm);
    return {imm[12], imm[10:5], rs2, rs1, 3'b000, imm[4:1], imm[11], OPCODE_BRANCH}  
  endfunction

  function logic [31:0] BNE(logic [4:0] rs1, logic [4:0] rs2, logic [12:1] imm);
    return {imm[12], imm[10:5], rs2, rs1, 3'b001, imm[4:1], imm[11], OPCODE_BRANCH}  
  endfunction

endmodule 