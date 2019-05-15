import riscv_defines::*;

module testbench
  #(
    parameter CORE_TEST = 2
  );

  logic clk, rst_n;

  // Interface de memória $i do lado core-mmc
  logic instr_req_core, instr_rvalid_core, instr_gnt_core;
  logic [WORD_WIDTH-1:0] instr_addr_core, instr_rdata_core;

  // Interface de memória $d do lado core-mmc
  logic data_req_core, data_we_core, data_rvalid_core, data_gnt_core;
  logic [WORD_WIDTH-1:0] data_addr_core, data_wdata_core, data_rdata_core;
  logic [3:0] data_be_core;

  // Interface de memória $i do lado mmc-memória
  logic instr_req_mem, instr_rvalid_mem, instr_gnt_mem;
  logic [WORD_WIDTH-1:0] instr_addr_mem, instr_rdata_mem;

  // Interface de memória $d do lado mmc-memória
  logic data_req_mem, data_we_mem, data_rvalid_mem, data_gnt_mem;
  logic [WORD_WIDTH-1:0] data_addr_mem, data_wdata_mem, data_rdata_mem;
  logic [3:0] data_be_mem;

  // Interface de controle
  logic fetch_en;
  logic [WORD_WIDTH-1:0] pc_start_addr;

  logic mmc_exception;

  // Instaciação do Core
  core core_da_massa
    (
      .clk                      (clk),
      .rst_n                    (rst_n),

      // Interface de memória de instruções
      .instr_req_o              (instr_req_core),
      .instr_addr_o             (instr_addr_core),
      .instr_rdata_i            (instr_rdata_core),
      .instr_rvalid_i           (instr_rvalid_core),
      .instr_gnt_i              (instr_gnt_core),

      // Interface de memória de dados
      .data_req_o               (data_req_core),
      .data_addr_o              (data_addr_core),
      .data_we_o                (data_we_core),
      .data_be_o                (data_be_core),
      .data_wdata_o             (data_wdata_core),
      .data_rdata_i             (data_rdata_core),
      .data_rvalid_i            (data_rvalid_core),
      .data_gnt_i               (data_gnt_core),

      // Interface de SocControl
      .fetch_en_i               (fetch_en),
      .pc_start_addr_i          (pc_start_addr)
/*    .irq_id_i                 (),
      .irq_event_i              (),
      .socctrl_mmc_exception_i  ()
*/
    );

  mmc mmc
    (
      .data_req_i               (data_req_core),
      .data_addr_i              (data_addr_core),
      .data_we_i                (data_we_core),
      .data_be_i                (data_be_core),
      .data_wdata_i             (data_wdata_core),
      .data_rdata_o             (data_rdata_core),
      .data_rvalid_o            (data_rvalid_core),
      .data_gnt_o               (data_gnt_core),
      .instr_req_i              (instr_req_core),
      .instr_addr_i             (instr_addr_core),
      .instr_rdata_o            (instr_rdata_core),
      .instr_rvalid_o           (instr_rvalid_core),
      .instr_gnt_o              (instr_gnt_core),
      
      .data_req_o               (data_req_mem),
      .data_addr_o              (data_addr_mem),
      .data_we_o                (data_we_mem),
      .data_be_o                (data_be_mem),
      .data_wdata_o             (data_wdata_mem),
      .data_rdata_i             (data_rdata_mem),
      .data_rvalid_i            (data_rvalid_mem),
      .data_gnt_i               (data_gnt_mem),
      .instr_req_o              (instr_req_mem),
      .instr_addr_o             (instr_addr_mem),
      .instr_rdata_i            (instr_rdata_mem),
      .instr_rvalid_i           (instr_rvalid_mem),
      .instr_gnt_i              (instr_gnt_mem),
      
      .mmc_exception_o          (mc_exception)
    );

  instr_mem
    #(
      .CORE_TEST(CORE_TEST)
    )
    MemoriaI
    (
      .clk                      (clk),
      .instr_req_i              (instr_req_mem),
      .instr_addr_i             (instr_addr_mem),
      .instr_rdata_o            (instr_rdata_mem),
      .instr_rvalid_o           (instr_rvalid_mem),
      .instr_gnt_o              (instr_gnt_mem)
    );

  data_mem MemoriaD
    (
      .clk                      (clk),
      .data_req_i               (data_req_mem),
      .data_addr_i              (data_addr_mem),
      .data_we_i                (data_we_mem),
      .data_be_i                (data_be_mem),
      .data_wdata_i             (data_wdata_mem),
      .data_rdata_o             (data_rdata_mem),
      .data_rvalid_o            (data_rvalid_mem),
      .data_gnt_o               (data_gnt_mem)
    );

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
    toggle_clk(2);
    rst_n = 1'b1;
    toggle_clk(2);
    fetch_en = 1'b1;
  endtask

  task toggle_clk(int n_of_clocks);
    for(int i = 0; i < n_of_clocks; i++) begin
      #10ns clk = !clk;
      #10ns clk = !clk;
    end
  endtask

endmodule 