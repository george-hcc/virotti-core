//////////////////////////////////////////////////////////////////////////////////////////////
// Autor:           George Camboim - george.camboim@embedded.ufcg.edu.br                    //
//                                                                                          //
// Nome do Design:  IF_to_ID                                                                //
// Nome do Projeto: MiniSoc                                                                 //
// Linguagem:       SystemVerilog                                                           //
//                                                                                          //
// Descrição:       Registrador entre-estágios de Pipeline                                  //
//                                                                                          //
//////////////////////////////////////////////////////////////////////////////////////////////

module IF_to_ID
  (
    input  logic                  clk,
    input  logic                  stall_ctrl,
    input  logic                  clear_ctrl,

    input  logic [WORD_WIDTH-1:0] instruction_i,
    input  logic [WORD_WIDTH-1:0] program_count_i,
    input  logic                  no_op_flag_i,

    output logic [WORD_WIDTH-1:0] instruction_o,
    output logic [WORD_WIDTH-1:0] program_count_o,
    output logic                  no_op_flag_o
  );

  logic [WORD_WIDTH-1:0] program_count_w;
  logic [WORD_WIDTH-1:0] instruction_w;
  logic                  no_op_flag_w;

  always_comb begin
    if(stall_ctrl) begin
      instruction_w   = instruction_o;
      program_count_w = program_count_o;
      no_op_flag_w    = no_op_flag_o;
    end
    else begin
      instruction_w   = instruction_i;
      program_count_w = program_count_i;
      no_op_flag_w    = no_op_flag_i;
    end
  end

  always_ff @(posedge clk) begin
    instruction_o    <= instruction_w;
    program_count_o  <= program_count_w;
    if(clear_ctrl)
      no_op_flag_o   <= 1'b1;
    else
      no_op_flag_o   <= no_op_flag_w;
  end

endmodule