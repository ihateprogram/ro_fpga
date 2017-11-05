/*
   Author: Ovidiu Plugariu
   Description: This is a test for the Static Distance Huffman tree used in the GZIP module.  
*/

`timescale 1 ns / 10 ps

`define DIST_CODE0	5'd0	
`define DIST_CODE1	5'd1	
`define DIST_CODE2	5'd2	
`define DIST_CODE3	5'd3	
`define DIST_CODE4	5'd4	
`define DIST_CODE5	5'd5	
`define DIST_CODE6	5'd6	
`define DIST_CODE7	5'd7	
`define DIST_CODE8	5'd8	
`define DIST_CODE9	5'd9	
`define DIST_CODE10	5'd10
`define DIST_CODE11	5'd11
`define DIST_CODE12	5'd12
`define DIST_CODE13	5'd13
`define DIST_CODE14	5'd14
`define DIST_CODE15	5'd15
`define DIST_CODE16	5'd16
`define DIST_CODE17	5'd17
`define DIST_CODE18	5'd18
`define DIST_CODE19	5'd19
`define DIST_CODE20	5'd20
`define DIST_CODE21	5'd21
`define DIST_CODE22	5'd22
`define DIST_CODE23	5'd23
`define DIST_CODE24	5'd24
`define DIST_CODE25	5'd25
`define DIST_CODE26	5'd26
`define DIST_CODE27	5'd27
`define DIST_CODE28	5'd28
`define DIST_CODE29	5'd29


module test_sdht;
 
    integer i;
    // Declare input/output variables
    reg clk;	
    reg rst_n;

	parameter DICTIONARY_DEPTH_LOG = 16;
	reg match_pos_valid_in = 0;
	reg [DICTIONARY_DEPTH_LOG-1:0]  match_pos_in = 0;
	
	wire  [17:0]  sdht_data_merged;
	wire  [4 :0]  sdht_valid_bits ;
    wire          sdht_data_valid_out;
	
    integer test_count    = 0;
    integer success_count = 0;
	integer error_count   = 0;
	
	reg [17:0] sdht_data_merged_exp_rev = 0;

	
    // Create clock signal - 100MHz
    always
    #5 clk = ~clk;
	
    // Instantiate DUT
    sdht
    #(      	
        .DATA_WIDTH(8),
        .DICTIONARY_DEPTH_LOG(DICTIONARY_DEPTH_LOG)		
	)
	sdht_i0
    (
    // Module inputs
    .clk,	
    .rst_n,	
	.match_pos_in,
	
    // Module outputs
	.sdht_data_merged,  // 18 bits { <5bit Huffman>, 13 bit binary code}
    .sdht_valid_bits    // this output says how many binary encoded bits are valid from the output of the decoder 
    );	
	


	initial
    begin
        $display($time, "<< Starting the Simulation >>");
	    match_pos_in = 0;
	    clk = 0;
	    rst_n = 0;
        repeat(15) @(posedge clk);
		rst_n = 1;
		
        $display($time, "**************************  SDHT TEST  **************************");
        repeat(5) @(posedge clk);
	
        load_data_task(16'd1);
        validate_sdht_data({13'b0,`DIST_CODE0}, 5'd5);
        load_data_task(16'd0);
        validate_sdht_data({13'b0,`DIST_CODE0}, 5'd5);		
        load_data_task(16'd2);
        validate_sdht_data({13'b0,`DIST_CODE1}, 5'd5);
        load_data_task(16'd3);
        validate_sdht_data({13'b0,`DIST_CODE2}, 5'd5);
        load_data_task(16'd4);
        validate_sdht_data({13'b0,`DIST_CODE3}, 5'd5);
		
		// Distance between 5-6
        load_data_task(16'd5);
        validate_sdht_data({12'b0, 1'b0, `DIST_CODE4}, 5'd6);	// one extra bit
        load_data_task(16'd6);
        validate_sdht_data({12'b0, 1'b1, `DIST_CODE4}, 5'd6);

		// Distance between 7-8
        load_data_task(16'd7);
        validate_sdht_data({12'b0, 1'b0, `DIST_CODE5}, 5'd6);    // one extra bit	
        load_data_task(16'd8);
        validate_sdht_data({12'b0, 1'b1, `DIST_CODE5}, 5'd6);

		// Distance between 9-12
        load_data_task(16'd9);
        validate_sdht_data({11'b0,2'd0, `DIST_CODE6}, 5'd7);    // two extra bits	
        load_data_task(16'd10);        
        validate_sdht_data({11'b0,2'd1, `DIST_CODE6}, 5'd7);
        load_data_task(16'd11);       
        validate_sdht_data({11'b0,2'd2, `DIST_CODE6}, 5'd7);
        load_data_task(16'd12);        
        validate_sdht_data({11'b0,2'd3, `DIST_CODE6}, 5'd7);

		// Distance between 13-16
        load_data_task(16'd13);
        validate_sdht_data({11'b0, 2'd0, `DIST_CODE7}, 5'd7);    // two extra bits
        load_data_task(16'd15);
        validate_sdht_data({11'b0, 2'd2, `DIST_CODE7}, 5'd7);    		
        load_data_task(16'd16);
        validate_sdht_data({11'b0, 2'd3, `DIST_CODE7}, 5'd7);     		

		// Distance between 17-24
        load_data_task(16'd17);
        validate_sdht_data({10'b0,3'd0,`DIST_CODE8}, 5'd8);    // three extra bits		
        load_data_task(16'd19);   
        validate_sdht_data({10'b0,3'd2,`DIST_CODE8}, 5'd8); 
        load_data_task(16'd21);   
        validate_sdht_data({10'b0,3'd4,`DIST_CODE8}, 5'd8); 
        load_data_task(16'd24);   
        validate_sdht_data({10'b0,3'd7,`DIST_CODE8}, 5'd8); 
		
		// Distance between 25-32
        load_data_task(16'd25);
        validate_sdht_data({10'b0, 3'd0, `DIST_CODE9}, 5'd8);    // three extra bits			
        load_data_task(16'd26);
        validate_sdht_data({10'b0, 3'd1, `DIST_CODE9}, 5'd8);
        load_data_task(16'd32);
        validate_sdht_data({10'b0, 3'd7, `DIST_CODE9}, 5'd8);
        load_data_task(16'd30);
        validate_sdht_data({10'b0, 3'd5, `DIST_CODE9}, 5'd8);
		
		// Distance between 33-48
        load_data_task(16'd33);
        validate_sdht_data({9'b0, 4'd0, `DIST_CODE10}, 5'd9);    // four extra bits
        load_data_task(16'd35);
        validate_sdht_data({9'b0, 4'd2, `DIST_CODE10}, 5'd9);
        load_data_task(16'd40);
        validate_sdht_data({9'b0, 4'd7, `DIST_CODE10}, 5'd9);
        load_data_task(16'd45);
        validate_sdht_data({9'b0, 4'd12, `DIST_CODE10}, 5'd9);
        load_data_task(16'd48);
        validate_sdht_data({9'b0, 4'd15, `DIST_CODE10}, 5'd9);

		// Distance between 49-64
        load_data_task(16'd49);
        validate_sdht_data({9'b0, 4'd0, `DIST_CODE11}, 5'd9);    // four extra bits
        load_data_task(16'd53);
        validate_sdht_data({9'b0, 4'd4, `DIST_CODE11}, 5'd9);
        load_data_task(16'd59);
        validate_sdht_data({9'b0, 4'd10, `DIST_CODE11}, 5'd9);
        load_data_task(16'd64);
        validate_sdht_data({9'b0, 4'd15,`DIST_CODE11}, 5'd9);
		
		// Distance between 65-96
        load_data_task(16'd65);
        validate_sdht_data({8'b0, 5'd0, `DIST_CODE12}, 5'd10);   // five extra bits
        load_data_task(16'd68);
        validate_sdht_data({8'b0, 5'd3, `DIST_CODE12}, 5'd10);		
        load_data_task(16'd87);
        validate_sdht_data({8'b0, 5'd22, `DIST_CODE12}, 5'd10);
        load_data_task(16'd96);
        validate_sdht_data({8'b0, 5'd31, `DIST_CODE12}, 5'd10);

		// Distance between 97-128
        load_data_task(16'd97);
        validate_sdht_data({8'b0, 5'd0, `DIST_CODE13}, 5'd10);   // five extra bits
        load_data_task(16'd101);
        validate_sdht_data({8'b0, 5'd4, `DIST_CODE13}, 5'd10);
        load_data_task(16'd111);
        validate_sdht_data({8'b0, 5'd14, `DIST_CODE13}, 5'd10);		
        load_data_task(16'd121);
        validate_sdht_data({8'b0, 5'd24, `DIST_CODE13}, 5'd10);
        load_data_task(16'd128);
        validate_sdht_data({8'b0, 5'd31, `DIST_CODE13}, 5'd10);
		
		// Distance between 129-192
        load_data_task(16'd129);
        validate_sdht_data({7'b0, 6'd0, `DIST_CODE14}, 5'd11);  // six extra bits 
        load_data_task(16'd134);
        validate_sdht_data({7'b0, 6'd5, `DIST_CODE14}, 5'd11); 
        load_data_task(16'd144);
        validate_sdht_data({7'b0, 6'd15, `DIST_CODE14}, 5'd11); 
        load_data_task(16'd164);
        validate_sdht_data({7'b0, 6'd35, `DIST_CODE14}, 5'd11); 
        load_data_task(16'd184);
        validate_sdht_data({7'b0, 6'd55, `DIST_CODE14}, 5'd11);
        load_data_task(16'd192);
        validate_sdht_data({7'b0, 6'd63, `DIST_CODE14}, 5'd11);

		// Distance between 193-256
        load_data_task(16'd193);
        validate_sdht_data({7'b0, 6'd0, `DIST_CODE15}, 5'd11);  // six extra bits 		
        load_data_task(16'd200);
        validate_sdht_data({7'b0, 6'd7, `DIST_CODE15}, 5'd11);
        load_data_task(16'd240);
        validate_sdht_data({7'b0, 6'd47, `DIST_CODE15}, 5'd11);		
        load_data_task(16'd256);
        validate_sdht_data({7'b0, 6'd63, `DIST_CODE15}, 5'd11);

		// Distance between 257-384
        load_data_task(16'd257);
        validate_sdht_data({6'b0, 7'd0, `DIST_CODE16}, 5'd12);  // seven extra bits 		
        load_data_task(16'd262);
        validate_sdht_data({6'b0, 7'd5, `DIST_CODE16}, 5'd12);
        load_data_task(16'd300);
        validate_sdht_data({6'b0, 7'd43, `DIST_CODE16}, 5'd12);
        load_data_task(16'd380);
        validate_sdht_data({6'b0, 7'd123, `DIST_CODE16}, 5'd12);
        load_data_task(16'd384);
        validate_sdht_data({6'b0, 7'd127, `DIST_CODE16}, 5'd12);

		// Distance between 385-512
        load_data_task(16'd385);
        validate_sdht_data({6'b0, 7'd0, `DIST_CODE17}, 5'd12);  // seven extra bits
        load_data_task(16'd386);
        validate_sdht_data({6'b0, 7'd1, `DIST_CODE17}, 5'd12);
        load_data_task(16'd433);
        validate_sdht_data({6'b0, 7'd48, `DIST_CODE17}, 5'd12);
        load_data_task(16'd512);
        validate_sdht_data({6'b0, 7'd127, `DIST_CODE17}, 5'd12);

		// Distance between 513-768
        load_data_task(16'd513);
        validate_sdht_data({5'b0, 8'd0, `DIST_CODE18}, 5'd13);  // eight extra bits		
        load_data_task(16'd515);
        validate_sdht_data({5'b0, 8'd2, `DIST_CODE18}, 5'd13);
        load_data_task(16'd600);
        validate_sdht_data({5'b0, 8'd87, `DIST_CODE18}, 5'd13);
        load_data_task(16'd713);
        validate_sdht_data({5'b0, 8'd200, `DIST_CODE18}, 5'd13);
        load_data_task(16'd768);
        validate_sdht_data({5'b0, 8'd255, `DIST_CODE18}, 5'd13);
		
        // Distance between 769-1024		
        load_data_task(16'd769);
        validate_sdht_data({5'b0, 8'd0, `DIST_CODE19}, 5'd13);  // eight extra bits
        load_data_task(16'd869);
        validate_sdht_data({5'b0, 8'd100, `DIST_CODE19}, 5'd13);
        load_data_task(16'd969);
        validate_sdht_data({5'b0, 8'd200,`DIST_CODE19}, 5'd13);		
        load_data_task(16'd1024);
        validate_sdht_data({5'b0, 8'd255, `DIST_CODE19}, 5'd13);			

        // Distance between 1025-1536
        load_data_task(16'd1025);
        validate_sdht_data({4'b0, 9'd0, `DIST_CODE20}, 5'd14);  // nine extra bits
        load_data_task(16'd1326);
        validate_sdht_data({4'b0, 9'd301, `DIST_CODE20}, 5'd14); 
        load_data_task(16'd1536);
        validate_sdht_data({4'b0, 9'd511, `DIST_CODE20}, 5'd14); 

        // Distance between 1537-2048
        load_data_task(16'd1537);
        validate_sdht_data({4'b0, 9'd0, `DIST_CODE21}, 5'd14);  // nine extra bits
        load_data_task(16'd1837);
        validate_sdht_data({4'b0, 9'd300, `DIST_CODE21}, 5'd14);
        load_data_task(16'd2048);
        validate_sdht_data({4'b0, 9'd511, `DIST_CODE21}, 5'd14);

        // Distance between 2049-3072
        load_data_task(16'd2049);
        validate_sdht_data({3'b0, 10'd0, `DIST_CODE22}, 5'd15);  // ten extra bits	
        load_data_task(16'd2059);
        validate_sdht_data({3'b0, 10'd10, `DIST_CODE22}, 5'd15); 	
        load_data_task(16'd3000);
        validate_sdht_data({3'b0, 10'd951, `DIST_CODE22}, 5'd15); 
        load_data_task(16'd3072);
        validate_sdht_data({3'b0, 10'd1023, `DIST_CODE22}, 5'd15);

        // Distance between 3073-4096
        load_data_task(16'd3073);
        validate_sdht_data({3'b0, 10'd0, `DIST_CODE23}, 5'd15);  // ten extra bits		
        load_data_task(16'd3093);
        validate_sdht_data({3'b0, 10'd20, `DIST_CODE23}, 5'd15); 
        load_data_task(16'd3999);
        validate_sdht_data({3'b0, 10'd926, `DIST_CODE23}, 5'd15);
        load_data_task(16'd4096);
        validate_sdht_data({3'b0, 10'd1023, `DIST_CODE23}, 5'd15);

        // Distance between 4097-6144
        load_data_task(16'd4097);
        validate_sdht_data({3'b0, 11'd0, `DIST_CODE24}, 5'd16);  // eleven extra bits
        load_data_task(16'd5321);
        validate_sdht_data({3'b0, 11'd1224, `DIST_CODE24}, 5'd16);		
        load_data_task(16'd6144);
        validate_sdht_data({3'b0, 11'd2047, `DIST_CODE24}, 5'd16);

        // Distance between 6145-8192
        load_data_task(16'd6145);
        validate_sdht_data({3'b0, 11'd0, `DIST_CODE25}, 5'd16);  // eleven extra bits		
        load_data_task(16'd6147);
        validate_sdht_data({3'b0, 11'd2, `DIST_CODE25}, 5'd16);
        load_data_task(16'd7896);
        validate_sdht_data({3'b0, 11'd1751, `DIST_CODE25}, 5'd16);
        load_data_task(16'd8192);
        validate_sdht_data({3'b0, 11'd2047, `DIST_CODE25}, 5'd16);
		
        // Distance between 8193-12288
        load_data_task(16'd8193);
        validate_sdht_data({2'b0, 12'd0, `DIST_CODE26}, 5'd17);  // twelve extra bits		
        load_data_task(16'd8199);
        validate_sdht_data({2'b0, 12'd6, `DIST_CODE26}, 5'd17); 		
        load_data_task(16'd11027);
        validate_sdht_data({2'b0, 12'd2834, `DIST_CODE26}, 5'd17);		
        load_data_task(16'd12288);
        validate_sdht_data({2'b0, 12'd4095, `DIST_CODE26}, 5'd17);

        // Distance between 12289-16384
        load_data_task(16'd12289);
        validate_sdht_data({2'b0, 12'd0, `DIST_CODE27}, 5'd17);  // twelve extra bits		
        load_data_task(16'd14343);
        validate_sdht_data({2'b0, 12'd2054, `DIST_CODE27}, 5'd17);
        load_data_task(16'd15343);
        validate_sdht_data({2'b0, 12'd3054, `DIST_CODE27}, 5'd17);
        load_data_task(16'd16384);
        validate_sdht_data({2'b0, 12'd4095, `DIST_CODE27}, 5'd17);

        // Distance between 16385-24576
        load_data_task(16'd16385);
        validate_sdht_data({1'b0, 13'd0, `DIST_CODE28}, 5'd18);	// thirteen extra bits	
        load_data_task(16'd18385);
        validate_sdht_data({1'b0, 13'd2000, `DIST_CODE28}, 5'd18);
        load_data_task(16'd19385);
        validate_sdht_data({1'b0,  13'd3000, `DIST_CODE28}, 5'd18);
        load_data_task(16'd24576);
        validate_sdht_data({1'b0, 13'd8191, `DIST_CODE28}, 5'd18);

        // Distance between 24577-32768 (maximum length of the gzip sliding window)
        load_data_task(16'd24577);
        validate_sdht_data({1'b0, 13'd0, `DIST_CODE29}, 5'd18);	// thirteen extra bits			
        load_data_task(16'd25677);
        validate_sdht_data({1'b0, 13'd1100, `DIST_CODE29}, 5'd18);
        load_data_task(16'd28677);
        validate_sdht_data({1'b0, 13'd4100, `DIST_CODE29}, 5'd18);		
        load_data_task(16'd32768);
        validate_sdht_data({1'b0, 13'd8191, `DIST_CODE29}, 5'd18);
		
        //load_data_task(16'd1);
        //load_data_task(16'd2);
        //load_data_task(16'd3);
        //load_data_task(16'd4);
		repeat(10) @(posedge clk);



		//load_data_task(32'hFFFFFFFF, 5'd31, 0);
		//load_data_task(32'hFFFFFFFF, 5'd30, 0);
	    //total_value = total_value + in_data[in_size:0];
		report_test_results;
        $display($time, "************************** SDHT test is DONE **************************");		
    end

	// Display the result of the sliding window module
	//always @(posedge clk)
	//	    display_output_data(out_valid, out_last, out_bvalid, out_data);
			
			
	//====================================================================================================================
	//======================================= Tasks for SDHT automatic validation ========================================
	//====================================================================================================================
	
    task load_data_task;
	    input  [DICTIONARY_DEPTH_LOG-1:0]  match_pos_in_val;
    begin
        @(posedge clk);
        match_pos_in = match_pos_in_val;
		$display($time, " Loading match_pos_in = %d", match_pos_in);
        @(posedge clk); 		
    end
    endtask //of load_data	
	
    task validate_sdht_data();
    input [17:0]  sdht_data_merged_exp;
	input [4 :0]  sdht_valid_bits_exp ;
    begin	
		sdht_data_merged_exp_rev = (sdht_data_merged_exp[17:5] << 5)
		                           | {sdht_data_merged_exp[0], sdht_data_merged_exp[1], sdht_data_merged_exp[2], sdht_data_merged_exp[3], sdht_data_merged_exp[4]};
		
		#1;
            test_count <= test_count + 1;
    	if( ({sdht_data_merged_exp_rev, sdht_valid_bits_exp} == {sdht_data_merged, sdht_valid_bits}) ) begin
    	    success_count <= success_count + 1; 
			$display($time,"Success at test %d",test_count);
			$display("            Static distance SD=%b, valid_bits=%d ", sdht_data_merged_exp_rev, sdht_valid_bits_exp);
    		end
        else begin
            error_count	<= error_count + 1;
			$display($time,"Error at test %d \n",test_count);
			$display("            Observed: distance SD=%b, valid_bits=%d\n        Expected: distance SD=%b, valid_bits=%d " 
			                                                                                                            ,sdht_data_merged, sdht_valid_bits
			                                                                                                            ,sdht_data_merged_exp_rev, sdht_valid_bits_exp);
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
