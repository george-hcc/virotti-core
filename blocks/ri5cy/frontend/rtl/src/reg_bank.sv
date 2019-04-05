//////////////////////////////////////////////////////////////////////////////////////////////
// Autor:         	George Camboim - george.camboim@embedded.ufcg.edu.br         						//
//																																													//
// Nome do Design:  Reg Bank (Banco de Registradores)				 									              //
// Nome do Projeto: MiniSoc                                                    							//
// Linguagem:       SystemVerilog                                              							//
//                                                                            							//
// Descrição:    		Banco de 32 registradores de 32 bits																		//
//                                                                            							//
//////////////////////////////////////////////////////////////////////////////////////////////

//import riscv_defines::*;

module reg_bank
	(
		input  logic										clk,

		input  logic	[ADDR_WIDTH-1:0]	read_addr1_i,
		input  logic	[ADDR_WIDTH-1:0]	read_addr2_i,
		input  logic	[ADDR_WIDTH-1:0]	write_addr_i,
		input  logic  [WORD_WIDTH-1:0] 	write_data_i, 
		input  logic 										write_en_i,

		output logic 	[WORD_WIDTH-1:0] 	read_data1_o,
		output logic 	[WORD_WIDTH-1:0] 	read_data2_o
	);

	localparam N_OF_REGS = 32;
	
	logic [WORD_WIDTH-1:0]	reg_bank	[N_OF_REGS-1:0];

	always_comb begin		
		read_data1_o = reg_bank[read_addr1_i];
		read_data2_o = reg_bank[read_addr2_i];
	end

	assign reg_bank[5'h0] = 32'h0;

	always_ff @(posedge clk) begin
		if(write_en_i && (write_addr_i != 5'b00000))
			reg_bank[write_addr_i] <= write_data_i;
	end

endmodule