
module umd_tb();
 
  reg [3:0] a, b;
  wire [3:0] out;
 
  umd #() DUT (
    .operand_a_i(a),
    .operand_b_i(b),
    .result_o(out),
    .operator_i(4)
  );
 
  initial begin
    a = 4'b0000;
    b = 4'b0000;
    #20
    a = 4'b1111;
    b = 4'b0101; 
    #20
    a = 4'b1100;
    b = 4'b1111;
    #20
    a = 4'b1100;
    b = 4'b0011;
    #20
    a = 4'b1100;
    b = 4'b1010;
	#20
    $finish;
  end
 
endmodule

module umd
	#(
		parameter WORD_SIZE = 32

	)

	(
		input  logic	[WORD_SIZE-1:0]		operand_a_i,
		input  logic	[WORD_SIZE-1:0]		operand_b_i,
		output logic	[WORD_SIZE:0]		result_o,

		input  logic	[WORD_SIZE:0]	operator_i
	);
	parameter MUL			= 3'b000;
	parameter MULH			= 3'b001;	
	parameter MULHU		    = 3'b010;
	parameter MULHSU		= 3'b011;
	parameter DIV			= 3'b100;
	parameter DIVU			= 3'b110;
	parameter REM			= 3'b111;
	parameter REMU			= 3'b101;

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
			MUL: result_o = mul_result;
			MULH: result_o = mul_result >> 4;
			MULHU: result_o = mul_signed_result >> 4;
			MULHSU: result_o = mul_signed_result;
			DIV: result_o = div_result;
			DIVU: result_o = div_signed_result;
			REM: result_o = remainder_result;
			REMU: result_o = remainder_signed_result;
			default: 	result_o = 'habc;
		endcase
	end

endmodule