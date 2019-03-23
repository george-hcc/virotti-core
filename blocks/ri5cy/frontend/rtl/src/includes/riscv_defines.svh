//package riscv_defines;

// Parametros de Configuração

parameter RISCV_M_CORE    = 1;
parameter PC_START_ADDR   = 32'h0000_00ff;
parameter NOP_INSTR       = 32'h0;

// Parametros globais

parameter WORD_WIDTH 			= 32;
parameter ADDR_WIDTH 			= 5;
parameter N_OF_REGS				=	32;

// Parametros de opcodes

parameter OPCODE_WIDTH		= 7;

parameter OPCODE_SYSTEM   = 7'h73;
parameter OPCODE_FENCE    = 7'h0f;
parameter OPCODE_COMP     = 7'h33;
parameter OPCODE_COMPIMM  = 7'h13;
parameter OPCODE_STORE    = 7'h23;
parameter OPCODE_LOAD     = 7'h03;
parameter OPCODE_BRANCH   = 7'h63;
parameter OPCODE_JALR     = 7'h67;
parameter OPCODE_JAL      = 7'h6f;
parameter OPCODE_AUIPC    = 7'h17;
parameter OPCODE_LUI      = 7'h37;

// Parametros do decodificador (Necessário otimizar(OTIMIZEI PRA CARALHO))

typedef enum
  {
    ADD,
    SUB,
    SLL,
    SRL,
    SRA,
    AND,
    OR,
    XOR,
    SLT,
    SLTU,
    ADDI,
    SLLI,
    SRLI,
    SRAI,
    ANDI,
    ORI,
    XORI,
    SLTI,
    SLTIU,
    LUI,
    AUIPC,
    LB,
    LBU,
    LH,
    LHU,
    LW,
    SB,
    SH,
    SW,
    FENCE,
    FENCEI,
    BEQ,
    BNE,
    BLT,
    BLTU,
    BGE,
    BGEU,
    JAL,
    JALR,
    MUL,
    MULH,
    MULHSU,
    MULHU,
    DIV,
    DIVU,
    REM,
    REMU
  } decoded_op;

// Controle da ULA

parameter ALU_OP_WIDTH		= 4;

parameter ALU_ADD					= 4'b0000;
parameter ALU_SUB					= 4'b0001;
parameter ALU_SLT					= 4'b0010;
parameter ALU_SLTU				= 4'b0011;
parameter ALU_OR					=	4'b0100;
parameter ALU_AND					=	4'b0101;
parameter ALU_XOR					=	4'b0110;
parameter ALU_SLL					= 4'b1000;
parameter ALU_SRL					= 4'b1001;
parameter ALU_SRA					=	4'b1010;

// Controle da UMD

parameter MDU_OP_WIDTH    = 3;

parameter MDU_MUL         = 3'b000;
parameter MDU_MULH        = 3'b001;
parameter MDU_MULHSU      = 3'b010;
parameter MDU_MULHU       = 3'b011;
parameter MDU_DIV         = 3'b100;
parameter MDU_DIVU        = 3'b101;
parameter MDU_REM         = 3'b110;
parameter MDU_REMU        = 3'b111;

//endpackage