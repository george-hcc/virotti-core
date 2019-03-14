module LSU
	#(
		parameter WORD_SIZE = 32
	)(
	Axi4_FULL_if.master 				Axi_full,

	input 								Para_escrever_i,
	input 								Para_ler_i,

	input	[1:0]						Quantos_Bytes_Escrita_i,
	input	[1:0]						Quantos_Bytes_Leitura_i,

	input 								Add_Write,
	input 	logic [WORD_SIZE -1 : 0] 	Data_Write,
	output 		axi4_resp_el			Resposta_Escrita,

	input 								Add_Read,
	output	logic [WORD_SIZE -1 : 0] 	Data_Read,
	output 		axi4_resp_el			Resposta_Leitura
	);
	// 	Tamanho do add é [ADD_LENGTH -1 + 2 : 0], pois é por Byte e não por linha.

	import axi4_types::*;

	logic Para_escrever_reg;
	logic Para_ler_reg;

	enum logic [1:0]
	{
		IDLE,
		MANDANDO_ADD,
		MANDANDO_DATA,
		RECEBENDO_BRESP
	}Estado_escrita;

	enum logic [1:0]
	{
		IDLE,
		MANDANDO_ADD,
		RECEBENDO_DATA_E_RRESP
	}Estado_leitura;



				//******** Função que tá faltando ********\\
				//Implementar as escritas Byte, HalfWord e Escrita comum.

	always_ff @(posedge Axi_full.ACLK or negedge Axi_full.ARESETn) 
	begin
		if(~Axi_full.ARESETn) begin
			Axi_full.AWID 		<= '0;
			Axi_full.AWLEN		<= '0;	//Como vai usar ?
			Axi_full.AWBURST	<= '0;	//Como vai usar ?
			Axi_full.AWCACHE	<= '0;
			Axi_full.AWPROT		<= '0;
			Axi_full.AWQOS 		<= 2'b01;
			Axi_full.AWREGION	<= '0;
			Axi_full.AWUSER		<= '0;

			Axi_full.WSTRB		<= '0;	//Como vai usar ?
			Axi_full.WLAST		<= '0;	//Como vai usar ?
			Axi_full.WUSER		<= '0;

			Axi_full.BID		<= '0;
			Axi_full.BUSER		<= '0;

			Axi_full.ARID		<= '0;
			Axi_full.ARLEN		<= '0;	//Como vai usar ?
			Axi_full.ARBURST	<= '0;	//Como vai usar ?
			Axi_full.ARCACHE	<= '0;
			Axi_full.ARPROT		<= '0;
			Axi_full.ARQOS		<= 2'b01;
			Axi_full.ARREGION	<= '0;
			Axi_full.ARUSER		<= '0;

			Axi_full.RID		<= '0;
			Axi_full.RUSER		<= '0;




			Axi_full.ARQOS 		<= 2'b01;

			Para_escrever_reg 	<= Para_escrever_i;
			Para_ler_reg		<= Para_ler_i;
			Estado_escrita		<= IDLE;
		end 
		else begin
			case (Estado_leitura)

				IDLE :
					begin 
						if(Para_ler_reg) begin
							Axi_full.ARVALID 	<= '1;
							Axi_full.ARADDR 	<= Add_Read;
							Estado_escrita		<= MANDANDO_ADD;
							Para_ler_reg 		<= '0;
						end
						else begin 
							Para_ler_reg		<= Para_ler_i;
						end
					end

				MANDANDO_ADD :
					begin 
						if(Axi_full.ARVALID && Axi_full.ARREADY) begin
							Axi_full.ARVALID 	<= '0;
							Axi_full.RREADY		<= '1;
							Estado_escrita		<= RECEBENDO_DATA_E_RRESP; 
						end
					end

				RECEBENDO_DATA_E_RRESP :
					begin 
						
						if(Axi_full.RVALID && Axi_full.RREADY) begin
							Data_Read			<= Axi_full.RDATA;
							Resposta_Leitura	<= Axi_full.RRESP;
							Estado_leitura		<= IDLE;
						end
					end
			
				default : Estado_leitura		<= IDLE;
			endcase

			case (Estado_escrita)

				IDLE :
					begin 
						if(Para_escrever_reg) begin
							Axi_full.AWVALID 	<= '1;
							Axi_full.AWADDR 	<= Add_Write;
							Estado_escrita		<= MANDANDO_ADD;
							Para_escrever_reg 	<= '0;
						end
						else begin 
							Para_escrever_reg 	<= Para_escrever_i;
						end
					end

				MANDANDO_ADD :
					begin 
						if(Axi_full.AWVALID && Axi_full.AWREADY) begin
							Axi_full.AWVALID 	<= '0;
							Axi_full.WVALID		<= '1;
							Axi_full.WDATA		<= Data_Write;
							Estado_escrita		<= MANDANDO_DATA;
						end
					end

				MANDANDO_DATA :
					begin 
						if(Axi_full.WVALID && Axi_full.WREADY) begin
							Axi_full.WVALID		<= '0;
							Axi_full.BREADY		<= '1;
							Estado_escrita		<= RECEBENDO_BRESP;
						end
					end

				RECEBENDO_BRESP :
					begin 
						if(Axi_full.BVALID && Axi_full.BREADY) begin
							Axi_full.BREADY		<= '0;
							Resposta_Escrita	<= Axi_full.BRESP;
							Estado_escrita		<= IDLE;
						end
					end
			
				default : Estado_escrita		<= IDLE;
			endcase
		end
	end

	always_comb begin 
		case (Quantos_Bytes_Leitura_i)
			2'b01: 
				begin 
					Axi_full.ARSIZE = '0;
				end

			2'b10: 
				begin 
					Axi_full.ARSIZE = 2'b01;
				end

			2'b11: 
				begin 
					Axi_full.ARSIZE = 2'b10;
				end

			default: 
				begin 
					Axi_full.ARSIZE = 2'b10;
				end
		endcase




		case (Quantos_Bytes_Escrita_i)
			2'b00: 
				begin //Não manda nada!
					Axi_full.WSTRB = 4'b0000;
					Axi_full.AWSIZE = '0;
				end

			2'b01: 
				begin 
					Axi_full.WSTRB = 4'b0001;
					Axi_full.AWSIZE = '0;
				end

			2'b10: 
				begin 
					Axi_full.WSTRB = 4'b0011;
					Axi_full.AWSIZE = 2'b01;
				end

			2'b11: 
				begin 
					Axi_full.WSTRB = 4'b1111;
					Axi_full.AWSIZE = 2'b10;
				end

			default: 
				begin 
					Axi_full.WSTRB = 4'b1111;
					Axi_full.AWSIZE = 2'b10;
				end
		endcase

	end
endmodule




// AWID 		Valor defalt de '0
// AWADDR		OK!!!
// AWLEN		********falta********
// AWSIZE		OK!!!
// AWBURST		********falta********
// AWCACHE		Valor defalt de '0
// AWPROT		Valor defalt de '0
// AWQOS		Valor defalt de 2'b01, para que outro mestre possa ter prioridade.
// AWREGION		********falta********
// AWUSER		Valor defalt de 4'b0000
// AWVALID		OK!!!
// AWREADY		Vem de fora!!!

// WDATA		OK!!!
// WSTRB		OK!!!
// WLAST		Vem de fora!!!
// WUSER		Valor defalt de 4'b0000
// WVALID		OK!!!
// WREADY		Vem de fora!!!

// BID 			Valor defalt de '0
// BRESP		Vem de fora!!!
// BUSER		Valor defalt de 4'b0000
// BVALID		Vem de fora!!!
// BREADY		OK!!!


// ARID			Valor defalt de '0
// ARADDR		OK!!!
// ARLEN		********falta********
// ARSIZE		OK!!!
// ARBURST		********falta********
// ARCACHE		Valor defalt de '0
// ARPROT		Valor defalt de '0
// ARQOS		Valor defalt de 2'b01, para que outro mestre possa ter prioridade.
// ARREGION		********falta********
// ARUSER		Valor defalt de 4'b0000
// ARVALID		OK!!!
// ARREADY		Vem de fora!!!

// RID			Valor defalt de '0
// RDATA		OK!!!
// RRESP		OK!!!
// RLAST		Vem de fora!!!
// RUSER		Valor defalt de 4'b0000
// RVALID		Vem de fora!!!
// RREADY		OK!!!