//import riscv_defines::*;

module controller
	(
		input  decoded_op								decoded_op_i,

		// Saídas de Controle
		output logic [ALU_OP_WIDTH-1:0]	alu_op_ctrl_o,
		output logic [2:0]							load_type_ctrl_o,
		output logic [1:0]							store_type_ctrl_o,
		output logic										write_en_o,
		output logic										stype_ctrl_o,
		output logic										utype_ctrl_o,
		output logic										jtype_ctrl_o,
		output logic										imm_alu_ctrl_o,
		output logic										auipc_alu_ctrl_o,
		output logic										branch_alu_ctrl_o,
		output logic										zeroflag_ctrl_o,
		output logic										branch_pc_ctrl_o,

		// Sinal de controle ULA/UMD - Só é usado caso UMD exista
		output logic										md_op_ctrl_o
	);

	logic [ALU_OP_WIDTH-1] 	alu_op;
	logic [2:0]							load_type;
	logic [1:0]							store_type;
	logic										write_en;
	logic										stype;
	logic										utype;
	logic										jtype;
	logic										imm_alu;
	logic										auipc_alu;
	logic										branch_alu;
	logic										zeroflag_inv;
	logic										branch_pc;

	// Decodificação de controle da ULA
	always_comb begin
		unique case(decoded_op_i)
			ADD, ADDI, AUIPC, LB, LBU, LH, LHU, LW, SB, SH, SW, JAL, JALR, LUI:
				alu_op  = ALU_ADD;
			SUB, BEQ, BNE:
				alu_op  = ALU_SUB;
			SLT, SLTI, BLT, BGE:
				alu_op  = ALU_SLT;
			SLTU, SLTIU, BLTU, BGEU:
				alu_op  = ALU_SLTU;
			OR, ORI:
				alu_op  = ALU_OR;
			AND, ANDI:
				alu_op  = ALU_AND;
			XOR, XORI:
				alu_op  = ALU_XOR;
			SLL, SLLI:
				alu_op  = ALU_SLL;
			SRL, SRLI:
				alu_op  = ALU_SRL;
			SRA, SRAI:
				alu_op  = ALU_SRA;
			default:
				alu_op  = ALU_ADD;
		endcase
	end

	// Decodificação de tipo de Load
	always_comb begin
		unique case(decoded_op_i) begin
			LB:				load_type = 3'b001;
			LBU:			load_type = 3'b101;
			LH:				load_type = 3'b010;
			LHU:			load_type = 3'b110;
			LW:				load_type = 3'b100;
			default:	load_type = 3'b000;
		endcase
	end

	// Decodificação de tipo de Store
	always_comb begin
		unique case(decoded_op_i) begin
			SB:				store_type = 2'b01;
			SH:				store_type = 2'b10;
			SW:				store_type = 2'b11;
			default:	store_type = 2'b00;
		endcase
	end

	// Decodificação de bits de controle
	always_comb begin
		unique case(decoded_op_i)
			ADD, SUB, SLL, SRL, SRA, AND, OR, XOR, SLT, SLTU:
				write_en			= 1'b1;
				stype					= 1'b0;
				utype					= 1'b0;
				jtype					= 1'b0;
				imm_alu				= 1'b0;
				auipc_alu			= 1'b0;
				branch_alu		= 1'b0;
				zeroflag_inv	= 1'b0;
				branch_pc			= 1'b0;
			ADDI, SLLI, SRLI, SRAI, ANDI, ORI, XORI, SLTI, SLTIU, LB, LBU, LH, LHU, LW:
				write_en			= 1'b1;
				stype					= 1'b0;
				utype					= 1'b0;
				jtype					= 1'b0;
				imm_alu				= 1'b1;
				auipc_alu			= 1'b0;
				branch_alu		= 1'b0;
				zeroflag_inv	= 1'b0;
				branch_pc			= 1'b0;
			LUI:
				write_en			= 1'b1;
				stype					= 1'b0;
				utype					= 1'b1;
				jtype					= 1'b0;
				imm_alu				= 1'b0;
				auipc_alu			= 1'b0;
				branch_alu		= 1'b0;
				zeroflag_inv	= 1'b0;
				branch_pc			= 1'b0;
			AUIPC:
				write_en			= 1'b1;
				stype					= 1'b0;
				utype					= 1'b1;
				jtype					= 1'b0;
				imm_alu				= 1'b1;
				auipc_alu			= 1'b1;
				branch_alu		= 1'b0;
				zeroflag_inv	= 1'b0;
				branch_pc			= 1'b0;
			SB, SH, SW:
				write_en			= 1'b0;
				stype					= 1'b1;
				utype					= 1'b0;
				jtype					= 1'b0;
				imm_alu				= 1'b1;
				auipc_alu			= 1'b0;
				branch_alu		= 1'b0;
				zeroflag_inv	= 1'b0;
				branch_pc			= 1'b0;
			BEQ, BLT, BLTU:
				write_en			= 1'b0;
				stype					= 1'b0;
				utype					= 1'b0;
				jtype					= 1'b0;
				imm_alu				= 1'b1;
				auipc_alu			= 1'b0;
				branch_alu		= 1'b1;
				zeroflag_inv	= 1'b0;
				branch_pc			= 1'b1;
			BNE, BGE, BGEU:
				write_en			= 1'b0;
				stype					= 1'b0;
				utype					= 1'b0;
				jtype					= 1'b0;
				imm_alu				= 1'b1;
				auipc_alu			= 1'b0;
				branch_alu		= 1'b1;
				zeroflag_inv	= 1'b1;
				branch_pc			= 1'b1;
			JAL:
				write_en			= 1'b1;
				stype					= 1'b0;
				utype					= 1'b0;
				jtype					= 1'b1;
				imm_alu				= 1'b0;
				auipc_alu			= 1'b0;
				branch_alu		= 1'b1;
				zeroflag_inv	= 1'b0;
				branch_pc			= 1'b1;
			JALR:
				write_en			= 1'b1;
				stype					= 1'b0;
				utype					= 1'b0;
				jtype					= 1'b0;
				imm_alu				= 1'b1;
				auipc_alu			= 1'b0;
				branch_alu		= 1'b0;
				zeroflag_inv	= 1'b0;
				branch_pc			= 1'b1;
			default:
				write_en			= 1'b0;
				stype					= 1'b0;
				utype					= 1'b0;
				jtype					= 1'b0;
				imm_alu				= 1'b0;
				auipc_alu			= 1'b0;
				branch_alu		= 1'b0;
				zeroflag_inv	= 1'b0;
				branch_pc			= 1'b0;
		endcase
	end

	generate

		/********************/
		/**BLOCO RISCV (IM)**/
		/********************/
		if(RISCV_M_CORE) begin

			logic [MDU_OP_WIDTH-1:0] 	mdu_op;

			always_comb begin
				case(decoded_op_i)
					MUL:			mdu_op = MDU_MUL;
					MULH:			mdu_op = MDU_MULH;
					MULHSU:		mdu_op = MDU_MULHSU;
					MULHU:		mdu_op = MDU_MULHU;
					DIV:			mdu_op = MDU_DIV;
					DIVU:			mdu_op = MDU_DIVU;
					REM:			mdu_op = MDU_REM;
					REMU:			mdu_op = MDU_REMU;
					default:	mdu_op = MDU_MUL;
				endcase
			end

			always_comb begin
				case(decoded_op_i)
					MUL, MULH, MULHSU, MULHU, DIV, DIVU, REM, REMU:
						md_op_ctrl_o = 1'b1;
					default:
						md_op_ctrl_o = 1'b0;
				endcase
			end

			always_comb begin
				if(md_op_ctrl_o) 
					alu_op_ctrl_o = {1'b0, mdu_op};
				else
					alu_op_ctrl_o = alu_op;
			end

			always_comb begin
				if(md_op_ctrl_o) begin
					load_type_ctrl_o 	= 3'b000;
					store_type_ctrl_o = 2'b00;
					write_en_o 				= 1'b1;
					stype_ctrl_o 			= 1'b0;
					utype_ctrl_o 			= 1'b0;
					jtype_ctrl_o 			= 1'b0;
					imm_alu_ctrl_o 		= 1'b0;
					auipc_alu_ctrl_o 	= 1'b0;
					branch_alu_ctrl_o = 1'b0;
					zeroflag_ctrl_o 	= 1'b0;
					branch_pc_ctrl_o 	= 1'b0;
				end
				else begin
					load_type_ctrl_o 	= load_type;
					store_type_ctrl_o = store_type;
					write_en_o 				= write_en;
					stype_ctrl_o 			= stype;
					utype_ctrl_o 			= utype;
					jtype_ctrl_o 			= jtype;
					imm_alu_ctrl_o 		= imm_alu;
					auipc_alu_ctrl_o 	= auipc_alu;
					branch_alu_ctrl_o = branch_alu;
					zeroflag_ctrl_o 	= zeroflag_inv;
					branch_pc_ctrl_o 	= branch_pc;
				end
			end

		end

		/********************/
		/***BLOCO RISCV (I)**/
		/********************/
		else begin

			always_comb begin
					load_type_ctrl_o 	= load_type;
					store_type_ctrl_o = store_type;
					write_en_o 				= write_en;
					stype_ctrl_o 			= stype;
					utype_ctrl_o 			= utype;
					jtype_ctrl_o 			= jtype;
					imm_alu_ctrl_o 		= imm_alu;
					auipc_alu_ctrl_o 	= auipc_alu;
					branch_alu_ctrl_o = branch_alu;
					zeroflag_ctrl_o 	= zeroflag_inv;
					branch_pc_ctrl_o 	= branch_pc;
			end

		end

	endgenerate

endmodule