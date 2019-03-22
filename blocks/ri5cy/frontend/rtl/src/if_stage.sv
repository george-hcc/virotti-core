//import riscv_defines::*;

module if_stage
	(
		input  logic clk,
		input  logic rst_n,

		// Interface da Memória de Instruções
		output logic 									instr_req_o; 		// Request Ready, precisa estar ativo até gnt_i estiver ativo por um ciclo
		output logic [WORD_WIDTH-1:0]	instr_addr_o; 	// Recebe PC e manda como endereço para memória
		input  logic [WORD_WIDTH-1:0]	instr_rdata_i; 	// Instrução vinda da memória
		input  logic 									instr_rvalid_i; // Quando ativo, rdata_i é valido durante o ciclo
		input  logic 									instr_gnt_i;		// O cache de instrução aceitou a requisição, addr_o pode mudar no próximo cíclo

		// Interface de Controle do Core
		input  logic 									fetch_en_i,
		input  logic [WORD_WIDTH-1:0]	pc_start_address_i,

		// Sinais de outros estágios
		input  logic [WORD_WIDTH-1:0] instr_wb_i, 		// Writeback de instruções para jalr
		output logic [WORD_WIDTH-1:0] pc_plus4_o, 		// PC + 4, armazenado em RD nas instruções JAL e JALR
		output logic [WORD_WIDTH-1:0]	instruction_o, 	// Instrução saindo para ID

		// Sinais de Controle
		input  logic 									hazard_ctrl_i,
		input  logic 									branch_pc_ctrl_i,
		input  logic 									branch_comp_flag_i
	);

	logic [WORD_WIDTH-1:0] 	pc;
	logic [WORD_WIDTH-1:0]	pc_plus4;
	logic	[WORD_WIDTH-1:0]	next_pc;

	logic										branch_pc_mux;

	// Logica de controle do PC_Mux
	assign branch_pc_mux = (branch_pc_ctrl_i) && (branch_comp_flag_i);
	
	// Mux para soma de PC ou branch
	assign pc_plus4 = pc + 32'd4;
	assign pc_plus_branch = pc + branch_pc_imm;
	assign next_pc = (branch_pc_mux) ? (pc_plus_branch) : (pc_plus4);

	// Program Counter
	always_ff @(posedge clk or negedge rst_n) begin
		if(~rst_n)
			pc <= pc_start_address_i;
		else
			pc <= next_pc;
	end

	// Saídas
	assign instr_addr_o = pc;
	assign pc_plus4_o = pc_plus4;
	assign instruction_o = (fetch_enable_i) ? (NOOP_INSTR) : instr_rdata_i;

endmodule