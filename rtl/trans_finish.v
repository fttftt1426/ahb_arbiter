module trans_finish(
					input				hclk,
					input				hresetn,
					input				hready,
					input  		 [1:0]	hresp,
					input 		 [1:0]	htrans,
					input  		 [2:0]	hburst,
					input				hmastlock,
//					input 		 [31:0]	haddr,
					output				transfin              //transfer finish
					);

parameter	IDLE 		= 3'b000;
parameter	LOCKTRANS	= 3'b001;
parameter	LASTLOCK	= 3'b010;
parameter	BURST		= 3'b011;
parameter	LASTBURST	= 3'b100;				
parameter	RETRY		= 2'b10;
					
reg  [2:0]	state;					
reg  [2:0]	nxt_state;					
reg	 [3:0]	hburst_q;

					
wire		lock_trans;
wire		normal_trans;
wire		last_trans;					
					
always @(posedge hclk)  begin
if(!hresetn)
	state <= IDLE;
else
	state <= nxt_state;
end

always @(lock_trans, normal_trans, last_trans, hresp, state)  begin
case(state)
IDLE:
	if(lock_trans)
		nxt_state = LOCKTRANS;
	else if(normal_trans)
		nxt_state = BURST;
	else
		nxt_state = IDLE;
LOCKTRANS:
	if(last_trans)
		nxt_state = LASTLOCK;
	else
		nxt_state = LOCKTRANS;
LASTLOCK:
	if(hresp==RETRY)
		nxt_state = LOCKTRANS;
	else if(normal_trans)
		nxt_state = BURST;
	else
		nxt_state = LASTLOCK;
BURST:
	if(last_trans)
		nxt_state = LASTBURST;
	else
		nxt_state = BURST;
LASTBURST:
	if(lock_trans)
		nxt_state = LOCKTRANS;
	else if(hresp==RETRY)
		nxt_state = BURST;
	else
		nxt_state = LASTBURST;
default:
	nxt_state = state;
endcase
end


assign lock_trans = hmastlock&htrans[1];
assign normal_trans = (~hmastlock)&htrans[1];
assign last_trans = (hburst_q==4'b000)&htrans[1];

assign transfin = ((state==LASTBURST)|(state==LASTLOCK))?
						1'b1:1'b0;

endmodule