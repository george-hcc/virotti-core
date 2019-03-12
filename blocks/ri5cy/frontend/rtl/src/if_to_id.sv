module IF_to_ID
  (
    input  logic clk,
    input  logic en,
    input  logic rst_n,

    input  logic [WORD_WIDTH-1:0] pc_i,
    input  logic [WORD_WIDTH-1:0] pc_plus4_i,
    input  logic [WORD_WIDTH-1:0] instruction_i,

    output logic [WORD_WIDTH-1:0] pc_o,
    output logic [WORD_WIDTH-1:0] pc_plus4_o,
    output logic [WORD_WIDTH-1:0] instruction_o
  );

  always_ff @(posedge clk) begin
    if(en) begin
      pc_o <= pc_i;
      pc_plus4_o <= pc_plus4_i;
      instruction_o <= instruction_i;
    end
  end

endmodule