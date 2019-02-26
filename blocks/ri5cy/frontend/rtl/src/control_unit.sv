`include "decoder.sv"
`include "controller.sv"

//import riscv_defines::*;

module control_unit
	(
		input  logic [WORD_WIDTH-1:0]		instr_i,

		// Sinais ULA
		output logic										neg_mux_ctrl_o,
		output logic [ALU_OP_WIDTH-1:0] alu_op_ctrl_o,

		output logic										regwrite_en_o
	);

	decoder decoder
		(

		);

	controller ctrlr
		(

		);

endmodule