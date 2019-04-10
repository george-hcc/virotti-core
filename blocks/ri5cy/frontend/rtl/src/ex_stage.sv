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
		input  logic										jarl_flag_i,				// Sinal de operação Jarl
		input  logic 										jal_flag_i,					// Sinal de operação tipo J (JAL)
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
	logic [WORD_WIDTH-1:0]	ex_data;
	logic										zero_flag;
	logic										branch_taken;

	// Imediatos I, S e U (Usados para cálculo)
	logic [11:0]					 	itype_imm;
	logic [11:0]					 	stype_imm;
	logic	[WORD_WIDTH-1:0] 	xtended_lower_imm;
	logic [19:0]						utype_imm;
	logic [WORD_WIDTH-1:0] 	xtended_upper_imm;
	logic [WORD_WIDTH-1:0] 	full_alu_immediate;

	// Imediatos SB e UJ (Usados para branches e jumps)
	logic [12:0]						btype_imm;
	logic	[WORD_WIDTH-1:0] 	xtended_branch_imm;
	logic [20:0]						jtype_imm;
	logic [WORD_WIDTH-1:0] 	xtended_jal_imm;
	logic [WORD_WIDTH-1:0]	full_pc_immediate;

	// Resultados de soma com program count
	logic [WORD_WIDTH-1:0]	pc_plus_four;
	logic [WORD_WIDTH-1:0]	pc_plus_imm;
	logic [WORD_WIDTH-1:0]  jarl_pc;

	// Extensão de sinal de imediatos inferiores de 12 bits (Tipo I e S)
	always_comb begin
		itype_imm = instruction_i[31:20];
		stype_imm = {instruction_i[31:25], instruction_i[11:7]};
		xtended_lower_imm[11:0] = (stype_imm_mux_i) ? (stype_imm) : (itype_imm);
		xtended_lower_imm[31:12] = (xtended_lower_imm[11]) ? 20'b1 : 20'b0;
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

	// Extensão de imediato de jal (Tipo UJ)
	always_comb begin
		jtype_imm = {instruction_i[31], instruction_i[19:12], instruction_i[20], instruction_i[30:21], 1'b0};
		xtended_jal_imm[20:0]  = jtype_imm;
		xtended_jal_imm[31:21] = (jtype_imm[20]) ? (11'b1) : (11'b0);
	end

	// Mux de escolha de imediato para cálculo
	assign full_alu_immediate = (auipc_flag_i) ? (xtended_upper_imm) : (xtended_lower_imm);

	// Caso AUIPC, operando A receberá PC para soma
	assign operand_a = (auipc_flag_i) ? (program_count_i) : (reg_rdata1_i);
	
	// Operando B recebe valor de registro ou imediato
	assign operand_b = (imm_alu_mux_i) ? (full_alu_immediate) : (reg_rdata2_i);

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

			assign ex_data = (alu_mdu_mux_i) ? (mdu_result) : (alu_result);

		end

		/********************/
		/***BLOCO RISCV (I)**/
		/********************/
		else begin

			assign ex_data = alu_result;			
		
		end
	endgenerate

	// Mux para seleção de imediato para branches e jumps
	assign full_pc_immediate = (jal_flag_i) ? (xtended_jal_imm) : (xtended_branch_imm);

	// Somas com PC para branches e jumps
	assign pc_plus_four = program_count_i + 32'h4;
	assign pc_plus_imm = program_count_i + full_pc_immediate;
	assign jarl_pc = xtended_lower_imm + reg_rdata1_i;

	// Zeroflag da ULA e geração de flag de resultado de comparação de branch
	assign zero_flag = (ex_data == 32'b0);

	// Flag de resultado de comparação de operações de branch
	assign branch_taken = (zeroflag_inv_i) ? (!zero_flag) : (zero_flag);

	/****************************/
	/***********SAIDAS***********/
	/****************************/

	// Mux de saída do EX_Stage
	always_comb begin
		if(lui_alu_bypass_i)									// Usado somente em LUI
			wb_data_o = xtended_upper_imm; 
		else if(jarl_flag_i || jal_flag_i)		// Usado em Jal e Jarl
			wb_data_o = pc_plus_four; 
		else																	// Caso Contrário
			wb_data_o = ex_data;
	end

	assign reg_waddr_o = instruction_i[11:7];

	assign pc_branch_addr_o = (jarl_flag_i) ? (jarl_pc) : (pc_plus_imm);

	assign pc_branch_ctrl_o = ((branch_taken && branch_flag_i) || jal_flag_i || jarl_flag_i);

endmodule