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
		output logic										jalr_ctrl_o
	);

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
				default:
			endcase
		end

		always_comb begin
			case(operation)
				ADD:
				SUB:
				SLL:
				SRL:
				SRA:
				AND:
				OR:
				XOR:
				SLT:
				SLTU:

			endcase
		end

endmodule