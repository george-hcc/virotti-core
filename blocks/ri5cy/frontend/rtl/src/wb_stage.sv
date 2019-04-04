//import riscv_defines::*;

module wb_stage
	(
		input  logic									clk,
		input  logic									rst_n,

		input  logic [WORD_WIDTH-1:0]	ex_data_i,
		input  logic [WORD_WIDTH-1:0] store_data_i,
		output logic [WORD_WIDTH-1:0]	writeback_data_o,

		// Interface da Memória de Dados
		output logic									data_req_o,
		output logic [WORD_WIDTH-1:0]	data_addr_o,
		output logic 									data_we_o,
		output logic [3:0]						data_be_o,
		output logic [WORD_WIDTH-1:0]	data_wdata_o,
		input  logic [WORD_WIDTH-1:0] data_rdata_i,
		input  logic									data_rvalid_i,
		input  logic									data_gnt_i

		// Sinais de Controle		
		input  logic [2:0]						load_type_i,
		input  logic [1:0]						store_type_i,
	);

	// Flags de operações load e stores
	logic 									load_flag;
	logic 									store_flag; 

	// Váriavel de controle para o LSU
	logic 									lsu_ctrl;

	// Dado lido na entrada pós processado
	logic [WORD_WIDTH-1:0] 	xtended_load_data;

	assign load_flag  = |(load_type_i);
	assign store_flag = |(store_type_i);	

	// Tradução dos sinais de controle decodificados para o controle da LSU
	always_comb begin
		if(load_flag) begin
			case(load_type_i)
				3'b001, 3'b101:
					lsu_ctrl = 2'b01;
				3'b010, 3'b110:
					lsu_ctrl = 2'b10;
				3'b100:
					lsu_ctrl = 2'b11;
				default:
					lsu_ctrl = 2'b00;
			endcase
		end
		else if(store_flag) begin
			case(store_type_i)
				2'b01:
					lsu_ctrl = 2'b01;
				2'b10:
					lsu_ctrl = 2'b10;
				2'b11:
					lsu_ctrl = 2'b11;
				default:
					lsu_ctrl = 2'b00;
			endcase
		end
		else
			lsu_ctrl = 2'b00;
	end

	lsu_lite unidade_de_load_store
		(
			.clk									(clk						),
			.rst_n								(rst_n					),

			.Controle_Funcao_i		(lsu_ctrl				),
			.Escrita1_Leitura0_i	(store_flag			),
			.data_addr_i					(ex_data_i			),	
			.data_wdata_i					(store_data_i		),
			.Dado_lido_o					(								),

			.data_req_o						(data_req_o			),
			.data_be_o						(data_be_o			),
			.data_addr_o					(data_addr_o		),
			.data_we_o						(data_we_o			),
			.data_wdata_o					(data_wdata_o		),

			.data_rdata_i					(data_rdata_i		),
			.data_rvalid_i				(data_rvalid_i	),
			.data_gnt_i						(data_gnt_i			)
		);

	// Extensão de sinal para operações de Load
	always_comb begin
		case(load_type_i)
			3'b001:
				xtended_load_data = (data_rdata_i[7]) ? {24'h1, data_rdata_i[7:0]} : {24'h0, data_rdata_i[7:0]};
			3'b010:
				xtended_load_data = (data_rdata_i[15]) ? {16'h1, data_rdata_i[15:0]} : {16'h1, data_rdata_i[15:0]};
			default:
				xtended_load_data = data_rdata_i;
		endcase
	end

	assign writeback_data_o = (load_flag) ? (xtended_load_data) : (ex_data_i);

endmodule