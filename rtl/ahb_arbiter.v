/**************************************
2017/10/31    ZhangRui

ahb_arbiter module: to choose which master device
                     should control the AHB bus.

***************************************/
module	ahb_arbiter(
				input   	      	hresetn,
				input 	      		hclk,
				//arbiter requests and locks
				input	 	[4:0]   hbusreqx,
				input 		[4:0]   hlockx,            //
				//address and control
				input		[4:0]   hsplitx,
				input		[1:0]   htrans,
				input 		[2:0]   hburst,
				input 	       		hready,              //slave is ready.
				input 		[1:0]   hresp,               //slave response, OKEY,ERROR,RETRY,SPLIT
				//arbiter grants
				output	 	[4:0] 	hgrantx,
				output		[4:0]  	hmaster,             //
				output     		hmastlock            //
				);
				

wire [24:0]	pri;
wire [4:0]	grant;
wire		mastlock;
wire		transfin;

/*******************************************
            Request Judge
Description: judge the request from the master

Input: hlock, hbusreq, hresp, hsplit, priority
Output: grant, mastlock


********************************************/				
reqjudge reqj(
				.hclk		(hclk),
				.hresetn	(hresetn),
				.hready		(hready),
				.htrans		(htrans),
				.hlockx		(hlockx),
				.hbusreq	(hbusreqx),
				.hresp		(hresp),
				.hsplit		(hsplitx),
				.pri		(pri),          
				.grant		(grant),
				.mastlock	(mastlock)
				);



/********************************************
			Priority Control
*********************************************/

prio prior(
			.hclk		(hclk),
			.hresetn	(hresetn),
			.hgrant		(hgrantx),
			.priout		(pri)
			);




/*********************************************
			Transfer Finish Judge
Description:

Input: hready, hburst, htrans, haddr(?), hmastlock
Output: transfinish 
*********************************************/
trans_finish transf(
					.hclk		(hclk),
					.hresetn	(hresetn),
					.hready		(hready),
					.hresp		(hresp),
					.htrans		(htrans),
					.hburst		(hburst),
					.hmastlock	(hmastlock),
//					haddr		(),
					.transfin	(transfin)              
					);



/*********************************************
			Bus handover
Description:

Input: grant, mastlock, hready, transfinish
Output: hgrantx, hmaster, hmastlock
*********************************************/

handover hand(
			.hclk		(hclk),
			.hresetn	(hresetn),
			.hready		(hready),
			.grant		(grant),
			.mastlock	(mastlock),
			.transfin	(transfin),          //transfer finish
			.hmaster	(hmaster),
			.hmastlock	(hmastlock),
			.hgrant		(hgrantx)
				);
				



endmodule