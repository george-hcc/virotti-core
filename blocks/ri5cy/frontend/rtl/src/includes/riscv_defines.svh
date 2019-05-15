package riscv_defines;

  // Parametro para adição de UMD ao core
  parameter RISCV_M_CORE    = 0;

  // Definições Globais
  parameter BYTE_WIDTH      = 8;
  parameter BYTES_PER_WIDTH = 4;
  parameter WORD_WIDTH      = BYTE_WIDTH * BYTES_PER_WIDTH;

  // Definições de Core
  parameter N_OF_REGS       = 32;
  parameter REG_ADDR_WIDTH  = 5;

  // Definições de Memória e Endereçamento
  parameter N_OF_INSTR      = 256;
  parameter INSTR_MEM_SIZE  = N_OF_INSTR * 4;
  parameter N_OF_DATA       = 256;
  parameter DATA_MEM_SIZE   = N_OF_DATA * 4;
  parameter DMEM_START_ADDR = INSTR_MEM_SIZE;
  parameter ROM_START_ADDR  = DMEM_START_ADDR + (DATA_MEM_SIZE / 4);
  
  // Definições de OpCodes
  parameter OPCODE_WIDTH    = 7;
  
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
  
  // Controle da ULA  
  parameter ALU_OP_WIDTH		= 4;
  
  parameter ALU_ADD					= 4'b0000;
  parameter ALU_SUB					= 4'b0001;
  parameter ALU_SLT					= 4'b0010;
  parameter ALU_SLTU		    = 4'b0011;
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

endpackage