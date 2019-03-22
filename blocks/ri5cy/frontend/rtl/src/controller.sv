//import riscv_defines::*;

module controller
	(
		input  decoded_op								decoded_op_i,

		// Saídas de Controle
		output logic [ALU_OP_WIDTH-1:0] alu_op_ctrl_o,
		output logic										write_en_ctrl_o,
		output logic										imm_ctrl_o,
		output logic										stype_ctrl_o,
		output logic										upper_ctrl_o,
		output logic										lui_shift_ctrl_o,
		output logic										pc_ula_ctrl_o,
		output logic										load_ctrl_o,
		output logic										store_ctrl_o,
		output logic										branch_ctrl_o,
		output logic										brn_inv_ctrl_o,
		output logic										jal_ctrl_o,
		output logic										jalr_ctrl_o,

		// Sinal de controle ULA/UMD - Só é usado caso UMD exista
		output logic										md_op_ctrl_o
	);

	logic [ALU_OP_WIDTH-1] 	alu_op;
	logic 									write_en;
	logic 									imm;
	logic 									stype;
	logic 									upper;
	logic 									lui_shift;
	logic 									pc_ula;
	logic 									load;
	logic 									store;
	logic 									branch;
	logic 									brn_inv;
	logic 									jal;
	logic 									jalr;

	always_comb begin
		case(decoded_op_i)
			ADD, ADDI, AUIPC, LB, LBU, LH, LHU, LW, SB, SH, SW, JAL, JALR:
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
			SLL, SLLI, LUI:
				alu_op  = ALU_SLL;
			SRL, SRLI:
				alu_op  = ALU_SRL;
			SRA, SRAI:
				alu_op  = ALU_SRA;
			default:
				alu_op  = ALU_ADD;
		endcase
	end

	always_comb begin
		case(decoded_op_i)
			ADD, SUB, SLL, SRL, SRA, AND, OR, XOR, SLT, SLTU:
				write_en 		= 1'b1;
				imm 				= 1'b0;
				stype 			= 1'b0;
				upper 			= 1'b0;
				lui_shift 	= 1'b0;
				pc_ula 			= 1'b0;
				load 				= 1'b0;
				store 			= 1'b0;
				branch 			= 1'b0;
				brn_inv 		= 1'b0;
				jal  				= 1'b0;
				jalr  			= 1'b0;
			ADDI, SLLI, SRLI, SRAI, ANDI, ORI, XORI, SLTI, SLTIU:
				write_en 		= 1'b1;
				imm 				= 1'b1;
				stype 			= 1'b0;
				upper 			= 1'b0;
				lui_shift 	= 1'b0;
				pc_ula 			= 1'b0;
				load 				= 1'b0;
				store 			= 1'b0;
				branch 			= 1'b0;
				brn_inv 		= 1'b0;
				jal  				= 1'b0;
				jalr  			= 1'b0;
			LUI: // Tem que mudar essa porra
				write_en 		= 1'b1;
				imm 				= 1'b0;
				stype 			= 1'b0;
				upper 			= 1'b1;
				lui_shift 	= 1'b1;
				pc_ula 			= 1'b0;
				load 				= 1'b0;
				store 			= 1'b0;
				branch 			= 1'b0;
				brn_inv 		= 1'b0;
				jal  				= 1'b0;
				jalr  			= 1'b0;
			AUIPC:
				write_en 		= 1'b1;
				imm 				= 1'b1;
				stype 			= 1'b0;
				upper 			= 1'b1;
				lui_shift 	= 1'b0;
				pc_ula 			= 1'b1;
				load 				= 1'b0;
				store 			= 1'b0;
				branch 			= 1'b0;
				brn_inv 		= 1'b0;
				jal  				= 1'b0;
				jalr  			= 1'b0;
			LB, LBU, LH, LHU, LW:
				write_en 		= 1'b1;
				imm 				= 1'b1;
				stype 			= 1'b0;
				upper 			= 1'b0;
				lui_shift 	= 1'b0;
				pc_ula 			= 1'b0;
				load 				= 1'b1;
				store 			= 1'b0;
				branch 			= 1'b0;
				brn_inv 		= 1'b0;
				jal  				= 1'b0;
				jalr  			= 1'b0;
			SB, SH, SW:
				write_en 		= 1'b0;
				imm 				= 1'b1;
				stype 			= 1'b1;
				upper 			= 1'b0;
				lui_shift 	= 1'b0;
				pc_ula 			= 1'b0;
				load 				= 1'b0;
				store 			= 1'b1;
				branch 			= 1'b0;
				brn_inv 		= 1'b0;
				jal  				= 1'b0;
				jalr  			= 1'b0;
			BEQ, BLT, BLTU:
				write_en 		= 1'b0;
				imm 				= 1'b0;
				stype 			= 1'b0;
				upper 			= 1'b0;
				lui_shift 	= 1'b0;
				pc_ula 			= 1'b0;
				load 				= 1'b0;
				store 			= 1'b0;
				branch 			= 1'b1;
				brn_inv 		= 1'b0;
				jal  				= 1'b0;
				jalr  			= 1'b0;
			BNE, BGE, BGEU:
				write_en 		= 1'b0;
				imm 				= 1'b0;
				stype 			= 1'b0;
				upper 			= 1'b0;
				lui_shift 	= 1'b0;
				pc_ula 			= 1'b0;
				load 				= 1'b0;
				store 			= 1'b0;
				branch 			= 1'b1;
				brn_inv 		= 1'b1;
				jal  				= 1'b0;
				jalr  			= 1'b0;
			JAL:
				write_en 		= 1'b1;
				imm 				= 1'b0;
				stype 			= 1'b0;
				upper 			= 1'b0;
				lui_shift 	= 1'b0;
				pc_ula 			= 1'b1;
				load 				= 1'b0;
				store 			= 1'b0;
				branch 			= 1'b1;
				brn_inv 		= 1'b0;
				jal  				= 1'b1;
				jalr  			= 1'b0;
			JALR: // Tem que mudar essa porra
				write_en 		= 1'b1;
				imm 				= 1'b1;
				stype 			= 1'b0;
				upper 			= 1'b0;
				lui_shift 	= 1'b0;
				pc_ula 			= 1'b0;
				load 				= 1'b0;
				store 			= 1'b0;
				branch 			= 1'b0;
				brn_inv 		= 1'b0;
				jal  				= 1'b0;
				jalr  			= 1'b0;
			default:
				write_en 		= 1'b1;
				imm 				= 1'b1;
				stype 			= 1'b0;
				upper 			= 1'b0;
				lui_shift 	= 1'b0;
				pc_ula 			= 1'b0;
				load 				= 1'b0;
				store 			= 1'b0;
				branch 			= 1'b0;
				brn_inv 		= 1'b0;
				jal  				= 1'b0;
				jalr  			= 1'b0;
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
					write_en_ctrl_o		= 1'b1;
					imm_ctrl_o				= 1'b0;
					stype_ctrl_o			= 1'b0;
					upper_ctrl_o			= 1'b0;
					lui_shift_ctrl_o	= 1'b0;
					pc_ula_ctrl_o			= 1'b0;
					load_ctrl_o				= 1'b0;
					store_ctrl_o			= 1'b0;
					branch_ctrl_o			= 1'b0;
					brn_inv_ctrl_o		= 1'b0;
					jal_ctrl_o				= 1'b0;
					jalr_ctrl_o				= 1'b0;
				end
				else begin
					write_en_ctrl_o		= write_en;
					imm_ctrl_o				= imm;
					stype_ctrl_o			= stype;
					upper_ctrl_o			= upper;
					lui_shift_ctrl_o	= lui_shift;
					pc_ula_ctrl_o			= pc_ula;
					load_ctrl_o				= load;
					store_ctrl_o			= store;
					branch_ctrl_o			= branch;
					brn_inv_ctrl_o		= brn_inv;
					jal_ctrl_o				= jal;
					jalr_ctrl_o				= jalr;
				end
			end

		end

		/********************/
		/***BLOCO RISCV (I)**/
		/********************/
		else begin

			always_comb begin
				alu_op_ctrl_o			= alu_op;
				write_en_ctrl_o		= write_en;
				imm_ctrl_o				= imm;
				stype_ctrl_o			= stype;
				upper_ctrl_o			= upper;
				lui_shift_ctrl_o	= lui_shift;
				pc_ula_ctrl_o			= pc_ula;
				load_ctrl_o				= load;
				store_ctrl_o			= store;
				branch_ctrl_o			= branch;
				brn_inv_ctrl_o		= brn_inv;
				jal_ctrl_o				= jal;
				jalr_ctrl_o				= jalr;
			end

		end

	endgenerate

endmodule