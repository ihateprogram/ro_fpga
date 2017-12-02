/*  
Title:            Sliding window algorithm for LZ77 encoder
Author:                                     Ovidiu Plugariu

Description:   Using this module the LZ77 encoder calculates the maximum length match 
            between the characters present in the search_buffer and in the dictionary.
            This module has the following characteristics:
            1. Parametrizable depth for search_buffer and dictionary (powers of 2).
            2. The input shift data has a 8bit width and shifts characters from the search dictionary 1 byte at a time.
            3. The input search data has a 8bit width and when the search function is enabled, the module returns the address where the specific data has been found.
               This is a SHIFTABLE CAM behaviour.            
            4. The module outputs: A. the next_symbol that should be encoded  
                                   B. the match_position (position pointer) where the string match starts (starts from 0)
                                   C. the match_length of the string that has been recognized 
								   D. an output_enable signal that shows the other outputs of the module are valid
*/


//`include "functions.v"

module lz77_encoder
    #( 
     	parameter DATA_WIDTH = 8,
        parameter DICTIONARY_DEPTH = 512,
		parameter DICTIONARY_DEPTH_LOG = 9,
		parameter LOOK_AHEAD_BUFF_DEPTH = 66,
		parameter CNT_WIDTH = 7     // The counter size must be changed according to the maximum match length
	 )
    (
    // Module inputs
    input clk,	
    input rst_n,
    input data_valid,
    input [DATA_WIDTH-1:0] input_data,	

    // Module outputs 
    output [DICTIONARY_DEPTH_LOG-1:0] match_position,
	output reg [CNT_WIDTH-1:0]        match_length,
	output [DATA_WIDTH-1:0]           next_symbol,
	output output_enable	

    );

	
    // Combinational logic
    wire match_global;
	wire set_match;
	wire match_position_valid;
	(* dont_touch = "{true}" *) wire [DATA_WIDTH-1:0] out_reg_PE [0:DICTIONARY_DEPTH-1];  // wires to connect the processing elements
	(* dont_touch = "{true}" *) wire [DICTIONARY_DEPTH-1:0] match_PE;
	(* dont_touch = "{true}" *) reg  [DICTIONARY_DEPTH-1:0] match_PE_buff;
	wire match_length_max;
	
	assign next_symbol = input_data;
	
	// The search array is a parameterizable module used to create the sliding dictionary and to return the match positions	
    genvar i;     
    generate
        for (i=0; i < DICTIONARY_DEPTH; i=i+1) begin : SLD_WIN
		    if ( i==0 )			      
                reg_PE REG_PE_i (.clk, .rst_n,
	                           .in_reg_PE(input_data[7:0]), .in_cmp_data(input_data[7:0]),
                               .shift_en(data_valid), .set_match,
                               .out_reg_PE(out_reg_PE[i]),  .match(match_PE[i]));					
			else 			
				reg_PE REG_PE_i (.clk, .rst_n,
	                           .in_reg_PE(out_reg_PE[i-1]), .in_cmp_data(input_data[7:0]),
                               .shift_en(data_valid), .set_match,
                               .out_reg_PE(out_reg_PE[i]), .match(match_PE[i]));
        end
    endgenerate

    /*generate
        for (i=0; i < DICTIONARY_DEPTH; i=i+1) begin : SLD_WIN
		    if ( i==0 )
                reg_PE REG_PE_i (.clk, .rst_n,
	                           .in_reg_PE(next_symbol[7:0]), .in_cmp_data(input_data[7:0]),
                               .shift_en(data_valid), .set_match,
                               .out_reg_PE(out_reg_PE[7:0]),  .match(match_PE[i]));					
			else 			
				reg_PE REG_PE_i (.clk, .rst_n,
	                           .in_reg_PE(out_reg_PE[i*8-1:(i-1)*8]), .in_cmp_data(input_data[7:0]),
                               .shift_en(data_valid), .set_match,
                               .out_reg_PE(out_reg_PE[(i+1)*8-1:i*8]), .match(match_PE[i]));
        end
    endgenerate */
	
	assign match_global = |match_PE[DICTIONARY_DEPTH-1:0];    // big OR gate used for match detection
	
	// The match calculation will function without data_valid=1 but the downstream modules must not see 
	// the output_enable signal set when no data is processed.
    assign output_enable = (data_valid & ~match_global) | match_length_max;

	// Create the signal that shows the maximum value of the counter
	assign match_length_max = (match_length == LOOK_AHEAD_BUFF_DEPTH-1);
	
    // Createa a counter which will count the matching length. 
	// At each positive edge if match=1 and data_valid=1 then the counter will increment.		
	always @(posedge clk or negedge rst_n)
	begin
	    if(!rst_n)                                               match_length <= 0;
		else if (match_global && data_valid && match_length_max) match_length <= 0;                     // the counter should reset if max value is reached
		else if (match_global && data_valid)                     match_length <= match_length + 1;      // the counter must not increment but will preservi its value
        else                                                     match_length <= 0;
	end
	
	// Until the first match occurs, the PEs need the match_ff high.
	// When the output_enable signal is set, it means data is outputed and the search for a new match should start again.
	assign set_match = output_enable;
	
	
	/////////////////////////////////////////// Priority encoder which returns the biggest match position in decimal ///////////////////////////////////////////
  
    // Make a pipeline stage before the priority encoder to limit the size of the combinational circuit
	always @(posedge clk or negedge rst_n)
	begin
	    if(!rst_n) match_PE_buff[DICTIONARY_DEPTH-1:0] <= 0;
		else       match_PE_buff[DICTIONARY_DEPTH-1:0] <= match_PE[DICTIONARY_DEPTH-1:0];
	end
 
	
    priority_enc 
       #(
    	    .ENCODER_DEPTH(DICTIONARY_DEPTH),
			.log2N(DICTIONARY_DEPTH_LOG)
    	)
		PRIO_ENC_i0
    	(
		    .rst_n,
			.clk,
    	    .A_IN(match_PE_buff[DICTIONARY_DEPTH-1:0]),  // Input Vector
    	    .P(match_position),                          // High Priority Index
    	    .F(match_position_valid)                     // This is used when the match is on position 0
    	);
		
		
endmodule




