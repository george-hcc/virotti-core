`include "alu.sv"

//import riscv_defines::*;

module ex_stage
	(
		input  logic [WORD_WIDTH-1:0]		reg_rdata1_i,
		input	 logic [WORD_WIDTH-1:0] 	reg_rdata2_i,
		input  logic [WORD_WIDTH-1:0]		instruction_i,
		input  logic [WORD_WIDTH-1:0]		program_count_i,
		output logic [WORD_WIDTH-1:0]		ex_data_o,
		output logic [WORD_WIDTH-1:0]		rdata2_store_o

		// Sinais de controle
		input  logic										imm_mux_i,
		input  logic										stype_mux_i,
		input  logic										utype_mux_i,
		input  logic										bypass_alu_mux_i,
		input  logic										pc_alu_mux_i,
		input  logic [ALU_OP_WIDTH-1:0]	alu_op_ctrl_i,
		output logic										zero_flag_o
	);

	logic [WORD_WIDTH-1:0] 	operand_a;
	logic [WORD_WIDTH-1:0] 	operand_b;
	logic	[WORD_WIDTH-1:0] 	alu_result;

	logic [11:0]					 	itype_imm;
	logic [11:0]					 	stype_imm;
	logic	[WORD_WIDTH-1:0] 	xtended_lower_imm;
	logic [19:0]						utype_imm;
	logic [WORD_WIDTH-1:0] 	xtended_upper_imm;
	logic [WORD_WIDTH-1:0] 	full_immediate;

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

	// Mux de escolha de imediato
	assign full_immediate = (utype_mux_i) ? (xtended_upper_imm) : (xtended_lower_imm);

	// Caso AUIPC, operando A receberá PC para soma
	assign operand_a = (pc_alu_mux_i) ? (program_count_i) : (reg_rdata1_i);
	
	// Operando B recebe valor de registro ou imediato
	assign operand_b = (imm_mux_i) ? (full_immediate) : (reg_rdata2_i);

	alu ALU
		(
			.operand_a_i(operand_a),
			.operand_b_i(operand_b),
			.result_o(alu_result),

			.operator_i(alu_op_ctrl_i)
		);

	// Operação LUI ignorando a ULA no momento (possivel utilizar SLL ao invéz disto)
	assign ex_data_o = (bypass_alu_mux_i) ? (full_immediate) : alu_result;

	// Saída de rs2 para operações de Store
	assign rdata2_store_o = reg_rdata2_i;

	assign zero_flag_o = (ex_data_o == 32'b0);

endmodule