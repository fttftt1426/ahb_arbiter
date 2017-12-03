/****************************************************************
2017/11/21         Author:ZhangRui

			Priority Control(5 masters)
Description: control the priority list.


			LAST GRANT  |       PRIORITY               STATE
			   M0       |  M0 > M1 > M2 > M3 > M4  |     s0
			   M1       |  M0 > M2 > M3 > M4 > M1  |     s1
			   M2       |  M0 > M3 > M4 > M1 > M2  |     s2
			   M3       |  M0 > M4 > M1 > M2 > M3  |     s3
			   M4       |  M0 > M1 > M2 > M3 > M4  |     s0


****************************************************************/

module prio(
			input 				hclk,
			input 				hresetn,
			input 		  [4:0]	hgrant,
			output reg 	 [24:0]	priout
			);

parameter S0 = 2'b00;			
parameter S1 = 2'b01;			
parameter S2 = 2'b11;			
parameter S3 = 2'b10;			

reg [1:0]	state;			
reg [1:0]	nxt_state;			

always @(posedge hclk) begin
if(!hresetn)
	state <= S0;
else
	state <= nxt_state;
end 

always @(state, hgrant) begin
	case(state)
	S0:
		if(hgrant[1])
			nxt_state = S1;
		else if(hgrant[2])
			nxt_state = S2;
		else if(hgrant[3])
			nxt_state = S3;
		else	
			nxt_state = S0;

	S1:
		if(hgrant[4])
			nxt_state = S0;
		else if(hgrant[2])
			nxt_state = S2;
		else if(hgrant[3])
			nxt_state = S3;
		else
			nxt_state = S1;
	
	S2:
		if(hgrant[1])
			nxt_state = S1;
		else if(hgrant[4])
			nxt_state = S0;
		else if(hgrant[3])
			nxt_state = S3;
		else	
			nxt_state = S2;

	
	S3:
		if(hgrant[1])
			nxt_state = S1;
		else if(hgrant[2])
			nxt_state = S2;
		else if(hgrant[4])
			nxt_state = S0;
		else	
			nxt_state = S3;

	endcase
end

always @(state) begin
	case(state)
	S0:
		priout = 25'b00001_00010_00100_01000_10000;
	S1:
		priout = 25'b00001_00100_01000_10000_00010;
	S2:
		priout = 25'b00001_01000_10000_00010_00100;
	S3:
		priout = 25'b00001_10000_00010_00100_01000;		
	endcase
end
			
endmodule