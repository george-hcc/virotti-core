//////////////////////////////////////////////////////////////////////////////////////////////
// Autor:           George Camboim - george.camboim@embedded.ufcg.edu.br                    //
//                                                                                          //
// Nome do Design:  EX_to_WB                                                                //
// Nome do Projeto: MiniSoc                                                                 //
// Linguagem:       SystemVerilog                                                           //
//                                                                                          //
// Descrição:       Registrador entre-estágios de Pipeline                                  //
//                                                                                          //
//////////////////////////////////////////////////////////////////////////////////////////////

module EX_to_WB
  (
    input  logic                  clk,
    input  logic                  stall_ctrl,
    input  logic                  clear_ctrl,

    input  logic [2:0]            load_type_i,
    input  logic [1:0]            store_type_i,
    input  logic                  write_en_i,
    input  logic [WORD_WIDTH-1:0] wb_data_i,
    input  logic [WORD_WIDTH-1:0] store_data_i,
    input  logic [ADDR_WIDTH-1:0] reg_waddr_i,

    output logic [2:0]            load_type_o,
    output logic [1:0]            store_type_o,
    output logic                  write_en_o,
    output logic [WORD_WIDTH-1:0] wb_data_o,
    output logic [WORD_WIDTH-1:0] store_data_o,
    output logic [ADDR_WIDTH-1:0] reg_waddr_o
  );

  logic [2:0]            load_type_w;
  logic [1:0]            store_type_w;
  logic                  write_en_w;
  logic [WORD_WIDTH-1:0] wb_data_w;
  logic [WORD_WIDTH-1:0] store_data_w;
  logic [ADDR_WIDTH-1:0] reg_waddr_w;

  always_comb begin
    if(stall_ctrl) begin
      load_type_w       = load_type_o;
      store_type_w      = store_type_o;
      write_en_w        = write_en_o;
      wb_data_w         = wb_data_o;
      store_data_w      = store_data_o;
      reg_waddr_w       = reg_waddr_o;
    end
    else begin      
      load_type_w       = load_type_i;
      store_type_w      = store_type_i;
      write_en_w        = write_en_i;
      wb_data_w         = wb_data_i;
      store_data_w      = store_data_i;
      reg_waddr_w       = reg_waddr_i;
    end
  end

  always_ff @(posedge clk) begin    
    load_type_o        <= load_type_w;
    wb_data_o          <= wb_data_w;
    store_data_o       <= store_data_w;
    reg_waddr_o        <= reg_waddr_w;
    if(clear_ctrl) begin
      write_en_o       <= 1'b0;
      store_type_o     <= 2'b00;
    end
    else begin
      write_en_o       <= write_en_w;
      store_type_o     <= store_type_w;
    end
  end

endmodule