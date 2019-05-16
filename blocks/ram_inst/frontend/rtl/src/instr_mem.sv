//////////////////////////////////////////////////////////////////////////////////////////////
// Autores:         																																				//
//									George Camboim - george.camboim@embedded.ufcg.edu.br         						//
//									Kelvin Dantas Vale - kelvin.vale@embedded.ufcg.edu.br 									// 
//																																													//
// Nome do Design:  Memória Ram de Instruções							                  								//
// Nome do Projeto: MiniSoc                                                    							//
// Linguagem:       SystemVerilog                                              							//
//                                                                            							//
// Descrição:    		Modelo de memória de instruções RISC-V para simulação do MiniSoc				//
//                                                                            							//
//////////////////////////////////////////////////////////////////////////////////////////////

import riscv_defines::*;

module instr_mem
	#(
		parameter CORE_TEST = 1
	)(
		input  logic									clk,
		// Interface de memória de instruções
		input  logic									instr_req_i,
		input  logic [WORD_WIDTH-1:0] instr_addr_i,
		output logic [WORD_WIDTH-1:0] instr_rdata_o,
		output logic 									instr_rvalid_o,
		output logic 									instr_gnt_o
	);
	
	// Array de Memória
	logic [INSTR_MEM_SIZE-1:0] 	instr_mem;
	// Endereço Ignorando os ultimos dois bits para evitar acesso de memória desalinhado
	logic [WORD_WIDTH-1:0]			instr_addr;

	assign instr_addr = {instr_addr_i[31:2], 2'b00};
	
	assign instr_gnt_o = instr_req_i;
	
	always_ff @(posedge clk) begin
		if(instr_req_i && instr_addr < INSTR_MEM_SIZE) begin
			instr_rvalid_o 	<= 1'b1;
			instr_rdata_o		<= instr_mem[8*instr_addr+:32]; //////////////////////////////////SE LIGA BOY
		end
		else
			instr_rvalid_o <= 1'b0;
	end

	/*####################################################################*/
	/*#Inicio da Lógica em alto nível de inseção de instruções na Memória#*/
	/*####################################################################*/

	localparam XZERO  = 5'b00000;
  localparam XRA    = 5'b00001;
  localparam XSP    = 5'b00010;
  localparam XGP    = 5'b00011;
  localparam XTP    = 5'b00100;
  localparam XT0    = 5'b00101;
  localparam XT1    = 5'b00110;
  localparam XT2    = 5'b00111;
  localparam XS0    = 5'b01000;
  localparam XS1    = 5'b01001;
  localparam XA0    = 5'b01010;
  localparam XA1    = 5'b01011;
  localparam XA2    = 5'b01100;
  localparam XA3    = 5'b01101;
  localparam XA4    = 5'b01110;
  localparam XA5    = 5'b01111;
  localparam XA6    = 5'b10000;
  localparam XA7    = 5'b10001;
  localparam XS2    = 5'b10010;
  localparam XS3    = 5'b10011;
  localparam XS4    = 5'b10100;
  localparam XS5    = 5'b10101;
  localparam XS6    = 5'b10110;
  localparam XS7    = 5'b10111;
  localparam XS8    = 5'b11000;
  localparam XS9    = 5'b11001;
  localparam XS10   = 5'b11010;
  localparam XS11   = 5'b11011;
  localparam XT3    = 5'b11100;
  localparam XT4    = 5'b11101;
  localparam XT5    = 5'b11110;
  localparam XT6    = 5'b11111;

	initial begin
		instr_mem = 'h0;
		case(CORE_TEST)
			1:	counter();
			2:	bubble_sort();
		endcase
		display_mem();
	end

  task display_mem();
    $display("################################");
    $display("####CARREGAMENTO DE MEMORIA#####");
    $display("################################");
    $display("###########INSTRUÇÕES###########");
    $display("################################");
    case(CORE_TEST)
    	1: $display("Algoritmo Inserido: Contador");
    	2: $display("Algoritmo Inserido: Bubble Sort");
    endcase
    for(int i = 0; i < N_OF_INSTR; i++) begin
    	if(instr_mem[32*i+:32] == 32'h0000_0000)
    		break;
    	else
      	$display("- Mem Instr #%2h = %h", i*4, instr_mem[32*i+:32]);
    end
    $display("################################");
    $display("#FIM DE CARREGAMENTO DE MEMORIA#");
    $display("################################\n");
  endtask

  // Inserção de algoritmo assembly na memória: Contador entre 0 e 15
	localparam COUNT = XS0;
	localparam REVERSE = XS1;
	localparam FIFTEEN  = XT0;

	task counter();
    // Inicialização
    instr_mem[0*WORD_WIDTH+:WORD_WIDTH]   = ADD(COUNT, XZERO, XZERO);     // 00
    instr_mem[1*WORD_WIDTH+:WORD_WIDTH]   = ADD(REVERSE, XZERO, XZERO);   // 04
    instr_mem[2*WORD_WIDTH+:WORD_WIDTH]   = ADDI(FIFTEEN, XZERO, 12'd15); // 08
    // Loop Infinito
    instr_mem[3*WORD_WIDTH+:WORD_WIDTH]   = BEQ(REVERSE, XZERO, 4*3);  		// 0c
    instr_mem[4*WORD_WIDTH+:WORD_WIDTH]   = ADDI(COUNT, COUNT, -1);       // 10
    instr_mem[5*WORD_WIDTH+:WORD_WIDTH]   = JAL(XZERO, 4*2);              // 14
    instr_mem[6*WORD_WIDTH+:WORD_WIDTH]   = ADDI(COUNT, COUNT, 1);        // 18
    instr_mem[7*WORD_WIDTH+:WORD_WIDTH]   = BNE(COUNT, XZERO, 4*2);    		// 1c
    instr_mem[8*WORD_WIDTH+:WORD_WIDTH]   = ADD(REVERSE, XZERO, XZERO);   // 20
    instr_mem[9*WORD_WIDTH+:WORD_WIDTH]   = BNE(COUNT, FIFTEEN, 4*2);  		// 24
    instr_mem[10*WORD_WIDTH+:WORD_WIDTH]  = ADDI(REVERSE, XZERO, 1);      // 28
    instr_mem[11*WORD_WIDTH+:WORD_WIDTH]  = JAL(XZERO, -4*8);             // 2c
	endtask

  // Inserção de algoritmo assembly na memória: Bubble Sort
	localparam ARRAY_ADDR		=	XS0;
	localparam ARRAY_LENGHT	=	XS1;
	localparam PNTR_I				=	XS2;
	localparam PNTR_J				=	XS3;
	localparam ARRAY_J			=	XT0;
	localparam ARRAY_JP1		=	XT1;

	task bubble_sort();
		// Inicialização
		instr_mem[0*WORD_WIDTH+:WORD_WIDTH]		=	ADDI(ARRAY_ADDR, XZERO, 12'h400);					// 00
		instr_mem[1*WORD_WIDTH+:WORD_WIDTH]		=	LW(ARRAY_LENGHT, ARRAY_ADDR, 0);					// 04
		instr_mem[2*WORD_WIDTH+:WORD_WIDTH]		= SLLI(ARRAY_LENGHT, ARRAY_LENGHT, 2);			// 08
		instr_mem[3*WORD_WIDTH+:WORD_WIDTH]		=	ADDI(ARRAY_ADDR, ARRAY_ADDR, 4);					// 0c
		instr_mem[4*WORD_WIDTH+:WORD_WIDTH]		=	JAL(XRA, 4*2);														// 10
		// End of Program
		instr_mem[5*WORD_WIDTH+:WORD_WIDTH]		=	JAL(XZERO, 4*0);													// 14
		// Bubble Sort
		instr_mem[6*WORD_WIDTH+:WORD_WIDTH]		=	ADD(PNTR_I, ARRAY_ADDR, ARRAY_LENGHT);		// 18
		instr_mem[7*WORD_WIDTH+:WORD_WIDTH]		=	ADDI(PNTR_I, PNTR_I, -4*1);								// 1c
		instr_mem[8*WORD_WIDTH+:WORD_WIDTH]		=	ADD(PNTR_J, ARRAY_ADDR, XZERO);						// 20
		instr_mem[9*WORD_WIDTH+:WORD_WIDTH]		=	LW(ARRAY_J, PNTR_J, 4*0);									// 24
		instr_mem[10*WORD_WIDTH+:WORD_WIDTH]	=	LW(ARRAY_JP1, PNTR_J, 4*1);								// 28
		instr_mem[11*WORD_WIDTH+:WORD_WIDTH]	=	BGE(ARRAY_JP1, ARRAY_J, 4*3);							// 2c
		// Swap de Memória
		instr_mem[12*WORD_WIDTH+:WORD_WIDTH]	=	SW(ARRAY_J, PNTR_J, 4*1);									// 30
		instr_mem[13*WORD_WIDTH+:WORD_WIDTH]	=	SW(ARRAY_JP1, PNTR_J, 4*0);								// 34
		// Bubble Sort cont.
		instr_mem[14*WORD_WIDTH+:WORD_WIDTH]	=	ADDI(PNTR_J, PNTR_J, 4*1);								// 38
		instr_mem[15*WORD_WIDTH+:WORD_WIDTH]	=	BLT(PNTR_J, PNTR_I, -4*7);								// 3c
		instr_mem[16*WORD_WIDTH+:WORD_WIDTH]	=	ADDI(PNTR_I, PNTR_I, -4*1);								// 40
		instr_mem[17*WORD_WIDTH+:WORD_WIDTH]	=	BNE(PNTR_I, ARRAY_ADDR, -4*9);						// 44
		instr_mem[18*WORD_WIDTH+:WORD_WIDTH]	=	JAL(XZERO, XRA);													// 48
	endtask

	// Funções codificadoras de instruções
  function logic [31:0] ADD(logic [4:0] rd, logic [4:0] rs1, logic [4:0] rs2);
    return {7'b0000000, rs2, rs1, 3'b000, rd, OPCODE_COMP};
  endfunction

  function logic [31:0] ADDI(logic [4:0] rd, logic [4:0] rs1, logic [11:0] imm);
    return {imm, rs1, 3'b000, rd, OPCODE_COMPIMM}; 
  endfunction

  function logic [31:0] SLLI(logic [4:0] rd, logic [4:0] rs1, logic [4:0] shamt);
    return {7'h00, shamt, rs1, 3'b001, rd, OPCODE_COMPIMM}; 
  endfunction

  function logic [31:0] LW(logic [4:0] rd, logic [4:0] rs1, logic [11:0] imm);
  	return {imm, rs1, 3'b010, rd, OPCODE_LOAD};
  endfunction

  function logic [31:0] SW(logic [4:0] rs2, logic [4:0] rs1, logic [11:0] imm);
  	return {imm[11:5], rs2, rs1, 3'b010, imm[4:0], OPCODE_STORE};
  endfunction

  function logic [31:0] BEQ(logic [4:0] rs1, logic [4:0] rs2, logic [12:0] imm);
    return {imm[12], imm[10:5], rs2, rs1, 3'b000, imm[4:1], imm[11], OPCODE_BRANCH};
  endfunction

  function logic [31:0] BNE(logic [4:0] rs1, logic [4:0] rs2, logic [12:0] imm);
    return {imm[12], imm[10:5], rs2, rs1, 3'b001, imm[4:1], imm[11], OPCODE_BRANCH};
  endfunction

  function logic [31:0] BLT(logic [4:0] rs1, logic [4:0] rs2, logic [12:0] imm);
    return {imm[12], imm[10:5], rs2, rs1, 3'b100, imm[4:1], imm[11], OPCODE_BRANCH};
  endfunction

  function logic [31:0] BGE(logic [4:0] rs1, logic [4:0] rs2, logic [12:0] imm);
    return {imm[12], imm[10:5], rs2, rs1, 3'b101, imm[4:1], imm[11], OPCODE_BRANCH};
  endfunction

  function logic [31:0] JAL(logic [4:0] rd, logic [20:0] imm);
    return {imm[20], imm[10:1], imm[11], imm[19:12], rd, OPCODE_JAL};
  endfunction

endmodule