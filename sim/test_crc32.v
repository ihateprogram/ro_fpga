/*
   Author: Ovidiu Plugariu
   Description: This is a test for the CRC32 block used in the GZIP module.  
   Test vectors were generated using:
	    https://www.lammertbies.nl/comm/info/crc-calculation.html
*/

`timescale 1 ns / 10 ps



module crc32_test();
 
    integer i;
    // Declare input/output variables
    reg clk;	
    reg rst_n;

	reg [7:0] crc32_in;
    reg crc32_valid_in;

	// Module outputs
	wire [31:0] crc32_out;
	
    integer test_count    = 0;
    integer success_count = 0;
	integer error_count   = 0;
	
    // Create clock signal - 100MHz
    always
    #2 clk = ~clk;
	
    // Instantiate DUT
    crc32 crc32_i0
    (
    // Module inputs
	.clk,
	.rst_n,
	.crc32_in,
    .crc32_valid_in,

	// Module outputs
	.crc32_out                            // 32 bit value of the CRC
    );	
	

	initial
    begin
        $display($time, "<< Starting the Simulation >>");
	    crc32_in = 0;
		crc32_valid_in = 0;
	    clk = 0;
	    rst_n = 0;
        repeat(15) @(posedge clk);
		rst_n = 1;
		
        $display($time, "**************************  CRC32 TEST  **************************");
        repeat(5) @(posedge clk);
	
	    // Load the ASCII data "0123456789" - Expected: 0xA684C7C6
        load_data_task("0");
        load_data_task("1");
        load_data_task("2");
        load_data_task("3");
        load_data_task("4");
        load_data_task("5");
        load_data_task("6");
        load_data_task("7");
        load_data_task("8");
        load_data_task("9");
        validate_crc32_data(32'hA684C7C6);
		
		// Module must reset between tests because the previous CRC value must be cleared
        reset_module();
		 
		// Loas HEX data 0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000; // expected 190A55AD
		// 16*2 = 32 bytes of 0
        for (i=0 ; i<32 ; i=i+1) begin
            load_data_task(8'h00);
        end		
	    validate_crc32_data(32'h190A55AD);
		
		
        reset_module();
		// Load hex FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;   // expected FF6CAB0B
        for (i=0 ; i<32 ; i=i+1) begin
            load_data_task(8'hFF);
        end		
	    validate_crc32_data(32'hFF6CAB0B);		

        reset_module();
		// Load hex  000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F  // expected 91267E8A
        for (i=0 ; i<32 ; i=i+1) begin
            load_data_task(i);
        end		
	    validate_crc32_data(32'h91267E8A);	
		
		reset_module();
		// Load ASCII "The quick brown fox jumps over the lazy dog"  // expected 414FA339
		load_data_task("T");
		load_data_task("h");
		load_data_task("e");
		load_data_task(" ");
		load_data_task("q");
		load_data_task("u");
		load_data_task("i");
		load_data_task("c");
		load_data_task("k");
		load_data_task(" ");
		load_data_task("b");
		load_data_task("r");
		load_data_task("o");
		load_data_task("w");
		load_data_task("n");
		load_data_task(" ");
		load_data_task("f");
		load_data_task("o");
		load_data_task("x"); 
		load_data_task(" ");
		load_data_task("j");
		load_data_task("u");
		load_data_task("m");
		load_data_task("p");
		load_data_task("s"); 
		load_data_task(" ");
		load_data_task("o");
		load_data_task("v");
		load_data_task("e");
		load_data_task("r"); 
		load_data_task(" ");
		load_data_task("t");
		load_data_task("h");
		load_data_task("e"); 
		load_data_task(" ");
		load_data_task("l");
		load_data_task("a");
		load_data_task("z");
		load_data_task("y"); 
		load_data_task(" ");
		load_data_task("d");
		load_data_task("o");
		load_data_task("g");
        validate_crc32_data(32'h414FA339);	

		
        repeat(10) @(posedge clk);
		report_test_results;
        $display($time, "************************** CRC32 test is DONE **************************");		
    end

	
	//====================================================================================================================
	//======================================= Tasks for SDHT automatic validation ========================================
	//====================================================================================================================

    task reset_module;
	begin
		repeat(1) @(posedge clk);
	    rst_n = 0;
        repeat(10) @(posedge clk);
		rst_n = 1;		
		repeat(2) @(posedge clk);
	end
	endtask

	
    task load_data_task;
	    input [7:0] crc32_in_val;
    begin	
	    crc32_valid_in = 1;
        crc32_in = crc32_in_val;
		$display($time, " Loading crc32_in = %d", crc32_in);
        @(posedge clk); 
        crc32_valid_in = 0;		
    end
    endtask 	
	
    task validate_crc32_data();
    input [31:0]  crc32_out_exp;
    begin
	    //@(posedge clk);                                 // wait for the module to update its outpus
		#1;
            test_count <= test_count + 1;
    	if ( (crc32_out_exp ==  crc32_out)) begin
    	    success_count <= success_count + 1; 
			$display($time,"Success at test %d",test_count);
			$display("            CRC32_OUT=%h", crc32_out);
    		end
        else begin
            error_count	<= error_count + 1;
			$display($time,"Error at test %d \n",test_count);
			$display("            Observed: CRC32_OUT=%h, \n        Expected: CRC32_OUT_EXP=%h \n " 
                     ,crc32_out ,crc32_out_exp);
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
