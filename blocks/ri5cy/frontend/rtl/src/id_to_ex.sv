module ID_to_EX
  (
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic                    stall_ctrl,

    input  logic [WORD_WIDTH-1:0]   program_count_i,
    input  logic [WORD_WIDTH-1:0]   instruction_i,
    input  logic [WORD_WIDTH-1:0]   rdata1_i,
    input  logic [WORD_WIDTH-1:0]   rdata2_i,
    input  logic [ALU_OP_WIDTH-1:0] alu_op_ctrl_i,
    input  logic                    write_en_i,
    input  logic                    stype_ctrl_i,
    input  logic                    utype_ctrl_i,
    input  logic                    jtype_ctrl_i,
    input  logic                    imm_alu_ctrl_i,
    input  logic                    auipc_alu_ctrl_i,
    input  logic                    branch_alu_ctrl_i,
    input  logic                    zeroflag_ctrl_i ,
    input  logic                    load_type_ctrl_i,
    input  logic                    store_type_ctrl_i,
    input  logic                    branch_pc_ctrl_i,

    output logic [WORD_WIDTH-1:0]   program_count_o,
    output logic [WORD_WIDTH-1:0]   instruction_o,
    output logic [WORD_WIDTH-1:0]   rdata1_o,
    output logic [WORD_WIDTH-1:0]   rdata2_o,
    output logic [ALU_OP_WIDTH-1:0] alu_op_ctrl_o,
    output logic                    write_en_o,
    output logic                    stype_ctrl_o,
    output logic                    utype_ctrl_o,
    output logic                    jtype_ctrl_o,
    output logic                    imm_alu_ctrl_o,
    output logic                    auipc_alu_ctrl_o,
    output logic                    branch_alu_ctrl_o,
    output logic                    zeroflag_ctrl_o,
    output logic                    load_type_ctrl_o,
    output logic                    store_type_ctrl_o,
    output logic                    branch_pc_ctrl_o
  );

  logic [WORD_WIDTH-1:0]    program_count_w;
  logic [WORD_WIDTH-1:0]    instruction_w;
  logic [WORD_WIDTH-1:0]    rdata1_w;
  logic [WORD_WIDTH-1:0]    rdata2_w;
  logic [ALU_OP_WIDTH-1:0]  alu_op_ctrl_w;
  logic                     write_en_w;
  logic                     stype_ctrl_w;
  logic                     utype_ctrl_w;
  logic                     jtype_ctrl_w;
  logic                     imm_alu_ctrl_w;
  logic                     auipc_alu_ctrl_w;
  logic                     branch_alu_ctrl_w;
  logic                     zeroflag_ctrl_w;
  logic                     load_type_ctrl_w;
  logic                     store_type_ctrl_w;
  logic                     branch_pc_ctrl_w;

  always_comb begin
    if(stall_ctrl) begin
      program_count_w   = program_count_o;
      instruction_w     = instruction_o;
      rdata1_w          = rdata1_o;
      rdata2_w          = rdata2_o;
      alu_op_ctrl_w     = alu_op_ctrl_o;
      write_en_w        = write_en_o;
      stype_ctrl_w      = stype_ctrl_o;
      utype_ctrl_w      = utype_ctrl_o;
      jtype_ctrl_w      = jtype_ctrl_o;
      imm_alu_ctrl_w    = imm_alu_ctrl_o;
      auipc_alu_ctrl_w  = auipc_alu_ctrl_o;
      branch_alu_ctrl_w = branch_alu_ctrl_o;
      zeroflag_ctrl_w   = zeroflag_ctrl_o;
      load_type_ctrl_w  = load_type_ctrl_o;
      store_type_ctrl_w = store_type_ctrl_o;
      branch_pc_ctrl_w  = branch_pc_ctrl_o;
    end
    else begin
      program_count_w   = program_count_i;
      instruction_w     = instruction_i;
      rdata1_w          = rdata1_i;
      rdata2_w          = rdata2_i;
      alu_op_ctrl_w     = alu_op_ctrl_i;
      write_en_w        = write_en_i;
      stype_ctrl_w      = stype_ctrl_i;
      utype_ctrl_w      = utype_ctrl_i;
      jtype_ctrl_w      = jtype_ctrl_i;
      imm_alu_ctrl_w    = imm_alu_ctrl_i;
      auipc_alu_ctrl_w  = auipc_alu_ctrl_i;
      branch_alu_ctrl_w = branch_alu_ctrl_i;
      zeroflag_ctrl_w   = zeroflag_ctrl_i;
      load_type_ctrl_w  = load_type_ctrl_i;
      store_type_ctrl_w = store_type_ctrl_i;
      branch_pc_ctrl_w  = branch_pc_ctrl_i;
    end
  end

  always_ff @(posedge clk) begin
    program_count_o   <= program_count_w;
    instruction_o     <= instruction_w;
    rdata1_o          <= rdata1_w;
    rdata2_o          <= rdata2_w;
    alu_op_ctrl_o     <= alu_op_ctrl_w;
    write_en_o        <= write_en_w;
    stype_ctrl_o      <= stype_ctrl_w;
    utype_ctrl_o      <= utype_ctrl_w;
    jtype_ctrl_o      <= jtype_ctrl_w;
    imm_alu_ctrl_o    <= imm_alu_ctrl_w;
    auipc_alu_ctrl_o  <= auipc_alu_ctrl_w;
    branch_alu_ctrl_o <= branch_alu_ctrl_w;
    zeroflag_ctrl_o   <= zeroflag_ctrl_w;
    load_type_ctrl_o  <= load_type_ctrl_w;
    store_type_ctrl_o <= store_type_ctrl_w;
    branch_pc_ctrl_o  <= branch_pc_ctrl_w;
  end
  
endmodule