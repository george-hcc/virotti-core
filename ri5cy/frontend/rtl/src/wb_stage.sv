//////////////////////////////////////////////////////////////////////////////////////////////
// Autor:         	George Camboim - george.camboim@embedded.ufcg.edu.br         						//
//																																													//
// Colaboradores:   Kelvin Dantas Vale - kelvin.vale@embedded.ufcg.edu.br										//
//																																													//
// Nome do Design:  WB_Stage (Estágio de Writeback)													                //
// Nome do Projeto: MiniSoc                                                    							//
// Linguagem:       SystemVerilog                                              							//
//                                                                            							//
// Descrição:    		Quarto e ultimo estágio do pipeline do core															//
//                 	Responsável por lidar com memória de dados e escrita nos registradores	//
//                                                                            							//
//////////////////////////////////////////////////////////////////////////////////////////////

import riscv_defines::*;

module wb_stage
	(
		input  logic									clk,

		// Interface da Memória de Dados
		output logic									data_req_o,
		output logic [WORD_WIDTH-1:0]	data_addr_o,
		output logic 									data_we_o,
		output logic [3:0]						data_be_o,
		output logic [WORD_WIDTH-1:0]	data_wdata_o,
		input  logic [WORD_WIDTH-1:0] data_rdata_i,
		input  logic									data_rvalid_i,
		input  logic									data_gnt_i,

		// Sinais de Datapath
		input  logic [WORD_WIDTH-1:0]	wb_data_i,
		input  logic [WORD_WIDTH-1:0] store_data_i,
		output logic [WORD_WIDTH-1:0]	reg_wdata_o,

		// Sinais de ControlPath	
		input  logic [2:0]						load_type_i,
		input  logic [1:0]						store_type_i,
		output logic 									load_flag_o
	);

	// Flags de operações load e stores
	logic 									load_flag;
	logic 									store_flag; 
	logic [WORD_WIDTH-1:0]	load_data;

	assign load_flag  = |(load_type_i);
	assign store_flag = |(store_type_i);

	lsu unidade_de_load_store
		(
			.data_addr_i					(wb_data_i			),	
			.data_wdata_i					(store_data_i		),
			.load_flag_i					(load_flag 			),
			.load_type_i					(load_type_i 		),
			.store_flag_i					(store_flag 		),
			.store_type_i					(store_type_i		),
			.load_data_o					(load_data 			),

			.data_req_o						(data_req_o			),
			.data_addr_o					(data_addr_o		),
			.data_we_o						(data_we_o			),
			.data_be_o						(data_be_o			),
			.data_wdata_o					(data_wdata_o		),
			.data_rdata_i					(data_rdata_i		),
			.data_rvalid_i				(data_rvalid_i	),
			.data_gnt_i						(data_gnt_i			)
		);

	assign reg_wdata_o = (load_flag) ? (load_data) : (wb_data_i);

	assign load_flag_o = load_flag;

endmodule