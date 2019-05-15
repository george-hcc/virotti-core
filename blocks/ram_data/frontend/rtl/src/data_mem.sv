//////////////////////////////////////////////////////////////////////////////////////////////
// Autores:         																																				//
//									Kelvin Dantas Vale - kelvin.vale@embedded.ufcg.edu.br 									// 
//									George Camboim - george.camboim@embedded.ufcg.edu.br         						//
//																																													//
// Nome do Design:  Memória Ram de dados 									                  								//
// Nome do Projeto: MiniSoc                                                    							//
// Linguagem:       SystemVerilog                                              							//
//                                                                            							//
// Descrição:    		Modelo de memória de dados para simulação do MiniSoc										//
//                                                                            							//
//////////////////////////////////////////////////////////////////////////////////////////////

module data_mem
#(
	parameter RAM_START_ADDR
)(
	input  logic									clk,
	// Interface de memória de dados
  input  logic                  data_req_i,
  input  logic [WORD_WIDTH-1:0] data_addr_i,
  input  logic                  data_we_i,
  input  logic [3:0]            data_be_i,
  input  logic [WORD_WIDTH-1:0]	data_wdata_i,
  output logic [WORD_WIDTH-1:0] data_rdata_o,
  output logic                  data_rvalid_o,
  output logic                  data_gnt_o
);

logic [DATA_MEM_SIZE+DMEM_START_ADDR-1:DMEM_START_ADDR] data_mem;

assign data_gnd_o = data_req_i;

always_ff @(posedge clk) begin
	if(data_req_i && DMEM_START_ADDR <= data_addr_i < ROM_START_ADDR) begin
		if(data_we_i) begin // WRITE
			data_rvalid_o <= 1'b0;
			if(data_be_i[0]) 
				data_mem[data_addr_i+:8] 		<= data_wdata_i[7:0];
			if(data_be_i[1]) 
				data_mem[data_addr_i+1+:8] 	<= data_wdata_i[15:8];
			if(data_be_i[2]) 
				data_mem[data_addr_i+2+:8] 	<= data_wdata_i[23:16];
			if(data_be_i[3]) 
				data_mem[data_addr_i+3+:8] 	<= data_wdata_i[31:24];
		end
		else begin // READ
			data_rvalid_o 			<= 1'b1;
			data_rdata_o[7:0] 	<= (data_be_i[0]) ? (data_mem[data_addr_i+:8]) 		: (8'h00);
			data_rdata_o[15:8] 	<= (data_be_i[1]) ? (data_mem[data_addr_i+1+:8]) 	: (8'h00);
			data_rdata_o[23:16] <= (data_be_i[2]) ? (data_mem[data_addr_i+2+:8]) 	: (8'h00);
			data_rdata_o[31:24] <= (data_be_i[3]) ? (data_mem[data_addr_i+3+:8]) 	: (8'h00);
		end
	end
	else
		data_rvalid_o <= 1'b0;
end

endmodule