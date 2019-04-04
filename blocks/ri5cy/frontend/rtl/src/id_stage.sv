`include "control_unit.sv"
`include "reg_bank.sv"

//import riscv_defines::*;

module id_stage
	(
		input  logic										clk,

		// Sinais de Datapath
		input  logic [WORD_WIDTH-1:0]		instruction_i,
		input  logic [ADDR_WIDTH-1:0]		reg_waddr_i,
		input  logic [WORD_WIDTH-1:0]		reg_wdata_i,
		output logic [WORD_WIDTH-1:0] 	reg_rdata1_o,
		output logic [WORD_WIDTH-1:0]		reg_rdata2_o,

		// Sinais de ControlPath
		input	 logic										no_op_flag_i,
		input  logic										reg_wen_i,
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

	logic [ADDR_WIDTH-1:0]	rs1_addr;
	logic [ADDR_WIDTH-1:0]	rs2_addr;

	assign rs1_addr = instruction_i[19:15];
	assign rs2_addr = instruction_i[24:20];

	reg_bank regbank 
		(
			.clk								(clk								),
			.read_addr1_i				(rs1_addr						),
			.read_addr2_i				(rs2_addr						),
			.write_addr_i				(reg_waddr_i				),
			.write_data_i				(reg_wdata_i				),
			.write_en_i					(reg_wen_i					),
			.read_data1_o				(reg_rdata1_o				),
			.read_data2_o				(reg_rdata2_o				)
		);

	control_unit ctrl_unit 
		(
			.instruction_i			(instruction_i			),

			.alu_op_ctrl_o			(alu_op_ctrl_o			),
			.load_type_ctrl_o		(load_type_ctrl_o		),
			.store_type_ctrl_o	(store_type_ctrl_o	),
			.write_en_o					(write_en_o					),
			.stype_ctrl_o				(stype_ctrl_o				),
			.imm_alu_ctrl_o			(imm_alu_ctrl_o			),
			.jarl_ctrl_o				(jarl_ctrl_o				),
			.jal_ctrl_o					(jal_ctrl_o					),
			.branch_ctrl_o			(branch_ctrl_o			),
			.auipc_ctrl_o				(auipc_ctrl_o				),
			.lui_ctrl_o					(lui_ctrl_o					),
			.zeroflag_ctrl_o		(zeroflag_ctrl_o		),

			.mdu_op_ctrl_o			(mdu_op_ctrl_o			)
		);

endmodule