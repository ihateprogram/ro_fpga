/*
   Author: Ovidiu Plugariu
   Description: This is a test for the Static Length Huffman tree used in the GZIP module.  
*/

`timescale 1 ns / 10 ps

`define LEN_CODE257	8'd1
`define LEN_CODE258	8'd2
`define LEN_CODE259	8'd3
`define LEN_CODE260	8'd4
`define LEN_CODE261	8'd5
`define LEN_CODE262	8'd6
`define LEN_CODE263	8'd7
`define LEN_CODE264	8'd8
`define LEN_CODE265	8'd9
`define LEN_CODE266	8'd10
`define LEN_CODE267	8'd11
`define LEN_CODE268	8'd12
`define LEN_CODE269	8'd13
`define LEN_CODE270	8'd14
`define LEN_CODE271	8'd15
`define LEN_CODE272	8'd16
`define LEN_CODE273	8'd17
`define LEN_CODE274	8'd18
`define LEN_CODE275	8'd19
`define LEN_CODE276	8'd20
`define LEN_CODE277	8'd21
`define LEN_CODE278	8'd22
`define LEN_CODE279	8'd23
`define LEN_CODE280 8'd192
`define LEN_CODE281 8'd193
`define LEN_CODE282 8'd194
`define LEN_CODE283 8'd195
`define LEN_CODE284 8'd196
`define LEN_CODE285 8'd197
`define LEN_CODE286 8'd198
`define LEN_CODE287 8'd199


module slength_test();
 
    integer i;
    // Declare input/output variables
    reg clk;	
    reg rst_n;

    reg  [8:0] match_length_in;             // 9bits: 3 <= match_length  <= 258   
	reg  match_length_valid_in;             // match_length_valid_in is used to enable the conversion of the lengths
	
	wire         slength_valid_out;
	wire [3:0]   slength_valid_bits; 
	reg  [3:0]   huffman_valid_bits; 
	wire [12:0]  slength_data_out;
	reg [12:0]  slength_data_out_exp_rev;
	reg [7:0]   huffman_code;
	reg [7:0]   huffman_code_rev;
	
	reg slength_huff_shift_right;
	
	reg[7 :0]  slength_huff_rev;              // the reversed value of the Huffman length value
	
    integer test_count    = 0;
    integer success_count = 0;
	integer error_count   = 0;
	
    // Create clock signal - 100MHz
    always
    #2 clk = ~clk;
	
    // Instantiate DUT
    slength slength_i0
    (
    // Module inputs
    .clk,	
    .rst_n,	
	.match_length_in,                    // 9bits: 3 <= match_length  <= 258
	
    // Module outputs
	.slength_data_out,                        // 13 bits { <7/8bit Huffman>, 5 extra bit binary code}
    .slength_valid_bits                       // this output says how many binary encoded bits are valid from the output of the decoder 
    );
	

	initial
    begin
        $display($time, "<< Starting the Simulation >>");
	    match_length_in = 0;
		match_length_valid_in = 0;
	    clk = 0;
	    rst_n = 0;
        repeat(15) @(posedge clk);
		rst_n = 1;
		
        $display($time, "**************************  SLENGTH TEST  **************************");
        repeat(5) @(posedge clk);
	
		// 257 ... 279 -- length 7 bit value
		// 1   ... 23
		/*for (i = 257; i <= 279; i = i +1) begin
    	  	$display ("`define LEN_CODE%d = 7'd%d", i, i-256);
    	end*/

		// 280 ... 287 -- length 8 bit value
		// 168 ... 175
		for (i = 280; i <= 287; i = i +1) begin
    	  	$display ("`define LEN_CODE%d = 8'd%d", i, i+24);
    	end
		
        // Values 0, 1 and 2 should be decoded with the default values
        load_data_task(9'd0);
        validate_slength_data(6'b0,`LEN_CODE257  , 4'd7,4'd0);
        load_data_task(9'd1);
        validate_slength_data(6'b0,`LEN_CODE257 , 4'd7,4'd1);
        load_data_task(9'd2);
        validate_slength_data(6'b0,`LEN_CODE257 , 4'd7,4'd2);


        // Distance between 3-10
        load_data_task(9'd3);
        validate_slength_data(6'b0,`LEN_CODE257 , 4'd7,4'd3);
        load_data_task(9'd4);
        validate_slength_data(6'b0,`LEN_CODE258, 4'd7,4'd3);
        load_data_task(9'd5);
        validate_slength_data(6'b0,`LEN_CODE259, 4'd7,4'd3);
        load_data_task(9'd6);
        validate_slength_data(6'b0,`LEN_CODE260, 4'd7,4'd3);
        load_data_task(9'd7);
        validate_slength_data(6'b0,`LEN_CODE261, 4'd7,4'd3);
        load_data_task(9'd8);
        validate_slength_data(6'b0,`LEN_CODE262, 4'd7,4'd3);
        load_data_task(9'd9);
        validate_slength_data(6'b0,`LEN_CODE263, 4'd7,4'd3);
        load_data_task(9'd10);
        validate_slength_data(6'b0,`LEN_CODE264, 4'd7,4'd3);
		
//`ifdef `baba
        // Distance between 11-18
        load_data_task(9'd11);
        validate_slength_data(6'b0,`LEN_CODE265 , 4'd8, 4'd7);
        load_data_task(9'd12);      
        validate_slength_data(6'b1,`LEN_CODE265 , 4'd8, 4'd7);
        load_data_task(9'd13);      
        validate_slength_data(6'b0,`LEN_CODE266 , 4'd8, 4'd7);
        load_data_task(9'd14);      
        validate_slength_data(6'b1,`LEN_CODE266, 4'd8, 4'd7);
        load_data_task(9'd15);      
        validate_slength_data(6'b0,`LEN_CODE267, 4'd8, 4'd7);
        load_data_task(9'd16);      
        validate_slength_data(6'b1,`LEN_CODE267, 4'd8, 4'd7);
        load_data_task(9'd17);      
        validate_slength_data(6'b0,`LEN_CODE268, 4'd8, 4'd7);
        load_data_task(9'd18);      
        validate_slength_data(6'b1,`LEN_CODE268, 4'd8, 4'd7);
        
        // Distance between 19-22
        load_data_task(9'd19);
        validate_slength_data(6'd0,`LEN_CODE269, 4'd9, 4'd9);   // two extra bits
        load_data_task(9'd20);
        validate_slength_data(6'd1,`LEN_CODE269, 4'd9, 4'd9);
        load_data_task(9'd21);
        validate_slength_data(6'd2,`LEN_CODE269, 4'd9, 4'd9);
        load_data_task(9'd22);
        validate_slength_data(6'd3,`LEN_CODE269, 4'd9, 4'd12);

        // Distance between 23-26
        load_data_task(9'd23);
        validate_slength_data(6'd0,`LEN_CODE270, 4'd9, 4'd9);
        load_data_task(9'd24);
        validate_slength_data(6'd1,`LEN_CODE270, 4'd9, 4'd9);
        load_data_task(9'd25);
        validate_slength_data(6'd2,`LEN_CODE270, 4'd9, 4'd9);
        load_data_task(9'd26);
        validate_slength_data(6'd3,`LEN_CODE270, 4'd9, 4'd9);

        // Distance between 27-30
        load_data_task(9'd27);
        validate_slength_data(6'd0,`LEN_CODE271, 4'd9, 4'd9);
        load_data_task(9'd28);
        validate_slength_data(6'd1,`LEN_CODE271, 4'd9, 4'd9);
        load_data_task(9'd29);
        validate_slength_data(6'd2,`LEN_CODE271, 4'd9, 4'd9);
        load_data_task(9'd30);
        validate_slength_data(6'd3,`LEN_CODE271, 4'd9, 4'd9);

        // Distance between 31-34
        load_data_task(9'd31);
        validate_slength_data(6'd0,`LEN_CODE272, 4'd9, 4'd9);
        load_data_task(9'd32);
        validate_slength_data(6'd1,`LEN_CODE272, 4'd9, 4'd9);
        load_data_task(9'd33);
        validate_slength_data(6'd2,`LEN_CODE272, 4'd9, 4'd9);
        load_data_task(9'd34);
        validate_slength_data(6'd3,`LEN_CODE272, 4'd9, 4'd11);
		
        //(extra_bits_val),(huffman_code_in),(slength_valid_bits_exp),(decimal_length)
        // Distance between 35-42
        load_data_task(9'd35);
        validate_slength_data(6'd0,`LEN_CODE273, 4'd10, match_length_in);     // three extra bits
        load_data_task(9'd37);
        validate_slength_data(6'd2,`LEN_CODE273, 4'd10, match_length_in);
        load_data_task(9'd39);
        validate_slength_data(6'd4,`LEN_CODE273, 4'd10, match_length_in);
        load_data_task(9'd42);
        validate_slength_data(6'd7,`LEN_CODE273, 4'd10, match_length_in);

        // Distance between 43-50
        load_data_task(9'd43);
        validate_slength_data(6'd0,`LEN_CODE274, 4'd10, match_length_in); 
        load_data_task(9'd47);
        validate_slength_data(6'd4,`LEN_CODE274, 4'd10, match_length_in); 		
        load_data_task(9'd50);
        validate_slength_data(6'd7,`LEN_CODE274, 4'd10, match_length_in); 

        // Distance between 51-58
        load_data_task(9'd51);
        validate_slength_data(3'd0,`LEN_CODE275, 4'd10, match_length_in); 
        load_data_task(9'd56);
        validate_slength_data(3'd5,`LEN_CODE275, 4'd10, match_length_in); 
        load_data_task(9'd58);
        validate_slength_data(3'd7,`LEN_CODE275, 4'd10, match_length_in); 

        // Distance between 59-66
        load_data_task(9'd59);
        validate_slength_data(3'd0,`LEN_CODE276, 4'd10, match_length_in); 
        load_data_task(9'd62);
        validate_slength_data(3'd3,`LEN_CODE276, 4'd10, match_length_in); 
        load_data_task(9'd66);
        validate_slength_data(3'd7,`LEN_CODE276, 4'd10, match_length_in);

        // Distance between 67-82
        load_data_task(9'd67);
        validate_slength_data(4'd0,`LEN_CODE277,  4'd11, match_length_in);  // four extra bits
        load_data_task(9'd69);
        validate_slength_data(4'd2,`LEN_CODE277,  4'd11, match_length_in); 		
        load_data_task(9'd75);
        validate_slength_data(4'd8,`LEN_CODE277,  4'd11, match_length_in); 
        load_data_task(9'd82);
        validate_slength_data(4'd15,`LEN_CODE277, 4'd11, match_length_in);

        // Distance between 83-98
        load_data_task(9'd83);
        validate_slength_data(4'd0,`LEN_CODE278, 4'd11, match_length_in);
        load_data_task(9'd88);
        validate_slength_data(4'd5,`LEN_CODE278, 4'd11, match_length_in);
        load_data_task(9'd98);
        validate_slength_data(4'd15,`LEN_CODE278, 4'd11, match_length_in);

        // Distance between 99-114
        load_data_task(9'd99);
        validate_slength_data(4'd0,`LEN_CODE279, 4'd11, match_length_in);
        load_data_task(9'd100);
        validate_slength_data(4'd1,`LEN_CODE279, 4'd11, match_length_in);
        load_data_task(9'd114);
        validate_slength_data(4'd15,`LEN_CODE279, 4'd11, match_length_in);

        // Distance between 115-130
		// Starting from here the huffman codes will have 8 bits
        load_data_task(9'd115);
        validate_slength_data(4'd0,`LEN_CODE280, 4'd12, match_length_in);
        load_data_task(9'd128);
        validate_slength_data(4'd13,`LEN_CODE280, 4'd12, match_length_in);
        load_data_task(9'd130);
        validate_slength_data(4'd15,`LEN_CODE280, 4'd12, match_length_in);

        // Distance between 131-162
        load_data_task(9'd131);
        validate_slength_data(5'd0, `LEN_CODE281,  4'd13, match_length_in);     // five extra bits
        load_data_task(9'd139);
        validate_slength_data(5'd8, `LEN_CODE281,  4'd13, match_length_in); 
        load_data_task(9'd151);
        validate_slength_data(5'd20, `LEN_CODE281,  4'd13, match_length_in); 
        load_data_task(9'd162);
        validate_slength_data( 5'd31, `LEN_CODE281, 4'd13, match_length_in); 

        // Distance between 163-194
        load_data_task(9'd163);
        validate_slength_data(5'd0, `LEN_CODE282, 4'd13, match_length_in);		
        load_data_task(9'd183);
        validate_slength_data(5'd20, `LEN_CODE282, 4'd13, match_length_in);
        load_data_task(9'd194);
        validate_slength_data(5'd31, `LEN_CODE282, 4'd13, match_length_in);

        // Distance between 195-226
        load_data_task(9'd195);
        validate_slength_data(5'd0, `LEN_CODE283, 4'd13, match_length_in);			
        load_data_task(9'd205);                   
        validate_slength_data(5'd10, `LEN_CODE283, 4'd13, match_length_in);
        load_data_task(9'd226);                   
        validate_slength_data(5'd31, `LEN_CODE283, 4'd13, match_length_in);

        // Distance between 227-257
        load_data_task(9'd227);
        validate_slength_data(5'd0, `LEN_CODE284,  4'd13, match_length_in);
        load_data_task(9'd237);
        validate_slength_data(5'd10, `LEN_CODE284, 4'd13, match_length_in);
        load_data_task(9'd241);
        validate_slength_data(5'd14, `LEN_CODE284, 4'd13, match_length_in);
        load_data_task(9'd257);
        validate_slength_data(5'd30, `LEN_CODE284, 4'd13, match_length_in);

        // Distance for 258
        load_data_task(9'd258);
        validate_slength_data(5'b0,`LEN_CODE285, 4'd8, match_length_in);	    // there are no extra bits for this distance	
		
		// Distances after 259 are treated as invalid and return the code for distance 3 but on 8 bits
        load_data_task(9'd259);
        validate_slength_data(6'b0,`LEN_CODE257, 4'd8, match_length_in);
        load_data_task(9'd279);
        validate_slength_data(6'b0,`LEN_CODE257, 4'd8, match_length_in);		
        load_data_task(9'd479);
        validate_slength_data(6'b0,`LEN_CODE257, 4'd8, match_length_in); 
//`endif
		
		repeat(10) @(posedge clk);


		report_test_results;
        $display($time, "************************** SLENGTH test is DONE **************************");		
    end

	
	//====================================================================================================================
	//======================================= Tasks for SDHT automatic validation ========================================
	//====================================================================================================================
	
    task load_data_task;
	    input  [8:0]  match_pos_in_val;
    begin
	    @(posedge clk); 
        match_length_in = match_pos_in_val;
		$display($time, " Loading match_length_in = %d", match_length_in);
		@(posedge clk);
    end
    endtask //of load_data	

	// Reverse the value of the Huffman length code. For the 7 bit values is has to shifted 1 bit to the right. RFC 1951 requirement
	
    task validate_slength_data();
    input [5 :0]  extra_bits_val;
	input [7 :0]  huffman_code_in;
	input [3 :0]  slength_valid_bits_exp ;
	input [8 :0]  decimal_length;  //  will determine if the huffman code has 7 or 8 bits
    begin
	    //@(posedge clk);                                 // wait for the module to update its outpus
		
		huffman_valid_bits = (decimal_length <= 114)? 4'd7 : 4'd8;
		huffman_code[7:0]  = (decimal_length <= 114)? {1'b0, huffman_code_in[6:0]} : huffman_code_in[7:0];
		huffman_code_rev[7:0] = {huffman_code[0],huffman_code[1],huffman_code[2],huffman_code[3],
		                         huffman_code[4],huffman_code[5],huffman_code[6],huffman_code[7]}; 
		//$display($time,"huffman_code_rev = %b",huffman_code_rev);
		
		slength_huff_shift_right = (decimal_length <= 114)? 1 : 0;
		
		slength_data_out_exp_rev[12:0] = (extra_bits_val << huffman_valid_bits) | (huffman_code_rev >> slength_huff_shift_right);
				
        #1   
     		test_count <= test_count + 1;
    	if( ({slength_data_out_exp_rev, slength_valid_bits_exp} == {slength_data_out, slength_valid_bits})) begin
    	    success_count <= success_count + 1; 
			$display($time,"Success at test %d",test_count);
			$display("            Static length SL=%b, valid_bits=%d", slength_data_out, slength_valid_bits);
    		end
        else begin
            error_count	<= error_count + 1;
			$display($time,"Error at test %d \n",test_count);
			$display("            Observed: length SL=%b, valid_bits=%d\n        Expected: length SD=%b, valid_bits=%d \n" 
			                                                                                                            ,slength_data_out, slength_valid_bits
			                                                                                                            ,slength_data_out_exp_rev, slength_valid_bits_exp);
    		end
        end
    endtask

    task report_test_results();
        begin       
	    if (test_count == success_count)  $display("	SDHT TEST finished SUCCESSFULLY");
        else                              $display("	SDHT TEST finished with ERRORS"); 
            $display("		test_count=%d",test_count);
            $display("		success_count=%d",success_count);
            $display("		error_count=%d",error_count);
        end
    endtask



	
endmodule
