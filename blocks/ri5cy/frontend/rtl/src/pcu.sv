`include "riscv_defines.svh"

module pcu
  (
    input  logic                  clk,
    input  logic                  rst_n,

    input  decoded_opcode         instr_type_i,
    input  logic [ADDR_WIDTH-1:0] read_addr1_i,
    input  logic [ADDR_WIDTH-1:0] read_addr2_i,
    input  logic [ADDR_WIDTH-1:0] write_addr_i,
    input  logic                  write_en_i,

    // Controle de Stall
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

  // Definição de Estado e Estágio
  typedef struct
    {
      decoded_opcode          instr_type;
      logic [ADDR_WIDTH-1:0]  read_addr1;
      logic [ADDR_WIDTH-1:0]  read_addr2;
      logic [ADDR_WIDTH-1:0]  write_addr;
      logic                   write_en;
    } stage_state;

  // Declaração de array de estados
  stage_state state_array [2:0];

  // Lógica combinacional do primeiro estado
  assign state_array[0].instr_type = instr_type_i;
  assign state_array[0].read_addr1 = read_addr1_i;
  assign state_array[0].read_addr2 = read_addr2_i;
  assign state_array[0].write_addr = write_addr_i;
  assign state_array[0].write_en   = write_en_i;

  // Lógica de transição para o segundo estado
  always_ff @(posedge clk) begin
    if(!id_to_ex_stall_o && !id_to_ex_clear_o) begin
      state_array[1] <= state_array[0];
    end
    else if(id_to_ex_clear_o) begin
      state_array[1].instr_type <= OP_NO_OP;
      state_array[1].write_en <= 1'b0;
    end
  end

  // Lógica de transição para o terceiro 
  always_ff @(posedge clk) begin
    if(!ex_to_wb_stall_o && !ex_to_wb_clear_o) begin
      state_array[2] <= state_array[1];
    end
    else if(ex_to_wb_clear_o) begin
      state_array[2].instr_type <= OP_NO_OP;
      state_array[2].write_en <= 1'b0;
    end
  end

  // Lógica de flags de uso de operandos
  always_comb begin
    case(state_array[0].instr_type)
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
    endcase
  end

  // Controle de Foward no operando A
  always_comb begin
    fwrd_opA_type1_o = 1'b0;
    fwrd_opA_type2_o = 1'b0;
    if(operation_use_opA) begin
      if(state_array[1].write_en && (state_array[1].write_addr == state_array[0].read_addr1))
        fwrd_opA_type1_o = 1'b1;
      else if(state_array[2].write_en && (state_array[2].write_addr == state_array[0].read_addr1))       
        fwrd_opA_type2_o = 1'b1;
    end
  end

  // Controle de Foward no operando B
  always_comb begin
    fwrd_opB_type1_o = 1'b0;
    fwrd_opB_type2_o = 1'b0;    
    if(operation_use_opB) begin
      if(state_array[1].write_en && (state_array[1].write_addr == state_array[0].read_addr2))
        fwrd_opB_type1_o = 1'b1;
      else if(state_array[2].write_en && (state_array[2].write_addr == state_array[0].read_addr2))       
        fwrd_opB_type2_o = 1'b1;
    end
  end

endmodule