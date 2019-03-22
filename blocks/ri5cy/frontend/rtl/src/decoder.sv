module decoder
	(
		input  logic [WORD_WIDTH-1:0]		instr_i,
		output decoded_op								decoded_op_o
	);

	logic [OPCODE_WIDTH-1:0]	opcode;
	logic [6:0]								funct7;
	logic [2:0]								funct3;
	decoded_op								comp_op;
	decoded_op								compimm_op;
	decoded_op								store_op;
	decoded_op								load_op;
	decoded_op								branch_op;
	decoded_op								decoded_op;

	assign opcode = instr_i[6:0];
	assign funct7 = instr_i[31:25];
	assign funct3 = instr_i[14:12];

	// Operações Computacionais tipo R
	always_comb begin
		case(funct3)
			3'b000: 	comp_op = (funct7[5]) ? (SUB) : (ADD);
			3'b001: 	comp_op = SLL;
			3'b010: 	comp_op = SLT;
			3'b011: 	comp_op = SLTU;
			3'b100: 	comp_op = XOR;
			3'b101: 	comp_op = (funct7[5]) ? (SRA) : (SRL);
			3'b110: 	comp_op = OR;
			3'b111: 	comp_op = AND;
			default:	comp_op = ADD;
		endcase
	end

	// Operações Computacionais tipo I
	always_comb begin
		case(funct3)
			3'b000: 	compimm_op = ADDI;
			3'b001: 	compimm_op = SLLI;
			3'b010: 	compimm_op = SLTI;
			3'b011: 	compimm_op = SLTIU;
			3'b100: 	compimm_op = XORI;
			3'b101: 	compimm_op = (funct7[5]) ? (SRAI) : (SRLI);
			3'b110: 	compimm_op = ORI;
			3'b111: 	compimm_op = ANDI;
			default:	compimm_op = ADDI;
		endcase
	end

	// Operações Store
	always_comb begin
		case(funct3)
			3'b000: 	store_op = SB;
			3'b001:		store_op = SH;
			3'b010:		store_op = SW;
			default:	store_op = SW;
		endcase
	end

	// Operações Load
	always_comb begin
		case(funct3)
			3'b000:		load_op	= LB;
			3'b001:		load_op = LH;
			3'b010:		load_op	=	LW;
			3'b100:		load_op = LBU;
			3'b101:		load_op	=	LHU;
			default:	load_op = LW;
		endcase
	end

	// Operações Branch
	always_comb begin
		case(funct3)
			3'b000:		branch_op = BEQ;
			3'b001:		branch_op	=	BNE;
			3'b100:		branch_op	=	BLT;
			3'b101:		branch_op = BGE;
			3'b110:		branch_op = BLTU;
			3'b111:		branch_op = BGEU;
			default		branch_op = BEQ;
		endcase 
	end

	// Mux de seleção de operação
	generate

		/********************/
		/**BLOCO RISCV (IM)**/
		/********************/
		if(RISCV_M_CORE) begin

			logic [DCODE_WIDTH-1:0] multdiv_op;

			// Operações MultDiv
			always_comb begin
				case(funct3)
					3'b000: 	multdiv_op = MUL;
					3'b001: 	multdiv_op = MULH;
					3'b010: 	multdiv_op = MULHSU;
					3'b011: 	multdiv_op = MULHU;
					3'b100: 	multdiv_op = DIV;
					3'b101: 	multdiv_op = DIVU;
					3'b110: 	multdiv_op = REM;
					3'b111: 	multdiv_op = REMU;
					default:	multdiv_op = MUL;
				endcase
			end

			always_comb begin
				case(opcode)
					OPCODE_COMP:		decoded_op = (funct7[0]) ? (multdiv_op) : (comp_op);
					OPCODE_COMPIMM: decoded_op = compimm_op;
					OPCODE_STORE:   decoded_op = store_op;
					OPCODE_LOAD:    decoded_op = load_op;
					OPCODE_BRANCH:  decoded_op = branch_op;
					OPCODE_JALR:    decoded_op = JALR;
					OPCODE_JAL:     decoded_op = JAL;
					OPCODE_AUIPC:   decoded_op = AUIPC;
					OPCODE_LUI:     decoded_op = LUI;
					default:				decoded_op = 'bx;
				endcase	
			end

		end

		/********************/
		/***BLOCO RISCV (I)**/
		/********************/
		else begin

			always_comb begin
				case(opcode)
					OPCODE_COMP:		decoded_op = comp_op;
					OPCODE_COMPIMM: decoded_op = compimm_op;
					OPCODE_STORE:   decoded_op = store_op;
					OPCODE_LOAD:    decoded_op = load_op;
					OPCODE_BRANCH:  decoded_op = branch_op;
					OPCODE_JALR:    decoded_op = JALR;
					OPCODE_JAL:     decoded_op = JAL;
					OPCODE_AUIPC:   decoded_op = AUIPC;
					OPCODE_LUI:     decoded_op = LUI;
					default:				decoded_op = 'bx;
				endcase	
			end

		end

	endgenerate

	assign decoded_op_o = decoded_op;

endmodule