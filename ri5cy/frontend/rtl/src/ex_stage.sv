//////////////////////////////////////////////////////////////////////////////////////////////
// Autor:         	George Camboim - george.camboim@embedded.ufcg.edu.br         						//
//																																													//
// Nome do Design:  EX_Stage (Estágio de Execução)				                  								//
// Nome do Projeto: MiniSoc                                                    							//
// Linguagem:       SystemVerilog                                              							//
//                                                                            							//
// Descrição:    		Terceiro estágio do pipeline do core																		//
//                 	Contém ULA e possivelmente UMD (Unidade de MultDiv)											//
//                                                                            							//
//////////////////////////////////////////////////////////////////////////////////////////////

import riscv_defines::*;

module ex_stage
	(
		// Sinais de DataPath
		input  logic [WORD_WIDTH-1:0]		reg_rdata1_i,				// Dado vindo de RS1
		input	 logic [WORD_WIDTH-1:0] 	reg_rdata2_i,				// Dado vindo de RS2
		input  logic [WORD_WIDTH-1:0]		instruction_i,			// Instrução vinda do Fetch
		input  logic [WORD_WIDTH-1:0]		program_count_i,		// Endereço da atual instrução
		output logic [WORD_WIDTH-1:0]		wb_data_o,					// Saída do EX_Stage
		output logic [ADDR_WIDTH-1:0]   reg_waddr_o, 				// Endereço de escrita nos registradores
		output logic [WORD_WIDTH-1:0]		pc_branch_addr_o,		// Endereço de novo PC em casos de Jumps e Branches

		// Sinais de ControlPath
		input  logic [ALU_OP_WIDTH-1:0]	alu_op_ctrl_i,			// Controle de ULA e UMD
		input  logic										stype_imm_mux_i,		// Sinal de operação tipo S (Stores)
		input  logic										auipc_flag_i,				// Sinal de operação tipo U (AUIPC)
		input  logic										imm_alu_mux_i,			// Sinal de operações imediatas (I, S e U)
		input  logic										jump_flag_i,				// Sinal de operações de Jump (JARL e JAL)
		input  logic										branch_flag_i,			// Sinal de Operações de Branch
		input  logic										lui_alu_bypass_i,		// Sinal de operação LUI
		input  logic										zeroflag_inv_i, 		// Inversor de zeroflag (Usado em alguns branches)
		output logic										pc_branch_ctrl_o,		// Saída de controle para modificar PC

		// Sinal de controle ULA/UMD - Só é usado caso UMD exista
		input  logic										alu_mdu_mux_i
	);

	logic [WORD_WIDTH-1:0] 	operand_a;
	logic [WORD_WIDTH-1:0] 	operand_b;
	logic	[WORD_WIDTH-1:0] 	alu_result;
	logic [WORD_WIDTH-1:0]	wb_data;
	logic										zero_flag;
	logic										branch_taken;

	// Imediatos I, S e U (Usados para cálculo)
	logic [11:0]					 	itype_imm;
	logic [11:0]					 	stype_imm;
	logic	[WORD_WIDTH-1:0] 	xtended_lower_imm;
	logic [19:0]						utype_imm;
	logic [WORD_WIDTH-1:0] 	xtended_upper_imm;
	logic [WORD_WIDTH-1:0] 	full_alu_immediate;

	// Imediato SB (Usado para branches)
	logic [12:0]						btype_imm;
	logic	[WORD_WIDTH-1:0] 	xtended_branch_imm;

	// Resultados de somas com PC
	logic [WORD_WIDTH-1:0]	pc_plus_four;
	logic [WORD_WIDTH-1:0]	pc_plus_imm;

	// Extensão de sinal de imediatos inferiores de 12 bits (Tipo I e S)
	always_comb begin
		itype_imm = instruction_i[31:20];
		stype_imm = {instruction_i[31:25], instruction_i[11:7]};
		xtended_lower_imm[11:0] = (stype_imm_mux_i) ? (stype_imm) : (itype_imm);
		xtended_lower_imm[31:12] = (xtended_lower_imm[11]) ? 20'hFFFFF : 20'h00000;
	end

	// Extensão de imediato superior (Tipo U)
	always_comb begin
		utype_imm = instruction_i[31:12];
		xtended_upper_imm = {utype_imm, 12'b0};
	end

	// Extensão de imediato de branch (Tipo SB)
	always_comb begin
		btype_imm = {instruction_i[31], instruction_i[7], instruction_i[30:25], instruction_i[11:8], 1'b0};
		xtended_branch_imm[12:0]  = btype_imm;
		xtended_branch_imm[31:13] = (btype_imm[12]) ? (19'h7FFFF) : (19'h00000);	
	end

	// Mux de escolha de imediato para cálculo
	assign full_alu_immediate = (auipc_flag_i) ? (xtended_upper_imm) : (xtended_lower_imm);

	// Caso AUIPC ou Jump, operando A receberá PC para soma
	assign operand_a = (auipc_flag_i || jump_flag_i) ? (program_count_i) : (reg_rdata1_i);
	
	// Operando B recebe valor de registro ou imediato
	always_comb begin
		if(jump_flag_i)
			operand_b = 32'h4;
		else if(imm_alu_mux_i)
			operand_b = full_alu_immediate;
		else
			operand_b = reg_rdata2_i;
	end

	alu ALU
		(
			.operand_a_i	(operand_a 			),
			.operand_b_i	(operand_b 			),
			.result_o			(alu_result 		),
			.operator_i		(alu_op_ctrl_i	)
		);

	generate
		/********************/
		/**BLOCO RISCV (IM)**/
		/********************/
		if(RISCV_M_CORE) begin

			logic [WORD_WIDTH-1:0] mdu_result;

			mdu MDU
				(
					.operand_a_i 	(operand_a 					),
					.operand_b_i 	(operand_b 					),
					.result_o 		(mdu_result					),

					.operator_i 	(alu_op_ctrl_i[2:0]	)
				);

			assign wb_data = (alu_mdu_mux_i) ? (mdu_result) : (alu_result);

		end

		/********************/
		/***BLOCO RISCV (I)**/
		/********************/
		else begin

			assign wb_data = alu_result;			
		
		end
	endgenerate

	// Somas com PC para branches
	assign pc_plus_imm = program_count_i + xtended_branch_imm;

	// Zeroflag da ULA e geração de flag de resultado de comparação de branch
	assign zero_flag = (wb_data == 32'h00000000);

	// Flag de resultado de comparação de operações de branch
	assign branch_taken = (zeroflag_inv_i) ? (!zero_flag) : (zero_flag);

	/****************************/
	/***********SAIDAS***********/
	/****************************/

	// Mux de saída do EX_Stage
	assign wb_data_o = (lui_alu_bypass_i) ? (xtended_upper_imm) : wb_data; 

	// Endereço de escrita nos registradores
	assign reg_waddr_o = instruction_i[11:7];

	// Endereço para branch
	assign pc_branch_addr_o = pc_plus_imm;

	// Flag de controle para alertar que um branch condicional foi tomado
	assign pc_branch_ctrl_o = branch_taken && branch_flag_i;

endmodule