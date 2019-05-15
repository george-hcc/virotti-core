import riscv_defines::*;

module mmc
  (
    // Interface da Memória de Dados vinda do Core
    input  logic                  data_req_i,
    input  logic [WORD_WIDTH-1:0] data_addr_i,
    input  logic                  data_we_i,
    input  logic [3:0]            data_be_i,
    input  logic [WORD_WIDTH-1:0] data_wdata_i,
    output logic [WORD_WIDTH-1:0] data_rdata_o,
    output logic                  data_rvalid_o,
    output logic                  data_gnt_o,

    // Interface da Memória de Instruções vinda do Core
    input  logic                  instr_req_i,
    input  logic [WORD_WIDTH-1:0] instr_addr_i,
    output logic [WORD_WIDTH-1:0] instr_rdata_o,
    output logic                  instr_rvalid_o,
    output logic                  instr_gnt_o,

    // Interface da Memória de Dados vinda da DataMem
    output logic                  data_req_o,
    output logic [WORD_WIDTH-1:0] data_addr_o,
    output logic                  data_we_o,
    output logic [3:0]            data_be_o,
    output logic [WORD_WIDTH-1:0] data_wdata_o,
    input  logic [WORD_WIDTH-1:0] data_rdata_i,
    input  logic                  data_rvalid_i,
    input  logic                  data_gnt_i,

    // Interface da Memória de Instruções vinda da InstrMem
    output logic                  instr_req_o,
    output logic [WORD_WIDTH-1:0] instr_addr_o,
    input  logic [WORD_WIDTH-1:0] instr_rdata_i,
    input  logic                  instr_rvalid_i,
    input  logic                  instr_gnt_i,

    output logic                  mmc_exception_o
  );

  logic instr_mmc_exception;
  logic data_mmc_exception;

  assign mmc_exception_o = instr_mmc_exception || data_mmc_exception;

  // Conexão entre interfaces de instruções
  always_comb begin
    instr_rdata_o   =   instr_rdata_i;
    instr_rvalid_o  =   instr_rvalid_i;
    instr_gnt_o     =   instr_gnt_i;
    instr_req_o     =   instr_req_i;
    instr_addr_o    =   instr_addr_i;
    if(!instr_req_i || instr_addr_i < DMEM_START_ADDR)
      instr_mmc_exception = 1'b0;
    else
      instr_mmc_exception = 1'b1;
  end

  // Conexão entre interfaces de dados
  always_comb begin
    data_req_o      =   data_req_i;
    data_addr_o     =   data_addr_i - DMEM_START_ADDR;
    data_we_o       =   data_we_i;
    data_be_o       =   data_be_i;
    data_wdata_o    =   data_wdata_i;
    data_rdata_o    =   data_rdata_i;
    data_rvalid_o   =   data_rvalid_i;
    data_gnt_o      =   data_gnt_i;
    if(!instr_req_i || DMEM_START_ADDR <= data_addr_i < ROM_START_ADDR)
      data_mmc_exception = 1'b0;
    else
      data_mmc_exception = 1'b1;
  end

endmodule