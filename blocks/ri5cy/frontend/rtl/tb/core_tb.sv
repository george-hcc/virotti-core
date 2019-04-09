import riscv_defines::*;

module core_tb;

  parameter N_OF_BYTES = 64;
  parameter MEM_SIZE = 64*4;

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
  logic [MEM_SIZE-1:0] virtual_mem ;

  logic instr_req, instr_rvalid, instr_gnt;
  logic [WORD_WIDTH-1:0] instr_addr, instr_rdata;

  logic fetch_en;
  logic [WORD_WIDTH-1:0] pc_start_addr;


  // Instaciação do Core
  core core_da_massa
    (
      .clk                      (clk),
      .rst_n                    (rst_n),

      // Interface de memória de instruções
      .instr_req_o              (instr_req),
      .instr_addr_o             (instr_addr),
      .instr_rdata_i            (instr_rdata),
      .instr_rvalid_i           (instr_rvalid),
      .instr_gnt_i              (instr_gnt),
/*
      // Interface de memória de dados
      .data_req_o               (),
      .data_addr_o              (),
      .data_we_o                (),
      .data_be_o                (),
      .data_wdata_o             (),
      .data_rdata_i             (),
      .data_rvalid_i            (),
      .data_gnt_i               (),
*/
      // Interface de SocControl
      .fetch_en_i               (fetch_en),
      .pc_start_addr_i          (pc_start_addr)
/*    .irq_id_i                 (),
      .irq_event_i              (),
      .socctrl_mmc_exception_i  ()
*/
    );

  always_ff @(posedge clk) begin
    if(instr_req) begin
      instr_rdata <= virtual_mem[instr_addr*8+:32];
      instr_rvalid <= 1'b1;
    end else
      instr_rvalid <= 1'b0;
  end

  assign instr_gnt = instr_req;

  localparam COUNT = XS0;
  localparam REVERSE_FLAG = XS1;
  localparam FIFTEEN  = XT0;

  initial begin
    prepare_test();
    for(int i = 0; i < 100; i++)
      toggle_clk();
    $finish;
  end

  task prepare_test();
    clk = 1'b0;
    rst_n = 1'b0;
    fetch_en = 1'b0;
    pc_start_addr = 32'b0;
    initiate_memory();
    toggle_clk();
    rst_n = 1'b1;
    toggle_clk();
    fetch_en = 1'b1;
  endtask

  task toggle_clk();
    #10 clk = !clk;
    #10 clk = !clk;
  endtask

  task initiate_memory();
    virtual_mem[0*WORD_WIDTH+:32]   = ADD(COUNT, XZERO, XZERO); // Start of Main
    virtual_mem[1*WORD_WIDTH+:32]   = ADD(REVERSE_FLAG, XZERO, XZERO);
    virtual_mem[2*WORD_WIDTH+:32]   = ADDI(FIFTEEN, XZERO, 12'd15);
    virtual_mem[3*WORD_WIDTH+:32]   = BEQ(REVERSE_FLAG, XZERO, 6*WORD_WIDTH/4); // Start of Loop
    virtual_mem[4*WORD_WIDTH+:32]   = ADDI(COUNT, COUNT, -1);
    virtual_mem[5*WORD_WIDTH+:32]   = BEQ(XZERO, XZERO, 7*WORD_WIDTH/4);
    virtual_mem[6*WORD_WIDTH+:32]   = ADDI(COUNT, COUNT, 1);
    virtual_mem[7*WORD_WIDTH+:32]   = BNE(COUNT, XZERO, 9*WORD_WIDTH/4);
    virtual_mem[8*WORD_WIDTH+:32]   = ADDI(REVERSE_FLAG, XZERO, 1);
    virtual_mem[9*WORD_WIDTH+:32]   = BNE(COUNT, FIFTEEN, 11*WORD_WIDTH/4);
    virtual_mem[10*WORD_WIDTH+:32]  = ADD(REVERSE_FLAG, XZERO, XZERO);
    virtual_mem[11*WORD_WIDTH+:32]  = BEQ(XZERO, XZERO, 3*WORD_WIDTH/4);
  endtask

  function logic [31:0] ADD(logic [4:0] rd, logic [4:0] rs1, logic [4:0] rs2);
    return {7'b0000000, rs2, rs1, 3'b000, rd, OPCODE_COMP};
  endfunction

  function logic [31:0] ADDI(logic [4:0] rd, logic [4:0] rs1, logic [11:0] imm);
    return {imm, rs1, 3'b000, rd, OPCODE_COMPIMM}; 
  endfunction

  function logic [31:0] BEQ(logic [4:0] rs1, logic [4:0] rs2, logic [12:1] imm);
    return {imm[12], imm[10:5], rs2, rs1, 3'b000, imm[4:1], imm[11], OPCODE_BRANCH};
  endfunction

  function logic [31:0] BNE(logic [4:0] rs1, logic [4:0] rs2, logic [12:1] imm);
    return {imm[12], imm[10:5], rs2, rs1, 3'b001, imm[4:1], imm[11], OPCODE_BRANCH};
  endfunction

endmodule 