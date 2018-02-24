/*
   Author: Ovidiu Plugariu
   Description: This is a test for the LZ77 sliding algorithm used in GZIP.  
*/

`timescale 1 ns / 10 ps

`include "../rtl_code/functions.v"

`define NO_COMPRESSION      2'b00
`define FIXED_HUFFMAN      2'b01
`define BTYPE_UNDEFINED    2'b10

`define BFINAL0            1'b0
`define BFINAL1            1'b1

`define GZIP_DONE_POS      2

`define TEST_ME

module test_gzip_compress();

    parameter DATA_WIDTH = 8;
    parameter SEARCH_BUFFER_DEPTH = 8;
    parameter DICTIONARY_DEPTH = 512;
	parameter DICTIONARY_DEPTH_LOG = clogb2(DICTIONARY_DEPTH);
	parameter LOOK_AHEAD_BUFF_DEPTH = 258;
	parameter CNT_WIDTH = clogb2(LOOK_AHEAD_BUFF_DEPTH);
	
	parameter ISIZE_OFFSET = 8;
	parameter CRC32_OFFSET = ISIZE_OFFSET + 32;
	parameter BLOCK_SIZE_OFFSET = CRC32_OFFSET + 32;
  
    //integer i;
    // Declare input/output variables
    reg clk;	
    reg rst_n;
    reg data_valid;
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

    wire last_out_fifo_32;		
	wire irq;

	
    reg run_KAT = 1;              // this should be set to make the KAT run
	integer kat_test_index = 0; 

	reg [31:0] data_in_32 =0;
	reg wr_en_fifo_in = 0;
	//reg rd_en = 0;
	reg rd_en_fifo_out = 0;
	wire [31:0] data_out_32;
	reg [31:0] data_out_rd_32 =0;
	wire full_in_fifo;
    wire empty_in_fifo;	
    wire [31:0] dout_out_fifo_32;  
	wire empty_out_fifo; 
    wire [119:0] debug_reg;	
    reg [7:0] byte0_in, byte1_in, byte2_in, byte3_in;
    reg [1:0] btype_in;
	reg rev_endianess_in;
	
    integer test_count   ;
    integer success_count;
	integer error_count  ;
	reg     start_test1 = 0;
	reg     start_test2 = 0;
	reg     start_test3 = 0;
	reg     reset_fifo  = 1;
	
	reg[31:0] test_index = 0;
	integer i;
	
	reg [19:0] data [0:3];
	
	reg [7:0] expected_data0 [0:23];
	reg [7:0] expected_data1 [0:47];
	reg [7:0] expected_data2 [0:39];
	reg [7:0] expected_data3 [0:535];
	reg [7:0] expected_data4 [0:535];
	reg [31:0] expected_vect;
	
	integer data_len_exp = 0;
	
	initial $readmemh("D:/gzip_work/shiftable_CAM/testbench/expected_data0.txt", expected_data0);  // Read the values for expected_data0
	initial $readmemh("D:/gzip_work/shiftable_CAM/testbench/expected_data1.txt", expected_data1);  // Read the values for expected_data1
	initial $readmemh("D:/gzip_work/shiftable_CAM/testbench/expected_data2.txt", expected_data2);  // Read the values for expected_data2
	initial $readmemh("D:/gzip_work/shiftable_CAM/testbench/expected_data3.txt", expected_data3);  // Read the values for expected_data3
	initial $readmemh("D:/gzip_work/shiftable_CAM/testbench/expected_data4.txt", expected_data4);  // Read the values for expected_data3
	
    initial begin
      #20;
      $display("\nrdata:");      
      for (i=0; i < 24; i=i+1)      
      $display("%d:%h",i,expected_data0[i]);

    end 
	
	
   //====================================================================================================================	
   //======================================= Create clock signal - 50MHz ================================================
   //====================================================================================================================	
    always
    #10 clk = ~clk;


   //====================================================================================================================	
   //========================================== Instantiate the DUT =====================================================
   //====================================================================================================================
   gzip_top
        #(      	
            .DICTIONARY_DEPTH(DICTIONARY_DEPTH),
            .DICTIONARY_DEPTH_LOG(DICTIONARY_DEPTH_LOG),			
    	    .LOOK_AHEAD_BUFF_DEPTH(LOOK_AHEAD_BUFF_DEPTH),    	    
    	    .CNT_WIDTH(CNT_WIDTH)	
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
		.rev_endianess_in,
		
        // Module outputs
        .debug_reg,		
        .full_in_fifo,
	    .dout_out_fifo_32,
        .last_out_fifo_32,                  // XXX new		
	    .empty_out_fifo,
		.irq
        );
		
		
    //====================================================================================================================	
    //========================================== Start the Testbench =====================================================
    //====================================================================================================================
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

		rev_endianess_in = 0;
		repeat(10) @(posedge clk);	
		reset_fifo = 0;
		
        reset_gzip_core();
		
        /// This is the KAT test from C done in Verilog and this should be run before each major change and synthesys 
        if (run_KAT == 1) begin
	    `ifdef TEST_ME
            $display($time, "<<<<<<<<< Known Answer Test START >>>>>>>>");
			kat_test_index = kat_test_index + 1;
			test_count = test_count + 1;
	
			$display("========================================================================================");
            $display($time, "\n\n TEST %d - BSIZE_ERR for NO_COMPRESSION ", kat_test_index);
            btype_in = `NO_COMPRESSION;                       // write_mem_array_data(BTYPE_NO_COMPRESSION, BTYPE_REG);
			feed_input_fifo({{7'b0,`BFINAL1}, 24'd65537});   // send_data_to_fpga(fdw, test_in, 65537, BFINAL1, IGNORE_PAYLOAD);
		    repeat(10) @(posedge clk);	                     // wait for the inputs to be processed
			
			if (debug_reg[0] == 1'b1) begin
			    $display($time, " SUCCESS: BSIZE_ERR = 1");
				success_count = success_count + 1;
			end 
			else begin
			    $display($time, " ERROR: BSIZE_ERR = 0");
			    error_count = error_count + 1;
			end
			
			
			$display("========================================================================================");
			reset_gzip_core();
			kat_test_index = kat_test_index + 1;
			test_count = test_count + 1;
			
            $display($time, "\n\n TEST %d - BSIZE_ERR for FIXED_HUFFMAN ", kat_test_index);
            btype_in = `FIXED_HUFFMAN;                       // write_mem_array_data(BTYPE_NO_COMPRESSION, BTYPE_REG);
			feed_input_fifo({{7'b0,`BFINAL1}, 24'd1025});    // send_data_to_fpga(fdw, test_in, 65537, BFINAL1, IGNORE_PAYLOAD);
		    repeat(10) @(posedge clk);	                     // wait for the inputs to be processed
			
			if (debug_reg[0] == 1'b1) begin
			    $display($time, " SUCCESS: BSIZE_ERR = 1");
				success_count = success_count + 1;
			end 
			else begin
			    $display($time, " ERROR: BSIZE_ERR = 0");
			    error_count = error_count + 1;
			end			
			

			$display("========================================================================================");			
			reset_gzip_core();
			kat_test_index = kat_test_index + 1;
			test_count = test_count + 1;
			
            $display($time, "\n\n TEST %d - BTYPE_ERR for BTYPE_UNDEFINED ", kat_test_index);
            btype_in = `BTYPE_UNDEFINED;                       // write_mem_array_data(BTYPE_NO_COMPRESSION, BTYPE_REG);
			feed_input_fifo({{7'b0,`BFINAL1}, 24'd3});         // send_data_to_fpga(fdw, test_in, 65537, BFINAL1, IGNORE_PAYLOAD);
		    repeat(10) @(posedge clk);	                       // wait for the inputs to be processed
			
			if (debug_reg[1] == 1'b1) begin
			    $display($time, " SUCCESS: BTYPE_ERR = 1");
				success_count = success_count + 1;
			end 
			else begin
			    $display($time, " ERROR: BTYPE_ERR = 0");
			    error_count = error_count + 1;
			end	


			$display("========================================================================================");
			reset_gzip_core();
			kat_test_index = kat_test_index + 1;
			test_count = test_count + 1;
			
            $display($time, "\n\n TEST %d - CRC32, ISIZE, BLOCK_SIZE integrity test", kat_test_index);
            btype_in = `NO_COMPRESSION;                
			feed_input_fifo({{7'b0,`BFINAL1}, 24'd4});
			$display($time, "Test phrase= '0001' ");
		    feed_input_fifo({"0","0","0","1"}); 			
			@(posedge debug_reg[`GZIP_DONE_POS]); 
			$display($time, " GZIP core finished processing data");		

			// Read the core output data
			data_len_exp = 24;
			if (empty_out_fifo) begin 
			   @(negedge empty_out_fifo);
            end 			   
			for (i=0;i<(data_len_exp/4);i=i+1) begin      // 24 bytes are expected to be in the output vector
                read_output_fifo(data_out_rd_32);
                expected_vect = {expected_data0[4*i], expected_data0[4*i+1], expected_data0[4*i+2], expected_data0[4*i+3]};					
                if ( expected_vect == data_out_rd_32) begin
                   $display($time, " SUCCESS: read_data = %h, expected_data = %h", data_out_rd_32, expected_vect); 
			    success_count = success_count + 1;
			    end 
			    else begin
                   $display($time, " ERROR: read_data = %h, expected_data = %h", data_out_rd_32, expected_vect); 
			       error_count = error_count + 1;
			    end
				if (empty_out_fifo && i<((data_len_exp/4)-1)) begin // Make another read only if the FIFO has data and only if it is not the last output double word
				   @(negedge empty_out_fifo);
				end 
			end	
			
			// Check the debug registers
			if (debug_reg[ISIZE_OFFSET+31:ISIZE_OFFSET] == 32'd4) begin
			    $display($time, " SUCCESS: ISIZE is correct"); 
				success_count = success_count + 1;
			end 
			else begin
			    $display($time, " ERROR: ISIZE is invalid");
			    error_count = error_count + 1;
			end	
			
			if (debug_reg[CRC32_OFFSET+31:CRC32_OFFSET] == 32'h7B9CF4E4) begin
			    $display($time, " SUCCESS: CRC is correct");
				success_count = success_count + 1;
			end 
			else begin
			    $display($time, " ERROR: CRC is invalid");
			    error_count = error_count + 1;
			end				

			if (debug_reg[BLOCK_SIZE_OFFSET+23:BLOCK_SIZE_OFFSET] == 24'd4) begin
			    $display($time, " SUCCESS: BLOCK_SIZE is correct");
				success_count = success_count + 1;
			end 
			else begin
			    $display($time, " ERROR: BLOCK_SIZE is invalid");
			    error_count = error_count + 1;
			end
	
			
			$display("========================================================================================");
			reset_gzip_core();
			kat_test_index = kat_test_index + 1;
			test_count = test_count + 1;
			
            $display($time, "\n\n TEST %d - NO_COMPRESSION test", kat_test_index);
            btype_in = `NO_COMPRESSION;

			$display($time, "Test phrase= 'Test GZIP compression core Test.' ");
			feed_input_fifo({{7'b0,`BFINAL1}, 24'd32});
		    feed_input_fifo({"T","e","s","t"}); 
		    feed_input_fifo({" ","G","Z","I"}); 
		    feed_input_fifo({"P"," ","c","o"});
		    feed_input_fifo({"m","p","r","e"});		
		    feed_input_fifo({"s","s","i","o"});
		    feed_input_fifo({"n"," ","c","o"});
		    feed_input_fifo({"r","e"," ","T"});
		    feed_input_fifo({"e","s","t","."});
 			
			@(posedge debug_reg[`GZIP_DONE_POS]); 
			$display($time, " GZIP core finished processing data");		

			// Read the core output data
			data_len_exp = 48;
			//@(negedge empty_out_fifo);			
			for (i=0;i<(data_len_exp/4);i=i+1) begin      // 24 bytes are expected to be in the output vector
                read_output_fifo(data_out_rd_32);
                expected_vect = {expected_data1[4*i], expected_data1[4*i+1], expected_data1[4*i+2], expected_data1[4*i+3]};					
                if ( expected_vect == data_out_rd_32) begin
                   $display($time, " SUCCESS: read_data = %h, expected_data = %h", data_out_rd_32, expected_vect); 
			    success_count = success_count + 1;
			    end 
			    else begin
                   $display($time, " ERROR: read_data = %h, expected_data = %h", data_out_rd_32, expected_vect); 
			       error_count = error_count + 1;
			    end
				if (empty_out_fifo && i<((data_len_exp/4)-1)) begin // Make another read only if the FIFO has data and only if it is not the last output double word
				   @(negedge empty_out_fifo);
				end 
			end	

			
			$display("========================================================================================");
			reset_gzip_core();
			kat_test_index = kat_test_index + 1;
			test_count = test_count + 1;
			
            $display($time, "\n\n TEST %d - FIXED_HUFFMAN test", kat_test_index);
            btype_in = `FIXED_HUFFMAN;

			$display($time, "Test phrase= 'Test GZIP compression core Test GZIP' ");
			feed_input_fifo({{7'b0,`BFINAL1}, 24'd36});
		    feed_input_fifo({"T","e","s","t"}); 
		    feed_input_fifo({" ","G","Z","I"}); 
		    feed_input_fifo({"P"," ","c","o"});
		    feed_input_fifo({"m","p","r","e"});		
		    feed_input_fifo({"s","s","i","o"});
		    feed_input_fifo({"n"," ","c","o"});
		    feed_input_fifo({"r","e"," ","T"});
		    feed_input_fifo({"e","s","t"," "});
		    feed_input_fifo({"G","Z","I","P"});
 			
			@(posedge debug_reg[`GZIP_DONE_POS]); 
			$display($time, " GZIP core finished processing data");		

			// Read the core output data
			data_len_exp = 40;
			//@(negedge empty_out_fifo);			
			for (i=0;i<(data_len_exp/4);i=i+1) begin      // 24 bytes are expected to be in the output vector
                read_output_fifo(data_out_rd_32);
                expected_vect = {expected_data2[4*i], expected_data2[4*i+1], expected_data2[4*i+2], expected_data2[4*i+3]};					
                if ( expected_vect == data_out_rd_32) begin
                   $display($time, " SUCCESS: read_data = %h, expected_data = %h", data_out_rd_32, expected_vect); 
			    success_count = success_count + 1;
			    end 
			    else begin
                   $display($time, " ERROR: read_data = %h, expected_data = %h", data_out_rd_32, expected_vect); 
			       error_count = error_count + 1;
			    end
				if (empty_out_fifo && i<((data_len_exp/4)-1)) begin // Make another read only if the FIFO has data and only if it is not the last output double word
				   @(negedge empty_out_fifo);
				end 
			end			
			
			
	        $display("========================================================================================");
			reset_gzip_core();
			kat_test_index = kat_test_index + 1;
			test_count = test_count + 1;
			
            $display($time, "\n\n TEST %d - NO_COMPRESSION test", kat_test_index);
            btype_in = `NO_COMPRESSION;

			$display($time, "Test phrase= 512x'1' and 1x'2' ");

			feed_input_fifo({{7'b0,`BFINAL0}, 24'd512});           
            for (i=0; i<=127; i=i+1) begin                            // BFINAL=0, BTYPE=NO_COMPRESSION, LENGTH=512 bytes
		        //$display($time, "  char_no = %d",i*4);
      		    feed_input_fifo({"1","1","1","1"});
			end

			// The character '2' is the first from the second block
			repeat(13) @(posedge clk);                // simulate a delay for another burst   
			feed_input_fifo({{7'b0,`BFINAL1}, 24'd1});
 			feed_input_fifo({"2", 8'h0, 8'h0, 8'h0});
				

		    // Wait for the interrupt signal
			@(posedge irq); 
			$display($time, " GZIP core finished processing data");		

			// Read the core output data
			data_len_exp = 536;
			//@(negedge empty_out_fifo);			
			for (i=0;i<(data_len_exp/4);i=i+1) begin      // 24 bytes are expected to be in the output vector
                read_output_fifo(data_out_rd_32);
                expected_vect = {expected_data3[4*i], expected_data3[4*i+1], expected_data3[4*i+2], expected_data3[4*i+3]};					
                if (expected_vect == data_out_rd_32) begin
                   $display($time, " SUCCESS: read_data = %h, expected_data = %h", data_out_rd_32, expected_vect); 
			    success_count = success_count + 1;
			    end 
			    else begin
                   $display($time, " ERROR: read_data = %h, expected_data = %h", data_out_rd_32, expected_vect); 
			       error_count = error_count + 1;
			    end
				if (empty_out_fifo && i<((data_len_exp/4)-1)) begin // Make another read only if the FIFO has data and only if it is not the last output double word
				   @(negedge empty_out_fifo);
				end 
			end
		`endif
		

	        $display("========================================================================================");
			reset_gzip_core();
			kat_test_index = kat_test_index + 1;
			test_count = test_count + 1;
			
            $display($time, "\n\n TEST %d - FIXED_HUFFMAN test", kat_test_index);
            btype_in = `FIXED_HUFFMAN;

			$display($time, "Test phrase= 511x'a' and 1x'b' ");

			feed_input_fifo({{7'b0,`BFINAL1}, 24'd512});           
            for (i=0; i<=126; i=i+1) begin                            // BFINAL=1, BTYPE=FIXED_HUFFMAN, LENGTH=512 bytes
		        $display($time, "  char_no = %d",i*4);
      		    feed_input_fifo({"a","a","a","a"});
			end

			// The character 'b' is the last from the same block
			//repeat(21) @(posedge clk);                // simulate a delay for this burst   
 			feed_input_fifo({"a", "a", "a", "b"});
				
			
			@(posedge debug_reg[`GZIP_DONE_POS]); 
			$display($time, " GZIP core finished processing data");		

			// Read the core output data
			data_len_exp = 24;
			//@(negedge empty_out_fifo);			
			for (i=0;i<(data_len_exp/4);i=i+1) begin      // 24 bytes are expected to be in the output vector
                read_output_fifo(data_out_rd_32);
                expected_vect = {expected_data4[4*i], expected_data4[4*i+1], expected_data4[4*i+2], expected_data4[4*i+3]};					
                if (expected_vect == data_out_rd_32) begin
                   $display($time, " SUCCESS: read_data = %h, expected_data = %h", data_out_rd_32, expected_vect); 
			    success_count = success_count + 1;
			    end 
			    else begin
                   $display($time, " ERROR: read_data = %h, expected_data = %h", data_out_rd_32, expected_vect); 
			       error_count = error_count + 1;
			    end
				if (empty_out_fifo && i<((data_len_exp/4)-1)) begin // Make another read only if the FIFO has data and only if it is not the last output double word
				   @(negedge empty_out_fifo);
				end 
			end	
			
			
            $display($time, "<<<<<<<<< Known Answer Test END >>>>>>>>");
        end 

        report_test_results;       
		
		
		
        start_test2 = 0;
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
			/*feed_input_fifo({{7'b0,`BFINAL1}, 24'd29});            // BFINAL=1, BTYPE=FIXED_HUFFMAN, LENGTH=6 bytes
		    feed_input_fifo({"T","h","a","t"}); 
		    feed_input_fifo({" ","a","p","p"}); 
		    feed_input_fifo({"l","e"," ","i"}); 
		    feed_input_fifo({"s"," ","o","u"}); 
		    feed_input_fifo({"r"," ","b","e"}); 
		    feed_input_fifo({"s","t"," ","a"}); 
		    feed_input_fifo({"p","p","l","e"}); 
		    feed_input_fifo({"."," "," "," "}); */

            // $display($time, "Test phrase= 'aaaaaaab' ");	// -> a@(6,1)b 		
			/*feed_input_fifo({{7'b0,`BFINAL1}, 24'd8});            // BFINAL=1, BTYPE=FIXED_HUFFMAN, LENGTH=8 bytes
		    feed_input_fifo({"a","a","a","a"}); 
		    feed_input_fifo({"a","a","a","b"}); */

			
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

			$display($time, "Test phrase= 'Test GZIP compression core Test GZIP' ");
			feed_input_fifo({{7'b0,`BFINAL1}, 24'd36});            // BFINAL=0, BTYPE=FIXED_HUFFMAN, LENGTH=18 bytes
		    feed_input_fifo({"T","e","s","t"}); 
		    feed_input_fifo({" ","G","Z","I"}); 
		    feed_input_fifo({"P"," ","c","o"});
		    feed_input_fifo({"m","p","r","e"});		
		    feed_input_fifo({"s","s","i","o"});
		    feed_input_fifo({"n"," ","c","o"});
		    feed_input_fifo({"r","e"," ","T"});
		    feed_input_fifo({"e","s","t"," "});
		    feed_input_fifo({"G","Z","I","P"});

			
		    //feed_input_fifo({"c","."," "," "});
		    /*feed_input_fifo({"e","f",8'd0,8'd0});

		    feed_input_fifo({{7'b0,1'b1}, 24'd5});              // BFINAL=1, BTYPE=FIXED_HUFFMAN, LENGTH=5 bytes
		    feed_input_fifo({"g","h","a","b"});
		    feed_input_fifo({"x",8'd0,8'd0,8'd0}); */

			
            /*$display($time, "Test phrase= 261 x '1' and one '2' ");
			feed_input_fifo({{7'b0,`BFINAL1}, 24'd262});           
            for (i=0; i<65; i=i+1)                              // BFINAL=0, BTYPE=FIXED_HUFFMAN, LENGTH=262 bytes
		       feed_input_fifo({"1","1","1","1"}); 
			feed_input_fifo({"1","2",8'b0,8'b0}); */

            /*$display($time, "Test phrase= 512 x '1' and one '2' ");
			feed_input_fifo({{7'b0,`BFINAL0}, 24'd512});           
            for (i=0; i<=127; i=i+1) begin                            // BFINAL=0, BTYPE=FIXED_HUFFMAN, LENGTH=512 bytes
		        $display($time, "  char_no = %d",i*4);
      		    feed_input_fifo({"1","1","1","1"});
			end
			
			feed_input_fifo({{7'b0,`BFINAL1}, 24'd1});                // BFINAL=1, BTYPE=FIXED_HUFFMAN, LENGTH=1 bytes
			//feed_input_fifo({"1","1","1","2"});
			feed_input_fifo({"2",8'b0,8'b0,8'b0});*/
			
			//feed_input_fifo({{7'b0,`BFINAL1}, 24'd39});       // BFINAL=1, BTYPE=FIXED_HUFFMAN, LENGTH=1 bytes
	        //feed_input_fifo({"2",8'b0,8'b0,8'b0});
			
			
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



	/*always @(*)            /// XXX this is for future tests
	begin
		@(posedge irq); 
		$display($time, " GZIP core finished processing data");		

		// Read the core output data
		data_len_exp = 536;
		//@(negedge empty_out_fifo);			
		for (i=0;i<(data_len_exp/4);i=i+1) begin      // 24 bytes are expected to be in the output vector
            read_output_fifo(data_out_rd_32);
            expected_vect = {expected_data3[4*i], expected_data3[4*i+1], expected_data3[4*i+2], expected_data3[4*i+3]};					
            if (expected_vect == data_out_rd_32) begin
               $display($time, " SUCCESS: read_data = %h, expected_data = %h", data_out_rd_32, expected_vect); 
		    success_count = success_count + 1;
		    end 
		    else begin
               $display($time, " ERROR: read_data = %h, expected_data = %h", data_out_rd_32, expected_vect); 
		       error_count = error_count + 1;
		    end
			if (empty_out_fifo && i<((data_len_exp/4)-1)) begin // Make another read only if the FIFO has data and only if it is not the last output double word
			   @(negedge empty_out_fifo);
			end 
		end
    end	 */
	
	
	// POP the data from the output FIFO 
	/*always @(posedge clk)
	begin
	   if (!empty_out_fifo) read_output_fifo(); data_out_rd_32
    end */   	

	
	
	// Display the result of the sliding window module
	//always @(posedge clk)
	//	    display_output_data(match_position, match_length, next_symbol, output_enable);	
	
	// Display the result of the sliding window module
	//always @(posedge clk)
    //    if(output_enable_filt)                        //data can displayed only when output_enable is set
	//	    display_output_data_filt(match_position_filt, match_length_filt, next_symbol_filt, output_enable_filt, match_position_valid);		
			
			
			
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
    // Testing tasks
    task report_test_results();
    begin       
	    if (error_count == 0)  $display("	GZIP TEST finished SUCCESSFULL");
        else                   $display("	GZIP TEST finished with ERRORS"); 
            $display("		test_count=%d",test_count);
            $display("		success_count=%d",success_count);
            $display("		error_count=%d",error_count);
        end
    endtask	
		
		
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

    // Task used to reset the module between tests
    task reset_gzip_core();
    begin       
        $display($time," RESET GZIP core");
	    repeat(2) @(negedge clk);   // rst_n will not be on the same edge as the gzip core (posedge)
	    rst_n = 0;        
	    repeat(2) @(negedge clk);
	    rst_n = 1;
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
     output [31:0] data_out_rd_32;
     begin
	    repeat(1) @(posedge clk);
        rd_en_fifo_out <= 1;       
    	repeat(1) @(posedge clk);
        rd_en_fifo_out <= 0;		
    	repeat(1) @(negedge clk);
        data_out_rd_32 = {dout_out_fifo_32[7:0], dout_out_fifo_32[15:8], dout_out_fifo_32[23:16], dout_out_fifo_32[31:24]};	
		$display($time, " gzip_fifo_out=%h", data_out_rd_32);
     end
    endtask	
	
	
endmodule
