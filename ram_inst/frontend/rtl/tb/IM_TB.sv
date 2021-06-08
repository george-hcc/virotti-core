`include "InstMem.sv"
module IM_TB ();


logic r_Clock = '0;
logic rst_n = '0;
logic instr_req_r;
logic [31:0]instr_addr_r;
logic [31:0]instr_rdata_r;
logic instr_rvalid_r;
logic instr_gnd_r;
logic [31:0]dado_lido;

InstMem I 
(
  .clk(r_Clock),
  .rst_n(rst_n),

  .instr_req_i(instr_req_r),
  .instr_addr_i(instr_addr_r),

  .instr_rdata_o(instr_rdata_r),
  .instr_rvalid_o(instr_rvalid_r),
  .instr_gnd_o(instr_gnd_r)
);

  always #2 r_Clock <= !r_Clock;
    initial
      begin
        instr_req_r = '1;
        instr_addr_r <= 32'b00000000_00000000_00000000_00000000;
        #1 rst_n <= '1;
        @(posedge r_Clock)
          begin 

            instr_addr_r <=  instr_addr_r + 3'b100;
          end
        @(posedge r_Clock)
          begin 
            instr_addr_r <=  instr_addr_r + 3'b100;
          end
        @(posedge r_Clock)
          begin 
            instr_addr_r <=  instr_addr_r + 3'b100;
          end


        
        @(posedge r_Clock);
        @(posedge r_Clock);

       
        #300;
        $finish();
      end

always_ff @(posedge r_Clock)
begin 
  if(instr_rvalid_r) begin
    dado_lido <= instr_rdata_r;
  end
end

endmodule
