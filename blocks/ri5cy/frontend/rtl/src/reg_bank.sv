//import riscv_defines::*;

module reg_bank
	(
		input  logic										clk,
		input  logic										rst_n,

		input  logic	[ADDR_WIDTH-1:0]	addr_rd1_i,
		input  logic	[ADDR_WIDTH-1:0]	addr_rd2_i,
		input  logic	[ADDR_WIDTH-1:0]	addr_wd_i,
		input  logic  [WORD_WIDTH-1:0] 	wd_i, 
		input  logic 										wen_i ,

		output logic 	[WORD_WIDTH-1:0] 	rd1_o,
		output logic 	[WORD_WIDTH-1:0] 	rd2_o
	);

	logic [WORD_WIDTH-1:0]	reg_bank	[N_OF_REGS-1:0];

	always_comb begin		
		rd1_o = reg_bank[addr_rd1_i];
		rd2_o = reg_bank[addr_rd2_i];
	end

	assign reg_bank[5'b0] = 32'b0;
	always_ff @(posedge clk) begin
		if(wen_i && addr_wd_i != 5'b00000)
			reg_bank[addr_wd_i] <= wd_i;
	end

endmodule