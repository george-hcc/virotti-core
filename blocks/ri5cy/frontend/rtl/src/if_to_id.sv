module IF_to_ID
  (
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic                  stall_ctrl,

    input  logic [WORD_WIDTH-1:0] program_count_i,
    input  logic [WORD_WIDTH-1:0] pc_plus4_i,
    input  logic [WORD_WIDTH-1:0] instruction_i,

    output logic [WORD_WIDTH-1:0] program_count_o,
    output logic [WORD_WIDTH-1:0] pc_plus4_o,
    output logic [WORD_WIDTH-1:0] instruction_o
  );

  logic [WORD_WIDTH-1:0] program_count_w;
  logic [WORD_WIDTH-1:0] pc_plus4_w;
  logic [WORD_WIDTH-1:0] instruction_w;

  always_comb begin
    if(stall_ctrl) begin
      program_count_w = program_count_o;
      pc_plus4_w      = pc_plus4_o;
      instruction_w   = instruction_o;
    end
    else begin
      program_count_w = program_count_i;
      pc_plus4_w      = pc_plus4_i;
      instruction_w   = instruction_i;
    end
  end

  always_ff @(posedge clk) begin
    program_count_o  <= program_count_w;
    pc_plus4_o       <= pc_plus4_w;
    instruction_o    <= instruction_w;
  end

endmodule