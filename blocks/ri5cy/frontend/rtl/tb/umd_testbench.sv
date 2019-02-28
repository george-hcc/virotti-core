`include "../../HDL/RI5CY/umd.sv"

module alu_testbench();
	parameter N_OF_TESTS = 1000;

	logic [WORD_WIDTH-1:0] entrada1, entrada2, saida, ideal;
	logic [ALU_OP_WIDTH-1:0]	operador;
	int i, n_de_erros;
	real media_de_erros;

	umd UMD
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
			mul_test();
			div_test();
			
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

	task mul_test();
		operador = 3'b000;
		ideal = entrada1 * entrada2;
		#10;
		if(saida !== ideal) begin
			$display("####################ERRO####################");
			$display("TESTE #%3d - OPERAÇÃO MUL", i);
			$display("a = %h\tb = %h", entrada1, entrada2);
			$display("saida = %h", saida);
			$display("ideal = %h", ideal);
			n_de_erros = n_de_erros + 1;
		end
		#10;
	endtask

	task div_test();
		operador = 3'b100;
		ideal = entrada1 % entrada2;
		#10;
		if(saida !== ideal) begin
			$display("####################ERRO####################");
			$display("TESTE #%3d - OPERAÇÃO DIV", i);
			$display("a = %h\tb = %h", entrada1, entrada2);
			$display("saida = %h", saida);
			$display("ideal = %h", ideal);
			n_de_erros = n_de_erros + 1;
		end
		#10;
	endtask

	

endmodule