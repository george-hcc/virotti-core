//////////////////////////////////////////////////////////////////////////////////////////////
// Autor:         	George Camboim - george.camboim@embedded.ufcg.edu.br         						//
//																																													//
// Nome do Design:  Controller (Controlador)							                  								//
// Nome do Projeto: MiniSoc                                                    							//
// Linguagem:       SystemVerilog                                              							//
//                                                                            							//
// Descrição:    		Recebe um sinal de instrução decodificada																//
//                 	Codifica em diversos sinais de controle para o datapath do Core					//
//                                                                            							//
//////////////////////////////////////////////////////////////////////////////////////////////

import riscv_defines::*;
import ctrl_typedefs::*;

module controller
	(
		input  decoded_instr						decoded_instr_i,

		// Saídas de Controle
		output logic [ALU_OP_WIDTH-1:0]	alu_op_ctrl_o,
		output logic [2:0]							load_type_ctrl_o,
		output logic [1:0]							store_type_ctrl_o,
		output logic										write_en_o,
		output logic										stype_ctrl_o,
		output logic										imm_alu_ctrl_o,
		output logic										jarl_ctrl_o,
		output logic										jal_ctrl_o,
		output logic										branch_ctrl_o,
		output logic										auipc_ctrl_o,
		output logic										lui_ctrl_o,
		output logic										zeroflag_ctrl_o,

		// Sinal de controle ULA/UMD - Só é usado caso UMD exista
		output logic										mdu_op_ctrl_o
	);

	logic [ALU_OP_WIDTH-1:0] 	alu_op;
	logic [2:0]								load_type;
	logic [1:0]								store_type;
	logic											write_en;
	logic											stype;
	logic											imm_alu;
	logic											jarl;
	logic											jal;
	logic											branch;
	logic											auipc;
	logic											lui;
	logic											zeroflag_inv;

	// Decodificação de controle da ULA
	always_comb begin
		case(decoded_instr_i)
			INSTR_ADD, INSTR_ADDI, INSTR_AUIPC, INSTR_LB, INSTR_LBU, INSTR_LH, INSTR_LHU, INSTR_LW, INSTR_SB, INSTR_SH, INSTR_SW, INSTR_JAL, INSTR_JALR, INSTR_LUI:
				alu_op  = ALU_ADD;
			INSTR_SUB, INSTR_BEQ, INSTR_BNE:
				alu_op  = ALU_SUB;
			INSTR_SLT, INSTR_SLTI, INSTR_BLT, INSTR_BGE:
				alu_op  = ALU_SLT;
			INSTR_SLTU, INSTR_SLTIU, INSTR_BLTU, INSTR_BGEU:
				alu_op  = ALU_SLTU;
			INSTR_OR, INSTR_ORI:
				alu_op  = ALU_OR;
			INSTR_AND, INSTR_ANDI:
				alu_op  = ALU_AND;
			INSTR_XOR, INSTR_XORI:
				alu_op  = ALU_XOR;
			INSTR_SLL, INSTR_SLLI:
				alu_op  = ALU_SLL;
			INSTR_SRL, INSTR_SRLI:
				alu_op  = ALU_SRL;
			INSTR_SRA, INSTR_SRAI:
				alu_op  = ALU_SRA;
			default:
				alu_op  = ALU_ADD;
		endcase
	end

	// Decodificação de tipo de Load
	always_comb begin
		case(decoded_instr_i)
			INSTR_LB:		load_type = 3'b001;
			INSTR_LBU:	load_type = 3'b101;
			INSTR_LH:		load_type = 3'b010;
			INSTR_LHU:	load_type = 3'b110;
			INSTR_LW:		load_type = 3'b100;
			default:		load_type = 3'b000;
		endcase
	end

	// Decodificação de tipo de Store
	always_comb begin
		case(decoded_instr_i)
			INSTR_SB:	store_type = 2'b01;
			INSTR_SH:	store_type = 2'b10;
			INSTR_SW:	store_type = 2'b11;
			default:	store_type = 2'b00;
		endcase
	end

	// Decodificação de bits de controle
	always_comb begin
		case(decoded_instr_i)
			INSTR_ADD, INSTR_SUB, INSTR_SLL, INSTR_SRL, INSTR_SRA, INSTR_AND, INSTR_OR, INSTR_XOR, INSTR_SLT, INSTR_SLTU:
			begin
				write_en			= 1'b1;
				stype					= 1'b0;
				imm_alu				= 1'b0;
				jarl					= 1'b0;
				jal						= 1'b0;
				branch				= 1'b0;
				auipc					= 1'b0;
				lui						= 1'b0;
				zeroflag_inv	= 1'b0;
			end
			INSTR_ADDI, INSTR_SLLI, INSTR_SRLI, INSTR_SRAI, INSTR_ANDI, INSTR_ORI, INSTR_XORI, INSTR_SLTI, INSTR_SLTIU, INSTR_LB, INSTR_LBU, INSTR_LH, INSTR_LHU, INSTR_LW:
			begin
				write_en			= 1'b1;
				stype					= 1'b0;
				imm_alu				= 1'b1;
				jarl					= 1'b0;
				jal						= 1'b0;
				branch				= 1'b0;
				auipc					= 1'b0;
				lui						= 1'b0;
				zeroflag_inv	= 1'b0;
			end
			INSTR_LUI:
			begin
				write_en			= 1'b1;
				stype					= 1'b0;
				imm_alu				= 1'b0;
				jarl					= 1'b0;
				jal						= 1'b0;
				branch				= 1'b0;
				auipc					= 1'b0;
				lui						= 1'b1;
				zeroflag_inv	= 1'b0;
			end
			INSTR_AUIPC:
			begin
				write_en			= 1'b1;
				stype					= 1'b0;
				imm_alu				= 1'b1;
				jarl					= 1'b0;
				jal						= 1'b0;
				branch				= 1'b0;
				auipc					= 1'b1;
				lui						= 1'b0;
				zeroflag_inv	= 1'b0;
			end
			INSTR_SB, INSTR_SH, INSTR_SW:
			begin
				write_en			= 1'b0;
				stype					= 1'b1;
				imm_alu				= 1'b1;
				jarl					= 1'b0;
				jal						= 1'b0;
				branch				= 1'b0;
				auipc					= 1'b0;
				lui						= 1'b0;
				zeroflag_inv	= 1'b0;
			end
			INSTR_BEQ, INSTR_BLT, INSTR_BLTU:
			begin
				write_en			= 1'b0;
				stype					= 1'b0;
				imm_alu				= 1'b0;
				jarl					= 1'b0;
				jal						= 1'b0;
				branch				= 1'b1;
				auipc					= 1'b0;
				lui						= 1'b0;
				zeroflag_inv	= 1'b0;
			end
			INSTR_BNE, INSTR_BGE, INSTR_BGEU:
			begin
				write_en			= 1'b0;
				stype					= 1'b0;
				imm_alu				= 1'b0;
				jarl					= 1'b0;
				jal						= 1'b0;
				branch				= 1'b1;
				auipc					= 1'b0;
				lui						= 1'b0;
				zeroflag_inv	= 1'b1;
			end
			INSTR_JAL:
			begin
				write_en			= 1'b1;
				stype					= 1'b0;
				imm_alu				= 1'b0;
				jarl					= 1'b0;
				jal						= 1'b1;
				branch				= 1'b0;
				auipc					= 1'b0;
				lui						= 1'b0;
				zeroflag_inv	= 1'b0;
			end
			INSTR_JALR:
			begin
				write_en			= 1'b1;
				stype					= 1'b0;
				imm_alu				= 1'b0;
				jarl					= 1'b1;
				jal						= 1'b0;
				branch				= 1'b0;
				auipc					= 1'b0;
				lui						= 1'b0;
				zeroflag_inv	= 1'b0;
			end
			default:
			begin
				write_en			= 1'b0;
				stype					= 1'b0;
				imm_alu				= 1'b0;
				jarl					= 1'b0;
				jal						= 1'b0;
				branch				= 1'b0;
				auipc					= 1'b0;
				lui						= 1'b0;
				zeroflag_inv	= 1'b0;
			end
		endcase
	end

	generate

		/********************/
		/**BLOCO RISCV (IM)**/
		/********************/
		if(RISCV_M_CORE) begin

			logic [MDU_OP_WIDTH-1:0] 	mdu_op;

			always_comb begin
				case(decoded_instr_i)
					INSTR_MUL:			mdu_op = MDU_MUL;
					INSTR_MULH:			mdu_op = MDU_MULH;
					INSTR_MULHSU:		mdu_op = MDU_MULHSU;
					INSTR_MULHU:		mdu_op = MDU_MULHU;
					INSTR_DIV:			mdu_op = MDU_DIV;
					INSTR_DIVU:			mdu_op = MDU_DIVU;
					INSTR_REM:			mdu_op = MDU_REM;
					INSTR_REMU:			mdu_op = MDU_REMU;
					default:	mdu_op = MDU_MUL;
				endcase
			end

			always_comb begin
				case(decoded_instr_i)
					INSTR_MUL, INSTR_MULH, INSTR_MULHSU, INSTR_MULHU, INSTR_DIV, INSTR_DIVU, INSTR_REM, INSTR_REMU:
						mdu_op_ctrl_o = 1'b1;
					default:
						mdu_op_ctrl_o = 1'b0;
				endcase
			end

			always_comb begin
				if(mdu_op_ctrl_o) 
					alu_op_ctrl_o = {1'b0, mdu_op};
				else
					alu_op_ctrl_o = alu_op;
			end

			always_comb begin
				if(mdu_op_ctrl_o) begin
					load_type_ctrl_o	= 3'b000;
					store_type_ctrl_o	= 2'b00;
					write_en_o				= 1'b1;
					stype_ctrl_o			= 1'b0;
					imm_alu_ctrl_o		= 1'b0;
					jarl_ctrl_o				= 1'b0;
					jal_ctrl_o				= 1'b0;
					branch_ctrl_o			= 1'b0;
					auipc_ctrl_o			= 1'b0;
					lui_ctrl_o				= 1'b0;
					zeroflag_ctrl_o		= 1'b0;
				end
				else begin
					load_type_ctrl_o	= load_type;
					store_type_ctrl_o	= store_type;
					write_en_o				= write_en;
					stype_ctrl_o			= stype	;
					imm_alu_ctrl_o		= imm_alu;
					jarl_ctrl_o				= jarl;
					jal_ctrl_o				= jal;
					branch_ctrl_o			= branch;
					auipc_ctrl_o			= auipc;
					lui_ctrl_o				= lui;
					zeroflag_ctrl_o		= zeroflag_inv;
				end
			end

		end

		/********************/
		/***BLOCO RISCV (I)**/
		/********************/
		else begin

			always_comb begin
					alu_op_ctrl_o 		= alu_op;
					load_type_ctrl_o	= load_type;
					store_type_ctrl_o	= store_type;
					write_en_o				= write_en;
					stype_ctrl_o			= stype	;
					imm_alu_ctrl_o		= imm_alu;
					jarl_ctrl_o				= jarl;
					jal_ctrl_o				= jal;
					branch_ctrl_o			= branch;
					auipc_ctrl_o			= auipc;
					lui_ctrl_o				= lui;
					zeroflag_ctrl_o		= zeroflag_inv;
			end

		end

	endgenerate

endmodule