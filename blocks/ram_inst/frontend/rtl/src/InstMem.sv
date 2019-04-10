module InstMem (//$I
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	input instr_req_i,
	input [31:0] instr_addr_i,

	output logic [31:0] instr_rdata_o,
	output logic instr_rvalid_o,
	output logic instr_gnd_o
);

parameter TAMANHO_DO_BANCO_DE_MEM = 4;

logic [31:0] Inst_Mem [TAMANHO_DO_BANCO_DE_MEM - 1 : 0];

assign Inst_Mem [0] = 32'd150;
assign Inst_Mem [1] = 32'd3215;
assign Inst_Mem [2] = 32'd2747;
assign Inst_Mem [3] = 32'd251111;


always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		instr_rvalid_o 	<= '0;
	end 
	else begin
		if(instr_gnd_o) begin
			instr_rvalid_o 	<= '1;
			instr_rdata_o <= Inst_Mem [2'b00:instr_addr_i[31:2]];
		end
		else
		begin 
			instr_rvalid_o 	<= '0;
		end
	end
end

always_comb begin 
	instr_gnd_o = instr_req_i;
end

endmodule