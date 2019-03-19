interface core_instr_mem_if;

  logic                   instr_req;
  logic [WORD_WIDTH-1:0]  instr_addr;
  logic [WORD_WIDTH-1:0]  instr_rdata;
  logic                   instr_rvalid;
  logic                   instr_gnt;

endinterface