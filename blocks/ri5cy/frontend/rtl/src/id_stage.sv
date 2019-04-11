//////////////////////////////////////////////////////////////////////////////////////////////
// Autor:         	George Camboim - george.camboim@embedded.ufcg.edu.br         						//
//																																													//
// Nome do Design:  ID_Stage (Estágio de Decodificação de Instruções)				                //
// Nome do Projeto: MiniSoc                                                    							//
// Linguagem:       SystemVerilog                                              							//
//                                                                            							//
// Descrição:    		Segundo estágio do pipeline do core																			//
//                 	Contém unidade de controle além do banco de registradores								//
//                                                                            							//
//////////////////////////////////////////////////////////////////////////////////////////////

import riscv_defines::*;
import ctrl_typedefs::*;

module id_stage
	(
		input  logic										clk,

		// Sinais de Datapath
		input  logic [WORD_WIDTH-1:0]		instruction_i,
		input  logic [ADDR_WIDTH-1:0]		reg_waddr_i,
		input  logic [WORD_WIDTH-1:0]		reg_wdata_i,
		input  logic [WORD_WIDTH-1:0]		program_count_i,
		output logic [WORD_WIDTH-1:0] 	reg_rdata1_o,
		output logic [WORD_WIDTH-1:0]		reg_rdata2_o,
		output logic [WORD_WIDTH-1:0]		pc_jump_addr_o,

		// Sinais de ControlPath
		input	 logic										no_op_flag_i,
		input  logic										reg_wen_i,
		output logic [ALU_OP_WIDTH-1:0]	alu_op_ctrl_o,
		output logic [2:0]							load_type_ctrl_o,
		output logic [1:0]							store_type_ctrl_o,
		output logic										write_en_o,
		output logic										stype_ctrl_o,
		output logic										imm_alu_ctrl_o,
		output logic										jump_ctrl_o,
		output logic										branch_ctrl_o,
		output logic										auipc_ctrl_o,
		output logic										lui_ctrl_o,
		output logic										zeroflag_ctrl_o,

		// Sinal de operação para o PCU
		output decoded_opcode						instr_type_o,

		// Sinal de controle ULA/UMD - Só é usado caso UMD exista
		output logic										mdu_op_ctrl_o
	);

	// Endereços de leitura de registradores
	logic [ADDR_WIDTH-1:0]	rs1_addr;
	logic [ADDR_WIDTH-1:0]	rs2_addr;

	// Imediatos I e UJ (Usados em JARL e JAL respectivamente)
	logic [11:0]					 	itype_imm;
	logic	[WORD_WIDTH-1:0] 	xtended_jarl_imm;
	logic [20:0]						jtype_imm;
	logic [WORD_WIDTH-1:0] 	xtended_jal_imm;

	// Flags de controle para jumps
	logic										jarl_flag;
	logic 									jal_flag;

	// Resultados de somas com o PC
	logic	[WORD_WIDTH-1:0]	reg_plus_imm;
	logic	[WORD_WIDTH-1:0]	pc_plus_imm;

	assign rs1_addr = instruction_i[19:15];
	assign rs2_addr = instruction_i[24:20];

	// Extensão de imediato tipo I (JARL)
	always_comb begin
		itype_imm = instruction_i[31:20];
		xtended_jarl_imm[11:0] 	= itype_imm;
		xtended_jarl_imm[31:12] = (itype_imm[11]) ? 20'hFFFFF : 20'h00000;
	end

	// Extensão de imediato tipo UJ (JAL)
	always_comb begin
		jtype_imm = {instruction_i[31], instruction_i[19:12], instruction_i[20], instruction_i[30:21], 1'b0};
		xtended_jal_imm[20:0]  = jtype_imm;
		xtended_jal_imm[31:21] = (jtype_imm[20]) ? (11'h7FF) : (11'h000);
	end

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

			.no_op_flag_i				(no_op_flag_i				),
			.alu_op_ctrl_o			(alu_op_ctrl_o			),
			.load_type_ctrl_o		(load_type_ctrl_o		),
			.store_type_ctrl_o	(store_type_ctrl_o	),
			.write_en_o					(write_en_o					),
			.stype_ctrl_o				(stype_ctrl_o				),
			.imm_alu_ctrl_o			(imm_alu_ctrl_o			),
			.jarl_ctrl_o				(jarl_flag					),
			.jal_ctrl_o					(jal_flag						),
			.branch_ctrl_o			(branch_ctrl_o			),
			.auipc_ctrl_o				(auipc_ctrl_o				),
			.lui_ctrl_o					(lui_ctrl_o					),
			.zeroflag_ctrl_o		(zeroflag_ctrl_o		),

			.instr_type_o     	(instr_type_o				),

			.mdu_op_ctrl_o			(mdu_op_ctrl_o			)
		);

	assign reg_plus_imm = reg_rdata1_o + xtended_jarl_imm;
	assign pc_plus_imm = program_count_i + xtended_jal_imm;

	assign pc_jump_addr_o = (jarl_flag) ? (reg_plus_imm) : (pc_plus_imm);	

	assign jump_ctrl_o = jarl_flag || jal_flag;

endmodule