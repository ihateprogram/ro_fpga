/*
   Author: Ovidiu Plugariu
   Description: This is a test for the word merge module used in used in GZIP.
*/

`timescale 1 ns / 10 ps


module test_word_merge;
 
    integer i;
    // Declare input/output variables
    reg clk;	
    reg rst_n;

    reg in_valid =0;
    reg in_last =0;
    reg [5:0]  in_size=0;
    reg [31:0] in_data=0;
    
	reg [31:0] total_value = 0;

    wire out_valid;
    wire out_last;
    wire [3:0] out_bvalid;
    wire [31:0] out_data;	
	
    // Create clock signal - 100MHz
    always
    #5 clk = ~clk;
	
    // Instantiate DUT
 
    word_merge64 word_merge_i0(
       // Module inputs
       .clock(clk),
       .reset(!rst_n),    
       .in_valid,
       .in_last,
       .in_size,
       .in_data,
    	
    	// Module outputs
       .out_valid,
       .out_last,
       //.out_bvalid,
       .out_data
    );		
		

	initial
    begin
        $display($time, "<< Starting the Simulation >>");
	    
	    clk = 0;
	    rst_n = 0;
	    in_valid = 0;
        in_last = 0;
        repeat(15) @(posedge clk);
		rst_n = 1;
        $display($time, "**************************  WordMerge TEST  **************************");	
         
        
        load_data_task(32'h555, 5'd12, 0);
        load_data_task(32'hAAA, 5'd12, 0);
        load_data_task(32'hDD, 5'd8, 0);
		repeat(10) @(posedge clk);
        load_data_task(32'hB, 5'd4, 0);
        load_data_task(32'hC, 5'd4, 0);
        load_data_task(32'hD, 5'd4, 0);
        load_data_task(32'hE, 5'd4, 0);
        load_data_task(32'hF, 5'd4, 0);
        load_data_task(32'h1, 5'd4, 0);
        load_data_task(32'h2, 5'd4, 0);
        load_data_task(32'h3, 5'd4, 0);

		repeat(10) @(posedge clk);
        load_data_task(32'h3FFFF, 5'd18, 0);
        load_data_task(32'hAAAAA, 5'd20, 0);  // raman 6 biti in plus
		
		repeat(20) @(posedge clk);
		// Mai punem 17 biti si astia sunt ultimii 
		load_data_task(32'h2, 5'd2, 0);    // ar trebui sa avem stocat 02 | 2A = 0x AA ; 8 biti valizi
		load_data_task(32'hFFF, 5'd3, 0);  
		load_data_task(32'h0, 5'd1, 0);  
		load_data_task(32'hB, 5'd4, 0);  
		load_data_task(32'hCD, 5'd7, 0);  
		load_data_task(32'h1, 5'd1, 1);    // va trebui sa avem pe iesire 18+6=24 biti = 00cdb7aa

		//load_data_task(32'hFFFFFFFF, 5'd31, 0);
		//load_data_task(32'hFFFFFFFF, 5'd30, 0);
	    //total_value = total_value + in_data[in_size:0];
		
        $display($time, "************************** WordMerge test is DONE **************************");		
    end

	// Display the result of the sliding window module
	always @(posedge clk)
		    display_output_data(out_valid, out_last, out_bvalid, out_data);
			
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
    // Testing tasks
	
    task load_data_task;
	    input [31:0] in_data_t;
	    input [5:0]  in_size_t;
        input in_last_t;
    begin	
	    in_valid = 1;
		in_last = in_last_t;
		in_size = in_size_t;
		in_data = in_data_t;
		$display($time, " Loading in_data=%h in_size=%d in_last=%b", in_data, in_size, in_last_t);
        @(posedge clk); 
        in_valid = 0;
        in_last = 0;
        //@(posedge clk); 		
    end
    endtask //of load_data	
	
	
	// Task used to display data from the lz77 encoder
    task display_output_data;
        input out_valid;		
        input out_last;		
        input [3:0] out_bvalid;		
        input [31:0] out_data;			
	begin
	    if(out_valid || out_last) $display($time, "======================= Output character out_data=%h out_bvalid=%d out_last=%b =======================", 
		                                   out_data, out_bvalid, out_last); 
    end		
	endtask
	
endmodule
