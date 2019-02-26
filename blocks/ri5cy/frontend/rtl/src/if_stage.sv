//import riscv_defines::*;

module if_stage
	(
		input  logic clk,
		input  logic rst_n,

		input  logic [WORD_WIDTH-1:0]	instruction_i, // Instrução vinda da memória
		input  logic [WORD_WIDTH-1:0] instr_wb_i, // Writeback de instruções para jalr
		output logic [WORD_WIDTH-1:0]	pc_o, // Endereço de instrução, igual a PC
		output logic [WORD_WIDTH-1:0] pc_plus4_o, // PC + 4
		output logic [WORD_WIDTH-1:0]	instruction_o, // Instrução saindo para ID

		input  logic 									branch_pc_ctrl_i,
		input  logic									jtype_mux_i,
		input  logic 									jarl_mux_i,
		input  logic									zeroflag_i,
		input  logic									zeroflag_inv_i
	);

	logic [WORD_WIDTH-1:0] 	pc;
	logic [WORD_WIDTH-1:0]	pc_plus4;
	logic	[WORD_WIDTH-1:0]	next_pc;
	logic	[WORD_WIDTH-1:0]	branch_pc_imm;

	logic [12:0]						btype_imm;
	logic	[WORD_WIDTH-1:0] 	xtended_branch_imm;
	logic [20:0]						jtype_imm;
	logic [WORD_WIDTH-1:0] 	xtended_jal_imm;

	logic										inverted_zeroflag;
	logic										branch_pc_mux;							

	// Extensão de imediato de branch (Tipo SB)
	always_comb begin
		btype_imm = {instruction_i[31], instruction_i[7], instruction_i[30:25], instruction_i[11:8], 1'b0};
		xtended_branch_imm[12:0]  = btype_imm;
		xtended_branch_imm[31:13] = (btype_imm[12]) ? (19'b1) : (19'b0);	
	end

	// Extensão de imediato de jal (Tipo UJ)
	always_comb begin
		jtype_imm = {instruction_i[31], instruction_i[19:12], instruction_i[20], instruction_i[30:21], 1'b0};
		xtended_jal_imm[20:0]  = jtype_imm;
		xtended_jal_imm[31:21] = (jtype_imm[20]) ? (11'b1) : (11'b0);
	end

	// Mux para seleção de imediato (Branch ou Jump)
	assign branch_pc_imm = (jtype_mux_i) ? (xtended_jal_imm) : (xtended_branch_imm);

	// Logica de controle do PC_Mux
	assign inverted_zeroflag = (zeroflag_inv_i) ? (~zeroflag_i) : (zeroflag_i);
	assign branch_pc_mux = (branch_pc_ctrl_i) && (inverted_zeroflag);
	
	// Mux para soma de PC ou branch
	assign pc_plus4 = pc + 32'd4;
	assign pc_plus_branch = pc + branch_pc_imm;
	assign next_pc = (branch_pc_mux) ? (pc_plus_branch) : (pc_plus4);

	// Program Counter
	always_ff @(posedge clk or negedge rst_n) begin
		if(~rst_n)
			pc <= 'b0;
		else if(jarl_mux_i)
			pc <= instr_wb_i;
		else
			pc <= next_pc;
	end

	// Saídas
	assign pc_o = pc;
	assign pc_plus4_o = pc_plus4;
	assign instruction_o = instruction_i;

endmodule