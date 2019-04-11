//////////////////////////////////////////////////////////////////////////////////////////////
// Autor:           George Camboim - george.camboim@embedded.ufcg.edu.br                    //
//                                                                                          //
// Nome do Design:  PCU (Unidade de Controle de Pipeline)                                   //
// Nome do Projeto: MiniSoc                                                                 //
// Linguagem:       SystemVerilog                                                           //
//                                                                                          //
// Descrição:       Responsável pela identificação de hazards e seu controle                //
//                                                                                          //
//////////////////////////////////////////////////////////////////////////////////////////////

import riscv_defines::*;
import ctrl_typedefs::*;

module pcu
  (
    input  logic                  clk,
    input  logic                  rst_n,

    input  decoded_opcode         instr_type_i,
    input  logic [ADDR_WIDTH-1:0] read_addr1_i,
    input  logic [ADDR_WIDTH-1:0] read_addr2_i,
    input  logic [ADDR_WIDTH-1:0] ex_write_addr_i,
    input  logic [ADDR_WIDTH-1:0] wb_write_addr_i,
    input  logic                  ex_write_en_i,
    input  logic                  wb_write_en_i,
    input  logic                  wb_load_flag_i,
    input  logic                  valid_lsu_load_i,
    input  logic                  branch_taken_i,
    input  logic                  jump_taken_i,

    // Controle de Stall
    output logic                  fetch_stall_o,
    output logic                  if_to_id_stall_o,
    output logic                  id_to_ex_stall_o,
    output logic                  ex_to_wb_stall_o,

    // Controle de Clear
    output logic                  if_to_id_clear_o,
    output logic                  id_to_ex_clear_o,
    output logic                  ex_to_wb_clear_o,

    // Controle de Muxes de Foward
    output logic                  fwrd_opA_type1_o,
    output logic                  fwrd_opA_type2_o,
    output logic                  fwrd_opB_type1_o,
    output logic                  fwrd_opB_type2_o
  );

  // Flags para separar quais operações utilizam quais operandos no EX_Stage
  // Necessário para identificar Data Hazards que podem ser solucionados com Fowarding
  logic operation_use_opA;
  logic operation_use_opB;

  // Maquina de estádos do PCU - Responsável pelo controle de clear e stalls
  enum logic [2:0]
    {
      RESET,
      WORK,
      BRANCH_FLUSH,
      JUMP_FLUSH,
      POST_FLUSH,
      LOAD_STALL
    } pcu_state, next_pcu_state;

  // Lógica de flags de uso de operandos
  always_comb begin
    case(instr_type_i)
      OP_COMP, OP_STORE, OP_BRANCH: begin
        operation_use_opA = 1'b1;
        operation_use_opB = 1'b1;
      end
      OP_COMP_IMM, OP_LOAD, OP_JALR: begin
        operation_use_opA = 1'b1;
        operation_use_opB = 1'b0;
      end
      default: begin
        operation_use_opA = 1'b0;
        operation_use_opB = 1'b0;
      end
    endcase
  end

  // Controle de Foward no operando A
  always_comb begin
    fwrd_opA_type1_o = 1'b0;
    fwrd_opA_type2_o = 1'b0;
    if(operation_use_opA) begin
      if(ex_write_en_i && (ex_write_addr_i == read_addr1_i) && ex_write_addr_i != 5'h00)
        fwrd_opA_type1_o = 1'b1;
      else if(wb_write_en_i && (wb_write_addr_i == read_addr1_i) && wb_write_addr_i != 5'h00)       
        fwrd_opA_type2_o = 1'b1;
    end
  end

  // Controle de Foward no operando B
  always_comb begin
    fwrd_opB_type1_o = 1'b0;
    fwrd_opB_type2_o = 1'b0;    
    if(operation_use_opB) begin
      if(ex_write_en_i && (ex_write_addr_i == read_addr2_i) && ex_write_addr_i != 5'h00)
        fwrd_opB_type1_o = 1'b1;
      else if(wb_write_en_i && (wb_write_addr_i == read_addr2_i) && wb_write_addr_i != 5'h00)       
        fwrd_opB_type2_o = 1'b1;
    end
  end

  always_comb begin
    unique case(pcu_state)
      RESET:
        next_pcu_state = (rst_n) ? (WORK) : (RESET);
      WORK: begin
        if(!rst_n)
          next_pcu_state = RESET;
        else if (wb_load_flag_i && wb_write_en_i)
          next_pcu_state = LOAD_STALL;
        else if(branch_taken_i)
          next_pcu_state = BRANCH_FLUSH;
        else if(jump_taken_i)
          next_pcu_state = JUMP_FLUSH;
        else
          next_pcu_state = WORK;
      end
      BRANCH_FLUSH, JUMP_FLUSH:
        next_pcu_state = (rst_n) ? (POST_FLUSH) : (RESET);
      POST_FLUSH:
        next_pcu_state = (rst_n) ? (WORK) : (RESET);
      LOAD_STALL: begin
        if(!rst_n)
          next_pcu_state = RESET;
        else if(valid_lsu_load_i) begin
          if(branch_taken_i)
            next_pcu_state = BRANCH_FLUSH;
          else if(jump_taken_i)
            next_pcu_state = JUMP_FLUSH;
          else
            next_pcu_state = WORK;
        end
        else
          next_pcu_state = LOAD_STALL;
      end
    endcase
  end

  always_comb begin
    unique case(next_pcu_state)
      RESET: begin
        fetch_stall_o     = 1'b0;
        if_to_id_stall_o  = 1'b0;
        id_to_ex_stall_o  = 1'b0;
        ex_to_wb_stall_o  = 1'b0;
        if_to_id_clear_o  = 1'b1;
        id_to_ex_clear_o  = 1'b1;
        ex_to_wb_clear_o  = 1'b1;
      end
      WORK: begin
        fetch_stall_o     = 1'b0;
        if_to_id_stall_o  = 1'b0;
        id_to_ex_stall_o  = 1'b0;
        ex_to_wb_stall_o  = 1'b0;
        if_to_id_clear_o  = 1'b0;
        id_to_ex_clear_o  = 1'b0;
        ex_to_wb_clear_o  = 1'b0;
      end
      BRANCH_FLUSH: begin
        fetch_stall_o     = 1'b0;
        if_to_id_stall_o  = 1'b0;
        id_to_ex_stall_o  = 1'b0;
        ex_to_wb_stall_o  = 1'b0;
        if_to_id_clear_o  = 1'b1;
        id_to_ex_clear_o  = 1'b1;
        ex_to_wb_clear_o  = 1'b1;
      end
      JUMP_FLUSH: begin
        fetch_stall_o     = 1'b0;
        if_to_id_stall_o  = 1'b0;
        id_to_ex_stall_o  = 1'b0;
        ex_to_wb_stall_o  = 1'b0;
        if_to_id_clear_o  = 1'b1;
        id_to_ex_clear_o  = 1'b0;
        ex_to_wb_clear_o  = 1'b0;
      end
      POST_FLUSH: begin
        fetch_stall_o     = 1'b0;
        if_to_id_stall_o  = 1'b1;
        id_to_ex_stall_o  = 1'b0;
        ex_to_wb_stall_o  = 1'b0;
        if_to_id_clear_o  = 1'b0;
        id_to_ex_clear_o  = 1'b0;
        ex_to_wb_clear_o  = 1'b0;
      end
      LOAD_STALL: begin
        fetch_stall_o     = 1'b1;
        if_to_id_stall_o  = 1'b1;
        id_to_ex_stall_o  = 1'b1;
        ex_to_wb_stall_o  = 1'b1;
        if_to_id_clear_o  = 1'b0;
        id_to_ex_clear_o  = 1'b0;
        ex_to_wb_clear_o  = 1'b0;
      end
    endcase
  end

  always_ff @(posedge clk) begin
    if(!rst_n)
      pcu_state <= RESET;  
    else
      pcu_state <= next_pcu_state;
  end

endmodule