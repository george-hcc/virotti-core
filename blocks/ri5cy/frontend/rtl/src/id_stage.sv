`include "control_unit.sv"
`include "reg_bank.sv"

//import riscv_defines::*;

module id_stage
	(
		input  logic										clk,
		input  logic										rst_n,

		// Vindo do estágio IF
		input  logic [WORD_WIDTH-1:0]		instruction_i,
		input  logic [WORD_WIDTH-1:0]		pc_plus4_i,

		// Saindo para estágio EX
		output logic [WORD_WIDTH-1:0] 	rdata1_o,
		output logic [WORD_WIDTH-1:0]		rdata2_o,

		// Vindo do estágio WB
		input  logic [ADDR_WIDTH-1:0]		waddr_wb_i,
		input  logic [WORD_WIDTH-1:0]		wdata_wb_i,

		// Sinais de controle
		input  logic										write_en_i,
		output logic [ALU_OP_WIDTH-1:0]	alu_op_ctrl_o,
		output logic [2:0]							load_type_ctrl_o,
		output logic [1:0]							store_type_ctrl_o,
		output logic										write_en_o,
		output logic										stype_ctrl_o,
		output logic										utype_ctrl_o,
		output logic										jtype_ctrl_o,
		output logic										imm_alu_ctrl_o,
		output logic										auipc_alu_ctrl_o,
		output logic										branch_alu_ctrl_o,
		output logic										zeroflag_ctrl_o,
		output logic										branch_pc_ctrl_o,

		// Sinal de controle ULA/UMD - Só é usado caso UMD exista
		output logic										mdu_ctrl_o
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
			.instruction_i(instruction_i),

			.alu_op_ctrl_o,
			.load_type_ctrl_o,
			.store_type_ctrl_o,
			.write_en_o,
			.stype_ctrl_o,
			.utype_ctrl_o,
			.jtype_ctrl_o,
			.imm_alu_ctrl_o,
			.auipc_alu_ctrl_o,
			.branch_alu_ctrl_o,
			.zeroflag_ctrl_o,
			.branch_pc_ctrl_o,

			.md_op_ctrl_o
		);

endmodule