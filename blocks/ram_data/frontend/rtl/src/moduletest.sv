import axi_4_FULL_Types::*;

module test;

  parameter DATA_WIDTH = 32;
  parameter ADD_WIDTH = 3;
  parameter LINHAS_DE_MEMORIA = 8;
  parameter ID_WIDTH = 4;

  parameter MEM_0 = 0;
    
  
  logic ACLK, ARESETn;

  //Write Address channel signals pg A2-29
  logic [ID_WIDTH-1:0] AWID;
  logic [ADD_WIDTH-1+2:0] AWADDR;
  logic [7:0] AWLEN;
  logic [2:0] AWSIZE;
  logic [3:0] AWCACHE;
  logic [3:0] AWQOS;
  logic [3:0] AWREGION;
  //AWUSER;
  logic AWVALID;
  logic AWREADY;

  //Write Data channel signals pg A2-30

  logic [DATA_WIDTH-1:0] WDATA;
  logic [3:0] WSTRB;
  logic WLAST;
  //WUSER;
  logic WVALID;
  logic WREADY;

  //Write Response channel signals pg A2-31
  logic [ID_WIDTH-1:0] BID;
  //BUSER;
  logic BVALID;
  logic BREADY;

  //Read Address channel signals pg A2-32
  logic [ID_WIDTH-1:0] ARID;
  logic [ADD_WIDTH-1+2:0] ARADDR;
  logic [7:0] ARLEN = 8'd5;
  logic [2:0] ARSIZE;
  logic [3:0] ARCACHE;
  logic [3:0] ARQOS;
  logic [3:0] ARREGION = '0;
  //ARUSER;
  logic ARVALID;
  logic ARREADY;

  //Read Data channel signals pg A2-33
  logic [ID_WIDTH-1:0] RID;
  logic [DATA_WIDTH-1:0] RDATA;
  logic RLAST;
  logic RVALID;
  logic RREADY;


  BURST ARBURST, AWBURST;
  axi4_resp_el RRESP, BRESP;


  
  RAM rr(
  //Global signals pg A2-28
  ACLK,
  ARESETn,  // Asynchronous reset active low
  
  //Write Address channel signals pg A2-29
  AWID,
  AWADDR,
  AWLEN,
  AWSIZE,
  AWBURST,
  AWCACHE,
  AWQOS,
  AWREGION,
  AWVALID,
  AWREADY,

  //Write Data channel signals pg A2-30
  WDATA,
  WSTRB,
  WLAST,
  WVALID,
  WREADY,

  //Write Response channel signals pg A2-31
  BID,
  BRESP,
  BVALID,
  BREADY,

  //Read Address channel signals pg A2-32
  ARID,
  ARADDR,
  ARLEN,
  ARSIZE,
  ARBURST,
  ARCACHE,
  ARQOS,
  ARREGION,
  ARVALID,
  ARREADY,

  //Read Data channel signals pg A2-33
  RID,
  RDATA,
  RRESP,
  RLAST,
  RVALID,
  RREADY,

  );
  
  
  logic Envio_duplo_de_escrita = '0;
  
  
  
  
  initial begin
    //$dumpfile("dump.vcd");
    //$dumpvars(0,test, rr);
    
    //Variáveis gerais
    ACLK = 1'b0;
    ARESETn = 1'b1;
    
    //Leitura
    ARVALID = '0;
    ARADDR = 5'd1;
    RREADY = '0;
    ARSIZE = 3'd1;
    ARREGION = '0;
    ARLEN = 8'd5;
    ARBURST = INCR;

    //Escrita
    AWVALID = '0;
    AWADDR = '0;
    WVALID = '0;
    WDATA = '0;
    
    
    
    //Simulação
    #1 ARESETn = ~ARESETn;
    #2 ARESETn = ~ARESETn;
    //#28 ARVALID <= '1;
    //#50 begin ARVALID <= '1; ARBURST = WRAP; ARADDR = 5'd6; ARLEN = 8'd3;end
    #28 begin AWVALID <= '1; AWADDR <= 5'd6; WVALID <= '1; WDATA <= '1; 
      BREADY <= '1; AWREGION <= '0; AWBURST <= WRAP;
      WSTRB <= 4'b1010; AWLEN <= 8'd3; AWSIZE <= 3'd1; end

    #200;
    
    $finish;
  end
  
  logic [DATA_WIDTH-1:0] Saida_Reg;
  always @(posedge ACLK or negedge ARESETn) begin : proc_
    if(~ARESETn) begin
    end else begin
        if(ARVALID && ARREADY) begin
          ARVALID <= '0;
          RREADY <= '1;
        end
        if(RVALID && RREADY) begin
          Saida_Reg <= RDATA;
        end
    end
  end
  //Variação do Clock
  always #2 ACLK = ~ACLK;
  
  
  
endmodule
