interface core_data_mem_if;

  logic                   data_req;
  logic [WORD_WIDTH-1:0]  data_addr;
  logic                   data_we;
  logic [3:0]             data_be;
  logic [WORD_WIDTH-1:0]  data_wdata;
  logic [WORD_WIDTH-1:0]  data_rdata;
  logic                   data_rvalid;
  logic                   data_gnt;

endinterface