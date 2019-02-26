
module umd_tb();
 
  reg [3:0] a, b;
  wire [3:0] out;
 
  umd #() DUT (
    .operand_a_i(a),
    .operand_b_i(b),
    .result_o(out),
    .operator_i(2)
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
	(
		input  logic	[4-1:0]		operand_a_i,
		input  logic	[4-1:0]		operand_b_i,
		output logic	[3:0]		result_o,

		input  logic	[1:0]	operator_i
	);

	logic	[4-1:0]	operand_a;
	logic	[4-1:0]	operand_b;

	/*
	---------------Multiply and return lower bits---------------
	*/

	logic [4*2-1:0]	mul_result;

	assign mul_result = operand_a_i * operand_b_i;

	/*
	---------------Multiply unsigned and return upper bits---------------
	*/
	logic [4*2-1:0]	mul_unsigned_result;
	assign mul_unsigned_result = operand_a_i * operand_b_i;


	/*
	-----------MUX DE RESULTADO----------
	*/
	always_comb begin
		case(operator_i)
			1: result_o = mul_result;
			2: result_o = mul_unsigned_result >> 4;

			default: 	result_o = 'habc;
		endcase
	end

endmodule