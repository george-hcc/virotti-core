//import riscv_defines::*;

module wb_stage
	(
		input  logic [WORD_WIDTH-1:0]	alu_result_i,
		input  logic [WORD_WIDTH-1:0] data_store_i,
		output logic [WORD_WIDTH-1:0]	reg_wb_o,

		// Comunicação com a memória de dados
		input  logic [WORD_WIDTH-1:0] dmem_data_i,
		output logic [WORD_WIDTH-1:0] dmem_addr_o,

		// Sinais de controle
		input  logic									loadmem_mux_i
	);

	assign dmem_addr_o = alu_result_i;
	assign reg_wb_o = (loadmem_mux_i) ? (dmem_data_i) : (alu_result_i);

endmodule