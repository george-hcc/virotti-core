module LSU
	#(
		parameter WORD_SIZE = 32
	)(
		input	 logic									clk,
		input  logic 									rst_n,

		input  logic	[WORD_SIZE-1:0]	data_rdata_i,
		input  logic									data_rvalid_i,
		input  logic									data_gnt_i,

		output logic									data_red_o,
		output logic	[WORD_SIZE-1:0] data_addr_o,
		output logic									data_we_o,		// Enable de Escrita - 1 para escrita, 0 para leitura
		output logic	[3:0]						data_be_o,
		output logic	[WORD_SIZE-1:0]	data_wdata_o
	);




endmodule