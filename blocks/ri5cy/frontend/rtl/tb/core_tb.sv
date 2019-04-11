import riscv_defines::*;

module core_tb;

  localparam BYTE_WIDTH      = 8;
  localparam BYTES_PER_INSTR = 4;
  localparam N_OF_INSTR      = 16;
  localparam WORD_WIDTH      = BYTE_WIDTH * BYTES_PER_INSTR;
  localparam MEM_SIZE        = WORD_WIDTH * N_OF_INSTR;

  localparam XZERO  = 5'b00000;
  localparam XRA    = 5'b00001;
  localparam XSP    = 5'b00010;
  localparam XGP    = 5'b00011;
  localparam XTP    = 5'b00100;
  localparam XT0    = 5'b00101;
  localparam XT1    = 5'b00110;
  localparam XT2    = 5'b00111;
  localparam XS0    = 5'b01000;
  localparam XS1    = 5'b01001;
  localparam XA0    = 5'b01010;
  localparam XA1    = 5'b01011;
  localparam XA2    = 5'b01100;
  localparam XA3    = 5'b01101;
  localparam XA4    = 5'b01110;
  localparam XA5    = 5'b01111;
  localparam XA6    = 5'b10000;
  localparam XA7    = 5'b10001;
  localparam XS2    = 5'b10010;
  localparam XS3    = 5'b10011;
  localparam XS4    = 5'b10100;
  localparam XS5    = 5'b10101;
  localparam XS6    = 5'b10110;
  localparam XS7    = 5'b10111;
  localparam XS8    = 5'b11000;
  localparam XS9    = 5'b11001;
  localparam XS10   = 5'b11010;
  localparam XS11   = 5'b11011;
  localparam XT3    = 5'b11100;
  localparam XT4    = 5'b11101;
  localparam XT5    = 5'b11110;
  localparam XT6    = 5'b11111;

  logic clk, rst_n;

  // Instaciação de array de memória
  logic [MEM_SIZE-1:0] virtual_mem;

  // Instaciação de array de instruções;
  logic [MEM_SIZE-1:0] list_of_instr;

  // Flag de endereço de memória válida
  logic valid_addr;

  // Interface de memória $i
  logic instr_req, instr_rvalid, instr_gnt;
  logic [WORD_WIDTH-1:0] instr_addr, instr_rdata;

  // Interface de controle
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

  // Lógica de handshake e push de instruções
  assign valid_addr = (instr_addr < N_OF_INSTR * BYTES_PER_INSTR);
  assign instr_gnt = (valid_addr) ? (instr_req) : (1'b0);
  always_ff @(posedge clk) begin
    if(!valid_addr) begin
      instr_rdata <= 32'hx;
      instr_rvalid <= 1'b0;
    end
    else if(instr_req) begin
      instr_rdata <= virtual_mem[instr_addr*8+:32];
      instr_rvalid <= 1'b1;
    end 
    else
      instr_rvalid <= 1'b0;
  end

  // Parametros de abstração de variáveis usadas
  localparam COUNT = XS0;
  localparam REVERSE = XS1;
  localparam FIFTEEN  = XT0;

  initial begin
    prepare_test();
    for(int i = 0; i < 1000; i++)
      toggle_clk(1);
    $finish;
  end

  task prepare_test();
    clk = 1'b0;
    rst_n = 1'b0;
    fetch_en = 1'b0;
    pc_start_addr = 32'b0;
    initiate_memory();
    toggle_clk(2);
    rst_n = 1'b1;
    toggle_clk(2);
    fetch_en = 1'b1;
  endtask

  task toggle_clk(int n_of_clocks);
    for(int i = 0; i < n_of_clocks; i++) begin
      #10 clk = !clk;
      #10 clk = !clk;
    end
  endtask

  task initiate_memory();
    $display("################################");
    $display("####CARREGAMENTO DE MEMORIA#####");
    $display("################################");
    assembly_code();
    for(int i = 0; i < N_OF_INSTR; i++) begin
      logic [WORD_WIDTH-1:0] addr;
      addr = i * WORD_WIDTH;
      virtual_mem[addr+:32] = list_of_instr[addr+:32];
      $display("- Mem Instr #%2h = %h", i*4, virtual_mem[addr+:32]);
    end
    $display("################################");
    $display("#FIM DE CARREGAMENTO DE MEMORIA#");
    $display("################################");
  endtask

  task assembly_code();
    list_of_instr = 'h0;
    // Inicialização
    list_of_instr[0*WORD_WIDTH+:32]   = ADD(COUNT, XZERO, XZERO);            // 00
    list_of_instr[1*WORD_WIDTH+:32]   = ADD(REVERSE, XZERO, XZERO);          // 04
    list_of_instr[2*WORD_WIDTH+:32]   = ADDI(FIFTEEN, XZERO, 12'd15);        // 08
    // Loop Infinito
    list_of_instr[3*WORD_WIDTH+:32]   = BEQ(REVERSE, XZERO, branch_imm(3));  // 0c
    list_of_instr[4*WORD_WIDTH+:32]   = ADDI(COUNT, COUNT, -1);              // 10
    list_of_instr[5*WORD_WIDTH+:32]   = JAL(XZERO, jal_imm(2));              // 14
    list_of_instr[6*WORD_WIDTH+:32]   = ADDI(COUNT, COUNT, 1);               // 18
    list_of_instr[7*WORD_WIDTH+:32]   = BNE(COUNT, XZERO, branch_imm(2));    // 1c
    list_of_instr[8*WORD_WIDTH+:32]   = ADD(REVERSE, XZERO, XZERO);          // 20
    list_of_instr[9*WORD_WIDTH+:32]   = BNE(COUNT, FIFTEEN, branch_imm(2));  // 24
    list_of_instr[10*WORD_WIDTH+:32]  = ADDI(REVERSE, XZERO, 1);             // 28
    list_of_instr[11*WORD_WIDTH+:32]  = JAL(XZERO, jal_imm(-8));             // 2c
  endtask

  function logic [12:0] branch_imm (int imm);
    return imm << 2;  
  endfunction

  function logic [20:0] jal_imm (int imm);
    return imm << 2;
  endfunction

  function logic [31:0] ADD(logic [4:0] rd, logic [4:0] rs1, logic [4:0] rs2);
    return {7'b0000000, rs2, rs1, 3'b000, rd, OPCODE_COMP};
  endfunction

  function logic [31:0] ADDI(logic [4:0] rd, logic [4:0] rs1, logic [11:0] imm);
    return {imm, rs1, 3'b000, rd, OPCODE_COMPIMM}; 
  endfunction

  function logic [31:0] BEQ(logic [4:0] rs1, logic [4:0] rs2, logic [12:0] imm);
    return {imm[12], imm[10:5], rs2, rs1, 3'b000, imm[4:1], imm[11], OPCODE_BRANCH};
  endfunction

  function logic [31:0] BNE(logic [4:0] rs1, logic [4:0] rs2, logic [12:0] imm);
    return {imm[12], imm[10:5], rs2, rs1, 3'b001, imm[4:1], imm[11], OPCODE_BRANCH};
  endfunction

  function logic [31:0] JAL(logic [4:0] rd, logic [20:0] imm);
    return {imm[20], imm[10:1], imm[11], imm[19:12], rd, OPCODE_JAL};
  endfunction

endmodule 