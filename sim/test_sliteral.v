/*
   Author: Ovidiu Plugariu
   Description: This is a test for the Static Literal Huffman tree used in the GZIP module.  
*/

`timescale 1 ns / 10 ps


`define LIT_CODE0    8'd48
`define LIT_CODE1    8'd49
`define LIT_CODE2    8'd50
`define LIT_CODE3    8'd51
`define LIT_CODE4    8'd52
`define LIT_CODE5    8'd53
`define LIT_CODE6    8'd54
`define LIT_CODE7    8'd55
`define LIT_CODE8    8'd56
`define LIT_CODE9    8'd57
`define LIT_CODE10   8'd58
`define LIT_CODE11   8'd59
`define LIT_CODE12   8'd60
`define LIT_CODE13   8'd61
`define LIT_CODE14   8'd62
`define LIT_CODE15   8'd63
`define LIT_CODE16   8'd64
`define LIT_CODE17   8'd65
`define LIT_CODE18   8'd66
`define LIT_CODE19   8'd67
`define LIT_CODE20   8'd68
`define LIT_CODE21   8'd69
`define LIT_CODE22   8'd70
`define LIT_CODE23   8'd71
`define LIT_CODE24   8'd72
`define LIT_CODE25   8'd73
`define LIT_CODE26   8'd74
`define LIT_CODE27   8'd75
`define LIT_CODE28   8'd76
`define LIT_CODE29   8'd77
`define LIT_CODE30   8'd78
`define LIT_CODE31   8'd79
`define LIT_CODE32   8'd80
`define LIT_CODE33   8'd81
`define LIT_CODE34   8'd82
`define LIT_CODE35   8'd83
`define LIT_CODE36   8'd84
`define LIT_CODE37   8'd85
`define LIT_CODE38   8'd86
`define LIT_CODE39   8'd87
`define LIT_CODE40   8'd88
`define LIT_CODE41   8'd89
`define LIT_CODE42   8'd90
`define LIT_CODE43   8'd91
`define LIT_CODE44   8'd92
`define LIT_CODE45   8'd93
`define LIT_CODE46   8'd94
`define LIT_CODE47   8'd95
`define LIT_CODE48   8'd96
`define LIT_CODE49   8'd97
`define LIT_CODE50   8'd98
`define LIT_CODE51   8'd99
`define LIT_CODE52   8'd100
`define LIT_CODE53   8'd101
`define LIT_CODE54   8'd102
`define LIT_CODE55   8'd103
`define LIT_CODE56   8'd104
`define LIT_CODE57   8'd105
`define LIT_CODE58   8'd106
`define LIT_CODE59   8'd107
`define LIT_CODE60   8'd108
`define LIT_CODE61   8'd109
`define LIT_CODE62   8'd110
`define LIT_CODE63   8'd111
`define LIT_CODE64   8'd112
`define LIT_CODE65   8'd113
`define LIT_CODE66   8'd114
`define LIT_CODE67   8'd115
`define LIT_CODE68   8'd116
`define LIT_CODE69   8'd117
`define LIT_CODE70   8'd118
`define LIT_CODE71   8'd119
`define LIT_CODE72   8'd120
`define LIT_CODE73   8'd121
`define LIT_CODE74   8'd122
`define LIT_CODE75   8'd123
`define LIT_CODE76   8'd124
`define LIT_CODE77   8'd125
`define LIT_CODE78   8'd126
`define LIT_CODE79   8'd127
`define LIT_CODE80   8'd128
`define LIT_CODE81   8'd129
`define LIT_CODE82   8'd130
`define LIT_CODE83   8'd131
`define LIT_CODE84   8'd132
`define LIT_CODE85   8'd133
`define LIT_CODE86   8'd134
`define LIT_CODE87   8'd135
`define LIT_CODE88   8'd136
`define LIT_CODE89   8'd137
`define LIT_CODE90   8'd138
`define LIT_CODE91   8'd139
`define LIT_CODE92   8'd140
`define LIT_CODE93   8'd141
`define LIT_CODE94   8'd142
`define LIT_CODE95   8'd143
`define LIT_CODE96   8'd144
`define LIT_CODE97   8'd145
`define LIT_CODE98   8'd146
`define LIT_CODE99   8'd147
`define LIT_CODE100  8'd148
`define LIT_CODE101  8'd149
`define LIT_CODE102  8'd150
`define LIT_CODE103  8'd151
`define LIT_CODE104  8'd152
`define LIT_CODE105  8'd153
`define LIT_CODE106  8'd154
`define LIT_CODE107  8'd155
`define LIT_CODE108  8'd156
`define LIT_CODE109  8'd157
`define LIT_CODE110  8'd158
`define LIT_CODE111  8'd159
`define LIT_CODE112  8'd160
`define LIT_CODE113  8'd161
`define LIT_CODE114  8'd162
`define LIT_CODE115  8'd163
`define LIT_CODE116  8'd164
`define LIT_CODE117  8'd165
`define LIT_CODE118  8'd166
`define LIT_CODE119  8'd167
`define LIT_CODE120  8'd168
`define LIT_CODE121  8'd169
`define LIT_CODE122  8'd170
`define LIT_CODE123  8'd171
`define LIT_CODE124  8'd172
`define LIT_CODE125  8'd173
`define LIT_CODE126  8'd174
`define LIT_CODE127  8'd175
`define LIT_CODE128  8'd176
`define LIT_CODE129  8'd177
`define LIT_CODE130  8'd178
`define LIT_CODE131  8'd179
`define LIT_CODE132  8'd180
`define LIT_CODE133  8'd181
`define LIT_CODE134  8'd182
`define LIT_CODE135  8'd183
`define LIT_CODE136  8'd184
`define LIT_CODE137  8'd185
`define LIT_CODE138  8'd186
`define LIT_CODE139  8'd187
`define LIT_CODE140  8'd188
`define LIT_CODE141  8'd189
`define LIT_CODE142  8'd190
`define LIT_CODE143  8'd191
`define LIT_CODE144  9'd400
`define LIT_CODE145  9'd401
`define LIT_CODE146  9'd402
`define LIT_CODE147  9'd403
`define LIT_CODE148  9'd404
`define LIT_CODE149  9'd405
`define LIT_CODE150  9'd406
`define LIT_CODE151  9'd407
`define LIT_CODE152  9'd408
`define LIT_CODE153  9'd409
`define LIT_CODE154  9'd410
`define LIT_CODE155  9'd411
`define LIT_CODE156  9'd412
`define LIT_CODE157  9'd413
`define LIT_CODE158  9'd414
`define LIT_CODE159  9'd415
`define LIT_CODE160  9'd416
`define LIT_CODE161  9'd417
`define LIT_CODE162  9'd418
`define LIT_CODE163  9'd419
`define LIT_CODE164  9'd420
`define LIT_CODE165  9'd421
`define LIT_CODE166  9'd422
`define LIT_CODE167  9'd423
`define LIT_CODE168  9'd424
`define LIT_CODE169  9'd425
`define LIT_CODE170  9'd426
`define LIT_CODE171  9'd427
`define LIT_CODE172  9'd428
`define LIT_CODE173  9'd429
`define LIT_CODE174  9'd430
`define LIT_CODE175  9'd431
`define LIT_CODE176  9'd432
`define LIT_CODE177  9'd433
`define LIT_CODE178  9'd434
`define LIT_CODE179  9'd435
`define LIT_CODE180  9'd436
`define LIT_CODE181  9'd437
`define LIT_CODE182  9'd438
`define LIT_CODE183  9'd439
`define LIT_CODE184  9'd440
`define LIT_CODE185  9'd441
`define LIT_CODE186  9'd442
`define LIT_CODE187  9'd443
`define LIT_CODE188  9'd444
`define LIT_CODE189  9'd445
`define LIT_CODE190  9'd446
`define LIT_CODE191  9'd447
`define LIT_CODE192  9'd448
`define LIT_CODE193  9'd449
`define LIT_CODE194  9'd450
`define LIT_CODE195  9'd451
`define LIT_CODE196  9'd452
`define LIT_CODE197  9'd453
`define LIT_CODE198  9'd454
`define LIT_CODE199  9'd455
`define LIT_CODE200  9'd456
`define LIT_CODE201  9'd457
`define LIT_CODE202  9'd458
`define LIT_CODE203  9'd459
`define LIT_CODE204  9'd460
`define LIT_CODE205  9'd461
`define LIT_CODE206  9'd462
`define LIT_CODE207  9'd463
`define LIT_CODE208  9'd464
`define LIT_CODE209  9'd465
`define LIT_CODE210  9'd466
`define LIT_CODE211  9'd467
`define LIT_CODE212  9'd468
`define LIT_CODE213  9'd469
`define LIT_CODE214  9'd470
`define LIT_CODE215  9'd471
`define LIT_CODE216  9'd472
`define LIT_CODE217  9'd473
`define LIT_CODE218  9'd474
`define LIT_CODE219  9'd475
`define LIT_CODE220  9'd476
`define LIT_CODE221  9'd477
`define LIT_CODE222  9'd478
`define LIT_CODE223  9'd479
`define LIT_CODE224  9'd480
`define LIT_CODE225  9'd481
`define LIT_CODE226  9'd482
`define LIT_CODE227  9'd483
`define LIT_CODE228  9'd484
`define LIT_CODE229  9'd485
`define LIT_CODE230  9'd486
`define LIT_CODE231  9'd487
`define LIT_CODE232  9'd488
`define LIT_CODE233  9'd489
`define LIT_CODE234  9'd490
`define LIT_CODE235  9'd491
`define LIT_CODE236  9'd492
`define LIT_CODE237  9'd493
`define LIT_CODE238  9'd494
`define LIT_CODE239  9'd495
`define LIT_CODE240  9'd496
`define LIT_CODE241  9'd497
`define LIT_CODE242  9'd498
`define LIT_CODE243  9'd499
`define LIT_CODE244  9'd500
`define LIT_CODE245  9'd501
`define LIT_CODE246  9'd502
`define LIT_CODE247  9'd503
`define LIT_CODE248  9'd504
`define LIT_CODE249  9'd505
`define LIT_CODE250  9'd506
`define LIT_CODE251  9'd507
`define LIT_CODE252  9'd508
`define LIT_CODE253  9'd509
`define LIT_CODE254  9'd510
`define LIT_CODE255  9'd511
`define LIT_CODE256	 7'b0000000



module sliteral_test();
 
    integer i;
    // Declare input/output variables
    reg clk;	
    reg rst_n;
 
    reg  [7:0] literal_in;
	reg  literal_valid_in;
	reg  gzip_last_symbol;
	
    wire        sliteral_valid_out;
    wire [8:0]  sliteral_data; 
    wire [3:0]  sliteral_valid_bits; 
	reg [8:0] sliteral_data_exp_rev;
	
	
    integer test_count    = 0;
    integer success_count = 0;
	integer error_count   = 0;
	
    // Create clock signal - 100MHz
    always
    #2 clk = ~clk;
	
    // Instantiate DUT

    sliteral sliteral_i0
    (
    // Module inputs
    .clk,	
    .rst_n,	
	.literal_in,                          // 9bits 
	.gzip_last_symbol,
	
    // Module outputs
	.sliteral_data,                       // 9 bits Huffman
    .sliteral_valid_bits                  // this output says how many binary encoded bits are valid from the output of the decoder 
    );


	initial
    begin
        $display($time, "<< Starting the Simulation >>");
	    literal_in = 0;
		literal_valid_in = 0;
		gzip_last_symbol = 0;
	    clk = 0;
	    rst_n = 0;
        repeat(15) @(posedge clk);
		rst_n = 1;
		
        $display($time, "**************************  SLENGTH TEST  **************************");
        repeat(5) @(posedge clk);
	
	    //display the codes for the 8 bit literals
		// 0   ... 143 -- character 8 bit value
		// 24  ... 167+24
		/*for (i = 0; i <= 143; i = i +1) begin
    	  	$display ("`define LIT_CODE%d  8'd%d", i, i+48);
    	end */

	    //display the codes for the 9 bit literals
		// 144 ... 255 -- character 8 bit value
		// 400 ... 511
		/*for (i = 144; i <= 255; i = i +1) begin
    	  	$display ("`define LIT_CODE%d  9'd%d", i, i+256);
    	end*/
		
		// display the codes for the 9 bit literals
		//for (i = 144; i <= 255; i = i +1) begin
    	//  	$display ("`define LIT_CODE%d  9'd%d", i, i);
		    // $display ("9'd%d :  sliteral_data  <= `LIT_CODE%d;", i, i);
    	//end
		
        // Validate data between 0  -143. We should have 8 data bits.
        // Validate data between 144-255. We should have 9 data bits.
		//for (i = 144; i <= 255; i = i +1) begin
        //    //load_data_task(9'd0);
        //    //validate_sliteral_data(`LIT_CODE0, 4'd8);
		//	$display (" load_data_task(%d);", i);
		//	$display (" validate_sliteral_data(`LIT_CODE%d, 4'd9);", i);
        //end

        load_data_task(          0);
        validate_sliteral_data(`LIT_CODE0, 4'd8);
        load_data_task(          1);   
        validate_sliteral_data(`LIT_CODE1, 4'd8);
        load_data_task(          2);   
        validate_sliteral_data(`LIT_CODE2, 4'd8);
        load_data_task(          3);   
        validate_sliteral_data(`LIT_CODE3, 4'd8);
        load_data_task(          4);   
        validate_sliteral_data(`LIT_CODE4, 4'd8);
        load_data_task(          5);   
        validate_sliteral_data(`LIT_CODE5, 4'd8);
        load_data_task(          6);   
        validate_sliteral_data(`LIT_CODE6, 4'd8);
        load_data_task(          7);   
        validate_sliteral_data(`LIT_CODE7, 4'd8);
        load_data_task(          8);   
        validate_sliteral_data(`LIT_CODE8, 4'd8);
        load_data_task(          9);   
        validate_sliteral_data(`LIT_CODE9, 4'd8);
        load_data_task(         10);
        validate_sliteral_data(`LIT_CODE10, 4'd8);
        load_data_task(         11);
        validate_sliteral_data(`LIT_CODE11, 4'd8);
        load_data_task(         12);
        validate_sliteral_data(`LIT_CODE12, 4'd8);
        load_data_task(         13);
        validate_sliteral_data(`LIT_CODE13, 4'd8);
        load_data_task(         14);
        validate_sliteral_data(`LIT_CODE14, 4'd8);
        load_data_task(         15);
        validate_sliteral_data(`LIT_CODE15, 4'd8);
        load_data_task(         16);
        validate_sliteral_data(`LIT_CODE16, 4'd8);
        load_data_task(         17);
        validate_sliteral_data(`LIT_CODE17, 4'd8);
        load_data_task(         18);
        validate_sliteral_data(`LIT_CODE18, 4'd8);
        load_data_task(         19);
        validate_sliteral_data(`LIT_CODE19, 4'd8);
        load_data_task(         20);
        validate_sliteral_data(`LIT_CODE20, 4'd8);
        load_data_task(         21);
        validate_sliteral_data(`LIT_CODE21, 4'd8);
        load_data_task(         22);
        validate_sliteral_data(`LIT_CODE22, 4'd8);
        load_data_task(         23);
        validate_sliteral_data(`LIT_CODE23, 4'd8);
        load_data_task(         24);
        validate_sliteral_data(`LIT_CODE24, 4'd8);
        load_data_task(         25);
        validate_sliteral_data(`LIT_CODE25, 4'd8);
        load_data_task(         26);
        validate_sliteral_data(`LIT_CODE26, 4'd8);
        load_data_task(         27);
        validate_sliteral_data(`LIT_CODE27, 4'd8);
        load_data_task(         28);
        validate_sliteral_data(`LIT_CODE28, 4'd8);
        load_data_task(         29);
        validate_sliteral_data(`LIT_CODE29, 4'd8);
        load_data_task(         30);
        validate_sliteral_data(`LIT_CODE30, 4'd8);
        load_data_task(         31);
        validate_sliteral_data(`LIT_CODE31, 4'd8);
        load_data_task(         32);
        validate_sliteral_data(`LIT_CODE32, 4'd8);
        load_data_task(         33);
        validate_sliteral_data(`LIT_CODE33, 4'd8);
        load_data_task(         34);
        validate_sliteral_data(`LIT_CODE34, 4'd8);
        load_data_task(         35);
        validate_sliteral_data(`LIT_CODE35, 4'd8);
        load_data_task(         36);
        validate_sliteral_data(`LIT_CODE36, 4'd8);
        load_data_task(         37);
        validate_sliteral_data(`LIT_CODE37, 4'd8);
        load_data_task(         38);
        validate_sliteral_data(`LIT_CODE38, 4'd8);
        load_data_task(         39);
        validate_sliteral_data(`LIT_CODE39, 4'd8);
        load_data_task(         40);
        validate_sliteral_data(`LIT_CODE40, 4'd8);
        load_data_task(         41);
        validate_sliteral_data(`LIT_CODE41, 4'd8);
        load_data_task(         42);
        validate_sliteral_data(`LIT_CODE42, 4'd8);
        load_data_task(         43);
        validate_sliteral_data(`LIT_CODE43, 4'd8);
        load_data_task(         44);
        validate_sliteral_data(`LIT_CODE44, 4'd8);
        load_data_task(         45);
        validate_sliteral_data(`LIT_CODE45, 4'd8);
        load_data_task(         46);
        validate_sliteral_data(`LIT_CODE46, 4'd8);
        load_data_task(         47);
        validate_sliteral_data(`LIT_CODE47, 4'd8);
        load_data_task(         48);
        validate_sliteral_data(`LIT_CODE48, 4'd8);
        load_data_task(         49);
        validate_sliteral_data(`LIT_CODE49, 4'd8);
        load_data_task(         50);
        validate_sliteral_data(`LIT_CODE50, 4'd8);
        load_data_task(         51);
        validate_sliteral_data(`LIT_CODE51, 4'd8);
        load_data_task(         52);
        validate_sliteral_data(`LIT_CODE52, 4'd8);
        load_data_task(         53);
        validate_sliteral_data(`LIT_CODE53, 4'd8);
        load_data_task(         54);
        validate_sliteral_data(`LIT_CODE54, 4'd8);
        load_data_task(         55);
        validate_sliteral_data(`LIT_CODE55, 4'd8);
        load_data_task(         56);
        validate_sliteral_data(`LIT_CODE56, 4'd8);
        load_data_task(         57);
        validate_sliteral_data(`LIT_CODE57, 4'd8);
        load_data_task(         58);
        validate_sliteral_data(`LIT_CODE58, 4'd8);
        load_data_task(         59);
        validate_sliteral_data(`LIT_CODE59, 4'd8);
        load_data_task(         60);
        validate_sliteral_data(`LIT_CODE60, 4'd8);
        load_data_task(         61);
        validate_sliteral_data(`LIT_CODE61, 4'd8);
        load_data_task(         62);
        validate_sliteral_data(`LIT_CODE62, 4'd8);
        load_data_task(         63);
        validate_sliteral_data(`LIT_CODE63, 4'd8);
        load_data_task(         64);
        validate_sliteral_data(`LIT_CODE64, 4'd8);
        load_data_task(         65);
        validate_sliteral_data(`LIT_CODE65, 4'd8);
        load_data_task(         66);
        validate_sliteral_data(`LIT_CODE66, 4'd8);
        load_data_task(         67);
        validate_sliteral_data(`LIT_CODE67, 4'd8);
        load_data_task(         68);
        validate_sliteral_data(`LIT_CODE68, 4'd8);
        load_data_task(         69);
        validate_sliteral_data(`LIT_CODE69, 4'd8);
        load_data_task(         70);
        validate_sliteral_data(`LIT_CODE70, 4'd8);
        load_data_task(         71);
        validate_sliteral_data(`LIT_CODE71, 4'd8);
        load_data_task(         72);
        validate_sliteral_data(`LIT_CODE72, 4'd8);
        load_data_task(         73);
        validate_sliteral_data(`LIT_CODE73, 4'd8);
        load_data_task(         74);
        validate_sliteral_data(`LIT_CODE74, 4'd8);
        load_data_task(         75);
        validate_sliteral_data(`LIT_CODE75, 4'd8);
        load_data_task(         76);
        validate_sliteral_data(`LIT_CODE76, 4'd8);
        load_data_task(         77);
        validate_sliteral_data(`LIT_CODE77, 4'd8);
        load_data_task(         78);
        validate_sliteral_data(`LIT_CODE78, 4'd8);
        load_data_task(         79);
        validate_sliteral_data(`LIT_CODE79, 4'd8);
        load_data_task(         80);
        validate_sliteral_data(`LIT_CODE80, 4'd8);
        load_data_task(         81);
        validate_sliteral_data(`LIT_CODE81, 4'd8);
        load_data_task(         82);
        validate_sliteral_data(`LIT_CODE82, 4'd8);
        load_data_task(         83);
        validate_sliteral_data(`LIT_CODE83, 4'd8);
        load_data_task(         84);
        validate_sliteral_data(`LIT_CODE84, 4'd8);
        load_data_task(         85);
        validate_sliteral_data(`LIT_CODE85, 4'd8);
        load_data_task(         86);
        validate_sliteral_data(`LIT_CODE86, 4'd8);
        load_data_task(         87);
        validate_sliteral_data(`LIT_CODE87, 4'd8);
        load_data_task(         88);
        validate_sliteral_data(`LIT_CODE88, 4'd8);
        load_data_task(         89);
        validate_sliteral_data(`LIT_CODE89, 4'd8);
        load_data_task(         90);
        validate_sliteral_data(`LIT_CODE90, 4'd8);
        load_data_task(         91);
        validate_sliteral_data(`LIT_CODE91, 4'd8);
        load_data_task(         92);
        validate_sliteral_data(`LIT_CODE92, 4'd8);
        load_data_task(         93);
        validate_sliteral_data(`LIT_CODE93, 4'd8);
        load_data_task(         94);
        validate_sliteral_data(`LIT_CODE94, 4'd8);
        load_data_task(         95);
        validate_sliteral_data(`LIT_CODE95, 4'd8);
        load_data_task(         96);
        validate_sliteral_data(`LIT_CODE96, 4'd8);
        load_data_task(         97);
        validate_sliteral_data(`LIT_CODE97, 4'd8);
        load_data_task(         98);
        validate_sliteral_data(`LIT_CODE98, 4'd8);
        load_data_task(         99);
        validate_sliteral_data(`LIT_CODE99, 4'd8);
        load_data_task(        100);
        validate_sliteral_data(`LIT_CODE100, 4'd8);
        load_data_task(        101);
        validate_sliteral_data(`LIT_CODE101, 4'd8);
        load_data_task(        102);
        validate_sliteral_data(`LIT_CODE102, 4'd8);
        load_data_task(        103);
        validate_sliteral_data(`LIT_CODE103, 4'd8);
        load_data_task(        104);
        validate_sliteral_data(`LIT_CODE104, 4'd8);
        load_data_task(        105);
        validate_sliteral_data(`LIT_CODE105, 4'd8);
        load_data_task(        106);
        validate_sliteral_data(`LIT_CODE106, 4'd8);
        load_data_task(        107);
        validate_sliteral_data(`LIT_CODE107, 4'd8);
        load_data_task(        108);
        validate_sliteral_data(`LIT_CODE108, 4'd8);
        load_data_task(        109);
        validate_sliteral_data(`LIT_CODE109, 4'd8);
        load_data_task(        110);
        validate_sliteral_data(`LIT_CODE110, 4'd8);
        load_data_task(        111);
        validate_sliteral_data(`LIT_CODE111, 4'd8);
        load_data_task(        112);
        validate_sliteral_data(`LIT_CODE112, 4'd8);
        load_data_task(        113);
        validate_sliteral_data(`LIT_CODE113, 4'd8);
        load_data_task(        114);
        validate_sliteral_data(`LIT_CODE114, 4'd8);
        load_data_task(        115);
        validate_sliteral_data(`LIT_CODE115, 4'd8);
        load_data_task(        116);
        validate_sliteral_data(`LIT_CODE116, 4'd8);
        load_data_task(        117);
        validate_sliteral_data(`LIT_CODE117, 4'd8);
        load_data_task(        118);
        validate_sliteral_data(`LIT_CODE118, 4'd8);
        load_data_task(        119);
        validate_sliteral_data(`LIT_CODE119, 4'd8);
        load_data_task(        120);
        validate_sliteral_data(`LIT_CODE120, 4'd8);
        load_data_task(        121);
        validate_sliteral_data(`LIT_CODE121, 4'd8);
        load_data_task(        122);
        validate_sliteral_data(`LIT_CODE122, 4'd8);
        load_data_task(        123);
        validate_sliteral_data(`LIT_CODE123, 4'd8);
        load_data_task(        124);
        validate_sliteral_data(`LIT_CODE124, 4'd8);
        load_data_task(        125);
        validate_sliteral_data(`LIT_CODE125, 4'd8);
        load_data_task(        126);
        validate_sliteral_data(`LIT_CODE126, 4'd8);
        load_data_task(        127);
        validate_sliteral_data(`LIT_CODE127, 4'd8);
        load_data_task(        128);
        validate_sliteral_data(`LIT_CODE128, 4'd8);
        load_data_task(        129);
        validate_sliteral_data(`LIT_CODE129, 4'd8);
        load_data_task(        130);
        validate_sliteral_data(`LIT_CODE130, 4'd8);
        load_data_task(        131);
        validate_sliteral_data(`LIT_CODE131, 4'd8);
        load_data_task(        132);
        validate_sliteral_data(`LIT_CODE132, 4'd8);
        load_data_task(        133);
        validate_sliteral_data(`LIT_CODE133, 4'd8);
        load_data_task(        134);
        validate_sliteral_data(`LIT_CODE134, 4'd8);
        load_data_task(        135);
        validate_sliteral_data(`LIT_CODE135, 4'd8);
        load_data_task(        136);
        validate_sliteral_data(`LIT_CODE136, 4'd8);
        load_data_task(        137);
        validate_sliteral_data(`LIT_CODE137, 4'd8);
        load_data_task(        138);
        validate_sliteral_data(`LIT_CODE138, 4'd8);
        load_data_task(        139);
        validate_sliteral_data(`LIT_CODE139, 4'd8);
        load_data_task(        140);
        validate_sliteral_data(`LIT_CODE140, 4'd8);
        load_data_task(        141);
        validate_sliteral_data(`LIT_CODE141, 4'd8);
        load_data_task(        142);
        validate_sliteral_data(`LIT_CODE142, 4'd8);
        load_data_task(        143);
        validate_sliteral_data(`LIT_CODE143, 4'd8);
    
	    repeat(10) @(posedge clk);
        //load_data_task(        256);
        //validate_sliteral_data(`LIT_CODE256, 4'd7);
        //load_data_task(        257);
        //validate_sliteral_data(`LIT_CODE1, 4'd0);      // we have 0 valid bits 
        //load_data_task(        357);
        //validate_sliteral_data(`LIT_CODE101, 4'd0);    // we have 0 valid bits 		
		
		repeat(10) @(posedge clk);

        load_data_task(        144);
        validate_sliteral_data(`LIT_CODE144, 4'd9);
        load_data_task(        145);
        validate_sliteral_data(`LIT_CODE145, 4'd9);
        load_data_task(        146);
        validate_sliteral_data(`LIT_CODE146, 4'd9);
        load_data_task(        147);
        validate_sliteral_data(`LIT_CODE147, 4'd9);
        load_data_task(        148);
        validate_sliteral_data(`LIT_CODE148, 4'd9);
        load_data_task(        149);
        validate_sliteral_data(`LIT_CODE149, 4'd9);
        load_data_task(        150);
        validate_sliteral_data(`LIT_CODE150, 4'd9);
        load_data_task(        151);
        validate_sliteral_data(`LIT_CODE151, 4'd9);
        load_data_task(        152);
        validate_sliteral_data(`LIT_CODE152, 4'd9);
        load_data_task(        153);
        validate_sliteral_data(`LIT_CODE153, 4'd9);
        load_data_task(        154);
        validate_sliteral_data(`LIT_CODE154, 4'd9);
        load_data_task(        155);
        validate_sliteral_data(`LIT_CODE155, 4'd9);
        load_data_task(        156);
        validate_sliteral_data(`LIT_CODE156, 4'd9);
        load_data_task(        157);
        validate_sliteral_data(`LIT_CODE157, 4'd9);
        load_data_task(        158);
        validate_sliteral_data(`LIT_CODE158, 4'd9);
        load_data_task(        159);
        validate_sliteral_data(`LIT_CODE159, 4'd9);
        load_data_task(        160);
        validate_sliteral_data(`LIT_CODE160, 4'd9);
        load_data_task(        161);
        validate_sliteral_data(`LIT_CODE161, 4'd9);
        load_data_task(        162);
        validate_sliteral_data(`LIT_CODE162, 4'd9);
        load_data_task(        163);
        validate_sliteral_data(`LIT_CODE163, 4'd9);
        load_data_task(        164);
        validate_sliteral_data(`LIT_CODE164, 4'd9);
        load_data_task(        165);
        validate_sliteral_data(`LIT_CODE165, 4'd9);
        load_data_task(        166);
        validate_sliteral_data(`LIT_CODE166, 4'd9);
        load_data_task(        167);
        validate_sliteral_data(`LIT_CODE167, 4'd9);
        load_data_task(        168);
        validate_sliteral_data(`LIT_CODE168, 4'd9);
        load_data_task(        169);
        validate_sliteral_data(`LIT_CODE169, 4'd9);
        load_data_task(        170);
        validate_sliteral_data(`LIT_CODE170, 4'd9);
        load_data_task(        171);
        validate_sliteral_data(`LIT_CODE171, 4'd9);
        load_data_task(        172);
        validate_sliteral_data(`LIT_CODE172, 4'd9);
        load_data_task(        173);
        validate_sliteral_data(`LIT_CODE173, 4'd9);
        load_data_task(        174);
        validate_sliteral_data(`LIT_CODE174, 4'd9);
        load_data_task(        175);
        validate_sliteral_data(`LIT_CODE175, 4'd9);
        load_data_task(        176);
        validate_sliteral_data(`LIT_CODE176, 4'd9);
        load_data_task(        177);
        validate_sliteral_data(`LIT_CODE177, 4'd9);
        load_data_task(        178);
        validate_sliteral_data(`LIT_CODE178, 4'd9);
        load_data_task(        179);
        validate_sliteral_data(`LIT_CODE179, 4'd9);
        load_data_task(        180);
        validate_sliteral_data(`LIT_CODE180, 4'd9);
        load_data_task(        181);
        validate_sliteral_data(`LIT_CODE181, 4'd9);
        load_data_task(        182);
        validate_sliteral_data(`LIT_CODE182, 4'd9);
        load_data_task(        183);
        validate_sliteral_data(`LIT_CODE183, 4'd9);
        load_data_task(        184);
        validate_sliteral_data(`LIT_CODE184, 4'd9);
        load_data_task(        185);
        validate_sliteral_data(`LIT_CODE185, 4'd9);
        load_data_task(        186);
        validate_sliteral_data(`LIT_CODE186, 4'd9);
        load_data_task(        187);
        validate_sliteral_data(`LIT_CODE187, 4'd9);
        load_data_task(        188);
        validate_sliteral_data(`LIT_CODE188, 4'd9);
        load_data_task(        189);
        validate_sliteral_data(`LIT_CODE189, 4'd9);
        load_data_task(        190);
        validate_sliteral_data(`LIT_CODE190, 4'd9);
        load_data_task(        191);
        validate_sliteral_data(`LIT_CODE191, 4'd9);
        load_data_task(        192);
        validate_sliteral_data(`LIT_CODE192, 4'd9);
        load_data_task(        193);
        validate_sliteral_data(`LIT_CODE193, 4'd9);
        load_data_task(        194);
        validate_sliteral_data(`LIT_CODE194, 4'd9);
        load_data_task(        195);
        validate_sliteral_data(`LIT_CODE195, 4'd9);
        load_data_task(        196);
        validate_sliteral_data(`LIT_CODE196, 4'd9);
        load_data_task(        197);
        validate_sliteral_data(`LIT_CODE197, 4'd9);
        load_data_task(        198);
        validate_sliteral_data(`LIT_CODE198, 4'd9);
        load_data_task(        199);
        validate_sliteral_data(`LIT_CODE199, 4'd9);
        load_data_task(        200);
        validate_sliteral_data(`LIT_CODE200, 4'd9);
        load_data_task(        201);
        validate_sliteral_data(`LIT_CODE201, 4'd9);
        load_data_task(        202);
        validate_sliteral_data(`LIT_CODE202, 4'd9);
        load_data_task(        203);
        validate_sliteral_data(`LIT_CODE203, 4'd9);
        load_data_task(        204);
        validate_sliteral_data(`LIT_CODE204, 4'd9);
        load_data_task(        205);
        validate_sliteral_data(`LIT_CODE205, 4'd9);
        load_data_task(        206);
        validate_sliteral_data(`LIT_CODE206, 4'd9);
        load_data_task(        207);
        validate_sliteral_data(`LIT_CODE207, 4'd9);
        load_data_task(        208);
        validate_sliteral_data(`LIT_CODE208, 4'd9);
        load_data_task(        209);
        validate_sliteral_data(`LIT_CODE209, 4'd9);
        load_data_task(        210);
        validate_sliteral_data(`LIT_CODE210, 4'd9);
        load_data_task(        211);
        validate_sliteral_data(`LIT_CODE211, 4'd9);
        load_data_task(        212);
        validate_sliteral_data(`LIT_CODE212, 4'd9);
        load_data_task(        213);
        validate_sliteral_data(`LIT_CODE213, 4'd9);
        load_data_task(        214);
        validate_sliteral_data(`LIT_CODE214, 4'd9);
        load_data_task(        215);
        validate_sliteral_data(`LIT_CODE215, 4'd9);
        load_data_task(        216);
        validate_sliteral_data(`LIT_CODE216, 4'd9);
        load_data_task(        217);
        validate_sliteral_data(`LIT_CODE217, 4'd9);
        load_data_task(        218);
        validate_sliteral_data(`LIT_CODE218, 4'd9);
        load_data_task(        219);
        validate_sliteral_data(`LIT_CODE219, 4'd9);
        load_data_task(        220);
        validate_sliteral_data(`LIT_CODE220, 4'd9);
        load_data_task(        221);
        validate_sliteral_data(`LIT_CODE221, 4'd9);
        load_data_task(        222);
        validate_sliteral_data(`LIT_CODE222, 4'd9);
        load_data_task(        223);
        validate_sliteral_data(`LIT_CODE223, 4'd9);
        load_data_task(        224);
        validate_sliteral_data(`LIT_CODE224, 4'd9);
        load_data_task(        225);
        validate_sliteral_data(`LIT_CODE225, 4'd9);
        load_data_task(        226);
        validate_sliteral_data(`LIT_CODE226, 4'd9);
        load_data_task(        227);
        validate_sliteral_data(`LIT_CODE227, 4'd9);
        load_data_task(        228);
        validate_sliteral_data(`LIT_CODE228, 4'd9);
        load_data_task(        229);
        validate_sliteral_data(`LIT_CODE229, 4'd9);
        load_data_task(        230);
        validate_sliteral_data(`LIT_CODE230, 4'd9);
        load_data_task(        231);
        validate_sliteral_data(`LIT_CODE231, 4'd9);
        load_data_task(        232);
        validate_sliteral_data(`LIT_CODE232, 4'd9);
        load_data_task(        233);
        validate_sliteral_data(`LIT_CODE233, 4'd9);
        load_data_task(        234);
        validate_sliteral_data(`LIT_CODE234, 4'd9);
        load_data_task(        235);
        validate_sliteral_data(`LIT_CODE235, 4'd9);
        load_data_task(        236);
        validate_sliteral_data(`LIT_CODE236, 4'd9);
        load_data_task(        237);
        validate_sliteral_data(`LIT_CODE237, 4'd9);
        load_data_task(        238);
        validate_sliteral_data(`LIT_CODE238, 4'd9);
        load_data_task(        239);
        validate_sliteral_data(`LIT_CODE239, 4'd9);
        load_data_task(        240);
        validate_sliteral_data(`LIT_CODE240, 4'd9);
        load_data_task(        241);
        validate_sliteral_data(`LIT_CODE241, 4'd9);
        load_data_task(        242);
        validate_sliteral_data(`LIT_CODE242, 4'd9);
        load_data_task(        243);
        validate_sliteral_data(`LIT_CODE243, 4'd9);
        load_data_task(        244);
        validate_sliteral_data(`LIT_CODE244, 4'd9);
        load_data_task(        245);
        validate_sliteral_data(`LIT_CODE245, 4'd9);
        load_data_task(        246);
        validate_sliteral_data(`LIT_CODE246, 4'd9);
        load_data_task(        247);
        validate_sliteral_data(`LIT_CODE247, 4'd9);
        load_data_task(        248);
        validate_sliteral_data(`LIT_CODE248, 4'd9);
        load_data_task(        249);
        validate_sliteral_data(`LIT_CODE249, 4'd9);
        load_data_task(        250);
        validate_sliteral_data(`LIT_CODE250, 4'd9);
        load_data_task(        251);
        validate_sliteral_data(`LIT_CODE251, 4'd9);
        load_data_task(        252);
        validate_sliteral_data(`LIT_CODE252, 4'd9);
        load_data_task(        253);
        validate_sliteral_data(`LIT_CODE253, 4'd9);
        load_data_task(        254);
        validate_sliteral_data(`LIT_CODE254, 4'd9);
        load_data_task(        255);
        validate_sliteral_data(`LIT_CODE255, 4'd9); 
		
		
		
		
		
		
		
		
        repeat(10) @(posedge clk);
		report_test_results;
        $display($time, "************************** SLENGTH test is DONE **************************");		
    end

	// Display the result of the sliding window module
	//always @(posedge clk)
	//	    display_output_data(out_valid, out_last, out_bvalid, out_data);
			
			
	//====================================================================================================================
	//====================================== Tasks for SLITERAL automatic validation =====================================
	//====================================================================================================================
	
    task load_data_task;
	    input  [7:0]  match_pos_in_val;
    begin	
        literal_in = match_pos_in_val;
		$display($time, " Loading literal_in = %d", literal_in);
        @(posedge clk);
        //@(posedge clk); 		
    end
    endtask //of load_data	
	
    task validate_sliteral_data();
       input [8:0]  sliteral_data_exp;
	   input [3:0]  sliteral_valid_bits_exp ;
    begin
	   
		sliteral_data_exp_rev[8:0] = {sliteral_data_exp[0], sliteral_data_exp[1], sliteral_data_exp[2], sliteral_data_exp[3], sliteral_data_exp[4],
		                              sliteral_data_exp[5], sliteral_data_exp[6], sliteral_data_exp[7], sliteral_data_exp[8]};
		
		sliteral_data_exp_rev = sliteral_data_exp_rev >> (4'd9-sliteral_valid_bits_exp);
	    //@(posedge clk);                                 // wait for the module to update its outpus
		#1;
            test_count <= test_count + 1;
    	if( ({sliteral_data_exp_rev, sliteral_valid_bits_exp} == {sliteral_data, sliteral_valid_bits}) ) begin
    	    success_count <= success_count + 1;
			$display($time,"Success at test %d",test_count);
			$display("            Static length SL=%b, valid_bits=%d", sliteral_data, sliteral_valid_bits);
    		end
        else begin
            error_count	<= error_count + 1;
			$display($time,"Error at test %d \n",test_count);
			$display("            Observed: literal SL=%b, valid_bits=%d\n        Expected: length SD=%b, valid_bits=%d \n " 
			                                                                                                            ,sliteral_data, sliteral_valid_bits
			                                                                                                            ,sliteral_data_exp, sliteral_valid_bits_exp);
    		end
        end
    endtask

    task report_test_results();
        begin       
	    if (test_count == success_count)  $display("	SLITERAL TEST finished SUCCESSFULLY");
        else                              $display("	SLITERAL TEST finished with ERRORS"); 
            $display("		test_count=%d",test_count);
            $display("		success_count=%d",success_count);
            $display("		error_count=%d",error_count);
        end
    endtask



	
endmodule
