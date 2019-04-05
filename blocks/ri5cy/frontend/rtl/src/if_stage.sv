//////////////////////////////////////////////////////////////////////////////////////////////
// Autor:         	George Camboim - george.camboim@embedded.ufcg.edu.br         						//
//																																													//
// Nome do Design:  IF_Stage (Estágio de Fetch de Instruções)								                //
// Nome do Projeto: MiniSoc                                                    							//
// Linguagem:       SystemVerilog                                              							//
//                                                                            							//
// Descrição:    		Primeiro estágio do pipeline do core																		//
//                                                                            							//
//////////////////////////////////////////////////////////////////////////////////////////////

import riscv_defines::*;

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

		// Sinais de DataPath
		input  logic [WORD_WIDTH-1:0] pc_branch_addr_i, // Writeback de instruções para Jumps e Branchs
		output logic [WORD_WIDTH-1:0]	instruction_o, 		// Instrução saindo para ID
		output logic [WORD_WIDTH-1:0] program_count_o,  // Endereço da instrução, levado ao EX_Stage para ser operado

		// Sinais de ControlPath
		input  logic									fetch_stall_i
		input  logic 									branch_pc_ctrl_i,
		output logic 									no_op_flag_o,
	);

	logic [WORD_WIDTH-1:0]	prev_pc;
	logic [WORD_WIDTH-1:0] 	pc;
	logic	[WORD_WIDTH-1:0]	next_pc;
	logic [WORD_WIDTH-1:0] 	pc_plus_four;
	logic [WORD_WIDTH-1:0]	stalled_instruction;

	assign pc_plus_four = pc + 32'd4;

	enum logic
		{
			RESET,
			IDLE,
			PRE_FETCH,
			FETCH,
			STALL,
			POST_STALL
		}	fetch_state, next_fetch_state;

	// Mudança de estados em cada clock
	always_ff @(posedge clk)
		fetch_state <= next_fetch_state;

	// Lógica de transição de estados (O proximo estágio está mais ou menos independente do estágio atual)
	always_comb  begin
		unique case(fetch_state)
			RESET: begin
				next_fetch_state = RESET;
				if(rst_n)
					next_fetch_state = (fetch_en_i) ? (PRE_FETCH) : (IDLE);
			end 
			IDLE: begin
				if(!rst_n)
					next_fetch_state = RESET;
				else if(!fetch_en_i)
					next_fetch_state = IDLE;
				else
					next_fetch_state = PRE_FETCH;
			end
			PRE_FETCH: begin
				if(!rst_n)
					next_fetch_state = RESET;
				else if(!fetch_en_i)
					next_fetch_state = IDLE;
				else
					next_fetch_state = FETCH;
			end
			FETCH, POST_STALL: begin
				if(!rst_n)
					next_fetch_state = RESET;
				else if(!fetch_en_i)
					next_fetch_state = IDLE;
				else if(fetch_stall_i)
					next_fetch_state = STALL;
				else
					next_fetch_state = FETCH;
			end
			STALL: begin
				if(!rst_n)
					next_fetch_state = RESET;
				else if(!fetch_en_i)
					next_fetch_state = IDLE;
				else if(fetch_stall_i)
					next_fetch_state = STALL;
				else
					next_fetch_state = POST_STALL;
			end
		endcase
	end

	always_comb begin
		unique case(next_fetch_state)
			RESET:
				next_pc = pc_start_address_i;
			IDLE, PRE_FETCH:
				next_pc = pc;
			FETCH, POST_STALL:
				next_pc = (branch_pc_ctrl_i) ? (pc_branch_addr_i) : (pc_plus_four);
			STALL:
				next_pc = prev_pc;
		endcase
	end

	always_comb begin
		unique case(fetch_state)
			RESET, IDLE:
				instr_req_o = 1'b0;
			PRE_FETCH, FETCH, STALL, POST_STALL:
				instr_req_o = 1'b1;
		endcase
	end

	// Program Counter
	always_ff @(posedge clk) begin
		pc <= next_pc;
		prev_pc <= pc;
	end

	always_ff @(posedge clk) stalled_instruction <= instruction_o;

	// Saídas
	assign instr_addr_o = pc;
	assign program_count_o = prev_pc;
	assign instruction_o = (next_fetch_state == POST_STALL) ? (stalled_instruction) : (instr_rdata_i);
	assign no_op_flag_o = (fetch_state != FETCH);

endmodule