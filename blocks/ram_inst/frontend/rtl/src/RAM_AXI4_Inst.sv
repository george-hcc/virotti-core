
module RAM_Inst (
  Add_PC,
  Pc_Out,

  //Global signals pg A2-28
  ACLK,
  ARESETn,  // Asynchronous reset active low
  
  //Write Address channel signals pg A2-29
  AWID,
  AWADDR,
  AWLEN,
  AWSIZE,
  AWBURST,
  //AWLOCK -> Nao e suportado no AXI4, mas era no AXI3
  AWCACHE,
  AWQOS,
  AWREGION,
  //AWUSER -> Permitido, porem nao recomendado. Devido a erros de usuarios iguais.
  AWVALID,
  AWREADY,

  //Write Data channel signals pg A2-30
  //WID -> Nao usa no AXI4, so no AXI3
  WDATA,
  WSTRB,
  WLAST,
  //WUSER -> Permitido, porem nao recomendado. Devido a erros de usuarios iguais.
  WVALID,
  WREADY,

  //Write Response channel signals pg A2-31
  BID,
  BRESP,
  //BUSER -> Permitido, porem nao recomendado. Devido a erros de usuarios iguais.
  BVALID,
  BREADY,

  //Read Address channel signals pg A2-32
  ARID,
  ARADDR,
  ARLEN,
  ARSIZE,
  ARBURST,
  //ARLOCK -> Nao e suportado no AXI4, mas era no AXI3
  ARCACHE,
  ARQOS,
  ARREGION,
  //ARUSER -> Permitido, porem nao recomendado. Devido a erros de usuarios iguais.
  ARVALID,
  ARREADY,

  //Read Data channel signals pg A2-33
  RID,
  RDATA,
  RRESP,
  RLAST,
  //RUSER -> Permitido, porem nao recomendado. Devido a erros de usuarios iguais.
  RVALID,
  RREADY,

  );
  
  parameter DATA_WIDTH = 32;
  parameter ADD_WIDTH = 3;
  parameter LINHAS_DE_MEMORIA = 8;
  parameter ID_WIDTH = 4;

  parameter MEM_0 = 0;
          
  enum logic [1:0]
    {
      ADD_DE_ESCRITA_RECEBIDO = 2'd1,
      DATA_DE_ESCRITA_RECEBIDO = 2'd2,
      USANDO_BVALID_BREADY = 2'd3
    } Estado_De_Trabalho_Escrita;
          
  Trabalho_Leitura Estado_De_Trabalho_Leitura;

  /*enum logic [1:0]
    {
      ESPERANDO = 2'd0,
        ADD_DE_LEITURA_RECEBIDO = 2'd1,
        PROXIMA_LEITURA = 2'd2,
        DADO_DE_LEITURA_TRANSMITIDO = 2'd3
    } Estado_De_Trabalho_Leitura;*/

/*Nos bits de AxCACHE teremos :
B   [0]   -> Bufferable ? Se sim, sim. Se nao, nao.     ***Serve para todos***
C   [1]   -> Cacheable ?
RA  [2]   -> Read-allocate ?
WA  [3]   -> Write-allocate ?

O bit RA NAO pode estar ativo quadno o bit C estiver baixo.
O bit WA NAO pode estar ativo quadno o bit C estiver baixo.

Essas explicaçoes estao na pg A4-59. Ainda tenho algumas duvidas.
*/
  input [ADD_WIDTH-1+2:0] Add_PC;
  output logic [DATA_WIDTH-1:0] Pc_Out;
  input ACLK, ARESETn;

  //Write Address channel signals pg A2-29
  input [ID_WIDTH-1:0] AWID;
  input [ADD_WIDTH-1+2:0] AWADDR;// + 2 por causa do numero de bytes
  input [7:0] AWLEN;
  input [2:0] AWSIZE;
  input [3:0] AWCACHE;
  input [3:0] AWQOS;
  input [3:0] AWREGION;
  //AWUSER;
  input AWVALID;
  output logic AWREADY;

  //Write Data channel signals pg A2-30

  input [DATA_WIDTH-1:0] WDATA;
  input [3:0] WSTRB;
  input WLAST;
  //WUSER;
  input WVALID;
  output logic WREADY;

  //Write Response channel signals pg A2-31
  input [ID_WIDTH-1:0] BID;
  //BUSER;
  output logic BVALID;
  input BREADY;

  //Read Address channel signals pg A2-32
  input [ID_WIDTH-1:0] ARID;
  input [ADD_WIDTH-1+2:0] ARADDR;
  input [7:0] ARLEN;
  input [2:0] ARSIZE;
  input [3:0] ARCACHE;
  input [3:0] ARQOS;
  input [3:0] ARREGION;
  //ARUSER;
  input ARVALID;
  output logic ARREADY;

  //Read Data channel signals pg A2-33
  input [ID_WIDTH-1:0] RID;
  output logic [DATA_WIDTH-1:0] RDATA;
  output logic RLAST;
  //RUSER;
  output logic RVALID;
  input RREADY;


  input BURST ARBURST, AWBURST;



  //Fim da declaração. ****************Agora Code****************

  /*typedef enum logic [1:0]
  {
    FIXED     = 2'b00,
    INCR      = 2'b01,
    WRAP      = 2'b10,
    RESERVED  = 2'b11
  } BURST;*/


  BURST Tipo_De_Burst_R, Tipo_De_Burst_W;



  logic [7:0] Burst_Size_W, Burst_Size_R;         //Lembrando que ele vai de 0-127. Tem que ter cuidado para nao achar que vai ate 128, como deveria,
  //Burst_Size_R = 1'b1 << ARSIZE;                // e tambem nao queria usar mais um bit so p isso, seria um desperdicio muito grande.
  //Burst_Size_W = 1'b1 << AWSIZE; 



  logic [8:0] Burst_Length_R, Burst_Length_W;     //Lembrar que o Burst_Length_x tem que somar mais um, porem nao quis usar mais um bit so p isso.
  //Burst_Length_R = ARLEN + 1'b1;
  //Burst_Length_W = AWLEN + 1'b1;
  logic [8:0] Burst_Length_R_WRAP, Burst_Length_W_WRAP;
  /*output enum logic [1:0]
    {
    OKAY = 2'b00,
    //EXOKAY = 2'b01,
    SLVERR = 2'b10,
    DECERR = 2'b11
    }RRESP, BRESP;*/
  output axi4_resp_el RRESP, BRESP;


  //Necessário leitura
  logic [3:0] CACHE_De_Leitura;
  logic [ADD_WIDTH-1+2:2] Add_De_Leitura_Linha;
  logic [1:0] Add_De_Leitura_Byte;
  logic [3:0] Qos_De_Leitura;
  logic [3:0] Regiao_Da_Leitura;
  //Auxiliar leitura
  logic Erro_De_Tamanho_De_Transm_Leitura;
  logic Erro_De_Tamanho_De_Align_Leitura;
  logic Erro_De_Tamanho_De_Byte_Leitura;
  logic [6:0] Data_Total_Transmitido_Leitura;
  logic [ADD_WIDTH-1 + 2:0] Wrap_Boundary_Leitura;
  logic [ADD_WIDTH-1 + 2:0] Add_Limite_Leitura;


  //Necessário escrita
  logic [3:0] CACHE_De_Escrita;
  logic [ADD_WIDTH-1+2:2] Add_De_Escrita_Linha;
  logic [1:0] Add_De_Escrita_Byte;
  logic [3:0] Qos_De_Escrita;
  logic [3:0] Regiao_Da_Escrita;
  logic [DATA_WIDTH-1:0] Data_De_Escrita;
  //Auxiliar leitura
  logic Erro_De_Tamanho_De_Transm_Escrita;
  logic Erro_De_Tamanho_De_Align_Escrita;
  logic Erro_De_Tamanho_De_Byte_Escrita;
  logic [6:0] Data_Total_Transmitido_Escrita;
  logic [ADD_WIDTH-1 + 2:0] Wrap_Boundary_Escrita;
  logic [ADD_WIDTH-1 + 2:0] Add_Limite_Escrita;
  //Auxiliar escrita



  logic [DATA_WIDTH-1:0] Mem_RAM [LINHAS_DE_MEMORIA-1:0];
  

  initial
    $readmemh("Mem_RAM.hex",Mem_RAM);












  always_ff @(posedge ACLK or negedge ARESETn)
    begin
     if(~ARESETn)
        begin
          //Para leitura!!!
          ARREADY <= '1;
          RVALID <= '0;
          Burst_Length_R <= '0;
          Burst_Length_R_WRAP <= '0;
          Burst_Size_R <= '0;
          Regiao_Da_Leitura <= '0;
          RLAST <= '0;
          Add_De_Leitura_Linha <= '0;
          Add_De_Leitura_Byte <= '0;
          CACHE_De_Leitura <= '0;
          Estado_De_Trabalho_Leitura <= ESPERANDO;
          Qos_De_Leitura <= '0;
          Tipo_De_Burst_R <= RESERVED;
          Erro_De_Tamanho_De_Transm_Leitura <= '0;
          Erro_De_Tamanho_De_Byte_Leitura <= '0;
          Erro_De_Tamanho_De_Align_Leitura <= '0;

            //Para escrita!!!
          AWREADY <= '1;
          WREADY <= '0;
        end
     else 
        begin
          if(ARREADY && ARVALID) begin
            Add_De_Leitura_Linha <= ARADDR[ADD_WIDTH-1+2:2];
            Add_De_Leitura_Byte <= ARADDR[1:0];
            Burst_Length_R <= ARLEN;
            Burst_Length_R_WRAP <= ARLEN + 1'b1;
            Burst_Size_R <= 1'b1 << ARSIZE;
            Tipo_De_Burst_R <= ARBURST;
            CACHE_De_Leitura <= ARCACHE;
            Qos_De_Leitura <= ARQOS;
            Regiao_Da_Leitura <= ARREGION;
            ARREADY <= '0;
            Estado_De_Trabalho_Leitura <= ADD_DE_LEITURA_RECEBIDO;
            RVALID <= '1;
            Data_Total_Transmitido_Leitura <= '1;
            

            case (ARLEN + 1'b1)

              9'b10000:begin 
                case (1'b1 << ARSIZE)

                  8'b100:begin 
                      Data_Total_Transmitido_Leitura <= 7'b1000000;//64
                      Wrap_Boundary_Leitura <= (ARADDR >> 6) << 6;
                  end
                    
                  8'b010:begin 
                      Data_Total_Transmitido_Leitura <= 7'b0100000;//32
                      Wrap_Boundary_Leitura <= (ARADDR >> 5) << 5;
                  end

                  8'b001:begin 
                      Data_Total_Transmitido_Leitura <= 7'b0010000;//16
                      Wrap_Boundary_Leitura <= (ARADDR >> 4) << 4;
                  end

                  default : ;
                endcase
              end
                
              9'b01000:begin 
                case (1'b1 << ARSIZE)

                  8'b100:begin 
                      Data_Total_Transmitido_Leitura <= 7'b0100000;//32
                      Wrap_Boundary_Leitura <= (ARADDR >> 5) << 5;
                  end
                    
                  8'b010:begin 
                      Data_Total_Transmitido_Leitura <= 7'b0010000;//16
                      Wrap_Boundary_Leitura <= (ARADDR >> 4) << 4;
                  end

                  8'b001:begin 
                      Data_Total_Transmitido_Leitura <= 7'b0001000;//8
                      Wrap_Boundary_Leitura <= (ARADDR >> 3) << 3;
                  end

                  default : ;
                endcase
              end

              9'b00100:begin 
                case (1'b1 << ARSIZE)

                  8'b100:begin 
                      Data_Total_Transmitido_Leitura <= 7'b0010000;
                      Wrap_Boundary_Leitura <= (ARADDR >> 4) << 4;
                  end
                    
                  8'b010:begin 
                      Data_Total_Transmitido_Leitura <= 7'b0001000;
                      Wrap_Boundary_Leitura <= (ARADDR >> 3) << 3;
                  end

                  8'b001:begin 
                      Data_Total_Transmitido_Leitura <= 7'b0000100;
                      Wrap_Boundary_Leitura <= (ARADDR >> 2) << 2;
                  end

                  default : ;
                endcase
              end

              9'b00010:begin 
                case (1'b1 << ARSIZE)

                  8'b100:begin 
                      Data_Total_Transmitido_Leitura <= 7'b0001000;
                      Wrap_Boundary_Leitura <= (ARADDR >> 3) << 3;
                  end
                    
                  8'b010:begin 
                      Data_Total_Transmitido_Leitura <= 7'b0000100;
                      Wrap_Boundary_Leitura <= (ARADDR >> 2) << 2;
                  end

                  8'b001:begin 
                      Data_Total_Transmitido_Leitura <= 7'b0000010;
                      Wrap_Boundary_Leitura <= (ARADDR >> 1) << 1;
                  end

                  default : ;
                endcase
              end

              default : ;
            endcase
          end

          if(RREADY && RVALID) begin
            if(Burst_Length_R != '0) begin
              Burst_Length_R <= Burst_Length_R - 1'b1;
              case (Tipo_De_Burst_R)
                FIXED:
                  begin
                    Add_De_Leitura_Linha <= Add_De_Leitura_Linha;
                    Add_De_Leitura_Byte <= '0;
                  end

              INCR:
                begin
                  case (Burst_Size_R)
                    8'd1:begin 
                      Add_De_Leitura_Byte <= Add_De_Leitura_Byte + 1'b1;
                      if(Add_De_Leitura_Byte + 1'b1 == 2'b00) begin
                        Add_De_Leitura_Linha <= Add_De_Leitura_Linha + 1'b1;
                      end
                    end

                    8'd2:begin 
                      if(Add_De_Leitura_Byte < 2'b10) begin
                        Add_De_Leitura_Byte <= 2'b10;
                        Add_De_Leitura_Linha <= Add_De_Leitura_Linha;
                      end
                      else begin 
                        Add_De_Leitura_Byte <= 2'b00;
                        Add_De_Leitura_Linha <= Add_De_Leitura_Linha + 1'b1;
                      end
                    end

                    8'd4:begin 
                      Add_De_Leitura_Byte <= 2'b00;
                      Add_De_Leitura_Linha <= Add_De_Leitura_Linha + 1'b1;
                    end
                    default :Erro_De_Tamanho_De_Byte_Leitura <= '1;
                  endcase
                end

              WRAP:
                begin
                  Add_Limite_Leitura <= Wrap_Boundary_Leitura + Data_Total_Transmitido_Leitura;
                  if(Burst_Length_R_WRAP == 9'd2 || Burst_Length_R_WRAP == 9'd4 || Burst_Length_R_WRAP == 9'd8 || Burst_Length_R_WRAP == 9'd16) begin
                    Erro_De_Tamanho_De_Transm_Leitura <= '0;

                    if({Add_De_Leitura_Linha, Add_De_Leitura_Byte} == Add_Limite_Leitura) begin
                      Add_De_Leitura_Linha <= Wrap_Boundary_Leitura[ADD_WIDTH-1+2:2];
                      Add_De_Leitura_Byte <= Wrap_Boundary_Leitura[1:0];
                    end
                    else begin 

                      case (Burst_Size_R)
                        8'd1:begin
                          Add_De_Leitura_Byte <= Add_De_Leitura_Byte + 1'b1;
                          if(Add_De_Leitura_Byte + 1'b1 == 2'b00) begin
                            Add_De_Leitura_Linha <= Add_De_Leitura_Linha + 1'b1;
                          end
                        end

                        8'd2:begin 
                          if(Add_De_Leitura_Byte[0]) begin
                            Erro_De_Tamanho_De_Align_Leitura <= 1;
                          end
                          else begin 
                            if(Add_De_Leitura_Byte < 2'b10) begin
                              Add_De_Leitura_Byte <= 2'b10;
                              Add_De_Leitura_Linha <= Add_De_Leitura_Linha;
                            end
                            else begin 
                              Add_De_Leitura_Byte <= 2'b00;
                              Add_De_Leitura_Linha <= Add_De_Leitura_Linha + 1'b1;
                            end
                          end
                        end

                        8'd4:begin 
                          if(Add_De_Leitura_Byte[1:0] != 2'b00) begin
                            Erro_De_Tamanho_De_Align_Leitura <= 1;
                          end
                          else begin 
                            Add_De_Leitura_Byte <= 2'b00;
                            Add_De_Leitura_Linha <= Add_De_Leitura_Linha + 1'b1;
                          end
                        end

                        default :Erro_De_Tamanho_De_Byte_Leitura <= '1;
                      endcase
                    end
                  end

                  else begin 
                    Erro_De_Tamanho_De_Transm_Leitura <= '1;
                  end
                end

                default : Add_De_Leitura_Linha <= 'x;
              endcase

              Estado_De_Trabalho_Leitura <= ADD_DE_LEITURA_RECEBIDO;
              if(Burst_Length_R - 1'b1 == '0)
                begin
                  RLAST <= '1;
                end
            end
            else begin
              Tipo_De_Burst_R <= RESERVED;
              Estado_De_Trabalho_Leitura <= DADO_DE_LEITURA_TRANSMITIDO;
              RVALID <= '0;
              RLAST <= '0;
              ARREADY <= '1;
            end
          end

          if(AWREADY && AWVALID) begin
            Add_De_Escrita_Linha <= AWADDR[ADD_WIDTH-1+2:2];
            Add_De_Escrita_Byte <= AWADDR[1:0];
            Burst_Length_W <= AWLEN + 1'b1;
            Burst_Length_W_WRAP <= AWLEN + 1'b1;
            Burst_Size_W <= 1'b1 << AWSIZE;
            Tipo_De_Burst_W <= AWBURST;
            CACHE_De_Escrita <= AWCACHE;
            Qos_De_Escrita <= AWQOS;
            Regiao_Da_Escrita <= AWREGION;
            AWREADY <= '0;
            WREADY <= '1;
            Data_Total_Transmitido_Escrita <= '1;
            Data_De_Escrita <= WDATA;
            

            case (AWLEN + 1'b1)

              9'b10000:begin 
                case (1'b1 << ARSIZE)

                  8'b100:begin 
                      Data_Total_Transmitido_Escrita <= 7'b1000000;//64
                      Wrap_Boundary_Escrita <= (ARADDR >> 6) << 6;
                  end
                    
                  8'b010:begin 
                      Data_Total_Transmitido_Escrita <= 7'b0100000;//32
                      Wrap_Boundary_Leitura <= (ARADDR >> 5) << 5;
                  end

                  8'b001:begin 
                      Data_Total_Transmitido_Escrita <= 7'b0010000;//16
                      Wrap_Boundary_Escrita <= (ARADDR >> 4) << 4;
                  end

                  default : ;
                endcase
              end
                
              9'b01000:begin 
                case (1'b1 << ARSIZE)

                  8'b100:begin 
                      Data_Total_Transmitido_Escrita <= 7'b0100000;//32
                      Wrap_Boundary_Escrita <= (ARADDR >> 5) << 5;
                  end
                    
                  8'b010:begin 
                      Data_Total_Transmitido_Escrita <= 7'b0010000;//16
                      Wrap_Boundary_Escrita <= (ARADDR >> 4) << 4;
                  end

                  8'b001:begin 
                      Data_Total_Transmitido_Escrita <= 7'b0001000;//8
                      Wrap_Boundary_Escrita <= (ARADDR >> 3) << 3;
                  end

                  default : ;
                endcase
              end

              9'b00100:begin 
                case (1'b1 << ARSIZE)

                  8'b100:begin 
                      Data_Total_Transmitido_Escrita <= 7'b0010000;
                      Wrap_Boundary_Escrita <= (ARADDR >> 4) << 4;
                  end
                    
                  8'b010:begin 
                      Data_Total_Transmitido_Escrita <= 7'b0001000;
                      Wrap_Boundary_Escrita <= (ARADDR >> 3) << 3;
                  end

                  8'b001:begin 
                      Data_Total_Transmitido_Escrita <= 7'b0000100;
                      Wrap_Boundary_Escrita <= (ARADDR >> 2) << 2;
                  end

                  default : ;
                endcase
              end

              9'b00010:begin 
                case (1'b1 << ARSIZE)

                  8'b100:begin 
                      Data_Total_Transmitido_Escrita <= 7'b0001000;
                      Wrap_Boundary_Escrita <= (ARADDR >> 3) << 3;
                  end
                    
                  8'b010:begin 
                      Data_Total_Transmitido_Escrita <= 7'b0000100;
                      Wrap_Boundary_Escrita <= (ARADDR >> 2) << 2;
                  end

                  8'b001:begin 
                      Data_Total_Transmitido_Escrita <= 7'b0000010;
                      Wrap_Boundary_Escrita <= (ARADDR >> 1) << 1;
                  end

                  default : ;
                endcase
              end

              default : ;
            endcase
          end 

          if(WVALID && WREADY) begin
            WREADY <= '0;
            BVALID <= '1;
            if(Burst_Length_W != '0) begin
              Burst_Length_W <= Burst_Length_W - 1'b1;
              case (Tipo_De_Burst_W)
                FIXED:
                  begin
                    BRESP <= OKAY;
                    case (Regiao_Da_Escrita) 
                      MEM_0: begin
                        case (Burst_Size_W)
                          8'd1:begin
                            case (Add_De_Escrita_Byte)
                              2'd0:begin
                                if(WSTRB[0]) begin
                                  Mem_RAM [Add_De_Escrita_Linha][7:0] <= WDATA[7:0];
                                end
                              end
                              2'd1:begin
                                if(WSTRB[0]) begin
                                    Mem_RAM [Add_De_Escrita_Linha][15:8] <= WDATA[7:0];
                                  end
                              end
                              2'd2:begin
                                if(WSTRB[0]) begin
                                    Mem_RAM [Add_De_Escrita_Linha][23:16] <= WDATA[7:0];
                                  end
                              end
                              2'd3:begin
                                if(WSTRB[0]) begin
                                    Mem_RAM [Add_De_Escrita_Linha][31:24] <= WDATA[7:0];
                                  end
                              end
                            
                              default : ;

                            endcase
                          end

                          8'd2:begin
                            case (Add_De_Escrita_Byte)
                              2'd0:begin
                                if(WSTRB[0]) begin
                                  Mem_RAM [Add_De_Escrita_Linha][7:0] <= WDATA[7:0];
                                end
                                if(WSTRB[1]) begin
                                  Mem_RAM [Add_De_Escrita_Linha][15:8] <= WDATA[15:8];
                                end
                            end
                            2'd1:begin
                              if(WSTRB[1]) begin
                                  Mem_RAM [Add_De_Escrita_Linha][15:8] <= WDATA[15:8];
                                end
                            end
                            2'd2:begin
                              if(WSTRB[0]) begin
                                  Mem_RAM [Add_De_Escrita_Linha][23:16] <= WDATA[7:0];
                                end
                                if(WSTRB[1]) begin
                                  Mem_RAM [Add_De_Escrita_Linha][31:24] <= WDATA[15:8];
                                end
                            end
                            2'd3:begin
                              if(WSTRB[1]) begin
                                  Mem_RAM [Add_De_Escrita_Linha][31:24] <= WDATA[15:8];
                                end
                            end

                              default : ;
                            endcase
                          end

                          8'd4:begin
                            case (Add_De_Escrita_Byte)
                              2'd0:begin
                                if(WSTRB[0]) begin
                                  Mem_RAM [Add_De_Escrita_Linha][7:0] <= WDATA[7:0];
                                end
                                if(WSTRB[1]) begin
                                  Mem_RAM [Add_De_Escrita_Linha][15:8] <= WDATA[15:8];
                                end
                                if(WSTRB[2]) begin
                                  Mem_RAM [Add_De_Escrita_Linha][23:16] <= WDATA[23:16];
                                end
                                if(WSTRB[3]) begin
                                  Mem_RAM [Add_De_Escrita_Linha][31:24] <= WDATA[31:24];
                                end
                            end
                            2'd1:begin
                                if(WSTRB[1]) begin
                                  Mem_RAM [Add_De_Escrita_Linha][15:8] <= WDATA[15:8];
                                end
                                if(WSTRB[2]) begin
                                  Mem_RAM [Add_De_Escrita_Linha][23:16] <= WDATA[23:16];
                                end
                                if(WSTRB[3]) begin
                                  Mem_RAM [Add_De_Escrita_Linha][31:24] <= WDATA[31:24];
                                end
                            end
                            2'd2:begin
                                if(WSTRB[2]) begin
                                  Mem_RAM [Add_De_Escrita_Linha][23:16] <= WDATA[23:16];
                                end
                                if(WSTRB[3]) begin
                                  Mem_RAM [Add_De_Escrita_Linha][31:24] <= WDATA[31:24];
                                end
                            end
                            2'd3:begin
                              if(WSTRB[3]) begin
                                  Mem_RAM [Add_De_Escrita_Linha][31:24] <= WDATA[31:24];
                                end 
                            end

                              default : ;
                            endcase
                          end
                          default :begin 
                            BRESP <= SLVERR;
                          end
                        endcase
                      end


                      default : begin
                        BRESP <= SLVERR;
                      end
                    endcase
                  end

                INCR:
                  begin
                    BRESP <= OKAY;
                    case (Regiao_Da_Escrita)
                      MEM_0: begin
                        case (Burst_Size_W)
                          8'd1:begin
                            case (Add_De_Escrita_Byte)
                              2'd0:begin
                                if(WSTRB[0]) begin
                                  Mem_RAM [Add_De_Escrita_Linha][7:0] <= WDATA[7:0];
                                end
                              end
                              2'd1:begin
                                if(WSTRB[0]) begin
                                    Mem_RAM [Add_De_Escrita_Linha][15:8] <= WDATA[7:0];
                                  end
                              end
                              2'd2:begin
                                if(WSTRB[0]) begin
                                    Mem_RAM [Add_De_Escrita_Linha][23:16] <= WDATA[7:0];
                                  end
                              end
                              2'd3:begin
                                if(WSTRB[0]) begin
                                    Mem_RAM [Add_De_Escrita_Linha][31:24] <= WDATA[7:0];
                                  end
                              end
                            
                              default : ;

                            endcase
                          end

                          8'd2:begin
                            case (Add_De_Escrita_Byte)
                              2'd0:begin
                                if(WSTRB[0]) begin
                                  Mem_RAM [Add_De_Escrita_Linha][7:0] <= WDATA[7:0];
                                end
                                if(WSTRB[1]) begin
                                  Mem_RAM [Add_De_Escrita_Linha][15:8] <= WDATA[15:8];
                                end
                              end
                              2'd1:begin
                                if(WSTRB[1]) begin
                                    Mem_RAM [Add_De_Escrita_Linha][15:8] <= WDATA[15:8];
                                  end
                              end
                              2'd2:begin
                                if(WSTRB[0]) begin
                                    Mem_RAM [Add_De_Escrita_Linha][23:16] <= WDATA[7:0];
                                  end
                                  if(WSTRB[1]) begin
                                    Mem_RAM [Add_De_Escrita_Linha][31:24] <= WDATA[15:8];
                                  end
                              end
                              2'd3:begin
                                if(WSTRB[1]) begin
                                    Mem_RAM [Add_De_Escrita_Linha][31:24] <= WDATA[15:8];
                                  end
                              end

                              default : ;
                            endcase
                          end

                          8'd4:begin
                            case (Add_De_Escrita_Byte)
                              2'd0:begin
                                if(WSTRB[0]) begin
                                  Mem_RAM [Add_De_Escrita_Linha][7:0] <= WDATA[7:0];
                                end
                                if(WSTRB[1]) begin
                                  Mem_RAM [Add_De_Escrita_Linha][15:8] <= WDATA[15:8];
                                end
                                if(WSTRB[2]) begin
                                  Mem_RAM [Add_De_Escrita_Linha][23:16] <= WDATA[23:16];
                                end
                                if(WSTRB[3]) begin
                                  Mem_RAM [Add_De_Escrita_Linha][31:24] <= WDATA[31:24];
                                end
                              end
                              2'd1:begin
                                  if(WSTRB[1]) begin
                                    Mem_RAM [Add_De_Escrita_Linha][15:8] <= WDATA[15:8];
                                  end
                                  if(WSTRB[2]) begin
                                    Mem_RAM [Add_De_Escrita_Linha][23:16] <= WDATA[23:16];
                                  end
                                  if(WSTRB[3]) begin
                                    Mem_RAM [Add_De_Escrita_Linha][31:24] <= WDATA[31:24];
                                  end
                              end
                              2'd2:begin
                                  if(WSTRB[2]) begin
                                    Mem_RAM [Add_De_Escrita_Linha][23:16] <= WDATA[23:16];
                                  end
                                  if(WSTRB[3]) begin
                                    Mem_RAM [Add_De_Escrita_Linha][31:24] <= WDATA[31:24];
                                  end
                              end
                              2'd3:begin
                                if(WSTRB[3]) begin
                                    Mem_RAM [Add_De_Escrita_Linha][31:24] <= WDATA[31:24];
                                  end 
                              end

                              default : ;
                            endcase
                          end

                          default :begin 
                            BRESP <= SLVERR;
                          end
                        endcase
                      end

                      default : begin
                        BRESP <= SLVERR;
                      end
                    endcase

                    case (Burst_Size_W)
                      8'd1:begin 
                        Add_De_Escrita_Byte <= Add_De_Escrita_Byte + 1'b1;
                        if(Add_De_Escrita_Byte + 1'b1 == 2'b00) begin
                          Add_De_Escrita_Linha <= Add_De_Escrita_Linha + 1'b1;
                        end
                      end

                      8'd2:begin 
                        if(Add_De_Escrita_Byte < 2'b10) begin
                          Add_De_Escrita_Byte <= 2'b10;
                          Add_De_Escrita_Linha <= Add_De_Escrita_Linha;
                        end
                        else begin 
                          Add_De_Escrita_Byte <= 2'b00;
                          Add_De_Escrita_Linha <= Add_De_Escrita_Linha + 1'b1;
                        end
                      end

                      8'd4:begin 
                        Add_De_Escrita_Byte <= 2'b00;
                        Add_De_Escrita_Linha <= Add_De_Escrita_Linha + 1'b1;
                      end
                      default :BRESP <= SLVERR;
                    endcase
                  end

                WRAP:
                  begin
                    case (Regiao_Da_Escrita)
                        MEM_0: begin
                          case (Burst_Size_W)
                            8'd1:begin
                              case (Add_De_Escrita_Byte)
                                2'd0:begin
                                  if(WSTRB[0]) begin
                                    Mem_RAM [Add_De_Escrita_Linha][7:0] <= WDATA[7:0];
                                  end
                              end
                              2'd1:begin
                                if(WSTRB[0]) begin
                                    Mem_RAM [Add_De_Escrita_Linha][15:8] <= WDATA[7:0];
                                  end
                              end
                              2'd2:begin
                                if(WSTRB[0]) begin
                                    Mem_RAM [Add_De_Escrita_Linha][23:16] <= WDATA[7:0];
                                  end
                              end
                              2'd3:begin
                                if(WSTRB[0]) begin
                                    Mem_RAM [Add_De_Escrita_Linha][31:24] <= WDATA[7:0];
                                  end
                              end
                              
                                default : ;

                              endcase
                            end

                            8'd2:begin
                              case (Add_De_Escrita_Byte)
                                2'd0:begin
                                  if(WSTRB[0]) begin
                                    Mem_RAM [Add_De_Escrita_Linha][7:0] <= WDATA[7:0];
                                  end
                                  if(WSTRB[1]) begin
                                    Mem_RAM [Add_De_Escrita_Linha][15:8] <= WDATA[15:8];
                                  end
                              end
                              2'd1:begin
                                if(WSTRB[1]) begin
                                    Mem_RAM [Add_De_Escrita_Linha][15:8] <= WDATA[15:8];
                                  end
                              end
                              2'd2:begin
                                if(WSTRB[0]) begin
                                    Mem_RAM [Add_De_Escrita_Linha][23:16] <= WDATA[7:0];
                                  end
                                  if(WSTRB[1]) begin
                                    Mem_RAM [Add_De_Escrita_Linha][31:24] <= WDATA[15:8];
                                  end
                              end
                              2'd3:begin
                                if(WSTRB[1]) begin
                                    Mem_RAM [Add_De_Escrita_Linha][31:24] <= WDATA[15:8];
                                  end
                              end

                                default : ;
                              endcase
                            end

                            8'd4:begin
                              case (Add_De_Escrita_Byte)
                                2'd0:begin
                                  if(WSTRB[0]) begin
                                    Mem_RAM [Add_De_Escrita_Linha][7:0] <= WDATA[7:0];
                                  end
                                  if(WSTRB[1]) begin
                                    Mem_RAM [Add_De_Escrita_Linha][15:8] <= WDATA[15:8];
                                  end
                                  if(WSTRB[2]) begin
                                    Mem_RAM [Add_De_Escrita_Linha][23:16] <= WDATA[23:16];
                                  end
                                  if(WSTRB[3]) begin
                                    Mem_RAM [Add_De_Escrita_Linha][31:24] <= WDATA[31:24];
                                  end
                              end
                              2'd1:begin
                                  if(WSTRB[1]) begin
                                    Mem_RAM [Add_De_Escrita_Linha][15:8] <= WDATA[15:8];
                                  end
                                  if(WSTRB[2]) begin
                                    Mem_RAM [Add_De_Escrita_Linha][23:16] <= WDATA[23:16];
                                  end
                                  if(WSTRB[3]) begin
                                    Mem_RAM [Add_De_Escrita_Linha][31:24] <= WDATA[31:24];
                                  end
                              end
                              2'd2:begin
                                  if(WSTRB[2]) begin
                                    Mem_RAM [Add_De_Escrita_Linha][23:16] <= WDATA[23:16];
                                  end
                                  if(WSTRB[3]) begin
                                    Mem_RAM [Add_De_Escrita_Linha][31:24] <= WDATA[31:24];
                                  end
                              end
                              2'd3:begin
                                if(WSTRB[3]) begin
                                    Mem_RAM [Add_De_Escrita_Linha][31:24] <= WDATA[31:24];
                                  end 
                              end

                                default : ;
                              endcase
                            end
                            default :begin 
                              BRESP <= SLVERR;
                            end
                          endcase
                        end


                        default : begin
                          BRESP <= SLVERR;
                        end
                    endcase
                    Add_Limite_Escrita <= Wrap_Boundary_Escrita + Data_Total_Transmitido_Escrita;
                    if(Burst_Length_W_WRAP == 9'd2 || Burst_Length_W_WRAP == 9'd4 || Burst_Length_W_WRAP == 9'd8 || Burst_Length_W_WRAP == 9'd16) begin
                      BRESP <= OKAY;

                      if({Add_De_Escrita_Linha, Add_De_Escrita_Byte} == Add_Limite_Escrita) begin
                        Add_De_Escrita_Linha <= Wrap_Boundary_Escrita[ADD_WIDTH-1+2:2];
                        Add_De_Escrita_Byte <= Wrap_Boundary_Escrita[1:0];
                      end
                      else begin 
                        case (Burst_Size_W)
                          8'd1:begin
                            Add_De_Escrita_Byte <= Add_De_Escrita_Byte + 1'b1;
                            if(Add_De_Escrita_Byte + 1'b1 == 2'b00) begin
                              Add_De_Escrita_Linha <= Add_De_Escrita_Linha + 1'b1;
                            end
                          end

                          8'd2:begin 
                            if(Add_De_Escrita_Byte[0]) begin
                              BRESP <= SLVERR;
                            end
                            else begin 
                              if(Add_De_Escrita_Byte < 2'b10) begin
                                Add_De_Escrita_Byte <= 2'b10;
                                Add_De_Escrita_Linha <= Add_De_Escrita_Linha;
                              end
                              else begin 
                                Add_De_Escrita_Byte <= 2'b00;
                                Add_De_Escrita_Linha <= Add_De_Escrita_Linha + 1'b1;
                              end
                            end
                          end

                          8'd4:begin 
                            if(Add_De_Escrita_Byte[1:0] != 2'b00) begin
                              BRESP <= SLVERR;
                            end
                            else begin 
                              Add_De_Escrita_Byte <= 2'b00;
                              Add_De_Escrita_Linha <= Add_De_Escrita_Linha + 1'b1;
                            end
                          end

                          default :BRESP <= SLVERR;
                        endcase
                      end
                    end
                    else begin 
                      BRESP <= SLVERR;
                    end
                  end

                default : Add_De_Escrita_Linha <= 'x;
              endcase
            end
            else begin//se o contador zerar 
            end
          end

          if(BVALID && BREADY) begin
            BRESP <= OKAY;
            BVALID <= '0;
            if(Burst_Length_W == '0) begin
              AWREADY <= '1;
            end
            else begin 
              WREADY <= '1;
            end
          end



        end
    end
  
  
  
  
  always_comb
    begin
        Pc_Out = Mem_RAM[Add_PC[ADD_WIDTH-1+2 : 2]];
        case (Estado_De_Trabalho_Leitura)
         
          ADD_DE_LEITURA_RECEBIDO:
            begin
              case (Regiao_Da_Leitura)
                MEM_0: begin
                  case (Burst_Size_R)
                    8'd1:begin
                      case (Add_De_Leitura_Byte)
                        2'd0:begin
                        RDATA[DATA_WIDTH-1:8] = 24'bx;
                        RDATA[7:0] = Mem_RAM [Add_De_Leitura_Linha][7:0];
                      end
                      2'd1:begin
                        RDATA[DATA_WIDTH-1:8] = 24'bx;
                        RDATA[7:0] = Mem_RAM [Add_De_Leitura_Linha][15:8];
                      end
                      2'd2:begin
                        RDATA[DATA_WIDTH-1:8] = 24'bx;
                        RDATA[7:0] = Mem_RAM [Add_De_Leitura_Linha][23:16];
                      end
                      2'd3:begin
                        RDATA[DATA_WIDTH-1:8] = 24'bx;
                        RDATA[7:0] = Mem_RAM [Add_De_Leitura_Linha][31:24];
                      end
                      
                        default : ;

                      endcase
                    end

                    8'd2:begin
                      case (Add_De_Leitura_Byte)
                        2'd0:begin
                          RDATA[DATA_WIDTH-1:16] = 16'bx;
                        RDATA[15:0] = Mem_RAM [Add_De_Leitura_Linha][15:0];
                      end
                      2'd1:begin
                        RDATA[DATA_WIDTH-1:16] = 16'bx;
                        RDATA[15:8] = Mem_RAM [Add_De_Leitura_Linha][15:8];
                        RDATA[7:0] = 8'bx;
                      end
                      2'd2:begin
                        RDATA[DATA_WIDTH-1:16] = 16'bx;
                        RDATA[15:0] = Mem_RAM [Add_De_Leitura_Linha][DATA_WIDTH-1:16];
                      end
                      2'd3:begin
                        RDATA[DATA_WIDTH-1:24] = 16'bx;
                        RDATA[15:8] = Mem_RAM [Add_De_Leitura_Linha][DATA_WIDTH-1:24];
                        RDATA[7:0] = 8'bx;
                      end

                        default : ;
                      endcase
                    end

                    8'd4:begin
                      case (Add_De_Leitura_Byte)
                        2'd0:begin
                        RDATA[DATA_WIDTH-1:0] = Mem_RAM [Add_De_Leitura_Linha][DATA_WIDTH-1:0];
                      end
                      2'd1:begin
                        RDATA[DATA_WIDTH-1:8] = Mem_RAM [Add_De_Leitura_Linha][DATA_WIDTH-1:8];
                        RDATA[7:0] = 8'bx;
                      end
                      2'd2:begin
                        RDATA[DATA_WIDTH-1:16] = Mem_RAM [Add_De_Leitura_Linha][DATA_WIDTH-1:16];
                        RDATA[15:0] = 16'bx;
                      end
                      2'd3:begin
                        RDATA[DATA_WIDTH-1:24] = Mem_RAM [Add_De_Leitura_Linha][DATA_WIDTH-1:24];
                        RDATA[23:0] = 24'bx;  
                      end

                        default : ;
                      endcase
                    end


                    
                    default : begin 
                      RDATA = '0;
                    end
                  endcase
                  if(Erro_De_Tamanho_De_Byte_Leitura) begin
                    RRESP = SLVERR;
                  end
                  else
                    RRESP = OKAY;
                end


                default : begin
                  RDATA = '0;
                  RRESP = SLVERR;
                end
              endcase
              end


            PROXIMA_LEITURA:;
                  

          DADO_DE_LEITURA_TRANSMITIDO:
            begin
                RDATA = '0;
                RRESP = SLVERR;
              end 
        
          default:
            begin
                RDATA = '0;
                RRESP = SLVERR;
              end
      endcase



        case (Estado_De_Trabalho_Escrita)
          
            USANDO_BVALID_BREADY:
              begin
                  
              end
            default:
              begin
                  
              end
        endcase
    end

endmodule
  
  

