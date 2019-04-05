module decoder
	(
		input  logic [WORD_WIDTH-1:0]		instr_i,
		output decoded_instr						decoded_instr_o,
		output decoded_opcode						instr_type_o,

		input	 logic										no_op_flag_i,
	);

	parameter DCODE_WIDTH = 7;

	logic [OPCODE_WIDTH-1:0]	opcode;
	logic [6:0]								funct7;
	logic [2:0]								funct3;
	decoded_instr							comp_instr;
	decoded_instr							compimm_instr;
	decoded_instr							store_instr;
	decoded_instr							load_instr;
	decoded_instr							branch_instr;
	decoded_instr							decoded_instr;

	assign opcode = instr_i[6:0];
	assign funct7 = instr_i[31:25];
	assign funct3 = instr_i[14:12];

	// Operações Computacionais tipo R
	always_comb begin
		case(funct3)
			3'b000: 	comp_instr = (funct7[5]) ? (INSTR_SUB) : (INSTR_ADD);
			3'b001: 	comp_instr = INSTR_SLL;
			3'b010: 	comp_instr = INSTR_SLT;
			3'b011: 	comp_instr = INSTR_SLTU;
			3'b100: 	comp_instr = INSTR_XOR;
			3'b101: 	comp_instr = (funct7[5]) ? (INSTR_SRA) : (INSTR_SRL);
			3'b110: 	comp_instr = INSTR_OR;
			3'b111: 	comp_instr = INSTR_AND;
			default:	comp_instr = INSTR_ADD;
		endcase
	end

	// Operações Computacionais tipo I
	always_comb begin
		case(funct3)
			3'b000: 	compimm_instr = INSTR_ADDI;
			3'b001: 	compimm_instr = INSTR_SLLI;
			3'b010: 	compimm_instr = INSTR_SLTI;
			3'b011: 	compimm_instr = INSTR_SLTIU;
			3'b100: 	compimm_instr = INSTR_XORI;
			3'b101: 	compimm_instr = (funct7[5]) ? (INSTR_SRAI) : (INSTR_SRLI);
			3'b110: 	compimm_instr = INSTR_ORI;
			3'b111: 	compimm_instr = INSTR_ANDI;
			default:	compimm_instr = INSTR_ADDI;
		endcase
	end

	// Operações Store
	always_comb begin
		case(funct3)
			3'b000: 	store_instr = INSTR_SB;
			3'b001:		store_instr = INSTR_SH;
			3'b010:		store_instr = INSTR_SW;
			default:	store_instr = INSTR_SW;
		endcase
	end

	// Operações Load
	always_comb begin
		case(funct3)
			3'b000:		load_instr	= INSTR_LB;
			3'b001:		load_instr 	= INSTR_LH;
			3'b010:		load_instr	=	INSTR_LW;
			3'b100:		load_instr 	= INSTR_LBU;
			3'b101:		load_instr	=	INSTR_LHU;
			default:	load_instr 	= INSTR_LW;
		endcase
	end

	// Operações Branch
	always_comb begin
		case(funct3)
			3'b000:		branch_instr = INSTR_BEQ;
			3'b001:		branch_instr = INSTR_BNE;
			3'b100:		branch_instr = INSTR_BLT;
			3'b101:		branch_instr = INSTR_BGE;
			3'b110:		branch_instr = INSTR_BLTU;
			3'b111:		branch_instr = INSTR_BGEU;
			default		branch_instr = INSTR_BEQ;
		endcase 
	end

	// Mux de seleção de operação
	generate

		/********************/
		/**BLOCO RISCV (IM)**/
		/********************/
		if(RISCV_M_CORE) begin

			logic [DCODE_WIDTH-1:0] multdiv_instr;

			// Operações MultDiv
			always_comb begin
				case(funct3)
					3'b000: 	multdiv_instr = INSTR_MUL;
					3'b001: 	multdiv_instr = INSTR_MULH;
					3'b010: 	multdiv_instr = INSTR_MULHSU;
					3'b011: 	multdiv_instr = INSTR_MULHU;
					3'b100: 	multdiv_instr = INSTR_DIV;
					3'b101: 	multdiv_instr = INSTR_DIVU;
					3'b110: 	multdiv_instr = INSTR_REM;
					3'b111: 	multdiv_instr = INSTR_REMU;
					default:	multdiv_instr = INSTR_MUL;
				endcase
			end

			always_comb begin
				if(no_op_flag_i)
					decoded_instr = INSTR_NO_OP;
					instr_type_o = OP_NO_OP;
				else case(opcode)
					OPCODE_COMP: begin		
						decoded_instr = (funct7[0]) ? (multdiv_instr) : (comp_instr);
						instr_type_o = OP_COMP;
					end
					OPCODE_COMPIMM: begin
						decoded_instr = compimm_instr;
						instr_type_o = OP_COMP_IMM;
					end
					OPCODE_STORE: begin
					  decoded_instr = store_instr;
						instr_type_o = OP_STORE;
					end
					OPCODE_LOAD: begin
						decoded_instr = load_instr;
						instr_type_o = OP_LOAD;
					end
					OPCODE_BRANCH: begin
						decoded_instr = branch_instr;
						instr_type_o = OP_BRANCH;
					end
					OPCODE_JALR: begin
						decoded_instr = INSTR_JALR;
						instr_type_o = OP_JALR;
					end
					OPCODE_JAL: begin
						decoded_instr = INSTR_JAL;
						instr_type_o = OP_JAL;
					end
					OPCODE_AUIPC: begin
						decoded_instr = INSTR_AUIPC;
						instr_type_o = OP_AUIPC;
					end
					OPCODE_LUI: begin
						decoded_instr = INSTR_LUI;
						instr_type_o = OP_LUI;
					end
					default: begin
						decoded_instr = INSTR_BAD_INSTR;
						instr_type_o = OP_NO_OP;
					end
				endcase	
				endcase
			end

		end

		/********************/
		/***BLOCO RISCV (I)**/
		/********************/
		else begin

			always_comb begin
				if(no_op_flag_i)
					decoded_instr = INSTR_NO_OP;
					instr_type_o = OP_NO_OP;
				else case(opcode)
					OPCODE_COMP: begin		
						decoded_instr = comp_instr;
						instr_type_o = OP_COMP;
					end
					OPCODE_COMPIMM: begin
						decoded_instr = compimm_instr;
						instr_type_o = OP_COMP_IMM;
					end
					OPCODE_STORE: begin
					  decoded_instr = store_instr;
						instr_type_o = OP_STORE;
					end
					OPCODE_LOAD: begin
						decoded_instr = load_instr;
						instr_type_o = OP_LOAD;
					end
					OPCODE_BRANCH: begin
						decoded_instr = branch_instr;
						instr_type_o = OP_BRANCH;
					end
					OPCODE_JALR: begin
						decoded_instr = INSTR_JALR;
						instr_type_o = OP_JALR;
					end
					OPCODE_JAL: begin
						decoded_instr = INSTR_JAL;
						instr_type_o = OP_JAL;
					end
					OPCODE_AUIPC: begin
						decoded_instr = INSTR_AUIPC;
						instr_type_o = OP_AUIPC;
					end
					OPCODE_LUI: begin
						decoded_instr = INSTR_LUI;
						instr_type_o = OP_LUI;
					end
					default: begin
						decoded_instr = INSTR_BAD_INSTR;
						instr_type_o = OP_NO_OP;
					end
				endcase	
			end

		end

	endgenerate

	assign decoded_instr_o = decoded_instr;

endmodule