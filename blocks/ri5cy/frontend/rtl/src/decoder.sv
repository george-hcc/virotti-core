module decoder
	(
		input  logic [WORD_WIDTH-1:0]		instr_i,
		output logic [DCODE_WIDTH-1:0]	decoded_op_o
	);

	logic [OPCODE_WIDTH-1:0]	opcode;
	logic [DCODE_WIDTH-1:0]		decoded_op;	

	enum logic [2:0]
		{
			R_TYPE_OP 	= 3'b000,
			I_TYPE_OP 	= 3'b001,
			S_TYPE_OP 	= 3'b010,
			SB_TYPE_OP 	= 3'b011,
			U_TYPE_OP		= 3'b100,
			UJ_TYPE_OP	= 3'b101,
			BAD_OP			=	3'bxxx
		} operation_type;

	assign opcode = instr_i[6:0];

	always_comb begin
		case(opcode)
			OPCODE_OP:
				operation_type = R_TYPE_OP;
			OPCODE_SYSTEM, OPCODE_OPIMM, OPCODE_FENCE, OPCODE_LOAD, OPCODE_JALR:
				operation_type = I_TYPE_OP;
			OPCODE_STORE:
				operation_type = S_TYPE_OP;
			OPCODE_BRANCH:
				operation_type = SB_TYPE_OP;
			OPCODE_AUIPC, OPCODE_LUI:
				operation_type = U_TYPE_OP;
			OPCODE_JAL:
				operation_type = UJ_TYPE_OP;
			default:
				operation_type = BAD_OP;
		endcase	
	end


	assign decoded_op_o = decoded_op;

endmodule