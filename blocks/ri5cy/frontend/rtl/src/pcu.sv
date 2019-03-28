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

    output logic                  if_to_id_stall_o,
    output logic                  if_to_id_clear_o,
    output logic                  id_to_ex_stall_o,
    output logic                  id_to_ex_clear_o,
    output logic                  ex_to_wb_stall_o,
    output logic                  ex_to_wb_clear_o
  );

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



endmodule