`define  CLK    20
module tb_atbiter();

reg			clk;
reg			rstn;
reg	 [4:0]	hbusreqx;
reg	 [4:0]	hlockx;	
reg  [4:0]	hsplitx;
reg	 [1:0]	htrans;
reg	 [2:0]	hburst;
reg	 		hready;
reg	 [1:0]	hresp;

wire [4:0]	hgrantx;
wire [4:0]	hmaster;
wire		hmastlock;

initial begin
clk = 1;
forever #(`CLK/2)
	clk = ~clk;
end


initial  begin
	rstn = 0;
	hbusreqx = 5'b0;
	hlockx = 5'b0;
	hsplitx = 5'b0;
	htrans = 2'b0;
	hburst = 3'b0;
	hready = 1'b0;
	hresp = 2'b0;

#(`CLK+1)
	rstn = 1;

#`CLK
	hbusreqx = 5'b01000;
#`CLK
	hready = 1'b1;
#(2*`CLK)
	hready = 1'b0;
	hresp = 2'b11;

end



ahb_arbiter arbi(
				.hresetn		(rstn),
				.hclk			(clk),
				.hbusreqx		(hbusreqx),
				.hlockx			(hlockx),            
				.hsplitx		(hsplitx),
				.htrans			(htrans),
				.hburst			(hburst),
				.hready			(hready),              
				.hresp			(hresp),              
				//output
				.hgrantx		(hgrantx),
				.hmaster		(hmaster),             
				.hmastlock		(hmastlock)            
				);


endmodule