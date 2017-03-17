/*
   Author: Ovidiu Plugariu
   Description: This is a test for the LZ77 sliding algorithm used in GZIP.  
*/

`timescale 1 ns / 10 ps

`include "../rtl_code/functions.v"

`define NO_COMRESSION      2'b00
`define FIXED_HUFFMAN      2'b01


module test_gzip();

    parameter DATA_WIDTH = 8;
    parameter SEARCH_BUFFER_DEPTH = 8;
    parameter DICTIONARY_DEPTH = 16;
	parameter DICTIONARY_DEPTH_LOG = clogb2(DICTIONARY_DEPTH);
	parameter LOOK_AHEAD_BUFF_DEPTH = 8;
	parameter CNT_WIDTH = clogb2(LOOK_AHEAD_BUFF_DEPTH);
	
  
    integer i;
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

    reg [DICTIONARY_DEPTH_LOG-1:0] match_position_ppl;
	reg [CNT_WIDTH-1:0]            match_length_ppl;
	reg [DATA_WIDTH-1:0]           next_symbol_ppl;
	reg                            output_enable_ppl;	
	
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
	reg wr_en = 0;
	reg rd_en = 0;
	wire [31:0] data_out_32;
	wire full_in_fifo;
    wire empty_in_fifo;	
 
    integer test_count   ;
    integer success_count;
	integer error_count  ;
	reg     start_test1 = 0;
	reg     start_test2 = 0;
	reg     start_test3 = 0;
    /*fifo_32 fifo_64kb_in(
    	.clk  (clk              ),
    	.rst  (~rst_n           ),
    	.din  (data_in_32       ),
    	.wr_en(wr_en            ),
    	.rd_en(rd_en),
    	
    	.dout (data_out_32      ),
    	.full (full_in_fifo     ),
    	.empty(empty_in_fifo    )
    );	*/

	
	
    // Instantiate DUT
    /*lz77_encoder 
	    #(.DATA_WIDTH(DATA_WIDTH) ,
		  .DICTIONARY_DEPTH(DICTIONARY_DEPTH),
          .CNT_WIDTH(CNT_WIDTH),
          .DICTIONARY_DEPTH_LOG(DICTIONARY_DEPTH_LOG) 
		 )
		lz77_enc
        (
        // Module inputs
        .clk,	
        .rst_n,
        .data_valid,
        .input_data,	
    
        // Module outputs
        .match_position,	
    	.match_length,
    	.next_symbol,
    	.output_enable    
        );  */
		
   gzip_top
        #(      	
            .DICTIONARY_DEPTH(DICTIONARY_DEPTH),		
    	    .LOOK_AHEAD_BUFF_DEPTH(8),
    	    .DICTIONARY_DEPTH_LOG(DICTIONARY_DEPTH_LOG),
    	    .CNT_WIDTH(CNT_WIDTH)             // The counter size must be changed according to the maximum match length			
    	)
        gzip_top_i0		
        (
        // Module inputs
        .clk,	
        .rst_n,	
    	.wr_en,
    	.din(data_in_32),
    	//input        rd_en,
    	
        // Module outputs
		.full_in_fifo,
        .match_position,
    	.match_length,
    	.next_symbol,
    	.output_enable	
        ); 
	
		

    // Make a 1 deep level pipeline between the encoder and the filter 		
   /* always @(posedge clk or negedge rst_n)
	begin
	    if(!rst_n) begin
   		    match_position_ppl <= 0;
			match_length_ppl   <= 0;
			next_symbol_ppl    <= 0;
			output_enable_ppl  <= 0;
		end
		else begin                               
   		    match_position_ppl <= match_position;
			match_length_ppl   <= match_length  ;
			next_symbol_ppl    <= next_symbol   ;
			output_enable_ppl  <= output_enable ;		    
		end
	end	 */

	
	// Instantiate LZ77 match filter
   /* lz77_match_filter
    #( 
        .DATA_WIDTH(DATA_WIDTH) ,
		.DICTIONARY_DEPTH(DICTIONARY_DEPTH),
        .CNT_WIDTH(CNT_WIDTH),
        .DICTIONARY_DEPTH_LOG(DICTIONARY_DEPTH_LOG)
	)
	lz_filt
    (
    // Module inputs
        .clk,	
        .rst_n,		
        .match_position ,
	    .match_length    ,
	    .next_symbol     ,
	    .output_enable_in(output_enable     ),	
	
	
    // Module outputs 
	    .data_flow_inhibit,
        .match_position_filt,	
	    .match_length_filt,
	    .next_symbol_filt,
	    .match_position_valid,
	    .output_enable_filt
    ); */
	
		

	initial
    begin
	
        test_count    = 0; 
        success_count = 0;
        error_count   = 0;
        $display($time, "<< Starting the Simulation >>");
	    
	    clk = 0;
	    rst_n = 0;
	    data_valid = 0;
        input_data = 8'b0;
        set_match = 0;	
       		
	    repeat(50) @(posedge clk);
	    rst_n = 1;
        repeat(5) @(posedge clk);		
	    @(posedge clk);         
        start_test1 = 1;
        if (start_test1 == 1 )	begin
            $display($time, "**************************   TEST1   **************************");	
		    $display($time, "Test phrase= ' she sells sea shells.' ");
		    feed_input_fifo({{5'b0,1'b1, `FIXED_HUFFMAN}, 24'd22});              // BFINAL=1, BTYPE=NO_COMRESSION, LENGTH=22 bytes
		    feed_input_fifo({" ","s","h","e"});
		    feed_input_fifo({" ","s","e","l"});
		    // Simulate a burst transmission delay 
		    repeat(30) @(posedge clk); 
		    feed_input_fifo({"l","s"," ","s"});
		    feed_input_fifo({"e","a"," ","s"});
		    feed_input_fifo({"h","e","l","l"});
		    feed_input_fifo({"s",".", 8'b0, 8'b0});
            
		    repeat(30) @(posedge clk);
		    start_test1 = 0;
			$display($time, "******************** TEST1 finished *************************");
		end
		
	
	    repeat(5) @(posedge clk);
	    rst_n = 0;
        repeat(5) @(posedge clk);
		rst_n = 1;
		repeat(5) @(posedge clk); 
        start_test2 = 1;
        if (start_test2 == 1 )	begin
            $display($time, "**************************   TEST2   **************************");	
		    $display($time, "Test phrase= 'betbedbeebearbe beta bets' ");
			feed_input_fifo({{5'b0,1'b0, `FIXED_HUFFMAN}, 24'd25}); 
            feed_input_fifo({"b","e","t","b"});
            feed_input_fifo({"e","d","b","e"});
            feed_input_fifo({"e","b","e","a"});
            feed_input_fifo({"r","b","e"," "});
	        repeat(10) @(posedge clk);
            feed_input_fifo({"b","e","t","a"});
		    feed_input_fifo({" ","b","e","t"});
		    feed_input_fifo({"s", 8'b0, 8'b0, 8'b0});
		    repeat(40) @(posedge clk);
		    start_test2 = 0;
			$display($time, "******************** TEST2 finished *************************");
		end
		
		
		
	    repeat(5) @(posedge clk);
	    rst_n = 0;
        repeat(5) @(posedge clk);
		rst_n = 1;
		repeat(5) @(posedge clk); 
        start_test3 = 1;
        if (start_test3 == 1 )	begin
            $display($time, "**************************   TEST3   **************************");	
		    $display($time, "Test phrase= 'aacaacabcabaaac' - Wikipedia example");
			feed_input_fifo({{5'b0,1'b0, `FIXED_HUFFMAN}, 24'd16});
            feed_input_fifo({"a","a","c","a"});
            feed_input_fifo({"a","c","a","b"});
            feed_input_fifo({"c","a","b","a"});
            feed_input_fifo({"a","a","c","$"});
		    repeat(40) @(posedge clk);
		    start_test3 = 0;
			$display($time, "******************** TEST3 finished *************************");
		end		
		
		report_test_results;
        $display($time, "************************** LZ77 test is DONE **************************");		
    end

	// Validate the results of TEST1
	always @(posedge clk)
	begin
	    if(start_test1 == 1) begin
		   if(test_count == 0 && output_enable) validate_lz77_data(match_position, match_length, next_symbol, 0, 0, " ");
		   if(test_count == 1 && output_enable) validate_lz77_data(match_position, match_length, next_symbol, 0, 0, "s");
		   if(test_count == 2 && output_enable) validate_lz77_data(match_position, match_length, next_symbol, 0, 0, "h");
		   if(test_count == 3 && output_enable) validate_lz77_data(match_position, match_length, next_symbol, 0, 0, "e");		   
		   if(test_count == 4 && output_enable) validate_lz77_data(match_position, match_length, next_symbol, 3, 2, "e");
		   if(test_count == 5 && output_enable) validate_lz77_data(match_position, match_length, next_symbol, 0, 0, "l");
		   if(test_count == 6 && output_enable) validate_lz77_data(match_position, match_length, next_symbol, 0, 1, "s");
		   if(test_count == 7 && output_enable) validate_lz77_data(match_position, match_length, next_symbol, 5, 3, "a");
		   if(test_count == 8 && output_enable) validate_lz77_data(match_position, match_length, next_symbol, 13, 4,"l");
		   if(test_count == 9 && output_enable) validate_lz77_data(match_position, match_length, next_symbol, 10, 2,".");  
		end
    end    	

	// Validate the results of TEST2
	always @(posedge clk)
	begin
	    if(start_test2 == 1) begin
		   if(test_count == 10 && output_enable) validate_lz77_data(match_position, match_length, next_symbol, 0, 0, "b");
		   if(test_count == 11 && output_enable) validate_lz77_data(match_position, match_length, next_symbol, 0, 0, "e");
		   if(test_count == 12 && output_enable) validate_lz77_data(match_position, match_length, next_symbol, 0, 0, "t");
		   if(test_count == 13 && output_enable) validate_lz77_data(match_position, match_length, next_symbol, 2, 2, "d");		   
		   if(test_count == 14 && output_enable) validate_lz77_data(match_position, match_length, next_symbol, 5, 2, "e");
		   if(test_count == 15 && output_enable) validate_lz77_data(match_position, match_length, next_symbol, 8, 2, "a");
		   if(test_count == 16 && output_enable) validate_lz77_data(match_position, match_length, next_symbol, 0, 0, "r");		   
		   if(test_count == 17 && output_enable) validate_lz77_data(match_position, match_length, next_symbol, 12, 2," ");
		   if(test_count == 18 && output_enable) validate_lz77_data(match_position, match_length, next_symbol, 15, 3,"a");
		   if(test_count == 19 && output_enable) validate_lz77_data(match_position, match_length, next_symbol,  4, 4,"s");  
		end
    end 	

	// Validate the results of TEST3
	always @(posedge clk)
	begin
	    if(start_test3 == 1) begin
		   if(test_count == 20 && output_enable) validate_lz77_data(match_position, match_length, next_symbol, 0, 0, "a");
		   if(test_count == 21 && output_enable) validate_lz77_data(match_position, match_length, next_symbol, 0, 1, "c");
		   if(test_count == 22 && output_enable) validate_lz77_data(match_position, match_length, next_symbol, 2, 4, "b");
		   if(test_count == 23 && output_enable) validate_lz77_data(match_position, match_length, next_symbol, 2, 3, "a");		   
		   if(test_count == 24 && output_enable) validate_lz77_data(match_position, match_length, next_symbol,11, 3, "$"); 
		end
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
    task display_output_data_filt;
		input [DICTIONARY_DEPTH_LOG-1:0] match_position;		
		input [CNT_WIDTH-1:0]                match_length;
        input [DATA_WIDTH-1:0]               next_symbol;
		input output_enable;
		input match_position_valid;
	begin
	    if(output_enable && ! match_position_valid) $display($time, "Output character Tn=%s", next_symbol); 
		if(output_enable &&   match_position_valid) $display($time, "Output character Tp=%d, Tl=%d, Tn=%s", match_position_filt, match_length_filt, next_symbol_filt);
    end		
	endtask
	
    task feed_input_fifo();                      // Reverse the data bytes to simulate the x86 memory storage effect
    input [31:0] data_feed;
     begin
        wr_en <= 1;
        //repeat(1) @(posedge clock);
    	data_in_32 <= {data_feed[7:0], data_feed[15:8], data_feed[23:16], data_feed[31:24]};		 
        repeat(1) @(posedge clk);	 
        wr_en    <= 1'b0;
    	//repeat(1) @(posedge clk);
     end
    endtask	

    task read_input_fifo();                      // Split a 128 bit data frame into 32 bit data frames starting from MSB
    input [31:0] data_out_32;
     begin
        rd_en <= 1;
        $display($time, "fifo_in=%s", data_out_32);
    	repeat(1) @(posedge clk);
		rd_en <= 0;
		//repeat(1) @(posedge clock);
     end
    endtask	

	//====================================================================================================================
	//======================================= Tasks for LZ77 automatic validation ========================================
	//====================================================================================================================
    task validate_lz77_data();
    input [DICTIONARY_DEPTH_LOG-1:0] match_position;
	input [CNT_WIDTH-1:0]            match_length;
	input [DATA_WIDTH-1:0]           next_symbol;	
    input [DICTIONARY_DEPTH_LOG-1:0] match_position_exp;
	input [CNT_WIDTH-1:0]            match_length_exp;
	input [DATA_WIDTH-1:0]           next_symbol_exp;
        begin
            test_count <= test_count + 1;
    	if( {match_position, match_length, next_symbol} == {match_position_exp, match_length_exp, next_symbol_exp}) begin
    	    success_count <= success_count + 1; 
			$display($time,"Success at test %d",test_count);
			$display("        Output character Tp=%d, Tl=%d, Tn=%s", match_position, match_length, next_symbol);
    		end
        else begin
            error_count	<= error_count + 1;
			$display($time,"Error at test %d \n",test_count);
			$display("        Output character Tp=%d, Tl=%d, Tn=%s \n             Expected characters:  Tp=%d, Tl=%d, Tn=%s", match_position, match_length, next_symbol
			                                                                                            , match_position_exp, match_length_exp, next_symbol_exp);
    		end
        end
    endtask

    task report_test_results();
        begin       
	    if (test_count == success_count)  $display("	GZIP TEST finished SUCCESSFULL");
        else                              $display("	GZIP TEST finished with ERRORS"); 
            $display("		test_count=%d",test_count);
            $display("		success_count=%d",success_count);
            $display("		error_count=%d",error_count);
        end
    endtask


	
endmodule
