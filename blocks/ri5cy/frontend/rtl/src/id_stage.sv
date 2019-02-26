`include "control_unit.sv"
`include "reg_bank.sv"

//import riscv_defines::*;

module id_stage
	(
		input  logic										clk,
		input  logic										rst_n,

		// Vindo do estágio IF
		input  logic [WORD_WIDTH-1:0]		instr_if_i,

		// Saindo para estágio EX
		output logic [WORD_WIDTH-1:0] 	rdata1_o,
		output logic [WORD_WIDTH-1:0]		rdata2_o,

		// Vindo do estágio WB
		input  logic [WORD_WIDTH-1:0]		wdata_wb_i,

		// Sinais de controle
		output logic										neg_mux_ctrl_o,
		output logic [ALU_OP_WIDTH-1:0]	alu_ctrl_o
	);

	logic										jal_flag;
	logic 									regwrite_en;
	logic [WORD_WIDTH-1:0]	wdata;

	assign wdata = (jal_flag) ? (pc_plus4) : (wdata_wb_i);

	reg_bank regbank 
		(
			.clk(clk),
			.rst_n(rst_n),
			.addr_rd1_i(instr_if_i[19:15]),
			.addr_rd2_i(instr_if_i[24:20]),
			.addr_wd_i(instr_if_i[11:7]),
			.wd_i(wdata),
			.wen_i(regwrite_en),
			.rd1_o(rdata1_o),
			.rd2_o(rdata2_o)
		);

	control_unit ctrl_unit 
		(

		);

/*	controller controller
		(
			.instr_i(instr_if_i),
			.neg_mux_ctrl_o(neg_mux_ctrl_o),
			.alu_op_ctrl_o(alu_ctrl_o),
			.regwrite_en_o(regwrite_en)
		);

*/

endmodule