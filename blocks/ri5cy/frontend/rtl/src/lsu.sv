//////////////////////////////////////////////////////////////////////////////////////////////
// Autores:         																																				//
//									George Camboim - george.camboim@embedded.ufcg.edu.br         						//
//									Kelvin Dantas Vale - kelvin.vale@embedded.ufcg.edu.br 									// 
//                                                                                          //
// Nome do Design:  LSU (Unidade de Load e Store)                                           //
// Nome do Projeto: MiniSoc                                                                 //
// Linguagem:       SystemVerilog                                                           //
//                                                                                          //
// Descrição:       Responsável pela comunicação com a interface de memória de dados        //
//									Utilizado nas 5 operações de Load e 3 de Store													//
//                                                                                          //
//////////////////////////////////////////////////////////////////////////////////////////////

import riscv_defines::*;

module lsu
	(
		// Comunicação com o WB Stage
		input  logic [WORD_WIDTH-1:0] data_addr_i,
		input  logic [WORD_WIDTH-1:0] data_wdata_i,
		input  logic 									load_flag_i,
		input  logic [2:0] 						load_type_i,
		input  logic 									store_flag_i,
		input  logic [1:0]						store_type_i,
		output logic [WORD_WIDTH-1:0] load_data_o,

		// Interface de memória $d
		output logic                  data_req_o,
    output logic [WORD_WIDTH-1:0] data_addr_o,
    output logic                  data_we_o,
    output logic [3:0]            data_be_o,
    output logic [WORD_WIDTH-1:0] data_wdata_o,
    input  logic [WORD_WIDTH-1:0] data_rdata_i,
    input  logic                  data_rvalid_i,
    input  logic                  data_gnt_i
	);

	logic [3:0]							store_be;
	logic [3:0]							load_be;

	assign data_req_o = store_flag_i || load_flag_i;
	assign data_addr_o = data_addr_i;
	assign data_we_o = store_flag_i;
	assign data_be_o = (store_flag_i) ? (store_be) : (load_be);
	assign data_wdata_o = data_wdata_i;

	// Lógica combinacional do store_be
	always_comb begin
		store_be = 4'b0000;
		if(store_flag_i) begin
			case(store_type_i)
				2'b01: store_be = 4'b0001;
				2'b10: store_be = 4'b0011;
				2'b11: store_be = 4'b1111;
			endcase
		end
	end

	// Lógica combinacional do load_be
	always_comb begin
		case(load_type_i)
			3'b001, 3'b101:	load_be = 4'b0001;
			3'b010, 3'b110:	load_be = 4'b0011;
			3'b100:					load_be = 4'b1111;
			default:				load_be = 4'b0000;
		endcase
	end

	// Extensão de sinal para dados carregados da memória
	always_comb begin
		case(load_type_i)
			3'b001:
				load_data_o = (data_rdata_i[7]) ? {24'hFFFFFF, data_rdata_i[7:0]} : {24'h000000, data_rdata_i[7:0]};
			3'b010:
				load_data_o = (data_rdata_i[15]) ? {16'hFFFF, data_rdata_i[15:0]} : {16'h0000, data_rdata_i[15:0]};
			default:
				load_data_o = data_rdata_i;
		endcase
	end

endmodule