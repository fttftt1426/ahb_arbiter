/*******************************************
2017/11/22         Author:ZhangRui

            Request Judge(5 masters)
Description: judge the request from the master

Input: hlock, hbusreq, hresp, hsplit, priority
Output: grant, mastlock


********************************************/		

module reqjudge(
				input				hclk,
				input				hresetn,
				input				hready,
				input  		 [1:0]	htrans,
				input 		 [4:0]	hlockx,
				input  		 [4:0]	hbusreq,
				input 		 [1:0]	hresp,
				input 		 [4:0]	hsplit,
				input 		 [24:0] pri,          //priority
				output reg	 [4:0]	grant,
				output reg 			mastlock
				);

parameter	IDLE 	= 2'b00;
parameter	SHIELD	= 2'b01;
parameter	NORMAL	= 2'b11;
parameter	CHANGE	= 2'b10;

parameter	OKAY 	= 2'b00;
parameter	ERROR 	= 2'b01;
parameter	RETRY 	= 2'b10;
parameter	SPLIT 	= 2'b11;


reg	 [1:0]	state;
reg  [1:0]	nxt_state;
reg  [4:0]	hbusreq_q;
reg  [4:0]	hsplit_q;
wire [4:0]	hbusreq_shield;
wire [4:0]	hbusreq_final;


always @(posedge hclk) begin
if(!hresetn)
	state <= IDLE;
else
	state <= nxt_state;
end

always @(state, hresp, hready, htrans)	begin
case(state)
IDLE:
	if(hready&hresp==OKAY)
		nxt_state = NORMAL;
	else if((~hready)&hready==SPLIT)
		nxt_state = SHIELD;
	else
		nxt_state = IDLE;
		
SHIELD:
	if(hready&hready==OKAY)
		nxt_state = NORMAL;
	else if((~htrans[0])&hready)
		nxt_state = CHANGE;
	else
		nxt_state = SHIELD;

NORMAL:
	if((~hready)&hready==SPLIT)
		nxt_state = SHIELD;
	else
		nxt_state = NORMAL;

CHANGE:
	if(hready&hresp==OKAY)
		nxt_state = NORMAL;
	else
		nxt_state = CHANGE;
endcase
end


always @(posedge hclk) begin
if(!hresetn)
	hbusreq_q <= 5'b0;
else
	hbusreq_q <= hbusreq;
end

always @(posedge hclk) begin
if(!hresetn)
	hsplit_q <= 5'b0;
else
	hsplit_q <= hsplit;
end

assign hbusreq_shield = hbusreq_q | hsplit_q;
assign hbusreq_final = (state==SHIELD)?hbusreq_shield:hbusreq_q;

always @(hresp, pri, hlockx, hbusreq_final) begin
if(hresp==OKAY) begin
	if(hbusreq_final&pri[24:20])
		grant = pri[24:20];
	else if(hbusreq_final&pri[19:15])
		grant = pri[19:15];
	else if(hbusreq_final&pri[14:10])
		grant = pri[14:10];
	else if(hbusreq_final&pri[9:5])
		grant = pri[9:5];
	else if(hbusreq_final&pri[4:0])
		grant = pri[4:0];
	if(hlockx)
		mastlock = 1'b1;
	else
		mastlock = 1'b0;
end
end
			
endmodule
				



