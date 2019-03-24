module EX_to_WB
  (
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic                  stall_ctrl,

    input  logic [WORD_WIDTH-1:0] store_data_i
    input  logic [2:0]            load_type_i,
    input  logic [1:0]            store_type_i,
    input  logic                  write_en_i,
    input  logic                  branch_pc_ctrl_i,
    input  logic [WORD_WIDTH-1:0] ex_data_i,
    input  logic [WORD_WIDTH-1:0] store_data_i,
    input  logic                  comp_flag_i,

    output logic [WORD_WIDTH-1:0] store_data_i
    output logic [2:0]            load_type_i,
    output logic [1:0]            store_type_i,
    output logic                  write_en_i,
    output logic                  branch_pc_ctrl_i,
    output logic [WORD_WIDTH-1:0] ex_data_i,
    output logic [WORD_WIDTH-1:0] store_data_i,
    output logic                  comp_flag_i
  );

  logic [2:0]            load_type_w;
  logic [1:0]            store_type_w;
  logic                  write_en_w;
  logic                  branch_pc_ctrl_w;
  logic [WORD_WIDTH-1:0] ex_data_w;
  logic [WORD_WIDTH-1:0] store_data_w;
  logic                  comp_flag_w;

  always_comb begin
    if(stall_ctrl) begin
      load_type_w       = load_type_o;
      store_type_w      = store_type_o;
      write_en_w        = write_en_o;
      branch_pc_ctrl_w  = branch_pc_ctrl_o;
      ex_data_w         = ex_data_o;
      store_data_w      = store_data_o;
      comp_flag_w       = comp_flag_o;
    end
    else begin      
      load_type_w       = load_type_i;
      store_type_w      = store_type_i;
      write_en_w        = write_en_i;
      branch_pc_ctrl_w  = branch_pc_ctrl_i;
      ex_data_w         = ex_data_i;
      store_data_w      = store_data_i;
      comp_flag_w       = comp_flag_i;
    end
  end

  always_ff @(posedge clk) begin    
      load_type_o       = load_type_w;
      store_type_o      = store_type_w;
      write_en_o        = write_en_w;
      branch_pc_ctrl_o  = branch_pc_ctrl_w;
      ex_data_o         = ex_data_w;
      store_data_o      = store_data_w;
      comp_flag_o       = comp_flag_w;
  end

endmodule