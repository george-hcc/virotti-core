interface interfaceAXI_4 #(int ADDR_SIZE = 24, int DATA_SIZE = 32) (
	input logic ACLK,
	input logic ARESETn);

	import axi4_types::*;
	
	localparam STRB_SIZE = (DATA_SIZE/8); //Quantidade de bytes que o data possui

	//Write Address Channel				MASTER 		SLAVE
	logic awvalid;				    //	output		input				
	logic awready;				    //	input		output
	logic [ADDR_SIZE-1:0]awaddr;	//	output		input
	logic [2:0]awprot;			    //	output		input

	//Write Data Channel				MASTER 		SLAVE
	logic wvalid;				    //	output		input
	logic wready;				    //	input		output
	logic [DATA_SIZE-1:0]wdata;		//	output		input
	logic [STRB_SIZE-1:0]wstrb;		//	output		input

	//Write Response Channel			MASTER 		SLAVE
	logic bvalid; 	   		 	    //	input		output
	logic bready;				    //	output		input
	axi4_resp_el bresp;			    //	input		output

	//Read Address Channel				MASTER 		SLAVE
	logic arvalid;				    //	output		input
	logic arready;				    //	input		output
	logic [ADDR_SIZE-1:0]araddr;	//	output		input
	logic [2:0]arprot; 			    //	output		input

	//Read Data Channel					MASTER 		SLAVE
	logic rvalid;				    //	input		output
	logic rready;				    //	output		input
	logic [DATA_SIZE-1:0]rdata;		//	input		output
	axi4_resp_el rresp;			    //	input		output

	modport master(
	  input   ACLK,
	  input   ARESETn,

	  output  awvalid,			
	  input	  awready,			
	  output  awaddr,	
	  output  awprot,		
	                            
	  output  wvalid,			
	  input	  wready,			
	  output  wdata,	
	  output  wstrb,	
	                            
	  input	  bvalid, 	   		
	  output  bready,			
	  input	  bresp,		
	                            
	  output  arvalid,			
	  input	  arready,			
	  output  araddr,	
	  output  arprot, 		
	                            
	  input	  rvalid,			
	  output  rready,			
	  input	  rdata,	
	  input	  rresp
	);

	modport slave(
	  input   ACLK,
	  input   ARESETn,

	  input	  awvalid,			
	  output  awready,			
	  input	  awaddr,	
	  input	  awprot,		
	                            
	  input	  wvalid,			
	  output  wready,			
	  input	  wdata,	
	  input	  wstrb,	
	                            
	  output  bvalid, 	   		
	  input	  bready,			
	  output  bresp,		
	                            
	  input	  arvalid,			
	  output  arready,			
	  input	  araddr,	
	  input	  arprot, 		
	                            
	  output  rvalid,			
	  input	  rready,			
	  output  rdata,	
	  output  rresp
	);

endinterface : interfaceAXI_4