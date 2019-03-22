`include "alu.sv"
`include "mdu.sv"

//import riscv_defines::*;

module ex_stage
	(
		input  logic [WORD_WIDTH-1:0]		reg_rdata1_i,				// Dado vindo de RS1
		input	 logic [WORD_WIDTH-1:0] 	reg_rdata2_i,				// Dado vindo de RS2
		input  logic [WORD_WIDTH-1:0]		instruction_i,			// Instrução vinda do Fetch
		input  logic [WORD_WIDTH-1:0]		program_count_i,		// Endereço da atual instrução
		output logic [WORD_WIDTH-1:0]		ex_data_o,					// Saída do EX_Stage
		output logic [WORD_WIDTH-1:0]		rdata2_store_o			// Dado de RS2, usados para operações de Store

		// Sinais de controle
		input  logic [ALU_OP_WIDTH-1:0]	alu_op_ctrl_i,			// Controle de ULA e UMD
		input  logic										stype_mux_i,				// Sinal de operação tipo S (Store)
		input  logic										utype_mux_i,				// Sinal de operação tipo U (LUI e AUIPC)
		input  logic 										jtype_mux_i,				// Sinal de operação tipo J (JAL)
		input  logic										imm_alu_mux_i,			// Sinal de operações imediatas (I, S e U)
		input  logic										pc_alu_mux_i,				// Sinal de operação com PC (AUIPC)
		input  logic 										branch_alu_mux_i,		// Sinal de bypass da ULA (Branches e JAL)
		input  logic										zeroflag_inv_i, 		// Inversor de zeroflag
		output logic										branch_comp_flag_o,	// Flag de resultado de comparação para branches

		// Sinal de controle ULA/UMD - Só é usado caso UMD exista
		input  logic										alu_mdu_mux_i
	);

	logic [WORD_WIDTH-1:0] 	operand_a;
	logic [WORD_WIDTH-1:0] 	operand_b;
	logic	[WORD_WIDTH-1:0] 	alu_result;
	logic [WORD_WIDTH-1:0]	ex_data;
	logic										zero_flag;
	logic										bypass_alu_mux;

	// Imediatos I, S e U (Usados para cálculo)
	logic [11:0]					 	itype_imm;
	logic [11:0]					 	stype_imm;
	logic	[WORD_WIDTH-1:0] 	xtended_lower_imm;
	logic [19:0]						utype_imm;
	logic [WORD_WIDTH-1:0] 	xtended_upper_imm;
	logic [WORD_WIDTH-1:0] 	full_comp_immediate;

	// Imediatos SB e UJ (Usados para branch)
	logic [12:0]						btype_imm;
	logic	[WORD_WIDTH-1:0] 	xtended_branch_imm;
	logic [WORD_WIDTH-1:0]	pc_plus_branch;
	logic [20:0]						jtype_imm;
	logic [WORD_WIDTH-1:0] 	xtended_jal_imm;
	logic [WORD_WIDTH-1:0]	full_branch_immediate;

	// Extensão de sinal de imediatos inferiores de 12 bits (Tipo I e S)
	always_comb begin
		itype_imm = instruction_i[31:20];
		stype_imm = {instruction_i[31:25], instruction_i[11:7]};
		xtended_lower_imm[11:0] = (stype_mux_i) ? (stype_imm) : (itype_imm);
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
		xtended_branch_imm[31:13] = (btype_imm[12]) ? (19'b1) : (19'b0);	
	end

	// Extensão de imediato de jal (Tipo UJ)
	always_comb begin
		jtype_imm = {instruction_i[31], instruction_i[19:12], instruction_i[20], instruction_i[30:21], 1'b0};
		xtended_jal_imm[20:0]  = jtype_imm;
		xtended_jal_imm[31:21] = (jtype_imm[20]) ? (11'b1) : (11'b0);
	end

	// Mux de escolha de imediato para cálculo
	assign full_comp_immediate = (utype_mux_i) ? (xtended_upper_imm) : (xtended_lower_imm);

	// Mux para seleção de imediato para Branch (JARL não incluso)
	assign pc_plus_branch = program_count_i + xtended_branch_imm;
	assign full_branch_immediate = (jtype_mux_i) ? (xtended_jal_imm) : (pc_plus_branch);

	// Caso AUIPC, operando A receberá PC para soma
	assign operand_a = (pc_alu_mux_i) ? (program_count_i) : (reg_rdata1_i);
	
	// Operando B recebe valor de registro ou imediato
	assign operand_b = (imm_alu_mux_i) ? (full_immediate) : (reg_rdata2_i);

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

	// Mux de saída do EX_Stage
	assign bypass_alu_mux = utype_mux_i && ~pc_alu_mux_i;
	always_comb begin
		if(bypass_alu_mux)										// Usado somente em LUI
			ex_data_o = full_comp_immediate; 
		else if(branch_alu_mux_i)							// Usando em Branches e JAL
			ex_data_o = full_branch_immediate; 
		else																	// Caso Contrário
			ex_data_o = ex_data;
	end

	// Saída de rs2 para operações de Store
	assign rdata2_store_o = reg_rdata2_i;

	// Zeroflag da ULA e geração de flag de resultado de comparação de branch
	assign zero_flag = (ex_data == 32'b0);
	assign branch_comp_flag_o = (zeroflag_inv_i) ? (~zeroflag) : (zeroflag);

endmodule