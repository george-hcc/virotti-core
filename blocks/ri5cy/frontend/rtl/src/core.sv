//////////////////////////////////////////////////////////////////////////////////////////////
// Autor:         	George Camboim - george.camboim@embedded.ufcg.edu.br         						//
//																																													//
// Nome do Design:  Core																	                  								//
// Nome do Projeto: MiniSoc                                                    							//
// Linguagem:       SystemVerilog                                              							//
//                                                                            							//
// Descrição:    		Processador Pipeline RISCV de 32 bits com instruções Base-I 						//
//									Instruções Base-M de multiplicação e divisão podem ser adicionadas			//
//                                                                            							//
//////////////////////////////////////////////////////////////////////////////////////////////

import riscv_defines::*;
import ctrl_typedefs::*;

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
	logic [WORD_WIDTH-1:0] 		instr_IF_EX_w1;
	logic [WORD_WIDTH-1:0]		pc_IF_EX_w1;
	logic											no_op_IF_ID_w1;
	// Saídas do IF_ID
	logic [WORD_WIDTH-1:0] 		instr_IF_EX_w2;
	logic [WORD_WIDTH-1:0]		pc_IF_EX_w2;
	logic											no_op_IF_ID_w2;
	// Saídas do ID_EX
	logic [WORD_WIDTH-1:0] 		instr_IF_EX_w3;
	logic [WORD_WIDTH-1:0]		pc_IF_EX_w3;
	/************************************/

	/*********Saídas do ID_STAGE*********/
	// Entradas do ID_EX
	logic	[WORD_WIDTH-1:0]		rdata1_ID_EX_w1;
	logic	[WORD_WIDTH-1:0]		rdata2_ID_EX_w1;
	logic [ALU_OP_WIDTH-1:0]	alu_op_ID_EX_w1;
	logic [2:0]								load_type_ID_WB_w1;
	logic [1:0]								store_type_ID_WB_w1;
	logic 										write_en_ID_WB_w1;
	logic 										stype_ctrl_ID_EX_w1;
	logic 										imm_alu_ctrl_ID_EX_w1;
	logic 										jarl_ctrl_ID_EX_w1;
	logic 										jal_ctrl_ID_EX_w1;
	logic 										branch_ctrl_ID_EX_w1;
	logic 										auipc_ctrl_ID_EX_w1;
	logic 										lui_ctrl_ID_EX_w1;
	logic 										zeroflag_ctrl_ID_EX_w1;
	// Saídas do ID_EX
	logic	[WORD_WIDTH-1:0]		rdata1_ID_EX_w2;
	logic	[WORD_WIDTH-1:0]		rdata2_ID_EX_w2;
	logic [ALU_OP_WIDTH-1:0]	alu_op_ID_EX_w2;
	logic [2:0]								load_type_ID_WB_w2;
	logic [1:0]								store_type_ID_WB_w2;
	logic 										write_en_ID_WB_w2;
	logic 										stype_ctrl_ID_EX_w2;
	logic 										imm_alu_ctrl_ID_EX_w2;
	logic 										jarl_ctrl_ID_EX_w2;
	logic 										jal_ctrl_ID_EX_w2;
	logic 										branch_ctrl_ID_EX_w2;
	logic 										auipc_ctrl_ID_EX_w2;
	logic 										lui_ctrl_ID_EX_w2;
	logic 										zeroflag_ctrl_ID_EX_w2;
	// Saídas do EX_WB
	logic	[WORD_WIDTH-1:0]		rdata2_ID_EX_w3;
	logic [2:0]								load_type_ID_WB_w3;
	logic [1:0]								store_type_ID_WB_w3;
	logic 										write_en_ID_WB_w3;
	// Saídas para_PCU
	decoded_opcode						instr_type_ID_PCU_w;
	/************************************/

	/*********Saídas do EX_STAGE*********/
	// Entradas do EX_WB
	logic [WORD_WIDTH-1:0]		wb_data_EX_WB_w1;
	logic	[ADDR_WIDTH-1:0]		reg_waddr_EX_WB_w1;
	// Saídas do EX_WB
	logic [WORD_WIDTH-1:0]		wb_data_EX_WB_w2;
	logic	[ADDR_WIDTH-1:0]		reg_waddr_EX_WB_w2;
	// Saídas para IF
	logic [WORD_WIDTH-1:0]		branch_addr_EX_IF_w;
	logic											branch_taken_EX_IF_w;
	/************************************/

	/*********Saídas do EX_STAGE*********/
	logic [WORD_WIDTH-1:0]		reg_wdata_WB_ID_w;
	/************************************/

	/*****Saídas do Pipeline Control*****/
	logic											fetch_stall_w;
	logic		                  if_to_id_stall_w;
	logic		                  id_to_ex_stall_w;
	logic		                  ex_to_wb_stall_w;
	logic		                  if_to_id_clear_w;
	logic		                  id_to_ex_clear_w;
	logic		                  ex_to_wb_clear_w;
	logic                  		fwrd_opA_type1_w;
	logic                  		fwrd_opA_type2_w;
	logic                  		fwrd_opB_type1_w;
	logic                  		fwrd_opB_type2_w;
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
			.pc_start_address_i	(pc_start_addr_i					),

			.pc_branch_addr_i		(branch_addr_EX_IF_w			),
			.instruction_o 			(instr_IF_EX_w1						),
			.program_count_o		(pc_IF_EX_w1							),

			.fetch_stall_i			(fetch_stall_w						),
			.branch_pc_ctrl_i		(branch_taken_EX_IF_w			),
			.no_op_flag_o     	(no_op_IF_ID_w1						)
		);

	IF_to_ID if_id 
		(
			.clk								(clk											),
			.stall_ctrl     		(if_to_id_stall_w					),
			.clear_ctrl     		(if_to_id_clear_w					),

			.instruction_i 			(instr_IF_EX_w1						),
			.program_count_i		(pc_IF_EX_w1							),
			.no_op_flag_i				(no_op_IF_ID_w1						),

			.instruction_o 			(instr_IF_EX_w2						),
			.program_count_o		(pc_IF_EX_w2							),
			.no_op_flag_o				(no_op_IF_ID_w2						)
		);

	id_stage ID 
		(
			.clk								(clk											),

			.instruction_i			(instr_IF_EX_w2						),
			.reg_waddr_i				(reg_waddr_EX_WB_w2				),
			.reg_wdata_i				(reg_wdata_WB_ID_w				),
			.reg_rdata1_o				(rdata1_ID_EX_w1					),
			.reg_rdata2_o				(rdata2_ID_EX_w1					),

			.no_op_flag_i     	(no_op_IF_ID_w2						),
			.reg_wen_i        	(write_en_ID_WB_w3				),
			.alu_op_ctrl_o			(alu_op_ID_EX_w1					),
			.load_type_ctrl_o		(load_type_ID_WB_w1				),
			.store_type_ctrl_o	(store_type_ID_WB_w1			),
			.write_en_o					(write_en_ID_WB_w1				),
			.stype_ctrl_o				(stype_ctrl_ID_EX_w1			),
			.imm_alu_ctrl_o			(imm_alu_ctrl_ID_EX_w1		),
			.jarl_ctrl_o				(jarl_ctrl_ID_EX_w1				),
			.jal_ctrl_o					(jal_ctrl_ID_EX_w1				),
			.branch_ctrl_o			(branch_ctrl_ID_EX_w1			),
			.auipc_ctrl_o				(auipc_ctrl_ID_EX_w1			),
			.lui_ctrl_o					(lui_ctrl_ID_EX_w1				),
			.zeroflag_ctrl_o		(zeroflag_ctrl_ID_EX_w1		),

			.instr_type_o     	(instr_type_ID_PCU_w			),

			.mdu_op_ctrl_o			(					)
		);

	ID_to_EX id_ex
		(
			.clk								(clk											),
			.stall_ctrl     		(id_to_ex_stall_w					),
			.clear_ctrl       	(id_to_ex_clear_w					),

			.program_count_i		(pc_IF_EX_w2							),
			.instruction_i 			(instr_IF_EX_w2						),
			.rdata1_i 					(rdata1_ID_EX_w1					),
			.rdata2_i 					(rdata2_ID_EX_w1					),
			.alu_op_ctrl_i			(alu_op_ID_EX_w1					),
			.load_type_ctrl_i		(load_type_ID_WB_w1				),
			.store_type_ctrl_i	(store_type_ID_WB_w1			),
			.write_en_i					(write_en_ID_WB_w1				),
			.stype_ctrl_i				(stype_ctrl_ID_EX_w1			),
			.imm_alu_ctrl_i			(imm_alu_ctrl_ID_EX_w1		),
			.jarl_ctrl_i				(jarl_ctrl_ID_EX_w1				),
			.jal_ctrl_i					(jal_ctrl_ID_EX_w1				),
			.branch_ctrl_i			(branch_ctrl_ID_EX_w1			),
			.auipc_ctrl_i				(auipc_ctrl_ID_EX_w1			),
			.lui_ctrl_i					(lui_ctrl_ID_EX_w1				),
			.zeroflag_ctrl_i		(zeroflag_ctrl_ID_EX_w1		),

			.program_count_o		(pc_IF_EX_w3							),
			.instruction_o 			(instr_IF_EX_w3						),			
			.rdata1_o 					(rdata1_ID_EX_w2					),
			.rdata2_o 					(rdata2_ID_EX_w2					),
			.alu_op_ctrl_o			(alu_op_ID_EX_w2					),
			.load_type_ctrl_o		(load_type_ID_WB_w2				),
			.store_type_ctrl_o	(store_type_ID_WB_w2			),
			.write_en_o					(write_en_ID_WB_w2				),
			.stype_ctrl_o				(stype_ctrl_ID_EX_w2			),
			.imm_alu_ctrl_o			(imm_alu_ctrl_ID_EX_w2		),
			.jarl_ctrl_o				(jarl_ctrl_ID_EX_w2				),
			.jal_ctrl_o					(jal_ctrl_ID_EX_w2				),
			.branch_ctrl_o			(branch_ctrl_ID_EX_w2			),
			.auipc_ctrl_o				(auipc_ctrl_ID_EX_w2			),
			.lui_ctrl_o					(lui_ctrl_ID_EX_w2				),
			.zeroflag_ctrl_o		(zeroflag_ctrl_ID_EX_w2		),

			.fwrd_type1_data_i	(wb_data_EX_WB_w1					),
    	.fwrd_type2_data_i	(reg_wdata_WB_ID_w				),
    	.fwrd_opA_type1_i		(fwrd_opA_type1_w					),
    	.fwrd_opA_type2_i		(fwrd_opA_type2_w					),
    	.fwrd_opB_type1_i		(fwrd_opB_type1_w					),
    	.fwrd_opB_type2_i		(fwrd_opB_type2_w					)
		);

	ex_stage EX 
		(
			.reg_rdata1_i				(rdata1_ID_EX_w2					),
			.reg_rdata2_i				(rdata2_ID_EX_w2					),
			.instruction_i   		(instr_IF_EX_w3						),
			.program_count_i		(pc_IF_EX_w3							),
			.wb_data_o 					(ex_data_EX_WB_w1					),
			.reg_waddr_o       	(reg_waddr_EX_WB_w1				),
			.pc_branch_addr_o		(branch_addr_EX_IF_w			),

			.alu_op_ctrl_i			(alu_op_ID_EX_w2					),
			.stype_imm_mux_i		(stype_ctrl_ID_EX_w2			),
			.auipc_flag_i				(auipc_ctrl_ID_EX_w2			),
			.imm_alu_mux_i			(imm_alu_ctrl_ID_EX_w2		),
			.jarl_flag_i     		(jarl_ctrl_ID_EX_w2				),
			.jal_flag_i 				(jal_ctrl_ID_EX_w2 				),
			.branch_flag_i   		(branch_ctrl_ID_EX_w2			),
			.lui_alu_bypass_i 	(lui_ctrl_ID_EX_w2				),
			.zeroflag_inv_i   	(zeroflag_ctrl_ID_EX_w2		),
			.pc_branch_ctrl_o		(branch_taken_EX_IF_w			)
		);

	EX_to_WB ex_wb
		(
			.clk								(clk											),
			.stall_ctrl     		(ex_to_wb_stall_w					),
			.clear_ctrl      		(ex_to_wb_clear_w					),
		
			.load_type_i				(load_type_ID_WB_w2				),
			.store_type_i				(store_type_ID_WB_w2			),
			.write_en_i					(write_en_ID_WB_w2				),
			.wb_data_i					(wb_data_EX_WB_w1					),
			.store_data_i				(store_data_EX_WB_w1			),
			.reg_waddr_i       	(reg_waddr_EX_WB_w1				),

			.load_type_o				(load_type_ID_WB_w3				),
			.store_type_o				(store_type_ID_WB_w3			),
			.write_en_o					(write_en_ID_WB_w3				),
			.wb_data_o					(wb_data_EX_WB_w2					),
			.store_data_o				(store_data_EX_WB_w2			),
			.reg_waddr_o       	(reg_waddr_EX_WB_w2				)
		);

	wb_stage WB 
		(
			.clk 								(clk											),

			.data_req_o   			(data_req_o								),
			.data_addr_o  			(data_addr_o							),
			.data_we_o    			(data_we_o								),
			.data_be_o    			(data_be_o								),
			.data_wdata_o 			(data_wdata_o							),
			.data_rdata_i 			(data_rdata_i							),
			.data_rvalid_i			(data_rvalid_i						),
			.data_gnt_i					(data_gnt_i								),

			.wb_data_i    			(wb_data_EX_WB_w2					),
			.store_data_i 			(rdata2_ID_EX_w3					),
			.reg_wdata_o 				(reg_wdata_WB_ID_w				),			

			.load_type_i 				(load_type_ID_WB_w3				),
			.store_type_i 			(store_type_ID_WB_w3			)
		);

		pcu pipeline_control_unit 
		(
			.clk								(clk											),
    	.rst_n							(rst_n										),

    	.instr_type_i				(instr_type_ID_PCU_w			),
    	.read_addr1_i				(instr_IF_EX_w2[19:15]		),
    	.read_addr2_i				(instr_IF_EX_w2[24:20]		),
    	.write_addr_i				(instr_IF_EX_w2[11:7]			),
    	.write_en_i					(write_en_ID_WB_w1				),
    	.valid_lsu_load_i		(data_rvalid_i						),
    	.branch_taken_i  		(branch_taken_EX_IF_w			),
    	
    	.fetch_stall_o   		(fetch_stall_w						),
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