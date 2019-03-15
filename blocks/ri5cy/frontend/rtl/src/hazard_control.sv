module pcu
  (
    input  logic clk,
    input  logic rst_n,

    input  logic [WORD_WIDTH-1:0] instruction_i,
    input  logic [WORD_WIDTH-1:0],

    output logic                  if_to_id_en,
    output logic                  id_to_ex_en,
    output logic                  ex_to_wb_en
  );

  logic [4:0] rs1;
  logic [4:0] rs2;
  logic [4:0] rd;

  // Registros de Controle e Status
  logic       csr_cycle;
  logic       csr_time;
  logic       csr_instret;
  logic       csr_cycleh;
  logic       csr_timeh;
  logic       csr_instreth;

  // Necessário otimizar codificação
  enum logic [3:0]
    {
      COMP    = 4'b0000,
      COMPIM  = 4'b0001,
      STORE   = 4'b0010,
      LOAD    = 4'b0011,
      BRANCH  = 4'b0100,
      JALR    = 4'b0101,
      JAL     = 4'b0110,
      AUIPC   = 4'b0111,
      LUI     = 4'b1000,
    } operation;


end