//////////////////////////////////////////////////////////////////////////////////////////////
// Autor:           Kelvin Dantas Vale - kelvin.vale@embedded.ufcg.edu.br                   //
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

module lsu_lite (
	input clk,
	input rst_n,

	input [1:0] Controle_Funcao_i,
	input Escrita1_Leitura0_i,
	input [31:0] data_addr_i,	
	input [31:0] data_wdata_i,

	output logic data_req_o,
	output logic [3:0] data_be_o,
	output logic [31:0] data_addr_o,
	output logic data_we_o,
	output logic [31:0] data_wdata_o,

	input [31:0] data_rdata_i,
	input data_rvalid_i,
	input data_gnt_i
);
/* 
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Escrita1_Leitura0[Bit 1,Bit 0]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
Bit 0: Se 1, escrever. Se 0, ler.
*/

// >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Todos os sinais '_i' vão ser enviados juntos. <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
// data_req_o 			// O sinal 'req' serve para requisitar uma transferência.
// data_be_o [3:0]		// O sinal 'be'(Byte enable) serve para escolher quais Bytes serão lidos ou escritos pelo core.
// data_addr_o[31:0]	// Manda o endereço que será lido ou escrito.
// data_we_o			// Se '1', deve-se escrever, se '0', deve-se ler.
// data_wdata_o[31:0]	// Dado para escrita.

// data_rdata_i[31:0]	// Dado lido.
// data_rvalid_i		// Dado válido para leitura.
// data_gnd_i			// Quando aceitar a requisição deve-se setar em '1' e baixar no próximo Clk.






// input [3:0] data_be_i, <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<  tirei !!!!!!!!!!!!!!!!

parameter 	FAZ_NADA 	= 2'b00, 
			XB 			= 2'b01, 
			XH 			= 2'b10, 
			XW 			= 2'b11;


always_ff @(posedge clk or negedge rst_n) 
	begin
		if(~rst_n) begin

			data_req_o		<= '0;
			data_be_o		<= '0;
			data_addr_o		<= '0;
			data_we_o		<= '0;
			data_wdata_o	<= '0;
		end 
		else begin
			data_addr_o		<= {2'b00, data_addr_i[31:2]};

			if(Controle_Funcao_i != 2'b00) 
				begin
					data_req_o 		<= '1;
					if(Escrita1_Leitura0_i)
						begin
							data_we_o		<= '1;
						end
					else 
						begin
							data_we_o		<= '0;
						end
				end
			else
				begin 
					data_req_o 		<= '0;
				end


			case (Controle_Funcao_i)
				FAZ_NADA:
					begin
						data_be_o		<= 4'b0000;
					end

				XB:
					begin
						case (data_addr_i[1:0])
							2'b00:
								begin 
									data_be_o			<= 4'b0001;
									data_wdata_o[7:0]	<= data_wdata_i[7:0];
								end

							2'b01:
								begin 
									data_be_o			<= 4'b0010;
									data_wdata_o[15:8]	<= data_wdata_i[7:0];
								end

							2'b10:
								begin 
									data_be_o			<= 4'b0100;
									data_wdata_o[23:16]	<= data_wdata_i[7:0];
								end

							2'b11:
								begin 
									data_be_o			<= 4'b1000;
									data_wdata_o[31:24]	<= data_wdata_i[7:0];
								end
						
							default:
								begin 
									data_be_o			<= 4'b0000;
								end
						endcase
					end

				XH:
					begin
						if(data_addr_i[1]) 
							begin
								data_be_o			<= 4'b1100;
								data_wdata_o[31:16]	<= data_wdata_i[15:0];
							end
						else 
							begin 
								data_be_o			<= 4'b0011;
								data_wdata_o[15:0]	<= data_wdata_i[15:0];
							end
					end

				XW:
					begin
						data_be_o		<= '1;	//Pega tudo !!!!!
						data_wdata_o	<= data_wdata_i;
					end
			
				default 
					begin
						data_be_o		<= 4'b0000;
					end
			endcase
		end
	end

endmodule