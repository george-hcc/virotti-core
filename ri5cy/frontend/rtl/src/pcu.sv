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
    output logic                  fwrd_opA_type3_o,
    output logic                  fwrd_opB_type1_o,
    output logic                  fwrd_opB_type2_o,
    output logic                  fwrd_opB_type3_o
  );

  // Flags para separar quais operações utilizam quais operandos no EX_Stage
  // Necessário para identificar Data Hazards que podem ser solucionados com Fowarding
  logic                   id_operation_use_opA;
  logic                   id_operation_use_opB;
  logic                   ex_operation_use_opA;
  logic                   ex_operation_use_opB;

  // Flag para lidar com o edge case em que uma Operação de Load está no EX_Stage e uma operação no ID_Stage que utilizará o dado
  // Um foward ocorrendo nessas condições resulta na segunda operação pegando erroneamente o endereço de load ao invés do conteúdo
  logic                   load_in_EX;

  decoded_opcode          id_instr_type;
  decoded_opcode          ex_instr_type;
  logic [ADDR_WIDTH-1:0]  id_rs1;
  logic [ADDR_WIDTH-1:0]  id_rs2;
  logic [ADDR_WIDTH-1:0]  ex_rs1;
  logic [ADDR_WIDTH-1:0]  ex_rs2;

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

  // Tipo de instrução atualmente no ID_Stage
  assign id_instr_type = instr_type_i;
  // Endereço de registradores utilizados em operações no ID_Stage
  assign id_rs1 = read_addr1_i;
  assign id_rs2 = read_addr2_i;

  // Tipo de instrução atualmente no EX_Stage
  always_ff @(posedge clk) begin
    if(id_to_ex_clear_o)
      ex_instr_type <= OP_NO_OP;
    else if(id_to_ex_stall_o)
      ex_instr_type <= ex_instr_type;
    else
      ex_instr_type <= id_instr_type;
  end

  // Endereço de registradores utilizados em operações no EX_Stage
  always_ff @(posedge clk) begin
    if(id_to_ex_stall_o) begin
      ex_rs1 <= ex_rs1;
      ex_rs2 <= ex_rs2;
    end
    else begin
      ex_rs1 <= id_rs1;
      ex_rs2 <= id_rs2;
    end
  end

  assign load_in_EX = ex_instr_type == OP_LOAD;

  // Lógica de flags de uso de operandos no ID_Stage
  always_comb begin
    case(id_instr_type)
      OP_COMP, OP_STORE, OP_BRANCH: begin
        id_operation_use_opA = 1'b1;
        id_operation_use_opB = 1'b1;
      end
      OP_COMP_IMM, OP_LOAD, OP_JALR: begin
        id_operation_use_opA = 1'b1;
        id_operation_use_opB = 1'b0;
      end
      default: begin
        id_operation_use_opA = 1'b0;
        id_operation_use_opB = 1'b0;
      end
    endcase
  end

  // Lógica de flags de uso de operandos no EX_Stage
  always_comb begin
    case(ex_instr_type)
      OP_COMP, OP_STORE, OP_BRANCH: begin
        ex_operation_use_opA = 1'b1;
        ex_operation_use_opB = 1'b1;
      end
      OP_COMP_IMM, OP_LOAD, OP_JALR: begin
        ex_operation_use_opA = 1'b1;
        ex_operation_use_opB = 1'b0;
      end
      default: begin
        ex_operation_use_opA = 1'b0;
        ex_operation_use_opB = 1'b0;
      end
    endcase
  end

  // Controle de Foward tipo 1
  always_comb begin
    fwrd_opA_type1_o = 1'b0;
    fwrd_opB_type1_o = 1'b0;
    if(ex_write_en_i && ex_write_addr_i != 5'h00 && ex_instr_type != OP_LOAD) begin
      fwrd_opA_type1_o = (ex_write_addr_i == id_rs1);
      fwrd_opB_type1_o = (ex_write_addr_i == id_rs2);
    end
  end

  // Controle de Foward tipo 2
  always_comb begin
    fwrd_opA_type2_o = 1'b0;
    fwrd_opB_type2_o = 1'b0;
    if(wb_write_en_i && wb_write_addr_i != 5'h00) begin
      fwrd_opA_type2_o = (wb_write_addr_i == id_rs1);
      fwrd_opB_type2_o = (wb_write_addr_i == id_rs2);
    end
  end

  // Controle de Foward tipo 3
  always_comb begin
    fwrd_opA_type3_o = 1'b0;
    fwrd_opB_type3_o = 1'b0;
    if(wb_write_en_i && wb_write_addr_i != 5'h00 && wb_load_flag_i) begin
      fwrd_opA_type3_o = (wb_write_addr_i == ex_rs1);
      fwrd_opB_type3_o = (wb_write_addr_i == ex_rs2);
    end
  end

  // Lógica sequencial de transição de estados
  always_ff @(posedge clk) begin
    if(!rst_n)
      pcu_state <= RESET;  
    else
      pcu_state <= next_pcu_state;
  end

  // Lógica combinacional de Próximo Estado
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

  // Lógica combinacional de stalls e clears baseados no próximo estado
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

endmodule