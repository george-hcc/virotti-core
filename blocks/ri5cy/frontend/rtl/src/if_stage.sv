//import riscv_defines::*;

module if_stage
	(
		input  logic clk,
		input  logic rst_n,

		// Interface da Memória de Instruções
		output logic 									instr_req_o 			// Request Ready, precisa estar ativo até gnt_i estiver ativo por um ciclo
		output logic [WORD_WIDTH-1:0]	instr_addr_o 			// Recebe PC e manda como endereço para memória
		input  logic [WORD_WIDTH-1:0]	instr_rdata_i 		// Instrução vinda da memória
		input  logic 									instr_rvalid_i 		// Quando ativo, rdata_i é valido durante o ciclo
		input  logic 									instr_gnt_i				// O cache de instrução aceitou a requisição, addr_o pode mudar no próximo cíclo

		// Interface de Controle do Core
		input  logic 									fetch_en_i,
		input  logic [WORD_WIDTH-1:0]	pc_start_address_i,

		// Sinais de outros estágios
		input  logic [WORD_WIDTH-1:0] writeback_data_i, // Writeback de instruções para jalr
		output logic [WORD_WIDTH-1:0] program_count_o,  // PC, levado ao EX_Stage para ser operado
		output logic [WORD_WIDTH-1:0] pc_plus4_o, 			// PC + 4, armazenado em RD nas instruções JAL e JALR
		output logic [WORD_WIDTH-1:0]	instruction_o, 		// Instrução saindo para ID

		// Sinais de Controle
		output logic 									no_op_flag_o,
		input  logic 									branch_pc_ctrl_i,
		input  logic 									branch_comp_flag_i
	);

	logic [WORD_WIDTH-1:0] 	pc;
	logic [WORD_WIDTH-1:0]	pc_plus4;
	logic	[WORD_WIDTH-1:0]	next_pc;
	logic [WORD_WIDTH-1:0]	prev_pc;

	logic										branch_pc_mux;

	enum logic
		{
			RESET,
			IDLE,
			PRE_FETCH,
			FETCH
		}	fetch_state, next_fetch_state;

	assign branch_pc_mux = ((branch_pc_ctrl_i) && (branch_comp_flag_i)) || (jump_flag_i);	
	assign pc_plus4 = prev_pc + 32'd4;

	// Mudança de estados em cada clock
	always_ff @(posedge clk)
		fetch_state <= next_fetch_state;

	// Lógica de transição de estados (O proximo estágio está mais ou menos independente do estágio atual)
	always_comb  begin
		if(!rst_n)
			next_fetch_state = RESET;
		else if(!fetch_en_i)
			next_fetch_state = IDLE;
		else if(fetch_state == PRE_FETCH)
			next_fetch_state = FETCH;
		else
			next_fetch_state = PRE_FETCH;
	end

	always_comb begin
		unique case(next_fetch_state)
			RESET:
				next_pc = pc_start_address_i;
			IDLE, PRE_FETCH:
				next_pc = pc;
			FETCH:
				next_pc = (branch_pc_mux) ? (writeback_data_i) : (pc_plus4);
		endcase
	end

	always_comb begin
		unique case(fetch_state)
			RESET, IDLE:
				instr_req_o = 1'b0;
			PRE_FETCH, FETCH:
				instr_req_o = 1'b1;
		endcase
	end

	// Program Counter
	always_ff @(posedge clk) begin
		pc <= next_pc;
		prev_pc <= pc;
	end

	// Saídas
	assign instr_addr_o = pc;
	assign program_count_o = prev_pc;
	assign pc_plus4_o = pc_plus4;
	assign instruction_o = instr_rdata_i;
	assign no_op_flag_o = (fetch_state == FETCH);

endmodule