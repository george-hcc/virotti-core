
module mdu
	#(
		parameter WORD_SIZE = 32

	)(
		input  logic	[WORD_SIZE-1:0]	operand_a_i,
		input  logic	[WORD_SIZE-1:0]	operand_b_i,
		output logic	[WORD_SIZE:0]		result_o,

		input  logic	[WORD_SIZE:0]	operator_i
	);

	logic	[WORD_SIZE-1:0]	operand_a;
	logic	[WORD_SIZE-1:0]	operand_b;

	/*
	---------------Multiply ---------------
	*/

	logic [WORD_SIZE*2-1:0]	mul_result;

	assign mul_result = operand_a_i * operand_b_i;

	/*
	---------------Multiply signed---------------
	*/
	logic signed [WORD_SIZE*2-1:0] mul_signed_result;
	assign mul_signed_result = $signed(operand_a_i) * $signed(operand_b_i);


	/*
	---------------Unsigned division--------------
	*/

	logic [WORD_SIZE*2-1:0]	div_result;

	assign div_result = operand_a_i / operand_b_i;

	/*
	---------------signed division--------------
	*/
	
	logic [WORD_SIZE*2-1:0]	div_signed_result;

	assign div_signed_result = $signed(operand_a_i) / $signed(operand_b_i);

	/*
	---------------Unsigned remainder--------------
	*/
	logic [WORD_SIZE*2-1:0]	remainder_result;

	assign remainder_result = operand_a_i % operand_b_i;

	/*
	---------------signed remainder--------------
	*/
	logic [WORD_SIZE*2-1:0]	remainder_signed_result;

	assign remainder_signed_result = $signed(operand_a_i) / $signed(operand_b_i);


	/*
	-----------MUX DE RESULTADO----------
	*/
	always_comb begin
		case(operator_i)
			MDU_MUL:     result_o = mul_result;
			MDU_MULH:    result_o = mul_result >> 4;
			MDU_MULHU:   result_o = mul_signed_result >> 4;
			MDU_MULHSU:  result_o = mul_signed_result;
			MDU_DIV:     result_o = div_result;
			MDU_DIVU:    result_o = div_signed_result;
			MDU_REM:     result_o = remainder_result;
			MDU_REMU:    result_o = remainder_signed_result;
			default: 	   result_o = 'habc;
		endcase
	end

endmodule