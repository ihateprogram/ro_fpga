/*
   Author: Ovidiu Plugariu
   Description: This is a test for the LZ77 sliding algorithm used in GZIP.  
*/

`timescale 1 ns / 10 ps

module test_lz77;

    parameter DATA_WIDTH = 8;
   // parameter SEARCH_BUFFER_DEPTH = 8;
    parameter DICTIONARY_DEPTH = 32;
	parameter DICTIONARY_DEPTH_LOG = $clog2(DICTIONARY_DEPTH);
	parameter LOOK_AHEAD_BUFF_DEPTH = 19;
	parameter CNT_WIDTH = $clog2(LOOK_AHEAD_BUFF_DEPTH);
	
  
    integer i;
    // Declare input/output variables
    reg clk;	
    reg rst_n;
    reg data_valid;
	reg set_match;
    reg [DATA_WIDTH-1:0] input_data;

    wire encode;
    wire [$clog2(DICTIONARY_DEPTH)-1:0] match_position;
	//wire match_valid;
	wire [CNT_WIDTH-1:0]        match_length;
	wire [DATA_WIDTH-1:0]       next_symbol;
	wire output_enable;			
	
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
        // Module inputs
        .clk,	
        .rst_n,
        .data_valid,
		//.set_match,
        .input_data,	
    
        // Module outputs
        .match_position,
		//.match_valid,	
    	.match_length,
    	.next_symbol,
    	.output_enable	
    
        );


	initial
    begin
        $display($time, "<< Starting the Simulation >>");
	    
	    clk = 0;
	    rst_n = 0;
	    data_valid = 0;
        input_data = 8'b0;
        set_match = 0;	
        /*$display($time, "**************************   TEST1   **************************");	
	    repeat(50) @(posedge clk);
	    rst_n = 1;
        repeat(5) @(posedge clk);		
	    @(posedge clk);         
        data_valid = 1'b1;
        for (i=0;i<=21;i=i+1) begin
	    	load_data_task(tst_txt1[i]);
        end
		data_valid = 1'b0;

        $display($time, "**************************   TEST2   **************************");		
		// Reset the module and use another test vector
	    repeat(5) @(posedge clk);
	    rst_n = 0;
		//in_txt_index = 0;
        repeat(5) @(posedge clk);
		rst_n = 1;
	    @(posedge clk);
        data_valid = 1'b1;		
        for (i=0;i<=15;i=i+1) begin
	    	load_data_task(tst_txt2[i]);
		end
        data_valid = 1'b0;


		$display($time, "**************************   TEST3   **************************");
		// Reset the module and use another test vector
	    repeat(5) @(posedge clk);
	    rst_n = 0;
		//in_txt_index = 0;
        repeat(5) @(posedge clk);
		rst_n = 1;
	    @(posedge clk);
        data_valid = 1'b1;		
        for (i=0;i<=15;i=i+1) begin
	    	load_data_task(tst_txt3[i]);
		end
        data_valid = 1'b0;   */
		
		$display($time, "**************************   TEST4   **************************");
		// Reset the module and use another test vector
	    repeat(5) @(posedge clk);
	    rst_n = 0;
		//in_txt_index = 0;
        repeat(5) @(posedge clk);
		rst_n = 1;
	    repeat(5) @(posedge clk);
        data_valid = 1'b1;		
        for (i=0;i<=15;i=i+1) begin
	    	load_data_task("a");
		end
		load_data_task("$");
        data_valid = 1'b0; 
		
        $display($time, "************************** LZ77 test is DONE **************************");		
    end

	// Display the result of the sliding window module
	always @(posedge clk)
        if(data_valid && output_enable)                        //data can displayed only when output_enable is set
		    display_output_data(match_position, match_length, next_symbol, output_enable);
         	

			
			
			
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
		input [$clog2(DICTIONARY_DEPTH)-1:0] match_position;
		input [CNT_WIDTH-1:0]                match_length;
        input [DATA_WIDTH-1:0]               next_symbol;
		input output_enable;
	begin
	    if(output_enable) $display($time, "Output character Tp=%d, Tl=%d, Tn=%s", match_position, match_length, next_symbol); 
    end		
	endtask
	
endmodule
