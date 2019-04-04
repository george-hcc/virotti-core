`include "decoder.sv"
`include "controller.sv"

//import riscv_defines::*;

module control_unit
	(
		input  logic [WORD_WIDTH-1:0]		instruction_i,

		// Sinais de ControlPath
		input	 logic										no_op_flag_i,
		output logic [ALU_OP_WIDTH-1:0]	alu_op_ctrl_o,
		output logic [2:0]							load_type_ctrl_o,
		output logic [1:0]							store_type_ctrl_o,
		output logic										write_en_o,
		output logic										stype_ctrl_o,
		output logic										imm_alu_ctrl_o,
		output logic										jarl_ctrl_o,
		output logic										jal_ctrl_o,
		output logic										branch_ctrl_o,
		output logic										auipc_ctrl_o,
		output logic										lui_ctrl_o,
		output logic										zeroflag_ctrl_o,

		// Sinal de controle ULA/UMD - Só é usado caso UMD exista
		output logic										mdu_op_ctrl_o		
	);

	decoded_instr operation;

	decoder decoder
		(
			.instr_i(instruction_i),
			.decoded_instr_o(operation)
		);

	generate

		if(RISCV_M_CORE) begin

			controller ctrlr
				(
					.decoded_instr_i(operation),

					.alu_op_ctrl_o,
					.load_type_ctrl_o,
					.store_type_ctrl_o,
					.write_en_o,
					.stype_ctrl_o,
					.imm_alu_ctrl_o,
					.jarl_ctrl_o,
					.jal_ctrl_o,
					.branch_ctrl_o,
					.auipc_ctrl_o,
					.lui_ctrl_o,
					.zeroflag_ctrl_o,

					.mdu_op_ctrl_o
				);

		end

		else begin

			controller ctrlr
				(
					.decoded_instr_i(operation),

					.alu_op_ctrl_o,
					.load_type_ctrl_o,
					.store_type_ctrl_o,
					.write_en_o,
					.stype_ctrl_o,
					.imm_alu_ctrl_o,
					.jarl_ctrl_o,
					.jal_ctrl_o,
					.branch_ctrl_o,
					.auipc_ctrl_o,
					.lui_ctrl_o,
					.zeroflag_ctrl_o,
				);

		end
		
	endgenerate

endmodule