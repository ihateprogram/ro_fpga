/*
   Author: Ovidiu Plugariu
   Description: This is a test for the LZ77 sliding algorithm used in GZIP.  
*/

`timescale 1 ns / 10 ps

`include "../rtl_code/functions.v"

module lz77_test();

    parameter DATA_WIDTH = 8;
   // parameter SEARCH_BUFFER_DEPTH = 8;
    parameter DICTIONARY_DEPTH = 32;
	parameter DICTIONARY_DEPTH_LOG = clogb2(DICTIONARY_DEPTH);
	parameter LOOK_AHEAD_BUFF_DEPTH = 19;
	parameter CNT_WIDTH = clogb2(LOOK_AHEAD_BUFF_DEPTH);
	
  
    integer i;
    // Declare input/output variables
    reg clk;	
    reg rst_n;
    reg input_valid;
	reg set_match;
    reg [DATA_WIDTH-1:0] input_data;
    reg input_last;

	
	// Variables for automatic checking
	reg start_test_1;
	reg start_test_2;
	reg start_test_3;
	
    //wire encode;
    wire [clogb2(DICTIONARY_DEPTH):0] match_position;
	//wire match_valid;
	wire [CNT_WIDTH-1:0]   match_length;
	wire output_valid;			
	wire output_last;
	wire [DATA_WIDTH-1:0]  match_next_symbol;
	wire                   match_valid;	

    integer test_count    = 0;
    integer success_count = 0;
	integer error_count   = 0;
	
	reg [4:0] in_txt_index = 0;
    wire [7:0] tst_txt1 [0:21];
    assign tst_txt1[0 ] = " ";
    assign tst_txt1[1 ] = "s";
    assign tst_txt1[2 ] = "h";
    assign tst_txt1[3 ] = "e";
    assign tst_txt1[4 ] = " ";
    assign tst_txt1[5 ] = "s";
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
	
	
	//data_test = "Ana are mere multe";
	//$display ("My String = %s",data_test);	

    // Create clock signal - 50MHz
    always
    #10 clk = ~clk;
	
    // Instantiate DUT
    lz77_encoder 
	    #(.DATA_WIDTH(DATA_WIDTH) ,
		  .DICTIONARY_DEPTH(DICTIONARY_DEPTH),
		  .LOOK_AHEAD_BUFF_DEPTH(LOOK_AHEAD_BUFF_DEPTH),
          .CNT_WIDTH(CNT_WIDTH),
          .DICTIONARY_DEPTH_LOG(DICTIONARY_DEPTH_LOG)		  
		 )
		lz77_enc
        (
        // Clock/Reset inputs
        .clk,	
        .rst_n,
		
		// Data inputs
        .input_valid,
        .input_data,
        .input_last,		
    
        // Module outputs
        .match_position,
    	.match_length,
    	.match_next_symbol,
		.match_valid,
    	.output_valid,
        .output_last
        );

	

	initial
    begin
        $display($time, "<< Starting the Simulation >>");
	    
	    clk = 0;
	    rst_n = 0;
	    input_valid = 0;
        input_data = 8'b0;
        set_match = 0;	
	    input_last = 1'b0;
		start_test_1 = 0;
		start_test_2 = 0;
		start_test_3 = 0;
        $display($time, "**************************   TEST1   **************************");	
	    repeat(50) @(posedge clk);
	    rst_n = 1;
        repeat(5) @(posedge clk);
		start_test_1 = 1;		
	    @(posedge clk);         
        input_valid = 1'b1;
        for (i=0;i<=21;i=i+1) begin
		    if (i==21) input_last = 1;
			else       input_last = 0;
	    	load_data_task(tst_txt1[i]);
        end
		input_valid = 1'b0;
		input_last = 0;
		repeat(10) @(posedge clk); // this compensates the delay givn by the internal pipeline
		start_test_1 = 0; 

		
		$display($time, "**************************   TEST2   **************************");
		// Reset the module and use another test vector
	    repeat(5) @(posedge clk);
	    rst_n = 0;
        repeat(5) @(posedge clk);
		rst_n = 1;
	    repeat(5) @(posedge clk);
		start_test_2 = 1;
        input_valid = 1'b1;		
        for (i=0;i<=15;i=i+1) begin
	    	load_data_task("a");
		end
	    input_last = 1;
		load_data_task("$");
        input_valid = 1'b0;	
	    input_last = 0;
	    repeat(10) @(posedge clk); // this compensates the delay givn by the internal pipeline
        start_test_2 = 0; 	


		$display($time, "**************************   TEST3   **************************");
		// Reset the module and use another test vector
	    repeat(5) @(posedge clk);
	    rst_n = 0;
		//in_txt_index = 0;
        repeat(5) @(posedge clk);
		rst_n = 1;
	    @(posedge clk);
		start_test_3 = 1;
        input_valid = 1'b1;		
        for (i=0;i<=15;i=i+1) begin
		    if (i==15) input_last = 1;
			else       input_last = 0;
	    	load_data_task(tst_txt3[i]);
		end
		input_last = 0;
        input_valid = 1'b0;  		
	    repeat(10) @(posedge clk); // this compensates the delay givn by the internal pipeline
        start_test_3 = 0;		
		
        /*$display($time, "**************************   TEST4   **************************");		
		// Reset the module and use another test vector
	    repeat(5) @(posedge clk);
	    rst_n = 0;
		//in_txt_index = 0;
        repeat(5) @(posedge clk);
		rst_n = 1;
	    @(posedge clk);
        input_valid = 1'b1;		
        for (i=0;i<=15;i=i+1) begin
	    	load_data_task(tst_txt2[i]);
		end
        input_valid = 1'b0; */
		
		report_test_results();
        $display($time, "************************** LZ77 test is DONE **************************");	
        $finish();		
    end

	// Display the result of the sliding window module
	always @(posedge clk)
        //if(input_valid && output_valid)                        //data can displayed only when output_valid is set
        if(output_valid)                        //data can displayed only when output_valid is set
		    display_output_data(match_position, match_length, match_next_symbol, output_valid);
         	

	// Automatic checker for test1		
    initial
    begin
       wait (start_test_1 == 1);
	   $display($time, "Automatic checker for test1 enabled");		
       wait (output_valid); @(negedge clk); // sample the data
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(0), .match_next_symbol_exp(" "), .match_valid_exp(1), .output_last_exp(0));
       wait (output_valid); @(negedge clk); // sample the data
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(0), .match_next_symbol_exp("s"), .match_valid_exp(1), .output_last_exp(0));	   
       wait (output_valid); @(negedge clk); // sample the data
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(0), .match_next_symbol_exp("h"), .match_valid_exp(1), .output_last_exp(0));	 	   
       wait (output_valid); @(negedge clk); // sample the data
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(0), .match_next_symbol_exp("e"), .match_valid_exp(1), .output_last_exp(0));	 
       wait (output_valid); @(negedge clk); // sample the data
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(0), .match_next_symbol_exp(" "), .match_valid_exp(1), .output_last_exp(0));
       wait (output_valid); @(negedge clk); // sample the data
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(0), .match_next_symbol_exp("s"), .match_valid_exp(0), .output_last_exp(0));
       wait (output_valid); @(negedge clk); // sample the data
	   validate_lz77_data(.match_position_exp(4), .match_length_exp(1), .match_next_symbol_exp("e"), .match_valid_exp(1), .output_last_exp(0));
       wait (output_valid); @(negedge clk);
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(0), .match_next_symbol_exp("l"), .match_valid_exp(1), .output_last_exp(0));
       wait (output_valid); @(negedge clk);
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(0), .match_next_symbol_exp("l"), .match_valid_exp(0), .output_last_exp(0));
       wait (output_valid); @(negedge clk);
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(1), .match_next_symbol_exp("s"), .match_valid_exp(1), .output_last_exp(0));
       wait (output_valid); @(negedge clk);
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(0), .match_next_symbol_exp(" "), .match_valid_exp(0), .output_last_exp(0));
       wait (output_valid); @(negedge clk);
	   validate_lz77_data(.match_position_exp(6), .match_length_exp(1), .match_next_symbol_exp("s"), .match_valid_exp(0), .output_last_exp(0));
       wait (output_valid); @(negedge clk);
	   validate_lz77_data(.match_position_exp(6), .match_length_exp(2), .match_next_symbol_exp("e"), .match_valid_exp(0), .output_last_exp(0));
       wait (output_valid); @(negedge clk);
	   validate_lz77_data(.match_position_exp(6), .match_length_exp(3), .match_next_symbol_exp("a"), .match_valid_exp(1), .output_last_exp(0));
       wait (output_valid); @(negedge clk);
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(0), .match_next_symbol_exp(" "), .match_valid_exp(0), .output_last_exp(0));
       wait (output_valid); @(negedge clk);
	   validate_lz77_data(.match_position_exp(10), .match_length_exp(1), .match_next_symbol_exp("s"), .match_valid_exp(0), .output_last_exp(0));
       wait (output_valid); @(negedge clk);
	   validate_lz77_data(.match_position_exp(10), .match_length_exp(2), .match_next_symbol_exp("h"), .match_valid_exp(1), .output_last_exp(0));
       wait (output_valid); @(negedge clk);
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(0), .match_next_symbol_exp("e"), .match_valid_exp(0), .output_last_exp(0));
       wait (output_valid); @(negedge clk);
	   validate_lz77_data(.match_position_exp(14), .match_length_exp(1), .match_next_symbol_exp("l"), .match_valid_exp(0), .output_last_exp(0));
       wait (output_valid); @(negedge clk);
	   validate_lz77_data(.match_position_exp(11), .match_length_exp(2), .match_next_symbol_exp("l"), .match_valid_exp(0), .output_last_exp(0));
       wait (output_valid); @(negedge clk);
	   validate_lz77_data(.match_position_exp(11), .match_length_exp(3), .match_next_symbol_exp("s"), .match_valid_exp(0), .output_last_exp(0));
       wait (output_valid); @(negedge clk);
	   validate_lz77_data(.match_position_exp(11), .match_length_exp(4), .match_next_symbol_exp("."), .match_valid_exp(1), .output_last_exp(1));
       @(negedge clk); // test finished
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(0), .match_next_symbol_exp("."), .match_valid_exp(0), .output_last_exp(0));  	   
    end 	


	// Automatic checker for test2	
    initial
    begin
       wait (start_test_2 == 1);
	   $display($time, "Automatic checker for test2 enabled");		
       wait (output_valid); @(negedge clk); // sample the data
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(0), .match_next_symbol_exp("a"), .match_valid_exp(1), .output_last_exp(0));
       wait (output_valid); @(negedge clk); // sample the data
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(0), .match_next_symbol_exp("a"), .match_valid_exp(1), .output_last_exp(0));
       wait (output_valid); @(negedge clk); // sample the data
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(0), .match_next_symbol_exp("a"), .match_valid_exp(0), .output_last_exp(0));	   
       wait (output_valid); @(negedge clk); // there is an ISIM error so a for loop didn't worked
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(1), .match_next_symbol_exp("a"), .match_valid_exp(0), .output_last_exp(0));	 	   
       wait (output_valid); @(negedge clk);
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(2), .match_next_symbol_exp("a"), .match_valid_exp(0), .output_last_exp(0));	
       wait (output_valid); @(negedge clk); 
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(3), .match_next_symbol_exp("a"), .match_valid_exp(0), .output_last_exp(0));	
       wait (output_valid); @(negedge clk); 
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(4), .match_next_symbol_exp("a"), .match_valid_exp(0), .output_last_exp(0));
       wait (output_valid); @(negedge clk); 
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(5), .match_next_symbol_exp("a"), .match_valid_exp(0), .output_last_exp(0));	
       wait (output_valid); @(negedge clk); 
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(6), .match_next_symbol_exp("a"), .match_valid_exp(0), .output_last_exp(0));	
       wait (output_valid); @(negedge clk); 
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(7), .match_next_symbol_exp("a"), .match_valid_exp(0), .output_last_exp(0));	
       wait (output_valid); @(negedge clk); 
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(8), .match_next_symbol_exp("a"), .match_valid_exp(0), .output_last_exp(0));
       wait (output_valid); @(negedge clk); 
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(9), .match_next_symbol_exp("a"), .match_valid_exp(0), .output_last_exp(0));	
       wait (output_valid); @(negedge clk); 
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(10), .match_next_symbol_exp("a"), .match_valid_exp(0), .output_last_exp(0));
       wait (output_valid); @(negedge clk); 
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(11), .match_next_symbol_exp("a"), .match_valid_exp(0), .output_last_exp(0));	
       wait (output_valid); @(negedge clk); 
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(12), .match_next_symbol_exp("a"), .match_valid_exp(0), .output_last_exp(0));
       wait (output_valid); @(negedge clk); 
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(13), .match_next_symbol_exp("a"), .match_valid_exp(0), .output_last_exp(0));
       wait (output_valid); @(negedge clk); 
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(14), .match_next_symbol_exp("$"), .match_valid_exp(1), .output_last_exp(1));	   
       @(negedge clk); // test finished
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(0), .match_next_symbol_exp("$"), .match_valid_exp(0), .output_last_exp(0)); 	   
    end	
	
	
	// Automatic checker for test2	
    initial
    begin
       wait (start_test_3 == 1);
	   $display($time, "Automatic checker for test2 enabled");		
       wait (output_valid); @(negedge clk); // sample the data
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(0), .match_next_symbol_exp("a"), .match_valid_exp(1), .output_last_exp(0));	 
       wait (output_valid); @(negedge clk); // sample the data
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(0), .match_next_symbol_exp("a"), .match_valid_exp(1), .output_last_exp(0));	
       wait (output_valid); @(negedge clk); // sample the data
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(0), .match_next_symbol_exp("c"), .match_valid_exp(1), .output_last_exp(0));	
       wait (output_valid); @(negedge clk); // sample the data
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(0), .match_next_symbol_exp("a"), .match_valid_exp(0), .output_last_exp(0));	
       wait (output_valid); @(negedge clk); 
	   validate_lz77_data(.match_position_exp(2), .match_length_exp(1), .match_next_symbol_exp("a"), .match_valid_exp(1), .output_last_exp(0));
       wait (output_valid); @(negedge clk); 
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(0), .match_next_symbol_exp("c"), .match_valid_exp(0), .output_last_exp(0));	
       wait (output_valid); @(negedge clk); 
	   validate_lz77_data(.match_position_exp(3), .match_length_exp(1), .match_next_symbol_exp("a"), .match_valid_exp(0), .output_last_exp(0));
       wait (output_valid); @(negedge clk); 
	   validate_lz77_data(.match_position_exp(3), .match_length_exp(2), .match_next_symbol_exp("b"), .match_valid_exp(1), .output_last_exp(0));
       wait (output_valid); @(negedge clk);
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(0), .match_next_symbol_exp("c"), .match_valid_exp(0), .output_last_exp(0));	
       wait (output_valid); @(negedge clk); 
	   validate_lz77_data(.match_position_exp(6), .match_length_exp(1), .match_next_symbol_exp("a"), .match_valid_exp(0), .output_last_exp(0));	
       wait (output_valid); @(negedge clk);
	   validate_lz77_data(.match_position_exp(6), .match_length_exp(2), .match_next_symbol_exp("b"), .match_valid_exp(0), .output_last_exp(0));	
       wait (output_valid); @(negedge clk); 
	   validate_lz77_data(.match_position_exp(3), .match_length_exp(3), .match_next_symbol_exp("a"), .match_valid_exp(1), .output_last_exp(0));	
       wait (output_valid); @(negedge clk); 
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(0), .match_next_symbol_exp("a"), .match_valid_exp(0), .output_last_exp(0));
       wait (output_valid); @(negedge clk); 
	   validate_lz77_data(.match_position_exp(11), .match_length_exp(1), .match_next_symbol_exp("a"), .match_valid_exp(0), .output_last_exp(0));
       wait (output_valid); @(negedge clk); 
	   validate_lz77_data(.match_position_exp(9), .match_length_exp(2), .match_next_symbol_exp("c"), .match_valid_exp(0), .output_last_exp(0));
       wait (output_valid); @(negedge clk); 
	   validate_lz77_data(.match_position_exp(9), .match_length_exp(3), .match_next_symbol_exp("$"), .match_valid_exp(1), .output_last_exp(1));	   
       @(negedge clk); // test finished
	   validate_lz77_data(.match_position_exp(1), .match_length_exp(0), .match_next_symbol_exp("$"), .match_valid_exp(0), .output_last_exp(0)); 	   
    end	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
    // Testing tasks
	
    task load_data_task;
        input [7:0] load_value;
    begin
		   // $display($time, " << Loading data %h >>", load_value);
		    input_valid = 1;
            input_data = load_value;
            @(posedge clk);
            input_valid = 0;            
    end
    endtask //of load_data	
		
	// Task used to display data from the lz77 encoder
    task display_output_data;
		input [clogb2(DICTIONARY_DEPTH):0] match_position;
		input [CNT_WIDTH-1:0]              match_length;
        input [DATA_WIDTH-1:0]             match_next_symbol;
		input output_valid;
	begin
	    if(output_valid) $display($time, "Output character Tp=%d, Tl=%d, Tn=%s", match_position, match_length, match_next_symbol); 
    end		
	endtask


	
    task validate_lz77_data();
    input [DICTIONARY_DEPTH_LOG:0]   match_position_exp;
	input [CNT_WIDTH-1:0]            match_length_exp;
	input [DATA_WIDTH-1:0]           match_next_symbol_exp;
	input                            match_valid_exp;
    input                            output_last_exp;
    begin	
		
		#1;
            test_count <= test_count + 1;
    	if( (match_position_exp == match_position) && (match_length_exp == match_length) && (match_next_symbol_exp == match_next_symbol) &&
		    (match_valid_exp == match_valid) && (output_last_exp == output_last)) begin
    	    success_count <= success_count + 1; 
			$display($time,"Success at test %d",test_count); // uncomment for verbosity
			/*$display("            Observed: match_position = %d       Expected: match_position_exp=%d \n" , match_position, match_position_exp );
			$display("            Observed: match_length = %d         Expected: match_length_exp=%d \n" , match_length, match_length_exp );
			$display("            Observed: match_next_symbol = %s    Expected: match_next_symbol_exp=%s \n" , match_next_symbol, match_next_symbol_exp );
			$display("            Observed: match_valid = %d          Expected: match_valid_exp=%d \n" , match_valid, match_valid_exp );
			$display("            Observed: output_last = %d          Expected: output_last_exp=%d \n" , output_last, output_last_exp );*/
    		end
        else begin
            error_count	<= error_count + 1;
			$display($time,"Error at test %d \n",test_count);
			$display("            Observed: match_position = %d       Expected: match_position_exp=%d \n" , match_position, match_position_exp );
			$display("            Observed: match_length = %d         Expected: match_length_exp=%d \n" , match_length, match_length_exp );
			$display("            Observed: match_next_symbol = %s    Expected: match_next_symbol_exp=%s \n" , match_next_symbol, match_next_symbol_exp );
			$display("            Observed: match_valid = %d          Expected: match_valid_exp=%d \n" , match_valid, match_valid_exp );
			$display("            Observed: output_last = %d          Expected: output_last_exp=%d \n" , output_last, output_last_exp );
    		end
        end
    endtask 

    task report_test_results();
        begin       
	    if (test_count == success_count)  $display("	LZ77 TEST finished SUCCESSFULLY");
        else                              $display("	LZ77 TEST finished with ERRORS"); 
            $display("		test_count=%d",test_count);
            $display("		success_count=%d",success_count);
            $display("		error_count=%d",error_count);
        end
    endtask	
	
endmodule
