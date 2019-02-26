//package riscv_defines;

// Parametros globais

parameter WORD_WIDTH 			= 32;
parameter ADDR_WIDTH 			= 5;
parameter N_OF_REGS				=	32;

// Parametros de opcodes

parameter OPCODE_WIDTH		= 7;

parameter OPCODE_SYSTEM   = 7'h73;
parameter OPCODE_FENCE    = 7'h0f;
parameter OPCODE_OP       = 7'h33;
parameter OPCODE_OPIMM    = 7'h13;
parameter OPCODE_STORE    = 7'h23;
parameter OPCODE_LOAD     = 7'h03;
parameter OPCODE_BRANCH   = 7'h63;
parameter OPCODE_JALR     = 7'h67;
parameter OPCODE_JAL      = 7'h6f;
parameter OPCODE_AUIPC    = 7'h17;
parameter OPCODE_LUI      = 7'h37;

// Parametros de funct7 (TIPO R)

parameter FUNCT7_DEFAULT	= 7'b0000000;
parameter FUNCT7_SUBSRA		= 7'b0100000; // Somente para SUB, SRA, SRAI

// Parametros de funct3 (TIPO R)

parameter FUNCT3_ADDER		=	3'b000;
parameter FUNCT3_SLL			=	3'b001;
parameter FUNCT3_SLT			=	3'b010;
parameter FUNCT3_SLTU			=	3'b011;
parameter FUNCT3_XOR			=	3'b100;
parameter FUNCT3_SR				=	3'b101;
parameter FUNCT3_OR				=	3'b110;
parameter FUNCT3_AND			=	3'b111;

// Parametros de funct4 (TIPO I)

parameter FUNCT4_ADDI			= 3'b000;
parameter FUNCT4_SLTI			= 3'b010;
parameter FUNCT4_SLTIU		= 3'b011;
parameter FUNCT4_XORI			= 3'b100;
parameter FUNCT4_ORI			= 3'b110;
parameter FUNCT4_ANDI			= 3'b111;

// Parametros de 

// Parametros do decodificador (Necessário otimizar)

parameter DCODE_WIDTH			= 6;

parameter DCODED_ADD			= 6'h00;
parameter DCODED_SUB			= 6'h01;
parameter DCODED_SLL			= 6'h02;
parameter DCODED_SRL			= 6'h03;
parameter DCODED_SRA			= 6'h04;
parameter DCODED_AND			= 6'h05;
parameter DCODED_OR				= 6'h06;
parameter DCODED_XOR			= 6'h07;
parameter DCODED_SLT			= 6'h08;
parameter DCODED_SLTU			= 6'h09;
parameter DCODED_ADDI			= 6'h0a;
parameter DCODED_SLLI			= 6'h0b;
parameter DCODED_SRLI			= 6'h0c;
parameter DCODED_SRAI			= 6'h0d;
parameter DCODED_ANDI			= 6'h0e;
parameter DCODED_ORI			= 6'h0f;
parameter DCODED_XORI			= 6'h10;
parameter DCODED_SLTI			= 6'h11;
parameter DCODED_SLTIU		= 6'h12;
parameter DCODED_LUI			= 6'h13;
parameter DCODED_AUIPC		= 6'h14;
parameter DCODED_LB				= 6'h15;
parameter DCODED_LBU			= 6'h16;
parameter DCODED_LH				= 6'h17;
parameter DCODED_LHU			= 6'h18;
parameter DCODED_LW				= 6'h19;
parameter DCODED_SB				= 6'h1a;
parameter DCODED_SH				= 6'h1b;
parameter DCODED_SW				= 6'h1c;
parameter DCODED_FENCE		= 6'h1d;
parameter DCODED_FENCEI		= 6'h1e;
parameter DCODED_BEQ			= 6'h1f;
parameter DCODED_BNE			= 6'h20;
parameter DCODED_BLT			= 6'h21;
parameter DCODED_BLTU			= 6'h22;
parameter DCODED_BGE			= 6'h23;
parameter DCODED_BGEU			= 6'h24;
parameter DCODED_JAL			= 6'h25;
parameter DCODED_JALR			= 6'h26;

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

//endpackage