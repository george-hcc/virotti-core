`include "control_unit.sv"
`include "reg_bank.sv"

//import riscv_defines::*;

module id_stage
	(
		input  logic										clk,
		input  logic										rst_n,

		// Vindo do estágio IF
		input  logic [WORD_WIDTH-1:0]		instr_i,
		input  logic [WORD_WIDTH-1:0]		pc_plus4_i,

		// Saindo para estágio EX
		output logic [WORD_WIDTH-1:0] 	rdata1_o,
		output logic [WORD_WIDTH-1:0]		rdata2_o,

		// Vindo do estágio WB
		input  logic [ADDR_WIDTH-1:0]		waddr_wb_i,
		input  logic [WORD_WIDTH-1:0]		wdata_wb_i,

		// Sinais de controle
		input  logic 										jal_mux_i, // Checar Necessidade
		input  logic										write_en_i,
		output logic [ALU_OP_WIDTH-1:0]	alu_ctrl_o,
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
		output logic										md_op_ctrl_o
	);

	logic [ADDR_WIDTH-1:0]	addr_rs1;
	logic [ADDR_WIDTH-1:0]	addr_rs2;
	logic [ADDR_WIDTH-1:0]  addr_rd;
	logic [WORD_WIDTH-1:0]	wdata;

	assign addr_rs1 = instr_i[19:15];
	assign addr_rs2 = instr_i[24:20];
	assign addr_rd  = waddr_wb_i;
	assign wdata 		= (jal_mux_i) ? (pc_plus4_i) : (wdata_wb_i);

	reg_bank regbank 
		(
			.clk(clk),
			.rst_n(rst_n),
			.addr_rd1_i(addr_rs1),
			.addr_rd2_i(addr_rs2),
			.addr_wd_i(addr_rd),
			.wd_i(wdata),
			.wen_i(write_en_i),
			.rd1_o(rdata1_o),
			.rd2_o(rdata2_o)
		);

	control_unit ctrl_unit 
		(
			.instr_i(instr_i),
			.alu_op_ctrl_o(alu_ctrl_o),
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

endmodule