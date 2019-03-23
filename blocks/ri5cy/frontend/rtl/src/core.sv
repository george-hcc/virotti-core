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
		output logic 									instr_req_o; 		// Request Ready, precisa estar ativo até gnt_i estiver ativo por um ciclo
		output logic [WORD_WIDTH-1:0]	instr_addr_o; 	// Recebe PC e manda como endereço para memória
		input  logic [WORD_WIDTH-1:0]	instr_rdata_i; 	// Instrução vinda da memória
		input  logic 									instr_rvalid_i; // Quando ativo, rdata_i é valido durante o ciclo
		input  logic 									instr_gnt_i;		// O cache de instrução aceitou a requisição, addr_o pode mudar no próximo cíclo

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
	logic [WORD_WIDTH-1:0] 		instr_IF_ID_w1;
	logic [WORD_WIDTH-1:0]		pc_IF_EX_w1;
	logic [WORD_WIDTH-1:0]		pc_plus4_IF_ID_w1;
	// Saídas do IF_ID
	logic [WORD_WIDTH-1:0] 		instr_IF_ID_w2;
	logic [WORD_WIDTH-1:0]		pc_IF_EX_w2;
	logic [WORD_WIDTH-1:0]		pc_plus4_IF_ID_w2;

	/*************************************/

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

	hazard_control hcu 
		(

		);

	if_stage IF
		(
			.clk								(clk								),
			.rst_n							(rst_n							),

			.instr_req_o				(instr_req_o				),
			.instr_addr_o				(instr_addr_o				),
			.instr_rdata_i			(instr_rdata_i			),
			.instr_rvalid_i			(instr_rvalid_i			),
			.instr_gnt_i				(instr_gnt_i				),

			.fetch_en_i        	(fetch_en_i 				),
			.pc_start_address_i	(pc_start_address_i	),

			.writeback_data_i		(										),
			.program_count_o		(pc_IF_EX_w1				),
			.pc_plus4_o 				(pc_plus4_IF_ID_w1	),
			.instruction_o 			(instr_IF_ID_w1			),

			.hazard_ctrl_i     	(										),
			.branch_pc_ctrl_i		(										),
			.branch_comp_flag_i (										)
		);

	IF_to_ID if_id 
		(
			.clk								(clk								),
			.rst_n							(rst_n							),

			.program_count_i		(pc_IF_EX_w1				),
			.pc_plus4_i 				(pc_plus4_IF_ID_w1	),
			.instruction_i 			(instr_IF_ID_w1			),

			.program_count_o		(pc_IF_EX_w2				),
			.pc_plus4_o 				(pc_plus4_IF_ID_w2	),
			.instruction_o 			(instr_IF_ID_w2			)
		);

	id_stage ID 
		(
			.clk								(clk								),
			.rst_n							(rst_n							),

			.instr_i 						(instr_IF_ID				),
			.pc_plus4_i      		(										),

			.rdata1_o 					(rd1_ID_EX					),
			.rdata2_o 					(rd2_ID_EX					),

			.waddr_wb_i      		(										),
			.wdata_wb_i 				(reg_wb_data_WB_ALL	),

			.jal_mux_i 					(										),
			.write_en_i      		(										),
			.alu_ctrl_o 				(alu_ctrl_ID_EX			),
			.write_en_ctrl_o 		(										),
			.imm_ctrl_o      		(										),
			.stype_ctrl_o    		(										),
			.upper_ctrl_o    		(										),
			.lui_shift_ctrl_o		(										),
			.pc_ula_ctrl_o   		(										),
			.load_ctrl_o     		(										),
			.store_ctrl_o    		(										),
			.branch_ctrl_o   		(										),
			.brn_inv_ctrl_o  		(										),
			.jal_ctrl_o      		(										),
			.jalr_ctrl_o     		(										),

			.md_op_ctrl_o				(										)
		);

	ID_to_EX id_ex
		(
			.clk								(clk								),
			.rst_n							(rst_n							),
		);

	ex_stage EX 
		(
			.reg_rdata1_i				(rd1_ID_EX					),
			.reg_rdata2_i				(rd2_ID_EX					),
			.instruction_i   		(instruction_i			),
			.program_count_i		(										),
			.ex_data_o 					(alu_result_EX_WB		),
			.rdata2_store_o			(										),

			.alu_op_ctrl_i			(alu_ctrl_ID_EX			),
			.stype_mux_i				(stype_ctrl_ID_EX		),
			.utype_mux_i				(utype_ctrl_ID_EX		),
			.jtype_mux_i      	(										),
			.imm_alu_mux_i			(imm_ctrl_ID_EX			),
			.pc_alu_mux_i				(pcalu_ctrl_ID_EX		),
			.branch_alu_mux_i 	(										),
			.zeroflag_inv_i   	(										),
			.branch_comp_flag_o	(										),

			.alu_mdu_mux_i   		(										)
		);

	EX_to_WB ex_wb
		(
			.clk							(clk								),
			.rst_n						(rst_n							),
		);	

	wb_stage WB 
		(
			.alu_result_i			(alu_result_EX_WB		),
			.data_store_i			(data_store_EX_WB		),
			
			.reg_wb_o					(reg_wb_data_WB_ALL	),
			.dmem_data_i			(										),
			.dmem_addr_o			(										),
			
			.loadmem_mux_i		(										)
		);

endmodule