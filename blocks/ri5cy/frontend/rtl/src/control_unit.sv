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
		output logic										jalr_ctrl_o
	);

	logic [DCODE_WIDTH-1:0] decoded_op;

	decoder decoder
		(
			.instr_i(instr_i),
			.decoded_op_o(decoded_op)
		);

	controller ctrlr
		(
			.decoded_op_i(decoded_op),
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

endmodule