//import riscv_defines::*;

module wb_stage
	(
		input  logic [WORD_WIDTH-1:0]	ex_data_i,
		input  logic [WORD_WIDTH-1:0] data_store_i,
		output logic [WORD_WIDTH-1:0]	data_wb_o,

		// Interface da Memória de Dados
		output logic									data_req_o,
		output logic [WORD_WIDTH-1:0]	data_addr_o,
		output logic 									data_we_o,
		output logic [3:0]						data_be_o,
		output logic [WORD_WIDTH-1:0]	data_wdata_o,
		input  logic [WORD_WIDTH-1:0] data_rdata_i,
		input  logic									data_rvalid_i,
		input  logic									data_gnt_i

		// Sinais de controle
		input  logic									loadmem_mux_i
	);

	assign dmem_addr_o = alu_result_i;
	assign reg_wb_o = (loadmem_mux_i) ? (dmem_data_i) : (alu_result_i);

endmodule