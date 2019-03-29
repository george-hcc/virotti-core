
`include "riscv_defines.svh"
`include "if_to_id.sv"
`include "id_stage.sv"
`include "id_to_ex.sv"
`include "ex_stage.sv"

module Kelvin_TB ();

	parameter 	WORD_WIDTH = 32,
				ALU_OP_WIDTH = 4;

	logic									clk = '0;
	logic									rst_n = '0;

	// Interface da Memória de Instruções
	logic 									instr_req_o;		// Request Ready; precisa estar ativo até gnt_i estiver ativo por um ciclo
	logic [WORD_WIDTH-1:0]	instr_addr_o;		// Recebe PC e manda como endereço para memória
	logic [WORD_WIDTH-1:0]	instr_rdata_i;	// Instrução vinda da memória
	logic 									instr_rvalid_i;	// Quando ativo; rdata_i é valido durante o ciclo
	logic 									instr_gnt_i;		// O cache de instrução aceitou a requisição; addr_o pode mudar no próximo cíclo

	// Interface da Memória de Dados
	logic									data_req_o;
	logic [WORD_WIDTH-1:0]	data_addr_o;
	logic 									data_we_o;
	logic [3:0]						data_be_o;
	logic [WORD_WIDTH-1:0]	data_wdata_o;
	logic [WORD_WIDTH-1:0] data_rdata_i;
	logic									data_rvalid_i;
	logic									data_gnt_i;

	// Interface de Controle do Core
	logic									fetch_en_i;
	logic [WORD_WIDTH-1:0]	pc_start_addr_i;
	logic [4:0]						irq_id_i;
	logic									irq_event_i;
	logic									socctrl_mmc_exception_i;

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
	// Saídas do EX_WB
	logic [WORD_WIDTH-1:0]		ex_data_EX_WB_w2;
	logic [WORD_WIDTH-1:0]		store_data_EX_WB_w2;
	logic											comp_flag_EX_WB_w2;
	/************************************/

	/*********Saídas do EX_STAGE*********/
	logic [WORD_WIDTH-1:0]		writeback_data_WB_w;
	/************************************/

	IF_to_ID if_id 
		(
			.clk								(clk											),
			.rst_n							(rst_n										),
			.stall_ctrl     		(1'b0),

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

			.waddr_wb_i      		(					),
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
			.stall_ctrl     		(1'b0),

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
			.write_en_o					(write_en_ID_WB_w2 				),
			.stype_ctrl_o				(stype_ctrl_ID_EX_w2			),
			.utype_ctrl_o				(utype_ctrl_ID_EX_w2			),
			.jtype_ctrl_o				(jtype_ctrl_ID_EX_w2			),
			.imm_alu_ctrl_o			(imm_alu_ctrl_ID_EX_w2		),
			.auipc_alu_ctrl_o		(auipc_alu_ctrl_ID_EX_w2	),
			.branch_alu_ctrl_o	(branch_alu_ctrl_ID_EX_w2	),
			.zeroflag_ctrl_o		(zeroflag_ctrl_ID_EX_w2		),
			.load_type_ctrl_o		(load_type_ID_WB_w2				),
			.store_type_ctrl_o	(store_type_ID_WB_w2			),
			.branch_pc_ctrl_o		(branch_pc_ctrl_ID_WB_w2	)
		);

	ex_stage EX 
		(
			.reg_rdata1_i				(rdata1_ID_EX_w2					),
			.reg_rdata2_i				(rdata2_ID_EX_w2					),
			.instruction_i   		(instr_IF_EX_w3						),
			.program_count_i		(pc_IF_EX_w3							),
			.ex_data_o 					(ex_data_EX_WB_w1					),

			.alu_op_ctrl_i			(alu_op_ID_EX_w2					),
			.stype_mux_i				(stype_ctrl_ID_EX_w2			),
			.utype_mux_i				(utype_ctrl_ID_EX_w2			),
			.jtype_mux_i      	(jtype_ctrl_ID_EX_w2			),
			.imm_alu_mux_i			(imm_alu_ctrl_ID_EX_w2		),
			.pc_alu_mux_i				(auipc_alu_ctrl_ID_EX_w2	),
			.branch_alu_mux_i 	(branch_alu_ctrl_ID_EX_w2	),
			.zeroflag_inv_i   	(zeroflag_ctrl_ID_EX_w2		),
			.branch_comp_flag_o	(comp_flag_EX_WB_w1				),

			.alu_mdu_mux_i   		(			1'b0		)
		);

always #2 clk = !clk;

initial begin
	$display("fiphrtpigjryohykehwrohr *************<<<<<<<<<<<<<<<<,"); 
	#10 rst_n <= '1;
	
	@(posedge clk);
	@(posedge clk)
		begin 
			pc_IF_EX_w1			<= 32'd0;
			pc_plus4_IF_ID_w1	<= 32'd0;
			instr_IF_EX_w1		<= 32'b 0000000_00001_00010_000_00011_0110011; //ADD
			no_op_IF_ID_w1		<= '0;
		end

	@(posedge clk);
	@(posedge clk);
	@(posedge clk);

	@(posedge clk)
		begin 
			pc_IF_EX_w1			<= 32'd0;
			pc_plus4_IF_ID_w1	<= 32'd0;
			instr_IF_EX_w1		<= 32'b 0100000_00010_00001_000_00011_0110011; //SUB
			no_op_IF_ID_w1		<= '0;
		end

	@(posedge clk);
	@(posedge clk);
	@(posedge clk);

	@(posedge clk)
		begin 
			pc_IF_EX_w1			<= 32'd0;
			pc_plus4_IF_ID_w1	<= 32'd0;
			instr_IF_EX_w1		<= 32'b 000001000000_00010_000_00011_0010011; //ADDi
			no_op_IF_ID_w1		<= '0;
		end

	@(posedge clk);
	@(posedge clk);
	@(posedge clk);

	@(posedge clk)
		begin 
			pc_IF_EX_w1			<= 32'd0;
			pc_plus4_IF_ID_w1	<= 32'd0;
			instr_IF_EX_w1		<= 32'b 0000000_00001_00010_111_00011_0110011; //AND
			no_op_IF_ID_w1		<= '0;
		end

	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	
	@(posedge clk)
		begin 
			pc_IF_EX_w1			<= 32'd0;
			pc_plus4_IF_ID_w1	<= 32'd0;
			instr_IF_EX_w1		<= 32'b 011110000101_00010_111_00011_0010011; //ANDi
			no_op_IF_ID_w1		<= '0;
		end


	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);

	$finish;
end





endmodule