module Data_Mem_Core (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	input data_req_i,
	input [3:0] data_be_i,
	input [31:0] data_addr_i,
	input data_we_i,
	input [31:0] data_wdata_i,

	output logic [31:0] data_rdata_o,
	output logic data_rvalid_o,
	output logic data_gnd_o
);

parameter TAMANHO_DO_BANCO_DE_MEM = 4;

logic [31:0] Mem_Data [TAMANHO_DO_BANCO_DE_MEM - 1 : 0];
logic data_we_r;
logic [3:0] data_be_r;

// >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Todos os sinais '_i' vão chegar juntos. <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
// data_req_i 			// O sinal 'req' serve para requisitar uma transferência.
// data_be_i [3:0]		// O sinal 'be'(Byte enable) serve para escolher quais Bytes serão lidos ou escritos pelo core.
// data_addr_i[31:0]	// Manda o endereço que será lido ou escrito.
// data_we_i			// Se '1', deve-se escrever, se '0', deve-se ler.
// data_wdata_i[31:0]	// Dado para escrita.

// data_rdata_o[31:0]	// Dado lido.
// data_rvalid_o		// Dado válido para leitura.
// data_gnd_o			// Quando aceitar a requisição deve-se setar em '1' e baixar no próximo Clk.


always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		//Mem_Data 		<= '{default,'0};
		data_we_r 		<= '0;
		data_be_r 		<= '0;
		data_rvalid_o 	<= '0;
	end 
	else begin
		if(data_gnd_o) begin
			data_we_r 	<= data_we_i;
			if(data_we_i) begin
				data_rvalid_o 	<= '0;
				if(data_be_i[0]) begin
					Mem_Data[data_addr_i][7:0] 		<= data_wdata_i[7:0];
				end

				if(data_be_i[1]) begin
					Mem_Data[data_addr_i][15:8] 	<= data_wdata_i[15:8];
				end

				if(data_be_i[2]) begin
					Mem_Data[data_addr_i][23:16] 	<= data_wdata_i[23:16];
				end

				if(data_be_i[3]) begin
					Mem_Data[data_addr_i][31:24] 	<= data_wdata_i[31:24];
				end
			end
			else begin
				data_be_r 		<= data_be_i;
				data_rvalid_o 	<= '1;
			end
		end
	end
end

always_comb begin 
	data_gnd_o = data_req_i;

	if(~data_we_r) begin
		if(data_be_r[0]) begin
			data_rdata_o [7:0] 		= Mem_Data[data_addr_i][7:0];
		end
		else begin
			data_rdata_o [7:0] 		= '0;
		end

		if(data_be_r[1]) begin
			data_rdata_o [15:8] 	= Mem_Data[data_addr_i][15:8];
		end
		else begin
			data_rdata_o [15:8]		= '0;
		end

		if(data_be_r[2]) begin
			data_rdata_o [23:16] 	= Mem_Data[data_addr_i][23:16];
		end
		else begin
			data_rdata_o [23:16] 	= '0;
		end

		if(data_be_r[3]) begin
			data_rdata_o [31:24] 	= Mem_Data[data_addr_i][31:24];
		end
		else begin
			data_rdata_o [31:24] 	= '0;
		end
	end
	else begin 
		data_rdata_o = '0;
	end
end

endmodule