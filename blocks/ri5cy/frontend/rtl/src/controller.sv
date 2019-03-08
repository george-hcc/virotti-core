//import riscv_defines::*;

module controller
	(
		input  logic [DCODE_WIDTH-1:0]	decoded_op_i,

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

	enum logic
		{
			// Computacionais R
			ADD,
			SUB,
			SLL,
			SRL,
			SRA,
			AND,
			OR,
			XOR,
			SLT,
			SLTU,
			// Computacionais I
			ADDI,
			SLLI,
			SRLI,
			SRAI,
			ANDI,
			ORI,
			XORI,
			SLTI,
			SLTIU,
			// Computacionais U
			LUI,
			AUIPC,
			// Loads
			LB,
			LBU,
			LH,
			LHU,
			LW,
			// Stores
			SB,
			SH,
			SW,
			// Branches
			BEQ,
			BNE,
			BLT,
			BLTU,
			BGE,
			BGEU,
			// Jumps
			JAL,
			JALR
		} operation;

	always_comb begin
		case(decoded_op_i)
			DCODED_ADD:			operation = ADD;
			DCODED_SUB:			operation = SUB;
			DCODED_SLL:			operation = SLL;
			DCODED_SRL:			operation = SRL;
			DCODED_SRA:			operation = SRA;
			DCODED_AND:			operation = AND;
			DCODED_OR:			operation = OR;
			DCODED_XOR:			operation = XOR;
			DCODED_SLT:			operation = SLT;
			DCODED_SLTU:		operation = SLTU;
			DCODED_ADDI:		operation = ADDI;
			DCODED_SLLI:		operation = SLLI;
			DCODED_SRLI:		operation = SRLI;
			DCODED_SRAI:		operation = SRAI;
			DCODED_ANDI:		operation = ANDI;
			DCODED_ORI:			operation = ORI;
			DCODED_XORI:		operation = XORI;
			DCODED_SLTI:		operation = SLTI;
			DCODED_SLTIU:		operation = SLTIU;
			DCODED_LUI:			operation = LUI;
			DCODED_AUIPC:		operation = AUIPC;
			DCODED_LB:			operation = LB;
			DCODED_LBU:			operation = LBU;
			DCODED_LH:			operation = LH;
			DCODED_LHU:			operation = LHU;
			DCODED_LW:			operation = LW;
			DCODED_SB:			operation = SB;
			DCODED_SH:			operation = SH;
			DCODED_SW:			operation = SW;
			DCODED_BEQ:			operation = BEQ;
			DCODED_BNE:			operation = BNE;
			DCODED_BLT:			operation = BLT;
			DCODED_BLTU:		operation = BLTU;	
			DCODED_BGE:			operation = BGE;
			DCODED_BGEU:		operation = BGEU;
			DCODED_JAL:			operation = JAL;
			DCODED_JALR:		operation = JALR;
			default:				operation = ADD;
		endcase
	end

	always_comb begin
		case(operation)
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
		case(operation)
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

			enum logic
				{
					MUL,
					MULH,
					MULHSU,
					MULHU,
					DIV,
					DIVU,
					REM,
					REMU
				} multdiv_operation;

			always_comb begin
				case(decoded_op_i)
					DCODED_MUL:			multdiv_operation = MUL;
					DCODED_MULH:		multdiv_operation = MULH;
					DCODED_MULHSU:	multdiv_operation = MULHSU;
					DCODED_MULHU:		multdiv_operation = MULHU;
					DCODED_DIV:			multdiv_operation = DIV;
					DCODED_DIVU:		multdiv_operation = DIVU;
					DCODED_REM:			multdiv_operation = REM;
					DCODED_REMU:		multdiv_operation = REMU;
					default:				multdiv_operation = MUL;
				endcase
			end

			always_comb begin
				case(multdiv_operation)
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
					DCODED_MUL, DCODED_MULH, DCODED_MULHSU, DCODED_MULHU, DCODED_DIV, DCODED_DIVU, DCODED_REM, DCODED_REMU:
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