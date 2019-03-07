module decoder
	(
		input  logic [WORD_WIDTH-1:0]		instr_i,
		output logic [DCODE_WIDTH-1:0]	decoded_op_o
	);

	logic [OPCODE_WIDTH-1:0]	opcode;
	logic [6:0]								funct7;
	logic [2:0]								funct3;
	logic [DCODE_WIDTH-1:0]		comp_op;
	logic [DCODE_WIDTH-1:0]		compimm_op;
	logic [DCODE_WIDTH-1:0]		store_op;
	logic [DCODE_WIDTH-1:0]		load_op;
	logic [DCODE_WIDTH-1:0]		branch_op;
	logic [DCODE_WIDTH-1:0]		decoded_op;	

	assign opcode = instr_i[6:0];
	assign funct7 = instr_i[31:25];
	assign funct3 = instr_i[14:12];

	// Operações Computacionais tipo R
	always_comb begin
		case(funct3)
			3'b000: 	comp_op = (funct7[5]) ? (DCODED_SUB) : (DCODED_ADD);
			3'b001: 	comp_op = DCODED_SLL;
			3'b010: 	comp_op = DCODED_SLT;
			3'b011: 	comp_op = DCODED_SLTU;
			3'b100: 	comp_op = DCODED_XOR;
			3'b101: 	comp_op = (funct7[5]) ? (DCODED_SRA) : (DCODED_SRL);
			3'b110: 	comp_op = DCODED_OR;
			3'b111: 	comp_op = DCODED_AND;
			default:	comp_op = DCODED_ADD;
		endcase
	end

	// Operações Computacionais tipo I
	always_comb begin
		case(funct3)
			3'b000: 	compimm_op = DCODED_ADDI;
			3'b001: 	compimm_op = DCODED_SLLI;
			3'b010: 	compimm_op = DCODED_SLTI;
			3'b011: 	compimm_op = DCODED_SLTIU;
			3'b100: 	compimm_op = DCODED_XORI;
			3'b101: 	compimm_op = (funct7[5]) ? (DCODED_SRAI) : (DCODED_SRLI);
			3'b110: 	compimm_op = DCODED_ORI;
			3'b111: 	compimm_op = DCODED_ANDI;
			default:	compimm_op = DCODED_ADDI;
		endcase
	end

	// Operações Store
	always_comb begin
		case(funct3)
			3'b000: 	store_op = DCODED_SB;
			3'b001:		store_op = DCODED_SH;
			3'b010:		store_op = DCODED_SW;
			default:	store_op = DCODED_SW;
		endcase
	end

	// Operações Load
	always_comb begin
		case(funct3)
			3'b000:		load_op	= DCODED_LB;
			3'b001:		load_op = DCODED_LH;
			3'b010:		load_op	=	DCODED_LW;
			3'b100:		load_op = DCODED_LBU;
			3'b101:		load_op	=	DCODED_LHU;
			default:	load_op = DCODED_LW;
		endcase
	end

	// Operações Branch
	always_comb begin
		case(funct3)
			3'b000:		branch_op = DCODED_BEQ;
			3'b001:		branch_op	=	DCODED_BNE;
			3'b100:		branch_op	=	DCODED_BLT;
			3'b101:		branch_op = DCODED_BGE;
			3'b110:		branch_op = DCODED_BLTU;
			3'b111:		branch_op = DCODED_BGEU;
			default		branch_op = DCODED_BEQ;
		endcase 
	end

	// Mux de seleção de operação
	generate

		// BLOCO RISCV (IM)
		if(RISCV_M_CORE) begin

			logic [DCODE_WIDTH-1:0] multdiv_op;

			// Operações MultDiv
			always_comb begin
				case(funct3)
					3'b000: 	multdiv_op = DCODED_MUL;
					3'b001: 	multdiv_op = DCODED_MULH;
					3'b010: 	multdiv_op = DCODED_MULHSU;
					3'b011: 	multdiv_op = DCODED_MULHU;
					3'b100: 	multdiv_op = DCODED_DIV;
					3'b101: 	multdiv_op = DCODED_DIVU;
					3'b110: 	multdiv_op = DCODED_REM;
					3'b111: 	multdiv_op = DCODED_REMU;
					default:	multdiv_op = DCODED_MUL;
				endcase
			end

			always_comb begin
				case(opcode)
					OPCODE_COMP:		decoded_op = comp_op;
					OPCODE_COMPIMM: decoded_op = compimm_op;
					OPCODE_STORE:   decoded_op = store_op;
					OPCODE_LOAD:    decoded_op = load_op;
					OPCODE_BRANCH:  decoded_op = branch_op;
					OPCODE_JALR:    decoded_op = DCODED_JALR;
					OPCODE_JAL:     decoded_op = DCODED_JAL;
					OPCODE_AUIPC:   decoded_op = DCODED_AUIPC;
					OPCODE_LUI:     decoded_op = DCODED_LUI;
					default:				decoded_op = 'bx;
				endcase	
			end

		end

		// BLOCO RISCV (I)
		else begin

			always_comb begin
				case(opcode)
					OPCODE_COMP:		decoded_op = comp_op;
					OPCODE_COMPIMM: decoded_op = compimm_op;
					OPCODE_STORE:   decoded_op = store_op;
					OPCODE_LOAD:    decoded_op = load_op;
					OPCODE_BRANCH:  decoded_op = branch_op;
					OPCODE_JALR:    decoded_op = DCODED_JALR;
					OPCODE_JAL:     decoded_op = DCODED_JAL;
					OPCODE_AUIPC:   decoded_op = DCODED_AUIPC;
					OPCODE_LUI:     decoded_op = DCODED_LUI;
					default:				decoded_op = 'bx;
				endcase	
			end

		end

	endgenerate

	assign decoded_op_o = decoded_op;

endmodule