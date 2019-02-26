//import riscv_defines::*;

module controller
	(
		input  logic [WORD_WIDTH-1:0]		instr_i,

		// Sinais ULA
		output logic										neg_mux_ctrl_o,
		output logic [ALU_OP_WIDTH-1:0] alu_op_ctrl_o,

		output logic										regwrite_en_o
	);

// SERÁ REFEITO NO FUTURO
/*
	logic negation_op;
	logic regwrite_en;

	// True para operações SUB, SRA e SRAI
	assign negation_op = instr_i[30];

	assign regwrite_en_o = regwrite_en;

	enum logic [0:0]
		{
			OPERATION 	= 'b0,
			BAD_TYPE		=	'bx
		} op_type;

	enum logic [1:0]
		{
			FUNCT_ADDER	= 'b00,
			FUNCT_AND		=	'b01,
			FUNCT_OR		= 'b10,
			FUNCT_XOR		=	'b11,
			BAD_FUNCT		=	'bx
		} op_function;

	// Estado de Operação
	always_comb begin
		case(instr_i[7:0])
			OPCODE_OP: 
				op_type = OPERATION;
			default:
				op_type = BAD_TYPE;
		endcase 
	end

	assign regwrite_en = (op_type == OPERATION) ? (1'b1) : (1'b0);

	// Estado de funct3 (Tipo R)
	always_comb begin
		if(op_type == OPERATION) begin
			case(instr_i[14:12])
				3'b000:
					op_function = FUNCT_ADDER;
				3'b100:
					op_function = FUNCT_XOR;
				3'b110:
					op_function = FUNCT_OR;
				3'b111:
					op_function	= FUNCT_AND;
				default:
					op_function = BAD_FUNCT;
			endcase
		end
		else begin
			op_function = BAD_FUNCT;
		end
	end

	// Saídas
	assign neg_mux_ctrl_o = negation_op;

	always_comb begin
		case(op_function)
			FUNCT_ADDER: begin
				if(negation_op)
					alu_op_ctrl_o = ALU_SUB;
				else
					alu_op_ctrl_o = ALU_ADD;
			end
			FUNCT_XOR:
				alu_op_ctrl_o = ALU_XOR;
			FUNCT_OR:
				alu_op_ctrl_o = ALU_OR;
			FUNCT_AND:
				alu_op_ctrl_o = ALU_AND;
			default: // ERRO FEDERAL - NA DUVIDA SOME
				alu_op_ctrl_o = ALU_ADD;
		endcase
	end
*/
endmodule