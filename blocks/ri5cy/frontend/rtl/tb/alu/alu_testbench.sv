`include "../../HDL/RI5CY/includes/riscv_defines.sv"
`include "../../HDL/RI5CY/alu.sv"

module alu_testbench();
	parameter N_OF_TESTS = 1000;

	logic [WORD_WIDTH-1:0] entrada1, entrada2, saida, ideal;
	logic [ALU_OP_WIDTH-1:0]	operador;
	int i, n_de_erros;
	real media_de_erros;

	alu ALU
		(
			.operand_a_i(entrada1),
			.operand_b_i(entrada2),
			.operator_i(operador),
			.result_o(saida)
		);

	initial begin
		n_de_erros = 0;
		entrada1 = 32'h0;
		entrada2 = 32'h0;
		operador = 5'h0;
		for(i = 0; i < N_OF_TESTS; i++) begin
			entrada1 = $urandom();
			entrada2 = $urandom();
			add_test();
			sub_test();
			and_test();
			or_test();
			xor_test();
			sll_test();
			srl_test();
			sra_test();
			slt_test();
			sltu_test();
		end
		$display("\n");
		$display("*********************************************************");
		$display("**********************FIM_DO_TESTE***********************");
		$display("*********************************************************");
		$display("NUMERO DE TESTES:\t%d", i);
		$display("NÚMERO DE ERROS:\t%d", n_de_erros);
		media_de_erros = $bitstoreal(n_de_erros) / $bitstoreal(i);
		$display("ERROS POR TESTE:\t\t %.2f", media_de_erros);
		$display("\n");
		$finish;
	end

	task add_test();
		operador = ALU_ADD;
		ideal = entrada1 + entrada2;
		#10;
		if(saida !== ideal) begin
			$display("####################ERRO####################");
			$display("TESTE #%3d - OPERAÇÃO ADD", i);
			$display("a = %h\tb = %h", entrada1, entrada2);
			$display("saida = %h", saida);
			$display("ideal = %h", ideal);
			n_de_erros = n_de_erros + 1;
		end
		#10;
	endtask

	task sub_test();
		operador = ALU_SUB;
		ideal = entrada1 - entrada2;
		#10;
		if(saida !== ideal) begin
			$display("####################ERRO####################");
			$display("TESTE #%3d - OPERAÇÃO SUB", i);
			$display("a = %h\tb = %h", entrada1, entrada2);
			$display("saida = %h", saida);
			$display("ideal = %h", ideal);
			n_de_erros = n_de_erros + 1;
		end
		#10;
	endtask

	task and_test();
		operador = ALU_AND;
		ideal = entrada1 & entrada2;
		#10;
		if(saida !== ideal) begin
			$display("####################ERRO####################");
			$display("TESTE #%3d - OPERAÇÃO AND", i);
			$display("a = %h\tb = %h", entrada1, entrada2);
			$display("saida = %h", saida);
			$display("ideal = %h", ideal);
			n_de_erros = n_de_erros + 1;
		end
		#10;
	endtask

	task or_test();
		operador = ALU_OR;
		ideal = entrada1 | entrada2;
		#10;
		if(saida !== ideal) begin
			$display("####################ERRO####################");
			$display("TESTE #%3d - OPERAÇÃO OR", i);
			$display("a = %h\tb = %h", entrada1, entrada2);
			$display("saida = %h", saida);
			$display("ideal = %h", ideal);
			n_de_erros = n_de_erros + 1;
		end
		#10;
	endtask

	task xor_test();
		operador = ALU_XOR;
		ideal = entrada1 ^ entrada2;
		#10;
		if(saida !== ideal) begin
			$display("####################ERRO####################");
			$display("TESTE #%3d - OPERAÇÃO XOR", i);
			$display("a = %h\tb = %h", entrada1, entrada2);
			$display("saida = %h", saida);
			$display("ideal = %h", ideal);
			n_de_erros = n_de_erros + 1;
		end
		#10;
	endtask

	task sll_test();
		operador = ALU_SLL;
		ideal = entrada1 << entrada2[4:0];
		#10;
		if(saida !== ideal) begin
			$display("####################ERRO####################");
			$display("TESTE #%3d - OPERAÇÃO SLL", i);
			$display("a = %h\tb = %h", entrada1, entrada2);
			$display("saida = %b", saida);
			$display("ideal = %b", ideal);
			n_de_erros = n_de_erros + 1;
		end
		#10;
	endtask

	task srl_test();
		operador = ALU_SRL;
		ideal = entrada1 >> entrada2[4:0];
		#10;
		if(saida !== ideal) begin
			$display("####################ERRO####################");
			$display("TESTE #%3d - OPERAÇÃO SRL", i);
			$display("a = %h\tb = %h", entrada1, entrada2);
			$display("saida = %b", saida);
			$display("ideal = %b", ideal);
			n_de_erros = n_de_erros + 1;
		end
		#10;
	endtask

	task sra_test();
		operador = ALU_SRA;
		ideal = $signed(entrada1) >>> entrada2[4:0];
		#10;
		if(saida !== ideal) begin
			$display("####################ERRO####################");
			$display("TESTE #%3d - OPERAÇÃO SRA", i);
			$display("a = %h\tb = %h", entrada1, entrada2);
			$display("saida = %b", saida);
			$display("ideal = %b", ideal);
			n_de_erros = n_de_erros + 1;
		end
		#10;
	endtask

	task slt_test();
		operador = ALU_SLT;
		ideal = $signed(entrada1) < $signed(entrada2);
		#10;
		if(saida !== ideal) begin
			$display("####################ERRO####################");
			$display("TESTE #%3d - OPERAÇÃO SLT", i);
			$display("a = %h\tb = %h", entrada1, entrada2);
			$display("saida = %b", saida);
			$display("ideal = %b", ideal);
			n_de_erros = n_de_erros + 1;
		end
		#10;
	endtask

	task sltu_test();
		operador = ALU_SLTU;
		ideal = $unsigned(entrada1) < $unsigned(entrada2);
		#10;
		if(saida !== ideal) begin
			$display("####################ERRO####################");
			$display("TESTE #%3d - OPERAÇÃO SLTU", i);
			$display("a = %h\tb = %h", entrada1, entrada2);
			$display("saida = %b", saida);
			$display("ideal = %b", ideal);
			n_de_erros = n_de_erros + 1;
		end
		#10;
	endtask

endmodule