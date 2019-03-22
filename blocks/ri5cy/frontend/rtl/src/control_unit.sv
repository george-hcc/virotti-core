`include "decoder.sv"
`include "controller.sv"

//import riscv_defines::*;

module control_unit
	(
		input  logic [WORD_WIDTH-1:0]		instr_i,

		// Saídas de controle
		output logic [ALU_OP_WIDTH-1:0] alu_op_ctrl_o,
		output logic										write_en_ctrl_o,
		output logic										imm_ctrl_o,
		output logic										stype_ctrl_o,
		output logic										upper_ctrl_o,
		output logic										lui_shift_ctrl_o,
		output logic										pc_ula_ctrl_o,
		output logic										load_ctrl_o,
		output logic										store_ctrl_o,
		output logic										branch_ctrl_o,
		output logic										brn_inv_ctrl_o,
		output logic										jal_ctrl_o,
		output logic										jalr_ctrl_o,

		// Sinal de controle ULA/UMD - Só é usado caso UMD exista
		output logic										md_op_ctrl_o		
	);

	decoded_op operation;

	decoder decoder
		(
			.instr_i(instr_i),
			.decoded_op_o(operation)
		);

	generate

		if(RISCV_M_CORE) begin

			controller ctrlr
				(
					.decoded_op_i(operation),
					.write_en_ctrl_o,
					.imm_ctrl_o,
					.stype_ctrl_o,
					.upper_ctrl_o,
					.lui_shift_ctrl_o,
					.pc_ula_ctrl_o,
					.load_ctrl_o,
					.store_ctrl_o,
					.branch_ctrl_o,
					.brn_inv_ctrl_o,
					.jal_ctrl_o,
					.jalr_ctrl_o,
					.md_op_ctrl_o
				);

		end

		else begin

			controller ctrlr
				(
					.decoded_op_i(operation),
					.write_en_ctrl_o,
					.imm_ctrl_o,
					.stype_ctrl_o,
					.upper_ctrl_o,
					.lui_shift_ctrl_o,
					.pc_ula_ctrl_o,
					.load_ctrl_o,
					.store_ctrl_o,
					.branch_ctrl_o,
					.brn_inv_ctrl_o,
					.jal_ctrl_o,
					.jalr_ctrl_o
				);

		end
		
	endgenerate

endmodule