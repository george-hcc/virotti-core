interface core_control_if;

  logic                   fetch_en;
  logic [WORD_WIDTH-1:0]  pc_start_address;
  logic [4:0]             irq_id;
  logic                   irq_event;
  logic                   soccontrol_mmc_exception;

endinterface