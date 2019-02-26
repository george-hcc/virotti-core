`ifndef axi_4_FULL_Types
`define axi_4_FULL_Types

typedef enum logic [1:0] {
	OKAY,
	EXOKAY,
	SLVERR,
	DECERR
} axi4_resp_el;

typedef enum logic [1:0]
  {
    FIXED,
    INCR,
    WRAP,
    RESERVED
  } BURST;

typedef enum logic [1:0]
{
	ESPERANDO,
    ADD_DE_LEITURA_RECEBIDO,
    PROXIMA_LEITURA,
    DADO_DE_LEITURA_TRANSMITIDO
} Trabalho_Leitura;

`endif
