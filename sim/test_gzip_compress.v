/*
   Author: Ovidiu Plugariu
   Description: This is a test for the LZ77 sliding algorithm used in GZIP.  
*/

`timescale 1 ns / 10 ps

`include "../rtl_code/functions.v"

`define NO_COMRESSION      2'b00
`define FIXED_HUFFMAN      2'b01

`define BFINAL0            1'b0
`define BFINAL1            1'b1


module test_gzip_compress();

    parameter DATA_WIDTH = 8;
    parameter SEARCH_BUFFER_DEPTH = 8;
    parameter DICTIONARY_DEPTH = 512;
	parameter DICTIONARY_DEPTH_LOG = clogb2(DICTIONARY_DEPTH);
	parameter LOOK_AHEAD_BUFF_DEPTH = 258;
	parameter CNT_WIDTH = clogb2(LOOK_AHEAD_BUFF_DEPTH);
	
  
    //integer i;
    // Declare input/output variables
    reg clk;	
    reg rst_n;
    reg data_valid;
	reg set_match;
    reg [DATA_WIDTH-1:0] input_data;

    wire [DICTIONARY_DEPTH_LOG-1:0] match_position;
	wire [CNT_WIDTH-1:0]            match_length;
	wire [DATA_WIDTH-1:0]           next_symbol;
	wire                            output_enable;			

	
	wire data_flow_inhibit;
	wire [CNT_WIDTH-1:0]            match_length_filt;
	wire [DATA_WIDTH-1:0]           next_symbol_filt;
    wire [DICTIONARY_DEPTH_LOG-1:0] match_position_filt;	
	wire                            match_position_valid;
	wire                            output_enable_filt;


	
	reg [4:0] in_txt_index = 0;
    wire [7:0] tst_txt1 [0:21];
    assign tst_txt1[0 ] = " ";
    assign tst_txt1[1 ] = "s";
    assign tst_txt1[2 ] = "h";
    assign tst_txt1[3 ] = "e";
    assign tst_txt1[4 ] = " ";
    assign tst_txt1[5 ] = "s";  // s
    assign tst_txt1[6 ] = "e";
    assign tst_txt1[7 ] = "l";
    assign tst_txt1[8 ] = "l";
    assign tst_txt1[9 ] = "s";
    assign tst_txt1[10] = " ";
    assign tst_txt1[11] = "s";
    assign tst_txt1[12] = "e";	
    assign tst_txt1[13] = "a";	
    assign tst_txt1[14] = " ";	
    assign tst_txt1[15] = "s";	
    assign tst_txt1[16] = "h";	
    assign tst_txt1[17] = "e";	
    assign tst_txt1[18] = "l";	
    assign tst_txt1[19] = "l";	
    assign tst_txt1[20] = "s";	
    assign tst_txt1[21] = ".";
	

    wire [7:0] tst_txt2 [0:21];
    assign tst_txt2[0 ] = "b";
    assign tst_txt2[1 ] = "e";
    assign tst_txt2[2 ] = "t";
    assign tst_txt2[3 ] = "b";
    assign tst_txt2[4 ] = "e";
    assign tst_txt2[5 ] = "d";
    assign tst_txt2[6 ] = "b";
    assign tst_txt2[7 ] = "e";
    assign tst_txt2[8 ] = "e";
    assign tst_txt2[9 ] = "b";
    assign tst_txt2[10] = "e";
    assign tst_txt2[11] = "a";
    assign tst_txt2[12] = "r";	
    assign tst_txt2[13] = "b";	
    assign tst_txt2[14] = "e";	
    assign tst_txt2[15] = ".";	

	// aacaacabcabaaac            -- Wikipedia example
    wire [7:0] tst_txt3 [0:21];
    assign tst_txt3[0 ] = "a";
    assign tst_txt3[1 ] = "a";
    assign tst_txt3[2 ] = "c";
    assign tst_txt3[3 ] = "a";
    assign tst_txt3[4 ] = "a";
    assign tst_txt3[5 ] = "c";
    assign tst_txt3[6 ] = "a";
    assign tst_txt3[7 ] = "b";
    assign tst_txt3[8 ] = "c";
    assign tst_txt3[9 ] = "a";
    assign tst_txt3[10] = "b";
    assign tst_txt3[11] = "a";
    assign tst_txt3[12] = "a";	
    assign tst_txt3[13] = "a";	
    assign tst_txt3[14] = "c";	
    assign tst_txt3[15] = "$";
	

    // Create clock signal - 50MHz
    always
    #10 clk = ~clk;

	reg [31:0] data_in_32 =0;
	reg wr_en_fifo_in = 0;
	//reg rd_en = 0;
	reg rd_en_fifo_out = 0;
	wire [31:0] data_out_32;
	wire full_in_fifo;
    wire empty_in_fifo;	
    wire [31:0] dout_out_fifo_32;  
	wire empty_out_fifo; 
    wire [24+32+32+8-1:0] debug_reg;	
    reg [7:0] i;
    reg [7:0] byte0_in, byte1_in, byte2_in, byte3_in;
    reg [1:0] btype_in;
	
	
    integer test_count   ;
    integer success_count;
	integer error_count  ;
	reg     start_test1 = 0;
	reg     start_test2 = 0;
	reg     start_test3 = 0;
	reg     reset_fifo  = 1;


   //====================================================================================================================	
   //========================================== Instantiate the DUT =====================================================
   //====================================================================================================================
   
   gzip_top
        #(      	
            .DICTIONARY_DEPTH(DICTIONARY_DEPTH),
            .DICTIONARY_DEPTH_LOG(DICTIONARY_DEPTH_LOG)			
    	    //.LOOK_AHEAD_BUFF_DEPTH(LOOK_AHEAD_BUFF_DEPTH),    	    
    	    //.CNT_WIDTH(CNT_WIDTH)             // The counter size must be changed according to the maximum match length			
    	)
        gzip_top_i0		
        (	
		// Module inputs
		.xilly_clk(clk),
        .clk,	
        .rst_n,
		.btype_in,
		.reset_fifo,
		.wr_en_fifo_in,
		.din_fifo_in(data_in_32),
	    .rd_en_fifo_out,
		
        // Module outputs
        .debug_reg,		
        .full_in_fifo,
	    .dout_out_fifo_32,  
	    .empty_out_fifo
        );		


	initial
    begin
	
        test_count    = 0; 
        success_count = 0;
        error_count   = 0;
        $display($time, "<< Starting the Simulation >>");
	    btype_in      = 0;
	    clk = 0;
	    rst_n = 0;
	    data_valid = 0;
        input_data = 8'b0;
        set_match = 0;
			
	    repeat(50) @(posedge clk);
	    rst_n = 1;
		reset_fifo = 0;
        repeat(5) @(posedge clk);		
	    @(posedge clk);         
        start_test2 = 1;
        if (start_test2 == 1)	begin
            $display($time, "**************************   TEST1   **************************");	
		    //$display($time, "Test phrase= 'abcd' ");
			btype_in = `FIXED_HUFFMAN;
		    
			// $display($time, "Test phrase= 'Ana mere.Ovi mere.' ");
			/*feed_input_fifo({{7'b0,`BFINAL1}, 24'd19});            // BFINAL=0, BTYPE=FIXED_HUFFMAN, LENGTH=18 bytes
		    feed_input_fifo({"A","n","a"," "}); 
		    feed_input_fifo({"m","e","r","e"}); 
		    feed_input_fifo({"."," ","O","v"});		
		    feed_input_fifo({"i"," ","m","e"});		
		    feed_input_fifo({"r","e","."," "});*/

            // $display($time, "Test phrase= 'That apple is our best apple.' ");			
			feed_input_fifo({{7'b0,`BFINAL1}, 24'd29});            // BFINAL=0, BTYPE=FIXED_HUFFMAN, LENGTH=6 bytes
		    feed_input_fifo({"T","h","a","t"}); 
		    feed_input_fifo({" ","a","p","p"}); 
		    feed_input_fifo({"l","e"," ","i"}); 
		    feed_input_fifo({"s"," ","o","u"}); 
		    feed_input_fifo({"r"," ","b","e"}); 
		    feed_input_fifo({"s","t"," ","a"}); 
		    feed_input_fifo({"p","p","l","e"}); 
		    feed_input_fifo({"."," "," "," "}); 
			
			/*$display($time, "Test phrase= 'Ana are mere. Ovidiu are mere mere.' ");
			feed_input_fifo({{7'b0,`BFINAL1}, 24'd35});            // BFINAL=0, BTYPE=FIXED_HUFFMAN, LENGTH=18 bytes
		    feed_input_fifo({"A","n","a"," "}); 
		    feed_input_fifo({"a","r","e"," "}); 
		    feed_input_fifo({"m","e","r","e"});
		    feed_input_fifo({"."," ","O","v"});		
		    feed_input_fifo({"i","d","i","u"});
		    feed_input_fifo({" ","a","r","e"});
		    feed_input_fifo({" ","m","e","r"});
		    feed_input_fifo({"e"," ","m","e"});
		    feed_input_fifo({"r","e","."," "}); */

			/*$display($time, "Test phrase= 'Ana are mere. Ovidiu are mere mere Ana.' ");
			feed_input_fifo({{7'b0,`BFINAL1}, 24'd39});            // BFINAL=0, BTYPE=FIXED_HUFFMAN, LENGTH=18 bytes
		    feed_input_fifo({"A","n","a"," "}); 
		    feed_input_fifo({"a","r","e"," "}); 
		    feed_input_fifo({"m","e","r","e"});
		    feed_input_fifo({"."," ","O","v"});		
		    feed_input_fifo({"i","d","i","u"});
		    feed_input_fifo({" ","a","r","e"});
		    feed_input_fifo({" ","m","e","r"});
		    feed_input_fifo({"e"," ","m","e"});
		    feed_input_fifo({"r","e"," ","A"});	
		    feed_input_fifo({"n","a",".","x"}); */
			
		    //feed_input_fifo({"c","."," "," "});
		    /*feed_input_fifo({"e","f",8'd0,8'd0});

		    feed_input_fifo({{7'b0,1'b1}, 24'd5});              // BFINAL=1, BTYPE=FIXED_HUFFMAN, LENGTH=5 bytes
		    feed_input_fifo({"g","h","a","b"});
		    feed_input_fifo({"x",8'd0,8'd0,8'd0}); */

		    //feed_input_fifo({{7'b0,`BFINAL1}, 24'd4});          // BFINAL=1, BTYPE=FIXED_HUFFMAN, LENGTH=3 bytes
		    //for (i=0; i<16; i=i+1)
			//   feed_input_fifo({"a", "b", "c", "d"});
			//feed_input_fifo({"a", "b", "a", "a"});
		    //feed_input_fifo({"a", "1", "9", " "});
            
		    repeat(150) @(posedge clk);
		    start_test1 = 0;
			$display($time, "******************** TEST1 finished *************************");
		end
		
		
		
        $display($time, "************************** GZIP uncompressed test is DONE **************************");		
    end

	
	// POP the data from the output FIFO 
	always @(posedge clk)
	begin
	   if (!empty_out_fifo) read_output_fifo();
    end    	


	// Display the result of the sliding window module
	//always @(posedge clk)
	//	    display_output_data(match_position, match_length, next_symbol, output_enable);	
	
	// Display the result of the sliding window module
	//always @(posedge clk)
    //    if(output_enable_filt)                        //data can displayed only when output_enable is set
	//	    display_output_data_filt(match_position_filt, match_length_filt, next_symbol_filt, output_enable_filt, match_position_valid);		
			
			
			
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
    // Testing tasks
	
	
    task load_data_task;
        input [7:0] load_value;
    begin
		   // $display($time, " << Loading data %h >>", load_value);
            input_data = load_value;
            //in_txt_index = in_txt_index + 1;
            @(posedge clk);            
    end
    endtask //of load_data	
		
		
	// Task used to display data from the lz77 encoder
    task display_output_data;
		input [DICTIONARY_DEPTH_LOG-1:0] match_position;
		input [CNT_WIDTH-1:0]                match_length;
        input [DATA_WIDTH-1:0]               next_symbol;
		input output_enable;
	begin
	    if(output_enable) $display($time, "Output character Tp=%d, Tl=%d, Tn=%s", match_position, match_length, next_symbol); 
    end		
	endtask

	
	// This task displays the filtered data after only match_lengths >2 are only allowed
   /* task display_output_data_filt;
		input [DICTIONARY_DEPTH_LOG-1:0] match_position;		
		input [CNT_WIDTH-1:0]                match_length;
        input [DATA_WIDTH-1:0]               next_symbol;
		input output_enable;
		input match_position_valid;
	begin
	    if(output_enable && ! match_position_valid) $display($time, "Output character Tn=%s", next_symbol); 
		if(output_enable &&   match_position_valid) $display($time, "Output character Tp=%d, Tl=%d, Tn=%s", match_position_filt, match_length_filt, next_symbol_filt);
    end		
	endtask */
	
    task feed_input_fifo();                      // Reverse the data bytes to simulate the x86 memory storage effect
    input [31:0] data_feed;
     begin
        wr_en_fifo_in <= 1;
        //repeat(1) @(posedge clock);
    	data_in_32 <= {data_feed[7:0], data_feed[15:8], data_feed[23:16], data_feed[31:24]};		 
        repeat(1) @(posedge clk);	 
        wr_en_fifo_in    <= 1'b0;
    	//repeat(1) @(posedge clk);
     end
    endtask	

   /* task read_input_fifo();                      // Read data from the input FIFO
    input [31:0] data_out_32;
     begin
        rd_en <= 1;
        $display($time, "fifo_in=%s", data_out_32);
    	repeat(1) @(posedge clk);
		rd_en <= 0;
		//repeat(1) @(posedge clock);
     end
    endtask	*/

	task read_output_fifo();                      // Read data from the output FIFO
    //input [31:0] data_out_32;
     begin
        rd_en_fifo_out <= 1;       
    	repeat(1) @(posedge clk);
        rd_en_fifo_out <= 0;		
    	repeat(1) @(negedge clk);		
		$display($time, " gzip_fifo_out=%h", dout_out_fifo_32);
     end
    endtask	
	
	
endmodule
