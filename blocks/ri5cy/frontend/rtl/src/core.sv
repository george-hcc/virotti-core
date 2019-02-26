`include "if_stage.sv"
`include "id_stage.sv"
`include "ex_stage.sv"
`include "wb_stage.sv"

//import riscv_defines::*;

module core
	(
		input  logic									clk,
		input  logic									rst_n,

		input  logic [WORD_WIDTH-1:0]	imem_data_i,
		output logic [WORD_WIDTH-1:0]	imem_addr_o,

		input  logic [WORD_WIDTH-1:0] dmem_data_i,
		output logic [WORD_WIDTH-1:0] dmem_addr_o
	);

	// Saídas do IF_STAGE
	logic [WORD_WIDTH-1:0] 		instr_IF_ID;
	logic [WORD_WIDTH-1:0]		pc_IF_EX;
	logic [WORD_WIDTH-1:0]		pc_plus4_IF_ID;

	// Saídas do ID_STAGE
	logic											branch_ctrl_ID_IF;
	logic [WORD_WIDTH-1:0] 		rd1_ID_EX;
	logic [WORD_WIDTH-1:0] 		rd2_ID_EX;
	logic											imm_ctrl_ID_EX;
	logic 								 		stype_ctrl_ID_EX;
	logic											utype_ctrl_ID_EX;
	logic											bypass_ctrl_ID_EX;
	logic											pcalu_ctrl_ID_EX;
	logic [ALU_OP_WIDTH-1:0]	alu_ctrl_ID_EX;
	logic											read_dmem_ID_WB;

	// Saídas do EX_STAGE
	logic [WORD_WIDTH-1:0] 		alu_result_EX_WB;
	logic [WORD_WIDTH-1:0]		data_store_EX_WB;

	// Saídas do WB_STAGE
	logic [WORD_WIDTH-1:0]		reg_wb_data_WB_ALL;

	if_stage IF
		(
			.clk(clk),
			.rst_n(rst_n),

			.instruction_i(imem_data_i),
			.instr_wb_i(reg_wb_data_WB_ALL),
			.pc_o(pc_IF_EX),
			.pc_plus4_o(pc_plus4_IF_ID)
			.instruction_o(instr_IF_ID),

			.branch_mux_i(branch_ctrl_ID_IF)
		);

	id_stage ID 
		(
			.clk(clk),
			.rst_n(rst_n),

			.instr_i(instr_IF_ID),
			.rdata1_o(rd1_ID_EX),
			.rdata2_o(rd2_ID_EX),
			.wdata_wb_i(reg_wb_data_WB_ALL),
			.neg_mux_ctrl_o(neg_ctrl_ID_EX),
			.alu_ctrl_o(alu_ctrl_ID_EX)
		);

	ex_stage EX 
		(
			.reg_rdata1_i(rd1_ID_EX),
			.reg_rdata2_i(rd2_ID_EX),
			.itype_imm_i(instr_IF_ID[31:20]),
			.stype_imm_i({instr_IF_ID[31:25], instr_IF_ID[11:7]}),
			.upper_imm_i(instr_IF_ID[31:12]),
			.program_count_i(pc_IF_EX),
			.ex_data_o(alu_result_EX_WB),
			.rdata2_store_o(data_store_EX_WB),

			.imm_mux_i(imm_ctrl_ID_EX),
			.stype_mux_i(stype_ctrl_ID_EX),
			.utype_mux_i(utype_ctrl_ID_EX),
			.bypass_alu_mux_i(bypass_ctrl_ID_EX),
			.pc_alu_mux_i(pcalu_ctrl_ID_EX),
			.alu_op_ctrl_i(alu_ctrl_ID_EX)
		);

	wb_stage WB 
		(
			.alu_result_i(alu_result_EX_WB),
			.data_store_i(data_store_EX_WB),
			.reg_wb_o(reg_wb_data_WB_ALL),
			.dmem_data_i(dmem_data_i),
			.dmem_addr_o(dmem_addr_o),
			.read_dmem(read_dmem_ID_WB)
		);		

endmodule