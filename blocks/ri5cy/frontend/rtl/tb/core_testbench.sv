module testbench();
	logic clk, rst_n;
	logic [WORD_WIDTH-1:0] imem_data, imem_addr;
	logic [WORD_WIDTH-1:0] dmem_data, dmem_addr;

	core core
		(
			.clk(clk),
			.rst_n(rst_n),
			.imem_data_i(imem_data),
			.imem_addr_o(imem_addr),
			.dmem_data_i(dmem_data),
			.dmem_addr_o(dmem_addr)
		);

endmodule