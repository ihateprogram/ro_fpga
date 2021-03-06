/*  
    Title:            Static Literal Huffman Tree for GZIP encoder
    Author:                                        Ovidiu Plugariu
    
    This file is a Static Literal Huffman Tree. These codes represent the literal values between 0-255 which are Huffman encoded.
        ASCII values: 0 - 255 
    Another parameter at the output of the module is number of valid bits.
	Codes legths:    0-143   : 8bits
	                 144-255 : 9bits
					 256     : 7bits (EOF for a GZIP compressed file)
*/

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


module sliteral
    (
    // Module inputs
    input  clk,	
    input  rst_n,	
	input  [7:0] literal_in,                    // 8 bits input literal
	//input  literal_valid_in,                    // literal_valid_in is used to enable the conversion of the lengths
	input  gzip_last_symbol,
	
    // Module outputs
	//output reg        sliteral_valid_out,
	output     [8:0]  sliteral_data,            // 9 bits Huffman
    output reg [3:0]  sliteral_valid_bits       // this output says how many binary encoded bits are valid from the output of the decoder 
    );
	
	
	wire [8:0] sliteral_data_reversed;
	
    //====================================================================================================================	
	//===================================== Create Huffman codes LUT for literals  =======================================
	//====================================================================================================================

	reg [8:0] sliteral_data_lut;     // LUT for values between 0-255
	
    always @(posedge clk)
	begin
        if (!rst_n)                sliteral_data_lut <= 0;
		else if (gzip_last_symbol) sliteral_data_lut <= `LIT_CODE256;
		else begin
            case ( literal_in[7:0] )                    // we use the last 8 bits to synthesize a 256x9bit read-only RAM
                8'd0   :  sliteral_data_lut  <= {1'b0, `LIT_CODE0  };
                8'd1   :  sliteral_data_lut  <= {1'b0, `LIT_CODE1  };
                8'd2   :  sliteral_data_lut  <= {1'b0, `LIT_CODE2  };
                8'd3   :  sliteral_data_lut  <= {1'b0, `LIT_CODE3  };
                8'd4   :  sliteral_data_lut  <= {1'b0, `LIT_CODE4  };
                8'd5   :  sliteral_data_lut  <= {1'b0, `LIT_CODE5  };
                8'd6   :  sliteral_data_lut  <= {1'b0, `LIT_CODE6  };
                8'd7   :  sliteral_data_lut  <= {1'b0, `LIT_CODE7  };
                8'd8   :  sliteral_data_lut  <= {1'b0, `LIT_CODE8  };
                8'd9   :  sliteral_data_lut  <= {1'b0, `LIT_CODE9  };
                8'd10  :  sliteral_data_lut  <= {1'b0, `LIT_CODE10 };
                8'd11  :  sliteral_data_lut  <= {1'b0, `LIT_CODE11 };
                8'd12  :  sliteral_data_lut  <= {1'b0, `LIT_CODE12 };
                8'd13  :  sliteral_data_lut  <= {1'b0, `LIT_CODE13 };
                8'd14  :  sliteral_data_lut  <= {1'b0, `LIT_CODE14 };
                8'd15  :  sliteral_data_lut  <= {1'b0, `LIT_CODE15 };
                8'd16  :  sliteral_data_lut  <= {1'b0, `LIT_CODE16 };
                8'd17  :  sliteral_data_lut  <= {1'b0, `LIT_CODE17 };
                8'd18  :  sliteral_data_lut  <= {1'b0, `LIT_CODE18 };
                8'd19  :  sliteral_data_lut  <= {1'b0, `LIT_CODE19 };
                8'd20  :  sliteral_data_lut  <= {1'b0, `LIT_CODE20 };
                8'd21  :  sliteral_data_lut  <= {1'b0, `LIT_CODE21 };
                8'd22  :  sliteral_data_lut  <= {1'b0, `LIT_CODE22 };
                8'd23  :  sliteral_data_lut  <= {1'b0, `LIT_CODE23 };
                8'd24  :  sliteral_data_lut  <= {1'b0, `LIT_CODE24 };
                8'd25  :  sliteral_data_lut  <= {1'b0, `LIT_CODE25 };
                8'd26  :  sliteral_data_lut  <= {1'b0, `LIT_CODE26 };
                8'd27  :  sliteral_data_lut  <= {1'b0, `LIT_CODE27 };
                8'd28  :  sliteral_data_lut  <= {1'b0, `LIT_CODE28 };
                8'd29  :  sliteral_data_lut  <= {1'b0, `LIT_CODE29 };
                8'd30  :  sliteral_data_lut  <= {1'b0, `LIT_CODE30 };
                8'd31  :  sliteral_data_lut  <= {1'b0, `LIT_CODE31 };
                8'd32  :  sliteral_data_lut  <= {1'b0, `LIT_CODE32 };
                8'd33  :  sliteral_data_lut  <= {1'b0, `LIT_CODE33 };
                8'd34  :  sliteral_data_lut  <= {1'b0, `LIT_CODE34 };
                8'd35  :  sliteral_data_lut  <= {1'b0, `LIT_CODE35 };
                8'd36  :  sliteral_data_lut  <= {1'b0, `LIT_CODE36 };
                8'd37  :  sliteral_data_lut  <= {1'b0, `LIT_CODE37 };
                8'd38  :  sliteral_data_lut  <= {1'b0, `LIT_CODE38 };
                8'd39  :  sliteral_data_lut  <= {1'b0, `LIT_CODE39 };
                8'd40  :  sliteral_data_lut  <= {1'b0, `LIT_CODE40 };
                8'd41  :  sliteral_data_lut  <= {1'b0, `LIT_CODE41 };
                8'd42  :  sliteral_data_lut  <= {1'b0, `LIT_CODE42 };
                8'd43  :  sliteral_data_lut  <= {1'b0, `LIT_CODE43 };
                8'd44  :  sliteral_data_lut  <= {1'b0, `LIT_CODE44 };
                8'd45  :  sliteral_data_lut  <= {1'b0, `LIT_CODE45 };
                8'd46  :  sliteral_data_lut  <= {1'b0, `LIT_CODE46 };
                8'd47  :  sliteral_data_lut  <= {1'b0, `LIT_CODE47 };
                8'd48  :  sliteral_data_lut  <= {1'b0, `LIT_CODE48 };
                8'd49  :  sliteral_data_lut  <= {1'b0, `LIT_CODE49 };
                8'd50  :  sliteral_data_lut  <= {1'b0, `LIT_CODE50 };
                8'd51  :  sliteral_data_lut  <= {1'b0, `LIT_CODE51 };
                8'd52  :  sliteral_data_lut  <= {1'b0, `LIT_CODE52 };
                8'd53  :  sliteral_data_lut  <= {1'b0, `LIT_CODE53 };
                8'd54  :  sliteral_data_lut  <= {1'b0, `LIT_CODE54 };
                8'd55  :  sliteral_data_lut  <= {1'b0, `LIT_CODE55 };
                8'd56  :  sliteral_data_lut  <= {1'b0, `LIT_CODE56 };
                8'd57  :  sliteral_data_lut  <= {1'b0, `LIT_CODE57 };
                8'd58  :  sliteral_data_lut  <= {1'b0, `LIT_CODE58 };
                8'd59  :  sliteral_data_lut  <= {1'b0, `LIT_CODE59 };
                8'd60  :  sliteral_data_lut  <= {1'b0, `LIT_CODE60 };
                8'd61  :  sliteral_data_lut  <= {1'b0, `LIT_CODE61 };
                8'd62  :  sliteral_data_lut  <= {1'b0, `LIT_CODE62 };
                8'd63  :  sliteral_data_lut  <= {1'b0, `LIT_CODE63 };
                8'd64  :  sliteral_data_lut  <= {1'b0, `LIT_CODE64 };
                8'd65  :  sliteral_data_lut  <= {1'b0, `LIT_CODE65 };
                8'd66  :  sliteral_data_lut  <= {1'b0, `LIT_CODE66 };
                8'd67  :  sliteral_data_lut  <= {1'b0, `LIT_CODE67 };
                8'd68  :  sliteral_data_lut  <= {1'b0, `LIT_CODE68 };
                8'd69  :  sliteral_data_lut  <= {1'b0, `LIT_CODE69 };
                8'd70  :  sliteral_data_lut  <= {1'b0, `LIT_CODE70 };
                8'd71  :  sliteral_data_lut  <= {1'b0, `LIT_CODE71 };
                8'd72  :  sliteral_data_lut  <= {1'b0, `LIT_CODE72 };
                8'd73  :  sliteral_data_lut  <= {1'b0, `LIT_CODE73 };
                8'd74  :  sliteral_data_lut  <= {1'b0, `LIT_CODE74 };
                8'd75  :  sliteral_data_lut  <= {1'b0, `LIT_CODE75 };
                8'd76  :  sliteral_data_lut  <= {1'b0, `LIT_CODE76 };
                8'd77  :  sliteral_data_lut  <= {1'b0, `LIT_CODE77 };
                8'd78  :  sliteral_data_lut  <= {1'b0, `LIT_CODE78 };
                8'd79  :  sliteral_data_lut  <= {1'b0, `LIT_CODE79 };
                8'd80  :  sliteral_data_lut  <= {1'b0, `LIT_CODE80 };
                8'd81  :  sliteral_data_lut  <= {1'b0, `LIT_CODE81 };
                8'd82  :  sliteral_data_lut  <= {1'b0, `LIT_CODE82 };
                8'd83  :  sliteral_data_lut  <= {1'b0, `LIT_CODE83 };
                8'd84  :  sliteral_data_lut  <= {1'b0, `LIT_CODE84 };
                8'd85  :  sliteral_data_lut  <= {1'b0, `LIT_CODE85 };
                8'd86  :  sliteral_data_lut  <= {1'b0, `LIT_CODE86 };
                8'd87  :  sliteral_data_lut  <= {1'b0, `LIT_CODE87 };
                8'd88  :  sliteral_data_lut  <= {1'b0, `LIT_CODE88 };
                8'd89  :  sliteral_data_lut  <= {1'b0, `LIT_CODE89 };
                8'd90  :  sliteral_data_lut  <= {1'b0, `LIT_CODE90 };
                8'd91  :  sliteral_data_lut  <= {1'b0, `LIT_CODE91 };
                8'd92  :  sliteral_data_lut  <= {1'b0, `LIT_CODE92 };
                8'd93  :  sliteral_data_lut  <= {1'b0, `LIT_CODE93 };
                8'd94  :  sliteral_data_lut  <= {1'b0, `LIT_CODE94 };
                8'd95  :  sliteral_data_lut  <= {1'b0, `LIT_CODE95 };
                8'd96  :  sliteral_data_lut  <= {1'b0, `LIT_CODE96 };
                8'd97  :  sliteral_data_lut  <= {1'b0, `LIT_CODE97 };
                8'd98  :  sliteral_data_lut  <= {1'b0, `LIT_CODE98 };
                8'd99  :  sliteral_data_lut  <= {1'b0, `LIT_CODE99 };
                8'd100 :  sliteral_data_lut  <= {1'b0, `LIT_CODE100};
                8'd101 :  sliteral_data_lut  <= {1'b0, `LIT_CODE101};
                8'd102 :  sliteral_data_lut  <= {1'b0, `LIT_CODE102};
                8'd103 :  sliteral_data_lut  <= {1'b0, `LIT_CODE103};
                8'd104 :  sliteral_data_lut  <= {1'b0, `LIT_CODE104};
                8'd105 :  sliteral_data_lut  <= {1'b0, `LIT_CODE105};
                8'd106 :  sliteral_data_lut  <= {1'b0, `LIT_CODE106};
                8'd107 :  sliteral_data_lut  <= {1'b0, `LIT_CODE107};
                8'd108 :  sliteral_data_lut  <= {1'b0, `LIT_CODE108};
                8'd109 :  sliteral_data_lut  <= {1'b0, `LIT_CODE109};
                8'd110 :  sliteral_data_lut  <= {1'b0, `LIT_CODE110};
                8'd111 :  sliteral_data_lut  <= {1'b0, `LIT_CODE111};
                8'd112 :  sliteral_data_lut  <= {1'b0, `LIT_CODE112};
                8'd113 :  sliteral_data_lut  <= {1'b0, `LIT_CODE113};
                8'd114 :  sliteral_data_lut  <= {1'b0, `LIT_CODE114};
                8'd115 :  sliteral_data_lut  <= {1'b0, `LIT_CODE115};
                8'd116 :  sliteral_data_lut  <= {1'b0, `LIT_CODE116};
                8'd117 :  sliteral_data_lut  <= {1'b0, `LIT_CODE117};
                8'd118 :  sliteral_data_lut  <= {1'b0, `LIT_CODE118};
                8'd119 :  sliteral_data_lut  <= {1'b0, `LIT_CODE119};
                8'd120 :  sliteral_data_lut  <= {1'b0, `LIT_CODE120};
                8'd121 :  sliteral_data_lut  <= {1'b0, `LIT_CODE121};
                8'd122 :  sliteral_data_lut  <= {1'b0, `LIT_CODE122};
                8'd123 :  sliteral_data_lut  <= {1'b0, `LIT_CODE123};
                8'd124 :  sliteral_data_lut  <= {1'b0, `LIT_CODE124};
                8'd125 :  sliteral_data_lut  <= {1'b0, `LIT_CODE125};
                8'd126 :  sliteral_data_lut  <= {1'b0, `LIT_CODE126};
                8'd127 :  sliteral_data_lut  <= {1'b0, `LIT_CODE127};
                8'd128 :  sliteral_data_lut  <= {1'b0, `LIT_CODE128};
                8'd129 :  sliteral_data_lut  <= {1'b0, `LIT_CODE129};
                8'd130 :  sliteral_data_lut  <= {1'b0, `LIT_CODE130};
                8'd131 :  sliteral_data_lut  <= {1'b0, `LIT_CODE131};
                8'd132 :  sliteral_data_lut  <= {1'b0, `LIT_CODE132};
                8'd133 :  sliteral_data_lut  <= {1'b0, `LIT_CODE133};
                8'd134 :  sliteral_data_lut  <= {1'b0, `LIT_CODE134};
                8'd135 :  sliteral_data_lut  <= {1'b0, `LIT_CODE135};
                8'd136 :  sliteral_data_lut  <= {1'b0, `LIT_CODE136};
                8'd137 :  sliteral_data_lut  <= {1'b0, `LIT_CODE137};
                8'd138 :  sliteral_data_lut  <= {1'b0, `LIT_CODE138};
                8'd139 :  sliteral_data_lut  <= {1'b0, `LIT_CODE139};
                8'd140 :  sliteral_data_lut  <= {1'b0, `LIT_CODE140};
                8'd141 :  sliteral_data_lut  <= {1'b0, `LIT_CODE141};
                8'd142 :  sliteral_data_lut  <= {1'b0, `LIT_CODE142};
                8'd143 :  sliteral_data_lut  <= {1'b0, `LIT_CODE143};
                8'd144 :  sliteral_data_lut  <= `LIT_CODE144;         // from this point the Huffman codes have 9 bits
                8'd145 :  sliteral_data_lut  <= `LIT_CODE145;
                8'd146 :  sliteral_data_lut  <= `LIT_CODE146;
                8'd147 :  sliteral_data_lut  <= `LIT_CODE147;
                8'd148 :  sliteral_data_lut  <= `LIT_CODE148;
                8'd149 :  sliteral_data_lut  <= `LIT_CODE149;
                8'd150 :  sliteral_data_lut  <= `LIT_CODE150;
                8'd151 :  sliteral_data_lut  <= `LIT_CODE151;
                8'd152 :  sliteral_data_lut  <= `LIT_CODE152;
                8'd153 :  sliteral_data_lut  <= `LIT_CODE153;
                8'd154 :  sliteral_data_lut  <= `LIT_CODE154;
                8'd155 :  sliteral_data_lut  <= `LIT_CODE155;
                8'd156 :  sliteral_data_lut  <= `LIT_CODE156;
                8'd157 :  sliteral_data_lut  <= `LIT_CODE157;
                8'd158 :  sliteral_data_lut  <= `LIT_CODE158;
                8'd159 :  sliteral_data_lut  <= `LIT_CODE159;
                8'd160 :  sliteral_data_lut  <= `LIT_CODE160;
                8'd161 :  sliteral_data_lut  <= `LIT_CODE161;
                8'd162 :  sliteral_data_lut  <= `LIT_CODE162;
                8'd163 :  sliteral_data_lut  <= `LIT_CODE163;
                8'd164 :  sliteral_data_lut  <= `LIT_CODE164;
                8'd165 :  sliteral_data_lut  <= `LIT_CODE165;
                8'd166 :  sliteral_data_lut  <= `LIT_CODE166;
                8'd167 :  sliteral_data_lut  <= `LIT_CODE167;
                8'd168 :  sliteral_data_lut  <= `LIT_CODE168;
                8'd169 :  sliteral_data_lut  <= `LIT_CODE169;
                8'd170 :  sliteral_data_lut  <= `LIT_CODE170;
                8'd171 :  sliteral_data_lut  <= `LIT_CODE171;
                8'd172 :  sliteral_data_lut  <= `LIT_CODE172;
                8'd173 :  sliteral_data_lut  <= `LIT_CODE173;
                8'd174 :  sliteral_data_lut  <= `LIT_CODE174;
                8'd175 :  sliteral_data_lut  <= `LIT_CODE175;
                8'd176 :  sliteral_data_lut  <= `LIT_CODE176;
                8'd177 :  sliteral_data_lut  <= `LIT_CODE177;
                8'd178 :  sliteral_data_lut  <= `LIT_CODE178;
                8'd179 :  sliteral_data_lut  <= `LIT_CODE179;
                8'd180 :  sliteral_data_lut  <= `LIT_CODE180;
                8'd181 :  sliteral_data_lut  <= `LIT_CODE181;
                8'd182 :  sliteral_data_lut  <= `LIT_CODE182;
                8'd183 :  sliteral_data_lut  <= `LIT_CODE183;
                8'd184 :  sliteral_data_lut  <= `LIT_CODE184;
                8'd185 :  sliteral_data_lut  <= `LIT_CODE185;
                8'd186 :  sliteral_data_lut  <= `LIT_CODE186;
                8'd187 :  sliteral_data_lut  <= `LIT_CODE187;
                8'd188 :  sliteral_data_lut  <= `LIT_CODE188;
                8'd189 :  sliteral_data_lut  <= `LIT_CODE189;
                8'd190 :  sliteral_data_lut  <= `LIT_CODE190;
                8'd191 :  sliteral_data_lut  <= `LIT_CODE191;
                8'd192 :  sliteral_data_lut  <= `LIT_CODE192;
                8'd193 :  sliteral_data_lut  <= `LIT_CODE193;
                8'd194 :  sliteral_data_lut  <= `LIT_CODE194;
                8'd195 :  sliteral_data_lut  <= `LIT_CODE195;
                8'd196 :  sliteral_data_lut  <= `LIT_CODE196;
                8'd197 :  sliteral_data_lut  <= `LIT_CODE197;
                8'd198 :  sliteral_data_lut  <= `LIT_CODE198;
                8'd199 :  sliteral_data_lut  <= `LIT_CODE199;
                8'd200 :  sliteral_data_lut  <= `LIT_CODE200;
                8'd201 :  sliteral_data_lut  <= `LIT_CODE201;
                8'd202 :  sliteral_data_lut  <= `LIT_CODE202;
                8'd203 :  sliteral_data_lut  <= `LIT_CODE203;
                8'd204 :  sliteral_data_lut  <= `LIT_CODE204;
                8'd205 :  sliteral_data_lut  <= `LIT_CODE205;
                8'd206 :  sliteral_data_lut  <= `LIT_CODE206;
                8'd207 :  sliteral_data_lut  <= `LIT_CODE207;
                8'd208 :  sliteral_data_lut  <= `LIT_CODE208;
                8'd209 :  sliteral_data_lut  <= `LIT_CODE209;
                8'd210 :  sliteral_data_lut  <= `LIT_CODE210;
                8'd211 :  sliteral_data_lut  <= `LIT_CODE211;
                8'd212 :  sliteral_data_lut  <= `LIT_CODE212;
                8'd213 :  sliteral_data_lut  <= `LIT_CODE213;
                8'd214 :  sliteral_data_lut  <= `LIT_CODE214;
                8'd215 :  sliteral_data_lut  <= `LIT_CODE215;
                8'd216 :  sliteral_data_lut  <= `LIT_CODE216;
                8'd217 :  sliteral_data_lut  <= `LIT_CODE217;
                8'd218 :  sliteral_data_lut  <= `LIT_CODE218;
                8'd219 :  sliteral_data_lut  <= `LIT_CODE219;
                8'd220 :  sliteral_data_lut  <= `LIT_CODE220;
                8'd221 :  sliteral_data_lut  <= `LIT_CODE221;
                8'd222 :  sliteral_data_lut  <= `LIT_CODE222;
                8'd223 :  sliteral_data_lut  <= `LIT_CODE223;
                8'd224 :  sliteral_data_lut  <= `LIT_CODE224;
                8'd225 :  sliteral_data_lut  <= `LIT_CODE225;
                8'd226 :  sliteral_data_lut  <= `LIT_CODE226;
                8'd227 :  sliteral_data_lut  <= `LIT_CODE227;
                8'd228 :  sliteral_data_lut  <= `LIT_CODE228;
                8'd229 :  sliteral_data_lut  <= `LIT_CODE229;
                8'd230 :  sliteral_data_lut  <= `LIT_CODE230;
                8'd231 :  sliteral_data_lut  <= `LIT_CODE231;
                8'd232 :  sliteral_data_lut  <= `LIT_CODE232;
                8'd233 :  sliteral_data_lut  <= `LIT_CODE233;
                8'd234 :  sliteral_data_lut  <= `LIT_CODE234;
                8'd235 :  sliteral_data_lut  <= `LIT_CODE235;
                8'd236 :  sliteral_data_lut  <= `LIT_CODE236;
                8'd237 :  sliteral_data_lut  <= `LIT_CODE237;
                8'd238 :  sliteral_data_lut  <= `LIT_CODE238;
                8'd239 :  sliteral_data_lut  <= `LIT_CODE239;
                8'd240 :  sliteral_data_lut  <= `LIT_CODE240;
                8'd241 :  sliteral_data_lut  <= `LIT_CODE241;
                8'd242 :  sliteral_data_lut  <= `LIT_CODE242;
                8'd243 :  sliteral_data_lut  <= `LIT_CODE243;
                8'd244 :  sliteral_data_lut  <= `LIT_CODE244;
                8'd245 :  sliteral_data_lut  <= `LIT_CODE245;
                8'd246 :  sliteral_data_lut  <= `LIT_CODE246;
                8'd247 :  sliteral_data_lut  <= `LIT_CODE247;
                8'd248 :  sliteral_data_lut  <= `LIT_CODE248;
                8'd249 :  sliteral_data_lut  <= `LIT_CODE249;
                8'd250 :  sliteral_data_lut  <= `LIT_CODE250;
                8'd251 :  sliteral_data_lut  <= `LIT_CODE251;
                8'd252 :  sliteral_data_lut  <= `LIT_CODE252;
                8'd253 :  sliteral_data_lut  <= `LIT_CODE253;
                8'd254 :  sliteral_data_lut  <= `LIT_CODE254;
                8'd255 :  sliteral_data_lut  <= `LIT_CODE255;    
    	    	default:  sliteral_data_lut  <= `LIT_CODE0;
            endcase
        end 
    end 			


    function inbetween (input [7:0] literal_in, input [7:0] low, input [7:0] high);
	begin
	    inbetween = (literal_in >= low && literal_in <= high) ? 1'b1 : 1'b0;
	end	
	endfunction	
	
	// The number of valid bits of the data output
    always @( posedge clk)
    begin
    	if (!rst_n)                                       sliteral_valid_bits <= 0;
		else if ( gzip_last_symbol                      ) sliteral_valid_bits <= 4'd7;
        else if ( inbetween(literal_in, 9'd0  , 9'd143) ) sliteral_valid_bits <= 4'd8;
        else if ( inbetween(literal_in, 9'd144, 9'd255) ) sliteral_valid_bits <= 4'd9;
		else                                              sliteral_valid_bits <= 0;       // invalid literal inputs don't have any valid bits (Redundant because all input values are covered)
        		
    end
		
	// Connect the bits in reverse order and shift them to right
	assign sliteral_data_reversed[8:0] = {sliteral_data_lut[0], sliteral_data_lut[1], sliteral_data_lut[2], sliteral_data_lut[3],
	                                      sliteral_data_lut[4], sliteral_data_lut[5], sliteral_data_lut[6], sliteral_data_lut[7], sliteral_data_lut[8]};
								 
	// Right shift the result of the sliteral calculation
	assign sliteral_data[8:0] = sliteral_data_reversed >> (4'd9 - sliteral_valid_bits);
	
endmodule
