/*
   Author: Ovidiu Plugariu
   Description: This is a test for the Static Literal Huffman tree used in the GZIP module.  
*/

`timescale 1 ns / 10 ps


`define LIT_CODE0	8'b00110000
`define LIT_CODE1	8'b00110001
`define LIT_CODE2	8'b00110010
`define LIT_CODE3	8'b00110011
`define LIT_CODE4	8'b00110100
`define LIT_CODE5	8'b00110101
`define LIT_CODE6	8'b00110110
`define LIT_CODE7	8'b00110111
`define LIT_CODE8	8'b00111000
`define LIT_CODE9	8'b00111001
`define LIT_CODE10	8'b00111010
`define LIT_CODE11	8'b00111011
`define LIT_CODE12	8'b00111100
`define LIT_CODE13	8'b00111101
`define LIT_CODE14	8'b00111110
`define LIT_CODE15	8'b00111111
`define LIT_CODE16	8'b01000000
`define LIT_CODE17	8'b01000001
`define LIT_CODE18	8'b01000010
`define LIT_CODE19	8'b01000011
`define LIT_CODE20	8'b01000100
`define LIT_CODE21	8'b01000101
`define LIT_CODE22	8'b01000110
`define LIT_CODE23	8'b01000111
`define LIT_CODE24	8'b01001000
`define LIT_CODE25	8'b01001001
`define LIT_CODE26	8'b01001010
`define LIT_CODE27	8'b01001011
`define LIT_CODE28	8'b01001100
`define LIT_CODE29	8'b01001101
`define LIT_CODE30	8'b01001110
`define LIT_CODE31	8'b01001111
`define LIT_CODE32	8'b01010000
`define LIT_CODE33	8'b01010001
`define LIT_CODE34	8'b01010010
`define LIT_CODE35	8'b01010011
`define LIT_CODE36	8'b01010100
`define LIT_CODE37	8'b01010101
`define LIT_CODE38	8'b01010110
`define LIT_CODE39	8'b01010111
`define LIT_CODE40	8'b01011000
`define LIT_CODE41	8'b01011001
`define LIT_CODE42	8'b01011010
`define LIT_CODE43	8'b01011011
`define LIT_CODE44	8'b01011100
`define LIT_CODE45	8'b01011101
`define LIT_CODE46	8'b01011110
`define LIT_CODE47	8'b01011111
`define LIT_CODE48	8'b01100000
`define LIT_CODE49	8'b01100001
`define LIT_CODE50	8'b01100010
`define LIT_CODE51	8'b01100011
`define LIT_CODE52	8'b01100100
`define LIT_CODE53	8'b01100101
`define LIT_CODE54	8'b01100110
`define LIT_CODE55	8'b01100111
`define LIT_CODE56	8'b01101000
`define LIT_CODE57	8'b01101001
`define LIT_CODE58	8'b01101010
`define LIT_CODE59	8'b01101011
`define LIT_CODE60	8'b01101100
`define LIT_CODE61	8'b01101101
`define LIT_CODE62	8'b01101110
`define LIT_CODE63	8'b01101111
`define LIT_CODE64	8'b01110000
`define LIT_CODE65	8'b01110001
`define LIT_CODE66	8'b01110010
`define LIT_CODE67	8'b01110011
`define LIT_CODE68	8'b01110100
`define LIT_CODE69	8'b01110101
`define LIT_CODE70	8'b01110110
`define LIT_CODE71	8'b01110111
`define LIT_CODE72	8'b01111000
`define LIT_CODE73	8'b01111001
`define LIT_CODE74	8'b01111010
`define LIT_CODE75	8'b01111011
`define LIT_CODE76	8'b01111100
`define LIT_CODE77	8'b01111101
`define LIT_CODE78	8'b01111110
`define LIT_CODE79	8'b01111111
`define LIT_CODE80	8'b10000000
`define LIT_CODE81	8'b10000001
`define LIT_CODE82	8'b10000010
`define LIT_CODE83	8'b10000011
`define LIT_CODE84	8'b10000100
`define LIT_CODE85	8'b10000101
`define LIT_CODE86	8'b10000110
`define LIT_CODE87	8'b10000111
`define LIT_CODE88	8'b10001000
`define LIT_CODE89	8'b10001001
`define LIT_CODE90	8'b10001010
`define LIT_CODE91	8'b10001011
`define LIT_CODE92	8'b10001100
`define LIT_CODE93	8'b10001101
`define LIT_CODE94	8'b10001110
`define LIT_CODE95	8'b10001111
`define LIT_CODE96	8'b10010000
`define LIT_CODE97	8'b10010001
`define LIT_CODE98	8'b10010010
`define LIT_CODE99	8'b10010011
`define LIT_CODE100	8'b10010100
`define LIT_CODE101	8'b10010101
`define LIT_CODE102	8'b10010110
`define LIT_CODE103	8'b10010111
`define LIT_CODE104	8'b10011000
`define LIT_CODE105	8'b10011001
`define LIT_CODE106	8'b10011010
`define LIT_CODE107	8'b10011011
`define LIT_CODE108	8'b10011100
`define LIT_CODE109	8'b10011101
`define LIT_CODE110	8'b10011110
`define LIT_CODE111	8'b10011111
`define LIT_CODE112	8'b10100000
`define LIT_CODE113	8'b10100001
`define LIT_CODE114	8'b10100010
`define LIT_CODE115	8'b10100011
`define LIT_CODE116	8'b10100100
`define LIT_CODE117	8'b10100101
`define LIT_CODE118	8'b10100110
`define LIT_CODE119	8'b10100111
`define LIT_CODE120	8'b10101000
`define LIT_CODE121	8'b10101001
`define LIT_CODE122	8'b10101010
`define LIT_CODE123	8'b10101011
`define LIT_CODE124	8'b10101100
`define LIT_CODE125	8'b10101101
`define LIT_CODE126	8'b10101110
`define LIT_CODE127	8'b10101111
`define LIT_CODE128	8'b10110000
`define LIT_CODE129	8'b10110001
`define LIT_CODE130	8'b10110010
`define LIT_CODE131	8'b10110011
`define LIT_CODE132	8'b10110100
`define LIT_CODE133	8'b10110101
`define LIT_CODE134	8'b10110110
`define LIT_CODE135	8'b10110111
`define LIT_CODE136	8'b10111000
`define LIT_CODE137	8'b10111001
`define LIT_CODE138	8'b10111010
`define LIT_CODE139	8'b10111011
`define LIT_CODE140	8'b10111100
`define LIT_CODE141	8'b10111101
`define LIT_CODE142	8'b10111110
`define LIT_CODE143	8'b10111111
`define LIT_CODE144	9'b110010000
`define LIT_CODE145	9'b110010001
`define LIT_CODE146	9'b110010010
`define LIT_CODE147	9'b110010011
`define LIT_CODE148	9'b110010100
`define LIT_CODE149	9'b110010101
`define LIT_CODE150	9'b110010110
`define LIT_CODE151	9'b110010111
`define LIT_CODE152	9'b110011000
`define LIT_CODE153	9'b110011001
`define LIT_CODE154	9'b110011010
`define LIT_CODE155	9'b110011011
`define LIT_CODE156	9'b110011100
`define LIT_CODE157	9'b110011101
`define LIT_CODE158	9'b110011110
`define LIT_CODE159	9'b110011111
`define LIT_CODE160	9'b110100000
`define LIT_CODE161	9'b110100001
`define LIT_CODE162	9'b110100010
`define LIT_CODE163	9'b110100011
`define LIT_CODE164	9'b110100100
`define LIT_CODE165	9'b110100101
`define LIT_CODE166	9'b110100110
`define LIT_CODE167	9'b110100111
`define LIT_CODE168	9'b110101000
`define LIT_CODE169	9'b110101001
`define LIT_CODE170	9'b110101010
`define LIT_CODE171	9'b110101011
`define LIT_CODE172	9'b110101100
`define LIT_CODE173	9'b110101101
`define LIT_CODE174	9'b110101110
`define LIT_CODE175	9'b110101111
`define LIT_CODE176	9'b110110000
`define LIT_CODE177	9'b110110001
`define LIT_CODE178	9'b110110010
`define LIT_CODE179	9'b110110011
`define LIT_CODE180	9'b110110100
`define LIT_CODE181	9'b110110101
`define LIT_CODE182	9'b110110110
`define LIT_CODE183	9'b110110111
`define LIT_CODE184	9'b110111000
`define LIT_CODE185	9'b110111001
`define LIT_CODE186	9'b110111010
`define LIT_CODE187	9'b110111011
`define LIT_CODE188	9'b110111100
`define LIT_CODE189	9'b110111101
`define LIT_CODE190	9'b110111110
`define LIT_CODE191	9'b110111111
`define LIT_CODE192	9'b111000000
`define LIT_CODE193	9'b111000001
`define LIT_CODE194	9'b111000010
`define LIT_CODE195	9'b111000011
`define LIT_CODE196	9'b111000100
`define LIT_CODE197	9'b111000101
`define LIT_CODE198	9'b111000110
`define LIT_CODE199	9'b111000111
`define LIT_CODE200	9'b111001000
`define LIT_CODE201	9'b111001001
`define LIT_CODE202	9'b111001010
`define LIT_CODE203	9'b111001011
`define LIT_CODE204	9'b111001100
`define LIT_CODE205	9'b111001101
`define LIT_CODE206	9'b111001110
`define LIT_CODE207	9'b111001111
`define LIT_CODE208	9'b111010000
`define LIT_CODE209	9'b111010001
`define LIT_CODE210	9'b111010010
`define LIT_CODE211	9'b111010011
`define LIT_CODE212	9'b111010100
`define LIT_CODE213	9'b111010101
`define LIT_CODE214	9'b111010110
`define LIT_CODE215	9'b111010111
`define LIT_CODE216	9'b111011000
`define LIT_CODE217	9'b111011001
`define LIT_CODE218	9'b111011010
`define LIT_CODE219	9'b111011011
`define LIT_CODE220	9'b111011100
`define LIT_CODE221	9'b111011101
`define LIT_CODE222	9'b111011110
`define LIT_CODE223	9'b111011111
`define LIT_CODE224	9'b111100000
`define LIT_CODE225	9'b111100001
`define LIT_CODE226	9'b111100010
`define LIT_CODE227	9'b111100011
`define LIT_CODE228	9'b111100100
`define LIT_CODE229	9'b111100101
`define LIT_CODE230	9'b111100110
`define LIT_CODE231	9'b111100111
`define LIT_CODE232	9'b111101000
`define LIT_CODE233	9'b111101001
`define LIT_CODE234	9'b111101010
`define LIT_CODE235	9'b111101011
`define LIT_CODE236	9'b111101100
`define LIT_CODE237	9'b111101101
`define LIT_CODE238	9'b111101110
`define LIT_CODE239	9'b111101111
`define LIT_CODE240	9'b111110000
`define LIT_CODE241	9'b111110001
`define LIT_CODE242	9'b111110010
`define LIT_CODE243	9'b111110011
`define LIT_CODE244	9'b111110100
`define LIT_CODE245	9'b111110101
`define LIT_CODE246	9'b111110110
`define LIT_CODE247	9'b111110111
`define LIT_CODE248	9'b111111000
`define LIT_CODE249	9'b111111001
`define LIT_CODE250	9'b111111010
`define LIT_CODE251	9'b111111011
`define LIT_CODE252	9'b111111100
`define LIT_CODE253	9'b111111101
`define LIT_CODE254	9'b111111110
`define LIT_CODE255	9'b111111111
`define LIT_CODE256	7'b0000000



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
	
		// display the codes for the 8 bit literals
		//for (i = 0; i <= 143; i = i +1) begin
    	  	//$display ("`define LIT_CODE%d = 9'd%d", i, i);
			//`LIT_CODE0: sliteral_data           <= `LIT_CODE0;	
    	//  	$display ("9'd%d :  sliteral_data  <= `LIT_CODE%d;", i, i);
    	//end

		// display the codes for the 9 bit literals
		//for (i = 144; i <= 255; i = i +1) begin
    	//  	$display ("`define LIT_CODE%d  9'd%d", i, i);
		    // $display ("9'd%d :  sliteral_data  <= `LIT_CODE%d;", i, i);
    	//end
		
        // Validate data between 0  -143. We should have 8 data bits.
        // Validate data between 144-255. We should have 9 data bits.
		//for (i = 144; i <= 255; i = i +1) begin
        //    //load_data_task(9'd0);
        //    //validate_slength_data(`LIT_CODE0, 4'd8);
		//	$display (" load_data_task(%d);", i);
		//	$display (" validate_slength_data(`LIT_CODE%d, 4'd9);", i);
        //end

        load_data_task(          0);
        validate_slength_data(`LIT_CODE0, 4'd8);
        load_data_task(          1);   
        validate_slength_data(`LIT_CODE1, 4'd8);
        load_data_task(          2);   
        validate_slength_data(`LIT_CODE2, 4'd8);
        load_data_task(          3);   
        validate_slength_data(`LIT_CODE3, 4'd8);
        load_data_task(          4);   
        validate_slength_data(`LIT_CODE4, 4'd8);
        load_data_task(          5);   
        validate_slength_data(`LIT_CODE5, 4'd8);
        load_data_task(          6);   
        validate_slength_data(`LIT_CODE6, 4'd8);
        load_data_task(          7);   
        validate_slength_data(`LIT_CODE7, 4'd8);
        load_data_task(          8);   
        validate_slength_data(`LIT_CODE8, 4'd8);
        load_data_task(          9);   
        validate_slength_data(`LIT_CODE9, 4'd8);
        load_data_task(         10);
        validate_slength_data(`LIT_CODE10, 4'd8);
        load_data_task(         11);
        validate_slength_data(`LIT_CODE11, 4'd8);
        load_data_task(         12);
        validate_slength_data(`LIT_CODE12, 4'd8);
        load_data_task(         13);
        validate_slength_data(`LIT_CODE13, 4'd8);
        load_data_task(         14);
        validate_slength_data(`LIT_CODE14, 4'd8);
        load_data_task(         15);
        validate_slength_data(`LIT_CODE15, 4'd8);
        load_data_task(         16);
        validate_slength_data(`LIT_CODE16, 4'd8);
        load_data_task(         17);
        validate_slength_data(`LIT_CODE17, 4'd8);
        load_data_task(         18);
        validate_slength_data(`LIT_CODE18, 4'd8);
        load_data_task(         19);
        validate_slength_data(`LIT_CODE19, 4'd8);
        load_data_task(         20);
        validate_slength_data(`LIT_CODE20, 4'd8);
        load_data_task(         21);
        validate_slength_data(`LIT_CODE21, 4'd8);
        load_data_task(         22);
        validate_slength_data(`LIT_CODE22, 4'd8);
        load_data_task(         23);
        validate_slength_data(`LIT_CODE23, 4'd8);
        load_data_task(         24);
        validate_slength_data(`LIT_CODE24, 4'd8);
        load_data_task(         25);
        validate_slength_data(`LIT_CODE25, 4'd8);
        load_data_task(         26);
        validate_slength_data(`LIT_CODE26, 4'd8);
        load_data_task(         27);
        validate_slength_data(`LIT_CODE27, 4'd8);
        load_data_task(         28);
        validate_slength_data(`LIT_CODE28, 4'd8);
        load_data_task(         29);
        validate_slength_data(`LIT_CODE29, 4'd8);
        load_data_task(         30);
        validate_slength_data(`LIT_CODE30, 4'd8);
        load_data_task(         31);
        validate_slength_data(`LIT_CODE31, 4'd8);
        load_data_task(         32);
        validate_slength_data(`LIT_CODE32, 4'd8);
        load_data_task(         33);
        validate_slength_data(`LIT_CODE33, 4'd8);
        load_data_task(         34);
        validate_slength_data(`LIT_CODE34, 4'd8);
        load_data_task(         35);
        validate_slength_data(`LIT_CODE35, 4'd8);
        load_data_task(         36);
        validate_slength_data(`LIT_CODE36, 4'd8);
        load_data_task(         37);
        validate_slength_data(`LIT_CODE37, 4'd8);
        load_data_task(         38);
        validate_slength_data(`LIT_CODE38, 4'd8);
        load_data_task(         39);
        validate_slength_data(`LIT_CODE39, 4'd8);
        load_data_task(         40);
        validate_slength_data(`LIT_CODE40, 4'd8);
        load_data_task(         41);
        validate_slength_data(`LIT_CODE41, 4'd8);
        load_data_task(         42);
        validate_slength_data(`LIT_CODE42, 4'd8);
        load_data_task(         43);
        validate_slength_data(`LIT_CODE43, 4'd8);
        load_data_task(         44);
        validate_slength_data(`LIT_CODE44, 4'd8);
        load_data_task(         45);
        validate_slength_data(`LIT_CODE45, 4'd8);
        load_data_task(         46);
        validate_slength_data(`LIT_CODE46, 4'd8);
        load_data_task(         47);
        validate_slength_data(`LIT_CODE47, 4'd8);
        load_data_task(         48);
        validate_slength_data(`LIT_CODE48, 4'd8);
        load_data_task(         49);
        validate_slength_data(`LIT_CODE49, 4'd8);
        load_data_task(         50);
        validate_slength_data(`LIT_CODE50, 4'd8);
        load_data_task(         51);
        validate_slength_data(`LIT_CODE51, 4'd8);
        load_data_task(         52);
        validate_slength_data(`LIT_CODE52, 4'd8);
        load_data_task(         53);
        validate_slength_data(`LIT_CODE53, 4'd8);
        load_data_task(         54);
        validate_slength_data(`LIT_CODE54, 4'd8);
        load_data_task(         55);
        validate_slength_data(`LIT_CODE55, 4'd8);
        load_data_task(         56);
        validate_slength_data(`LIT_CODE56, 4'd8);
        load_data_task(         57);
        validate_slength_data(`LIT_CODE57, 4'd8);
        load_data_task(         58);
        validate_slength_data(`LIT_CODE58, 4'd8);
        load_data_task(         59);
        validate_slength_data(`LIT_CODE59, 4'd8);
        load_data_task(         60);
        validate_slength_data(`LIT_CODE60, 4'd8);
        load_data_task(         61);
        validate_slength_data(`LIT_CODE61, 4'd8);
        load_data_task(         62);
        validate_slength_data(`LIT_CODE62, 4'd8);
        load_data_task(         63);
        validate_slength_data(`LIT_CODE63, 4'd8);
        load_data_task(         64);
        validate_slength_data(`LIT_CODE64, 4'd8);
        load_data_task(         65);
        validate_slength_data(`LIT_CODE65, 4'd8);
        load_data_task(         66);
        validate_slength_data(`LIT_CODE66, 4'd8);
        load_data_task(         67);
        validate_slength_data(`LIT_CODE67, 4'd8);
        load_data_task(         68);
        validate_slength_data(`LIT_CODE68, 4'd8);
        load_data_task(         69);
        validate_slength_data(`LIT_CODE69, 4'd8);
        load_data_task(         70);
        validate_slength_data(`LIT_CODE70, 4'd8);
        load_data_task(         71);
        validate_slength_data(`LIT_CODE71, 4'd8);
        load_data_task(         72);
        validate_slength_data(`LIT_CODE72, 4'd8);
        load_data_task(         73);
        validate_slength_data(`LIT_CODE73, 4'd8);
        load_data_task(         74);
        validate_slength_data(`LIT_CODE74, 4'd8);
        load_data_task(         75);
        validate_slength_data(`LIT_CODE75, 4'd8);
        load_data_task(         76);
        validate_slength_data(`LIT_CODE76, 4'd8);
        load_data_task(         77);
        validate_slength_data(`LIT_CODE77, 4'd8);
        load_data_task(         78);
        validate_slength_data(`LIT_CODE78, 4'd8);
        load_data_task(         79);
        validate_slength_data(`LIT_CODE79, 4'd8);
        load_data_task(         80);
        validate_slength_data(`LIT_CODE80, 4'd8);
        load_data_task(         81);
        validate_slength_data(`LIT_CODE81, 4'd8);
        load_data_task(         82);
        validate_slength_data(`LIT_CODE82, 4'd8);
        load_data_task(         83);
        validate_slength_data(`LIT_CODE83, 4'd8);
        load_data_task(         84);
        validate_slength_data(`LIT_CODE84, 4'd8);
        load_data_task(         85);
        validate_slength_data(`LIT_CODE85, 4'd8);
        load_data_task(         86);
        validate_slength_data(`LIT_CODE86, 4'd8);
        load_data_task(         87);
        validate_slength_data(`LIT_CODE87, 4'd8);
        load_data_task(         88);
        validate_slength_data(`LIT_CODE88, 4'd8);
        load_data_task(         89);
        validate_slength_data(`LIT_CODE89, 4'd8);
        load_data_task(         90);
        validate_slength_data(`LIT_CODE90, 4'd8);
        load_data_task(         91);
        validate_slength_data(`LIT_CODE91, 4'd8);
        load_data_task(         92);
        validate_slength_data(`LIT_CODE92, 4'd8);
        load_data_task(         93);
        validate_slength_data(`LIT_CODE93, 4'd8);
        load_data_task(         94);
        validate_slength_data(`LIT_CODE94, 4'd8);
        load_data_task(         95);
        validate_slength_data(`LIT_CODE95, 4'd8);
        load_data_task(         96);
        validate_slength_data(`LIT_CODE96, 4'd8);
        load_data_task(         97);
        validate_slength_data(`LIT_CODE97, 4'd8);
        load_data_task(         98);
        validate_slength_data(`LIT_CODE98, 4'd8);
        load_data_task(         99);
        validate_slength_data(`LIT_CODE99, 4'd8);
        load_data_task(        100);
        validate_slength_data(`LIT_CODE100, 4'd8);
        load_data_task(        101);
        validate_slength_data(`LIT_CODE101, 4'd8);
        load_data_task(        102);
        validate_slength_data(`LIT_CODE102, 4'd8);
        load_data_task(        103);
        validate_slength_data(`LIT_CODE103, 4'd8);
        load_data_task(        104);
        validate_slength_data(`LIT_CODE104, 4'd8);
        load_data_task(        105);
        validate_slength_data(`LIT_CODE105, 4'd8);
        load_data_task(        106);
        validate_slength_data(`LIT_CODE106, 4'd8);
        load_data_task(        107);
        validate_slength_data(`LIT_CODE107, 4'd8);
        load_data_task(        108);
        validate_slength_data(`LIT_CODE108, 4'd8);
        load_data_task(        109);
        validate_slength_data(`LIT_CODE109, 4'd8);
        load_data_task(        110);
        validate_slength_data(`LIT_CODE110, 4'd8);
        load_data_task(        111);
        validate_slength_data(`LIT_CODE111, 4'd8);
        load_data_task(        112);
        validate_slength_data(`LIT_CODE112, 4'd8);
        load_data_task(        113);
        validate_slength_data(`LIT_CODE113, 4'd8);
        load_data_task(        114);
        validate_slength_data(`LIT_CODE114, 4'd8);
        load_data_task(        115);
        validate_slength_data(`LIT_CODE115, 4'd8);
        load_data_task(        116);
        validate_slength_data(`LIT_CODE116, 4'd8);
        load_data_task(        117);
        validate_slength_data(`LIT_CODE117, 4'd8);
        load_data_task(        118);
        validate_slength_data(`LIT_CODE118, 4'd8);
        load_data_task(        119);
        validate_slength_data(`LIT_CODE119, 4'd8);
        load_data_task(        120);
        validate_slength_data(`LIT_CODE120, 4'd8);
        load_data_task(        121);
        validate_slength_data(`LIT_CODE121, 4'd8);
        load_data_task(        122);
        validate_slength_data(`LIT_CODE122, 4'd8);
        load_data_task(        123);
        validate_slength_data(`LIT_CODE123, 4'd8);
        load_data_task(        124);
        validate_slength_data(`LIT_CODE124, 4'd8);
        load_data_task(        125);
        validate_slength_data(`LIT_CODE125, 4'd8);
        load_data_task(        126);
        validate_slength_data(`LIT_CODE126, 4'd8);
        load_data_task(        127);
        validate_slength_data(`LIT_CODE127, 4'd8);
        load_data_task(        128);
        validate_slength_data(`LIT_CODE128, 4'd8);
        load_data_task(        129);
        validate_slength_data(`LIT_CODE129, 4'd8);
        load_data_task(        130);
        validate_slength_data(`LIT_CODE130, 4'd8);
        load_data_task(        131);
        validate_slength_data(`LIT_CODE131, 4'd8);
        load_data_task(        132);
        validate_slength_data(`LIT_CODE132, 4'd8);
        load_data_task(        133);
        validate_slength_data(`LIT_CODE133, 4'd8);
        load_data_task(        134);
        validate_slength_data(`LIT_CODE134, 4'd8);
        load_data_task(        135);
        validate_slength_data(`LIT_CODE135, 4'd8);
        load_data_task(        136);
        validate_slength_data(`LIT_CODE136, 4'd8);
        load_data_task(        137);
        validate_slength_data(`LIT_CODE137, 4'd8);
        load_data_task(        138);
        validate_slength_data(`LIT_CODE138, 4'd8);
        load_data_task(        139);
        validate_slength_data(`LIT_CODE139, 4'd8);
        load_data_task(        140);
        validate_slength_data(`LIT_CODE140, 4'd8);
        load_data_task(        141);
        validate_slength_data(`LIT_CODE141, 4'd8);
        load_data_task(        142);
        validate_slength_data(`LIT_CODE142, 4'd8);
        load_data_task(        143);
        validate_slength_data(`LIT_CODE143, 4'd8);
    
	    repeat(10) @(posedge clk);
        //load_data_task(        256);
        //validate_slength_data(`LIT_CODE256, 4'd7);
        //load_data_task(        257);
        //validate_slength_data(`LIT_CODE1, 4'd0);      // we have 0 valid bits 
        //load_data_task(        357);
        //validate_slength_data(`LIT_CODE101, 4'd0);    // we have 0 valid bits 		
		
		repeat(10) @(posedge clk);

        load_data_task(        144);
        validate_slength_data(`LIT_CODE144, 4'd9);
        load_data_task(        145);
        validate_slength_data(`LIT_CODE145, 4'd9);
        load_data_task(        146);
        validate_slength_data(`LIT_CODE146, 4'd9);
        load_data_task(        147);
        validate_slength_data(`LIT_CODE147, 4'd9);
        load_data_task(        148);
        validate_slength_data(`LIT_CODE148, 4'd9);
        load_data_task(        149);
        validate_slength_data(`LIT_CODE149, 4'd9);
        load_data_task(        150);
        validate_slength_data(`LIT_CODE150, 4'd9);
        load_data_task(        151);
        validate_slength_data(`LIT_CODE151, 4'd9);
        load_data_task(        152);
        validate_slength_data(`LIT_CODE152, 4'd9);
        load_data_task(        153);
        validate_slength_data(`LIT_CODE153, 4'd9);
        load_data_task(        154);
        validate_slength_data(`LIT_CODE154, 4'd9);
        load_data_task(        155);
        validate_slength_data(`LIT_CODE155, 4'd9);
        load_data_task(        156);
        validate_slength_data(`LIT_CODE156, 4'd9);
        load_data_task(        157);
        validate_slength_data(`LIT_CODE157, 4'd9);
        load_data_task(        158);
        validate_slength_data(`LIT_CODE158, 4'd9);
        load_data_task(        159);
        validate_slength_data(`LIT_CODE159, 4'd9);
        load_data_task(        160);
        validate_slength_data(`LIT_CODE160, 4'd9);
        load_data_task(        161);
        validate_slength_data(`LIT_CODE161, 4'd9);
        load_data_task(        162);
        validate_slength_data(`LIT_CODE162, 4'd9);
        load_data_task(        163);
        validate_slength_data(`LIT_CODE163, 4'd9);
        load_data_task(        164);
        validate_slength_data(`LIT_CODE164, 4'd9);
        load_data_task(        165);
        validate_slength_data(`LIT_CODE165, 4'd9);
        load_data_task(        166);
        validate_slength_data(`LIT_CODE166, 4'd9);
        load_data_task(        167);
        validate_slength_data(`LIT_CODE167, 4'd9);
        load_data_task(        168);
        validate_slength_data(`LIT_CODE168, 4'd9);
        load_data_task(        169);
        validate_slength_data(`LIT_CODE169, 4'd9);
        load_data_task(        170);
        validate_slength_data(`LIT_CODE170, 4'd9);
        load_data_task(        171);
        validate_slength_data(`LIT_CODE171, 4'd9);
        load_data_task(        172);
        validate_slength_data(`LIT_CODE172, 4'd9);
        load_data_task(        173);
        validate_slength_data(`LIT_CODE173, 4'd9);
        load_data_task(        174);
        validate_slength_data(`LIT_CODE174, 4'd9);
        load_data_task(        175);
        validate_slength_data(`LIT_CODE175, 4'd9);
        load_data_task(        176);
        validate_slength_data(`LIT_CODE176, 4'd9);
        load_data_task(        177);
        validate_slength_data(`LIT_CODE177, 4'd9);
        load_data_task(        178);
        validate_slength_data(`LIT_CODE178, 4'd9);
        load_data_task(        179);
        validate_slength_data(`LIT_CODE179, 4'd9);
        load_data_task(        180);
        validate_slength_data(`LIT_CODE180, 4'd9);
        load_data_task(        181);
        validate_slength_data(`LIT_CODE181, 4'd9);
        load_data_task(        182);
        validate_slength_data(`LIT_CODE182, 4'd9);
        load_data_task(        183);
        validate_slength_data(`LIT_CODE183, 4'd9);
        load_data_task(        184);
        validate_slength_data(`LIT_CODE184, 4'd9);
        load_data_task(        185);
        validate_slength_data(`LIT_CODE185, 4'd9);
        load_data_task(        186);
        validate_slength_data(`LIT_CODE186, 4'd9);
        load_data_task(        187);
        validate_slength_data(`LIT_CODE187, 4'd9);
        load_data_task(        188);
        validate_slength_data(`LIT_CODE188, 4'd9);
        load_data_task(        189);
        validate_slength_data(`LIT_CODE189, 4'd9);
        load_data_task(        190);
        validate_slength_data(`LIT_CODE190, 4'd9);
        load_data_task(        191);
        validate_slength_data(`LIT_CODE191, 4'd9);
        load_data_task(        192);
        validate_slength_data(`LIT_CODE192, 4'd9);
        load_data_task(        193);
        validate_slength_data(`LIT_CODE193, 4'd9);
        load_data_task(        194);
        validate_slength_data(`LIT_CODE194, 4'd9);
        load_data_task(        195);
        validate_slength_data(`LIT_CODE195, 4'd9);
        load_data_task(        196);
        validate_slength_data(`LIT_CODE196, 4'd9);
        load_data_task(        197);
        validate_slength_data(`LIT_CODE197, 4'd9);
        load_data_task(        198);
        validate_slength_data(`LIT_CODE198, 4'd9);
        load_data_task(        199);
        validate_slength_data(`LIT_CODE199, 4'd9);
        load_data_task(        200);
        validate_slength_data(`LIT_CODE200, 4'd9);
        load_data_task(        201);
        validate_slength_data(`LIT_CODE201, 4'd9);
        load_data_task(        202);
        validate_slength_data(`LIT_CODE202, 4'd9);
        load_data_task(        203);
        validate_slength_data(`LIT_CODE203, 4'd9);
        load_data_task(        204);
        validate_slength_data(`LIT_CODE204, 4'd9);
        load_data_task(        205);
        validate_slength_data(`LIT_CODE205, 4'd9);
        load_data_task(        206);
        validate_slength_data(`LIT_CODE206, 4'd9);
        load_data_task(        207);
        validate_slength_data(`LIT_CODE207, 4'd9);
        load_data_task(        208);
        validate_slength_data(`LIT_CODE208, 4'd9);
        load_data_task(        209);
        validate_slength_data(`LIT_CODE209, 4'd9);
        load_data_task(        210);
        validate_slength_data(`LIT_CODE210, 4'd9);
        load_data_task(        211);
        validate_slength_data(`LIT_CODE211, 4'd9);
        load_data_task(        212);
        validate_slength_data(`LIT_CODE212, 4'd9);
        load_data_task(        213);
        validate_slength_data(`LIT_CODE213, 4'd9);
        load_data_task(        214);
        validate_slength_data(`LIT_CODE214, 4'd9);
        load_data_task(        215);
        validate_slength_data(`LIT_CODE215, 4'd9);
        load_data_task(        216);
        validate_slength_data(`LIT_CODE216, 4'd9);
        load_data_task(        217);
        validate_slength_data(`LIT_CODE217, 4'd9);
        load_data_task(        218);
        validate_slength_data(`LIT_CODE218, 4'd9);
        load_data_task(        219);
        validate_slength_data(`LIT_CODE219, 4'd9);
        load_data_task(        220);
        validate_slength_data(`LIT_CODE220, 4'd9);
        load_data_task(        221);
        validate_slength_data(`LIT_CODE221, 4'd9);
        load_data_task(        222);
        validate_slength_data(`LIT_CODE222, 4'd9);
        load_data_task(        223);
        validate_slength_data(`LIT_CODE223, 4'd9);
        load_data_task(        224);
        validate_slength_data(`LIT_CODE224, 4'd9);
        load_data_task(        225);
        validate_slength_data(`LIT_CODE225, 4'd9);
        load_data_task(        226);
        validate_slength_data(`LIT_CODE226, 4'd9);
        load_data_task(        227);
        validate_slength_data(`LIT_CODE227, 4'd9);
        load_data_task(        228);
        validate_slength_data(`LIT_CODE228, 4'd9);
        load_data_task(        229);
        validate_slength_data(`LIT_CODE229, 4'd9);
        load_data_task(        230);
        validate_slength_data(`LIT_CODE230, 4'd9);
        load_data_task(        231);
        validate_slength_data(`LIT_CODE231, 4'd9);
        load_data_task(        232);
        validate_slength_data(`LIT_CODE232, 4'd9);
        load_data_task(        233);
        validate_slength_data(`LIT_CODE233, 4'd9);
        load_data_task(        234);
        validate_slength_data(`LIT_CODE234, 4'd9);
        load_data_task(        235);
        validate_slength_data(`LIT_CODE235, 4'd9);
        load_data_task(        236);
        validate_slength_data(`LIT_CODE236, 4'd9);
        load_data_task(        237);
        validate_slength_data(`LIT_CODE237, 4'd9);
        load_data_task(        238);
        validate_slength_data(`LIT_CODE238, 4'd9);
        load_data_task(        239);
        validate_slength_data(`LIT_CODE239, 4'd9);
        load_data_task(        240);
        validate_slength_data(`LIT_CODE240, 4'd9);
        load_data_task(        241);
        validate_slength_data(`LIT_CODE241, 4'd9);
        load_data_task(        242);
        validate_slength_data(`LIT_CODE242, 4'd9);
        load_data_task(        243);
        validate_slength_data(`LIT_CODE243, 4'd9);
        load_data_task(        244);
        validate_slength_data(`LIT_CODE244, 4'd9);
        load_data_task(        245);
        validate_slength_data(`LIT_CODE245, 4'd9);
        load_data_task(        246);
        validate_slength_data(`LIT_CODE246, 4'd9);
        load_data_task(        247);
        validate_slength_data(`LIT_CODE247, 4'd9);
        load_data_task(        248);
        validate_slength_data(`LIT_CODE248, 4'd9);
        load_data_task(        249);
        validate_slength_data(`LIT_CODE249, 4'd9);
        load_data_task(        250);
        validate_slength_data(`LIT_CODE250, 4'd9);
        load_data_task(        251);
        validate_slength_data(`LIT_CODE251, 4'd9);
        load_data_task(        252);
        validate_slength_data(`LIT_CODE252, 4'd9);
        load_data_task(        253);
        validate_slength_data(`LIT_CODE253, 4'd9);
        load_data_task(        254);
        validate_slength_data(`LIT_CODE254, 4'd9);
        load_data_task(        255);
        validate_slength_data(`LIT_CODE255, 4'd9);		
		
		
		
		
		
		
		
		
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
	
    task validate_slength_data();
    input [8:0]  sliteral_data_exp;
	input [3:0]  sliteral_valid_bits_exp ;
    begin
	    //@(posedge clk);                                 // wait for the module to update its outpus
		#1;
            test_count <= test_count + 1;
    	if( ({sliteral_data_exp, sliteral_valid_bits_exp} == {sliteral_data, sliteral_valid_bits}) ) begin
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
