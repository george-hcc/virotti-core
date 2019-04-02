`include "hazard_control.sv"
`include "if_stage.sv"
`include "id_stage.sv"
`include "ex_stage.sv"
`include "wb_stage.sv"

//import riscv_defines::*;

module core
	(
		input  logic									clk,
		input  logic									rst_n,

		// Interface da Memória de Instruções
		output logic 									instr_req_o,		// Request Ready, precisa estar ativo até gnt_i estiver ativo por um ciclo
		output logic [WORD_WIDTH-1:0]	instr_addr_o,		// Recebe PC e manda como endereço para memória
		input  logic [WORD_WIDTH-1:0]	instr_rdata_i,	// Instrução vinda da memória
		input  logic 									instr_rvalid_i,	// Quando ativo, rdata_i é valido durante o ciclo
		input  logic 									instr_gnt_i,		// O cache de instrução aceitou a requisição, addr_o pode mudar no próximo cíclo

		// Interface da Memória de Dados
		output logic									data_req_o,
		output logic [WORD_WIDTH-1:0]	data_addr_o,
		output logic 									data_we_o,
		output logic [3:0]						data_be_o,
		output logic [WORD_WIDTH-1:0]	data_wdata_o,
		input  logic [WORD_WIDTH-1:0] data_rdata_i,
		input  logic									data_rvalid_i,
		input  logic									data_gnt_i,

		// Interface de Controle do Core
		input  logic									fetch_en_i,
		input	 logic [WORD_WIDTH-1:0]	pc_start_addr_i,
		input  logic [4:0]						irq_id_i,
		input  logic									irq_event_i,
		input	 logic									socctrl_mmc_exception_i
	);

	/*********Saídas do IF_STAGE*********/
	// Entradas do IF_ID
	logic [WORD_WIDTH-1:0]		pc_plus4_IF_ID_w1;
	logic											no_op_IF_ID_w1;
	logic [WORD_WIDTH-1:0] 		instr_IF_EX_w1;
	logic [WORD_WIDTH-1:0]		pc_IF_EX_w1;
	// Saídas do IF_ID
	logic [WORD_WIDTH-1:0]		pc_plus4_IF_ID_w2;
	logic											no_op_IF_ID_w2;
	logic [WORD_WIDTH-1:0] 		instr_IF_EX_w2;
	logic [WORD_WIDTH-1:0]		pc_IF_EX_w2;
	// Saídas do ID_EX
	logic [WORD_WIDTH-1:0] 		instr_IF_EX_w3;
	logic [WORD_WIDTH-1:0]		pc_IF_EX_w3;
	/************************************/

	/*********Saídas do ID_STAGE*********/
	// Entradas do ID_EX
	logic	[WORD_WIDTH-1:0]		rdata1_ID_EX_w1;
	logic	[WORD_WIDTH-1:0]		rdata2_ID_EX_w1;
	logic [ALU_OP_WIDTH-1:0]	alu_op_ID_EX_w1;
	logic 										stype_ctrl_ID_EX_w1;
	logic 										utype_ctrl_ID_EX_w1;
	logic 										jtype_ctrl_ID_EX_w1;
	logic 										imm_alu_ctrl_ID_EX_w1;
	logic 										auipc_alu_ctrl_ID_EX_w1;
	logic 										branch_alu_ctrl_ID_EX_w1;
	logic 										zeroflag_ctrl_ID_EX_w1;
	logic [2:0]								load_type_ID_WB_w1;
	logic [1:0]								store_type_ID_WB_w1;
	logic 										write_en_ID_WB_w1;
	logic 										branch_pc_ctrl_ID_WB_w1;
	// Saídas do ID_EX	
	logic	[WORD_WIDTH-1:0]		rdata1_ID_EX_w2;
	logic	[WORD_WIDTH-1:0]		rdata2_ID_EX_w2;
	logic [ALU_OP_WIDTH-1:0]	alu_op_ID_EX_w2;
	logic 										stype_ctrl_ID_EX_w2;
	logic 										utype_ctrl_ID_EX_w2;
	logic 										jtype_ctrl_ID_EX_w2;
	logic 										imm_alu_ctrl_ID_EX_w2;
	logic 										auipc_alu_ctrl_ID_EX_w2;
	logic 										branch_alu_ctrl_ID_EX_w2;
	logic 										zeroflag_ctrl_ID_EX_w2;
	logic [2:0]								load_type_ID_WB_w2;
	logic [1:0]								store_type_ID_WB_w2;
	logic 										write_en_ID_WB_w2;
	logic 										branch_pc_ctrl_ID_WB_w2;
	// Saídas do EX_WB
	logic	[WORD_WIDTH-1:0]		rdata2_ID_EX_w3;
	logic [2:0]								load_type_ID_WB_w3;
	logic [1:0]								store_type_ID_WB_w3;
	logic 										write_en_ID_WB_w3;
	logic 										branch_pc_ctrl_ID_WB_w3;
	/************************************/

	/*********Saídas do EX_STAGE*********/
	// Entradas do EX_WB
	logic [WORD_WIDTH-1:0]		ex_data_EX_WB_w1;
	logic [WORD_WIDTH-1:0]		store_data_EX_WB_w1;
	logic											comp_flag_EX_WB_w1;
	logic	[ADDR_WIDTH-1:0]		reg_waddr_EX_WB_w1;
	// Saídas do EX_WB
	logic [WORD_WIDTH-1:0]		ex_data_EX_WB_w2;
	logic [WORD_WIDTH-1:0]		store_data_EX_WB_w2;
	logic											comp_flag_EX_WB_w2;
	logic	[ADDR_WIDTH-1:0]		reg_waddr_EX_WB_w2;
	/************************************/

	/*********Saídas do EX_STAGE*********/
	logic [WORD_WIDTH-1:0]		writeback_data_WB_w;
	/************************************/

	/*****Saídas do Pipeline Control*****/
	logic		                  if_to_id_stall_w,
	logic		                  id_to_ex_stall_w,
	logic		                  ex_to_wb_stall_w,
	logic		                  if_to_id_clear_w,
	logic		                  id_to_ex_clear_w,
	logic		                  ex_to_wb_clear_w,
	logic                  		fwrd_opA_type1_w,
	logic                  		fwrd_opA_type2_w,
	logic                  		fwrd_opB_type1_w,
	logic                  		fwrd_opB_type2_w
	/************************************/

	if_stage IF
		(
			.clk								(clk											),
			.rst_n							(rst_n										),

			.instr_req_o				(instr_req_o							),
			.instr_addr_o				(instr_addr_o							),
			.instr_rdata_i			(instr_rdata_i						),
			.instr_rvalid_i			(instr_rvalid_i						),
			.instr_gnt_i				(instr_gnt_i							),

			.fetch_en_i        	(fetch_en_i 							),
			.pc_start_address_i	(pc_start_address_i				),

			.writeback_data_i		(writeback_data_WB_w			),
			.program_count_o		(pc_IF_EX_w1							),
			.pc_plus4_o 				(pc_plus4_IF_ID_w1				),
			.instruction_o 			(instr_IF_EX_w1						),

			.no_op_flag_o     	(no_op_IF_ID_w1						),
			.branch_pc_ctrl_i		(branch_pc_ctrl_ID_WB_w3	),
			.branch_comp_flag_i (comp_flag_EX_WB_w2				)
		);

	IF_to_ID if_id 
		(
			.clk								(clk											),
			.rst_n							(rst_n										),
			.stall_ctrl     		(if_to_id_stall_w					),
			.clear_ctrl     		(if_to_id_clear_w					),

			.program_count_i		(pc_IF_EX_w1							),
			.pc_plus4_i 				(pc_plus4_IF_ID_w1				),
			.instruction_i 			(instr_IF_EX_w1						),
			.no_op_flag_i				(no_op_IF_ID_w1						),

			.program_count_o		(pc_IF_EX_w2							),
			.pc_plus4_o 				(pc_plus4_IF_ID_w2				),
			.instruction_o 			(instr_IF_EX_w2						),
			.no_op_flag_o				(no_op_IF_ID_w2						)
		);

	id_stage ID 
		(
			.clk								(clk											),
			.rst_n							(rst_n										),

			.instruction_i 			(instr_IF_EX_w2						),
			.pc_plus4_i      		(pc_plus4_IF_ID_w2				),

			.rdata1_o 					(rdata1_ID_EX_w1					),
			.rdata2_o 					(rdata2_ID_EX_w1					),

			.waddr_wb_i      		(reg_waddr_EX_WB_w2				),
			.wdata_wb_i 				(writeback_data_WB_w			),

			.no_op_flag_i				(no_op_IF_ID_w2						),
			.write_en_i					(write_en_ID_WB_w3				),
			.alu_op_ctrl_o			(alu_op_ID_EX_w1					),
			.load_type_ctrl_o		(load_type_ID_WB_w1				),
			.store_type_ctrl_o	(store_type_ID_WB_w1			),
			.write_en_o					(write_en_ID_WB_w1 				),
			.stype_ctrl_o				(stype_ctrl_ID_EX_w1			),
			.utype_ctrl_o				(utype_ctrl_ID_EX_w1			),
			.jtype_ctrl_o				(jtype_ctrl_ID_EX_w1			),
			.imm_alu_ctrl_o			(imm_alu_ctrl_ID_EX_w1		),
			.auipc_alu_ctrl_o		(auipc_alu_ctrl_ID_EX_w1	),
			.branch_alu_ctrl_o	(branch_alu_ctrl_ID_EX_w1	),
			.zeroflag_ctrl_o		(zeroflag_ctrl_ID_EX_w1		),
			.branch_pc_ctrl_o		(branch_pc_ctrl_ID_WB_w1	),

			.mdu_op_ctrl_o				(					)
		);

	ID_to_EX id_ex
		(
			.clk								(clk											),
			.rst_n							(rst_n										),
			.stall_ctrl     		(id_to_ex_stall_w					),
			.clear_ctrl       	(id_to_ex_clear_w					),

			.program_count_i		(pc_IF_EX_w2							),
			.instruction_i 			(instr_IF_EX_w2						),
			.rdata1_i 					(rdata1_ID_EX_w1					),
			.rdata2_i 					(rdata2_ID_EX_w1					),			
			.alu_op_ctrl_i			(alu_op_ID_EX_w1					),
			.write_en_i					(write_en_ID_WB_w1 				),
			.stype_ctrl_i				(stype_ctrl_ID_EX_w1			),
			.utype_ctrl_i				(utype_ctrl_ID_EX_w1			),
			.jtype_ctrl_i				(jtype_ctrl_ID_EX_w1			),
			.imm_alu_ctrl_i			(imm_alu_ctrl_ID_EX_w1		),
			.auipc_alu_ctrl_i		(auipc_alu_ctrl_ID_EX_w1	),
			.branch_alu_ctrl_i	(branch_alu_ctrl_ID_EX_w1	),
			.zeroflag_ctrl_i		(zeroflag_ctrl_ID_EX_w1		),
			.load_type_ctrl_i		(load_type_ID_WB_w1				),
			.store_type_ctrl_i	(store_type_ID_WB_w1			),
			.branch_pc_ctrl_i		(branch_pc_ctrl_ID_WB_w1	),

			.program_count_o		(pc_IF_EX_w3							),
			.instruction_o 			(instr_IF_EX_w3						),			
			.rdata1_o 					(rdata1_ID_EX_w2					),
			.rdata2_o 					(rdata2_ID_EX_w2					),
			.alu_op_ctrl_o			(alu_op_ID_EX_w2					),
			.load_type_ctrl_o		(load_type_ID_WB_w2				),
			.store_type_ctrl_o	(store_type_ID_WB_w2			),
			.write_en_o					(write_en_ID_WB_w2 				),
			.jtype_ctrl_o				(jtype_ctrl_ID_EX_w2			),
			.imm_alu_ctrl_o			(imm_alu_ctrl_ID_EX_w2		),
			.auipc_alu_ctrl_o		(auipc_alu_ctrl_ID_EX_w2	),
			.branch_alu_ctrl_o	(branch_alu_ctrl_ID_EX_w2	),
			.zeroflag_ctrl_o		(zeroflag_ctrl_ID_EX_w2		),
			.stype_ctrl_o				(stype_ctrl_ID_EX_w2			),
			.utype_ctrl_o				(utype_ctrl_ID_EX_w2			),
			.branch_pc_ctrl_o		(branch_pc_ctrl_ID_WB_w2	),

			.fwrd_type1_data_i	(ex_data_EX_WB_w1					),
    	.fwrd_type2_data_i	(writeback_data_WB_w			),
    	.fwrd_opA_type1_i		(fwrd_opA_type1_w					),
    	.fwrd_opA_type2_i		(fwrd_opA_type2_w					),
    	.fwrd_opB_type1_i		(fwrd_opB_type1_w					),
    	.fwrd_opB_type2_i		(fwrd_opB_type2_w					),

			.mdu_op_ctrl_i			(),
			.mdu_op_ctrl_o			()
		);

	ex_stage EX 
		(
			.reg_rdata1_i				(rdata1_ID_EX_w2					),
			.reg_rdata2_i				(rdata2_ID_EX_w2					),
			.instruction_i   		(instr_IF_EX_w3						),
			.program_count_i		(pc_IF_EX_w3							),
			.ex_data_o 					(ex_data_EX_WB_w1					),
			.reg_waddr_o       	(reg_waddr_EX_WB_w1				),

			.alu_op_ctrl_i			(alu_op_ID_EX_w2					),
			.stype_mux_i				(stype_ctrl_ID_EX_w2			),
			.utype_mux_i				(utype_ctrl_ID_EX_w2			),
			.jtype_mux_i      	(jtype_ctrl_ID_EX_w2			),
			.imm_alu_mux_i			(imm_alu_ctrl_ID_EX_w2		),
			.pc_alu_mux_i				(auipc_alu_ctrl_ID_EX_w2	),
			.branch_alu_mux_i 	(branch_alu_ctrl_ID_EX_w2	),
			.zeroflag_inv_i   	(zeroflag_ctrl_ID_EX_w2		),
			.branch_comp_flag_o	(comp_flag_EX_WB_w1				),

			.alu_mdu_mux_i   		(					)
		);

	EX_to_WB ex_wb
		(
			.clk								(clk											),
			.rst_n							(rst_n										),
			.stall_ctrl     		(ex_to_wb_stall_w					),
			.clear_ctrl      		(ex_to_wb_clear_w					),

			.store_data_i				(rdata2_ID_EX_w2					),			
			.load_type_i				(load_type_ID_WB_w2				),
			.store_type_i				(store_type_ID_WB_w2			),
			.write_en_i					(write_en_ID_WB_w2				),
			.branch_pc_ctrl_i		(branch_pc_ctrl_ID_WB_w2	),
			.ex_data_i					(ex_data_EX_WB_w1					),
			.store_data_i				(store_data_EX_WB_w1			),
			.comp_flag_i				(comp_flag_EX_WB_w1				),
			.reg_waddr_i       	(reg_waddr_EX_WB_w1				),

			.store_data_o				(rdata2_ID_EX_w3					),
			.load_type_o				(load_type_ID_WB_w3				),
			.store_type_o				(store_type_ID_WB_w3			),
			.write_en_o					(write_en_ID_WB_w3				),
			.branch_pc_ctrl_o		(branch_pc_ctrl_ID_WB_w3	),
			.ex_data_o					(ex_data_EX_WB_w2					),
			.store_data_o				(store_data_EX_WB_w2			),
			.comp_flag_o				(comp_flag_EX_WB_w2				),
			.reg_waddr_o       	(reg_waddr_EX_WB_w2				),
		);

	wb_stage WB 
		(
			.ex_data_i    			(ex_data_EX_WB_w2					),
			.store_data_i 			(rdata2_ID_EX_w3					),
			.writeback_data_o 	(writeback_data_WB_w			),

			.data_req_o   			(data_req_o								),
			.data_addr_o  			(data_addr_o							),
			.data_we_o    			(data_we_o								),
			.data_be_o    			(data_be_o								),
			.data_wdata_o 			(data_wdata_o							),
			.data_rdata_i 			(data_rdata_i							),
			.data_rvalid_i			(data_rvalid_i						),
			.data_gnt_i					(data_gnt_i								),

			.load_type_i 				(load_type_ID_WB_w3				),
			.store_type_i 			(store_type_ID_WB_w3			)
		);

		pcu pipeline_control_unit 
		(
			.clk								(clk											),
    	.rst_n							(rst_n										),

    	.instr_type_i				(													),
    	.read_addr1_i				(													),
    	.read_addr2_i				(													),
    	.write_addr_i				(													),
    	.write_en_i					(													),
    	
    	.if_to_id_stall_o		(if_to_id_stall_w					),
    	.id_to_ex_stall_o		(id_to_ex_stall_w					),
    	.ex_to_wb_stall_o		(ex_to_wb_stall_w					),
    	.if_to_id_clear_o		(if_to_id_clear_w					),
    	.id_to_ex_clear_o		(id_to_ex_clear_w					),
    	.ex_to_wb_clear_o		(ex_to_wb_clear_w					),
    	.fwrd_opA_type1_o		(fwrd_opA_type1_w					),
    	.fwrd_opA_type2_o		(fwrd_opA_type2_w					),
    	.fwrd_opB_type1_o		(fwrd_opB_type1_w					),
    	.fwrd_opB_type2_o		(fwrd_opB_type2_w					)
		);

endmodule