module handover(
				input				hclk,
				input				hresetn,
				input				hready,
				input		[4:0]	grant,
				input				mastlock,
				input				transfin,          //transfer finish
				output	reg	[4:0]	hmaster,
				output	reg			hmastlock,
				output	reg	[4:0]	hgrant
				);
				
				
				
always @(posedge hclk)   begin
if(!hresetn) begin
	hmastlock <= 1'b0;
	hgrant <= 5'b0;
end
else if(hready&transfin) begin
	hmastlock <= mastlock;
	hgrant <= grant;
end
end

always @(grant) begin
case(grant)
5'b00001:
	hmaster <= 4'b0000;
5'b00010:
	hmaster <= 4'b0001;
5'b00100:
	hmaster <= 4'b0010;
5'b01000:
	hmaster <= 4'b0011;
5'b10000:
	hmaster <= 4'b0100;
default:
	hmaster <= 4'b0000;
endcase	
end

endmodule