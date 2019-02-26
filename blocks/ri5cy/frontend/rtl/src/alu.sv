//import riscv_defines::*;

module alu
	(
		input  logic	[WORD_WIDTH-1:0]		operand_a_i,
		input	 logic	[WORD_WIDTH-1:0]		operand_b_i,
		output logic	[WORD_WIDTH-1:0]		result_o,

		input  logic	[ALU_OP_WIDTH-1:0]	operator_i
	);

	logic	[WORD_WIDTH-1:0]	operand_a;
	logic	[WORD_WIDTH-1:0]	operand_b;
	logic										negate_op_b;

	always_comb begin
		case(operator_i)
			ALU_SUB, ALU_SLT, ALU_SLTU:
				negate_op_b = 1'b1;
			default:
				negate_op_b = 1'b0;
		endcase	
	end

	assign operand_a = operand_a_i;
	assign operand_b = (negate_op_b) ? (~operand_b_i + 1) : operand_b_i;

	/*
	#####################################
	---------------SOMADOR---------------
	#####################################
	*/

	logic [WORD_WIDTH-1:0]	adder_result;

	assign adder_result = operand_a + operand_b;

	/*
	#####################################
	-------------DESLOCADOR--------------
	#####################################
	*/

	logic [WORD_WIDTH-1:0] 	rev_operand_a; // Operando revertido para SLL
	logic [WORD_WIDTH-1:0] 	shift_operand;
	logic [WORD_WIDTH:0]		xtended_shift_operand; // Operando extendido para preenchimento de sinal em SRA
	logic [ADDR_WIDTH-1:0] 	shift_ammount;
	logic [WORD_WIDTH-1:0] 	l_shift_result;
	logic [WORD_WIDTH-1:0] 	r_shift_result;
	logic [WORD_WIDTH-1:0] 	shift_result;

	logic										left_shift;
	logic										arithmetic_shift;

	assign shift_ammount = operand_b_i[4:0];
	assign left_shift = (operator_i == ALU_SLL);
	assign arithmetic_shift = (operator_i == ALU_SRA);

	// Invertendo bits para deslocamento a esquerda
	generate
		genvar i;
		for(i = 0; i < WORD_WIDTH; i++) begin
			assign rev_operand_a[i] = operand_a[WORD_WIDTH-1-i];
		end
	endgenerate

	assign shift_operand = (left_shift) ? rev_operand_a : operand_a;
	assign xtended_shift_operand = {(arithmetic_shift && shift_operand[31]), shift_operand};
	// Os três tipos de deslocamento usam o mesmo deslocador (ponto critico para otimização)
	assign r_shift_result = $signed(xtended_shift_operand) >>> shift_ammount;

	// Re-invertendo bits para deslocamento a esquerda
	generate
		genvar j;
		for(j = 0; j < WORD_WIDTH; j++) begin
			assign l_shift_result[j] = r_shift_result[WORD_WIDTH-1-j];
		end
	endgenerate

	assign shift_result = (left_shift) ? l_shift_result : r_shift_result;

	/*
	#####################################
	-------------COMPARADOR--------------
	#####################################
	*/

	logic is_equal;
	logic sign_comp; // Flag de signed (SLT/SLTI)
	logic a_is_greater_equal; // Operando A é maior ou igual que B
	logic comp_result;

	assign is_equal = (adder_result == 32'b0);
	assign sign_comp = (operator_i == ALU_SLT) ? 1'b1 : 1'b0;

	always_comb begin
		if((operand_a_i[31] ^ operand_b_i[31]) == 1'b0) // Se os bits de sinais forem iguais
			a_is_greater_equal = (adder_result[31] == 0);
		else
			a_is_greater_equal = operand_a_i[31] ^ sign_comp;
	end

	always_comb begin
		case(operator_i)
			ALU_SLT, ALU_SLTU:	comp_result = ~(a_is_greater_equal);
			default:						comp_result = 1'bx;
		endcase
	end

	/*
	#####################################
	-----------MUX DE RESULTADO----------
	#####################################
	*/

	always_comb begin
		case(operator_i)
			ALU_ADD, ALU_SUB:
								result_o = adder_result;
			ALU_SLL, ALU_SRL, ALU_SRA:
								result_o = shift_result;
			ALU_SLT, ALU_SLTU:
								result_o = comp_result;
			ALU_AND: 	
								result_o = operand_a & operand_b;
			ALU_OR:		
								result_o = operand_a | operand_b;
			ALU_XOR:	
								result_o = operand_a ^ operand_b;
								
			default: 	result_o = 'habc;
		endcase
	end

endmodule