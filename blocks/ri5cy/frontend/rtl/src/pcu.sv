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
    input  logic [ADDR_WIDTH-1:0] write_addr_i,
    input  logic                  write_en_i,
    input  logic                  valid_lsu_load_i,
    input  logic                  branch_taken_i,

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

  // Definição de Estado de Estágios
  typedef struct
    {
      decoded_opcode          instr_type;
      logic [ADDR_WIDTH-1:0]  read_addr1;
      logic [ADDR_WIDTH-1:0]  read_addr2;
      logic [ADDR_WIDTH-1:0]  write_addr;
      logic                   write_en;
    } stage_state;

  // Declaração de vetor de estados
  stage_state state_vector [2:0];

  // Maquina de estádos do PCU - Responsável pelo controle de clear e stalls
  enum logic [2:0]
    {
      RESET,
      WORK,
      BRNCH_FLUSH1,
      BRNCH_FLUSH2,
      LOAD_STALL
    } pcu_state, next_pcu_state;

  // Lógica combinacional do primeiro elemento do vetor de estados
  assign state_vector[0].instr_type = instr_type_i;
  assign state_vector[0].read_addr1 = read_addr1_i;
  assign state_vector[0].read_addr2 = read_addr2_i;
  assign state_vector[0].write_addr = write_addr_i;
  assign state_vector[0].write_en   = write_en_i;

  // Lógica de transição para o segundo estado
  always_ff @(posedge clk) begin
    if(!id_to_ex_stall_o && !id_to_ex_clear_o) begin
      state_vector[1] <= state_vector[0];
    end
    else if(id_to_ex_clear_o) begin
      state_vector[1].instr_type <= OP_NO_OP;
      state_vector[1].write_en <= 1'b0;
    end
  end

  // Lógica de transição para o terceiro 
  always_ff @(posedge clk) begin
    if(!ex_to_wb_stall_o && !ex_to_wb_clear_o) begin
      state_vector[2] <= state_vector[1];
    end
    else if(ex_to_wb_clear_o) begin
      state_vector[2].instr_type <= OP_NO_OP;
      state_vector[2].write_en <= 1'b0;
    end
  end

  // Lógica de flags de uso de operandos
  always_comb begin
    case(state_vector[0].instr_type)
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
      if(state_vector[1].write_en && (state_vector[1].write_addr == state_vector[0].read_addr1))
        fwrd_opA_type1_o = 1'b1;
      else if(state_vector[2].write_en && (state_vector[2].write_addr == state_vector[0].read_addr1))       
        fwrd_opA_type2_o = 1'b1;
    end
  end

  // Controle de Foward no operando B
  always_comb begin
    fwrd_opB_type1_o = 1'b0;
    fwrd_opB_type2_o = 1'b0;    
    if(operation_use_opB) begin
      if(state_vector[1].write_en && (state_vector[1].write_addr == state_vector[0].read_addr2))
        fwrd_opB_type1_o = 1'b1;
      else if(state_vector[2].write_en && (state_vector[2].write_addr == state_vector[0].read_addr2))       
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
        else if (state_vector[2].instr_type == OP_LOAD)
          next_pcu_state = LOAD_STALL;
        else if(branch_taken_i)
          next_pcu_state = BRNCH_FLUSH1;
        else
          next_pcu_state = WORK;
      end
      BRNCH_FLUSH1:
        next_pcu_state = (rst_n) ? (BRNCH_FLUSH2) : (RESET);
      BRNCH_FLUSH2:
        next_pcu_state = (rst_n) ? (WORK) : (RESET);
      LOAD_STALL: begin
        if(!rst_n)
          next_pcu_state = RESET;
        else if(valid_lsu_load_i) begin
          if(branch_taken_i)
            next_pcu_state = BRNCH_FLUSH1;
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
      BRNCH_FLUSH1: begin
        fetch_stall_o     = 1'b0;
        if_to_id_stall_o  = 1'b0;
        id_to_ex_stall_o  = 1'b0;
        ex_to_wb_stall_o  = 1'b0;
        if_to_id_clear_o  = 1'b1;
        id_to_ex_clear_o  = 1'b1;
        ex_to_wb_clear_o  = 1'b1;
      end
      BRNCH_FLUSH2: begin
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