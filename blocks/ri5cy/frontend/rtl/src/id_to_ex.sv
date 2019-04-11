//////////////////////////////////////////////////////////////////////////////////////////////
// Autor:           George Camboim - george.camboim@embedded.ufcg.edu.br                    //
//                                                                                          //
// Nome do Design:  ID_to_EX                                                                //
// Nome do Projeto: MiniSoc                                                                 //
// Linguagem:       SystemVerilog                                                           //
//                                                                                          //
// Descrição:       Registrador entre-estágios de Pipeline                                  //
//                                                                                          //
//////////////////////////////////////////////////////////////////////////////////////////////

import riscv_defines::*;

module ID_to_EX
  (
    input  logic                    clk,
    input  logic                    stall_ctrl,
    input  logic                    clear_ctrl,

    input  logic [WORD_WIDTH-1:0]   program_count_i,
    input  logic [WORD_WIDTH-1:0]   instruction_i,
    input  logic [WORD_WIDTH-1:0]   rdata1_i,
    input  logic [WORD_WIDTH-1:0]   rdata2_i,
    input  logic [ALU_OP_WIDTH-1:0] alu_op_ctrl_i,
    input  logic                    load_type_ctrl_i,
    input  logic                    store_type_ctrl_i,
    input  logic                    write_en_i,
    input  logic                    stype_ctrl_i,
    input  logic                    imm_alu_ctrl_i,
    input  logic                    jump_ctrl_i,
    input  logic                    branch_ctrl_i,
    input  logic                    auipc_ctrl_i,
    input  logic                    lui_ctrl_i,
    input  logic                    zeroflag_ctrl_i,

    output logic [WORD_WIDTH-1:0]   program_count_o,
    output logic [WORD_WIDTH-1:0]   instruction_o,
    output logic [WORD_WIDTH-1:0]   rdata1_o,
    output logic [WORD_WIDTH-1:0]   rdata2_o,
    output logic [ALU_OP_WIDTH-1:0] alu_op_ctrl_o,
    output logic                    load_type_ctrl_o,
    output logic                    store_type_ctrl_o,
    output logic                    write_en_o,
    output logic                    stype_ctrl_o,
    output logic                    imm_alu_ctrl_o,
    output logic                    jump_ctrl_o,
    output logic                    branch_ctrl_o,
    output logic                    auipc_ctrl_o,
    output logic                    lui_ctrl_o,
    output logic                    zeroflag_ctrl_o,

    input  logic [WORD_WIDTH-1:0]   fwrd_type1_data_i,
    input  logic [WORD_WIDTH-1:0]   fwrd_type2_data_i,    
    input  logic                    fwrd_opA_type1_i,
    input  logic                    fwrd_opA_type2_i,
    input  logic                    fwrd_opB_type1_i,
    input  logic                    fwrd_opB_type2_i
  );

  logic [WORD_WIDTH-1:0]   rdata1_w;
  logic [WORD_WIDTH-1:0]   rdata2_w;

  logic [WORD_WIDTH-1:0]   program_count_w;
  logic [WORD_WIDTH-1:0]   instruction_w;
  logic [ALU_OP_WIDTH-1:0] alu_op_ctrl_w;
  logic                    load_type_ctrl_w;
  logic                    store_type_ctrl_w;
  logic                    write_en_w;
  logic                    stype_ctrl_w;
  logic                    imm_alu_ctrl_w;
  logic                    jump_ctrl_w;
  logic                    branch_ctrl_w;
  logic                    auipc_ctrl_w;
  logic                    lui_ctrl_w;
  logic                    zeroflag_ctrl_w;

  // Mux do dado vindo do registrador 1, com controle de foward
  always_comb begin
    if(stall_ctrl)
      rdata1_w = rdata1_o;
    else if(fwrd_opA_type1_i)
      rdata1_w = fwrd_type1_data_i;
    else if(fwrd_opA_type2_i)
      rdata1_w = fwrd_type2_data_i;
    else
      rdata1_w = rdata1_i;
  end

  // Mux do dado vindo do registrador 2, com controle de foward
  always_comb begin
    if(stall_ctrl)
      rdata2_w = rdata2_o;
    else if(fwrd_opB_type1_i)
      rdata2_w = fwrd_type1_data_i;
    else if(fwrd_opB_type2_i)
      rdata2_w = fwrd_type2_data_i;
    else
      rdata2_w = rdata2_i;
  end

  always_ff @(posedge clk) begin
    rdata1_o <= rdata1_w;
    rdata2_o <= rdata2_w;
  end

  always_comb begin
    if(stall_ctrl) begin
      program_count_w   = program_count_o;
      instruction_w     = instruction_o;
      alu_op_ctrl_w     = alu_op_ctrl_o;
      load_type_ctrl_w  = load_type_ctrl_o;
      store_type_ctrl_w = store_type_ctrl_o;
      write_en_w        = write_en_o;
      stype_ctrl_w      = stype_ctrl_o;
      imm_alu_ctrl_w    = imm_alu_ctrl_o;
      jump_ctrl_w       = jump_ctrl_o;
      branch_ctrl_w     = branch_ctrl_o;
      auipc_ctrl_w      = auipc_ctrl_o;
      lui_ctrl_w        = lui_ctrl_o;
      zeroflag_ctrl_w   = zeroflag_ctrl_o;
    end
    else begin
      program_count_w   = program_count_i;
      instruction_w     = instruction_i;
      alu_op_ctrl_w     = alu_op_ctrl_i;
      load_type_ctrl_w  = load_type_ctrl_i;
      store_type_ctrl_w = store_type_ctrl_i;
      write_en_w        = write_en_i;
      stype_ctrl_w      = stype_ctrl_i;
      imm_alu_ctrl_w    = imm_alu_ctrl_i;
      jump_ctrl_w       = jump_ctrl_i;
      branch_ctrl_w     = branch_ctrl_i;
      auipc_ctrl_w      = auipc_ctrl_i;
      lui_ctrl_w        = lui_ctrl_i;
      zeroflag_ctrl_w   = zeroflag_ctrl_i;
    end
  end

  always_ff @(posedge clk) begin
    program_count_o    <= program_count_w;
    instruction_o      <= instruction_w;
    alu_op_ctrl_o      <= alu_op_ctrl_w;
    load_type_ctrl_o   <= load_type_ctrl_w;
    stype_ctrl_o       <= stype_ctrl_w;
    imm_alu_ctrl_o     <= imm_alu_ctrl_w;
    jump_ctrl_o        <= jump_ctrl_w;
    branch_ctrl_o      <= branch_ctrl_w;
    auipc_ctrl_o       <= auipc_ctrl_w;
    lui_ctrl_o         <= lui_ctrl_w;
    zeroflag_ctrl_o    <= zeroflag_ctrl_w;
    if(clear_ctrl) begin
      write_en_o        <= 1'b0;
      store_type_ctrl_o <= 2'b00;
    end
    else begin
      write_en_o        <= write_en_w;
      store_type_ctrl_o <= store_type_ctrl_w;
    end
  end
  
endmodule