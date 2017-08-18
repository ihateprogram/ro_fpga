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
            4. The module outputs: A. 1 bit encode signal 
                                   B. address value where the searched character has been found
                                   C. 1 bit match signal if the searched data is found at a speciffic address
*/

`include "functions.v"
//import gzip_pkg::*;

module lz77_encoder
    #( 
     	parameter DATA_WIDTH = 8,
        //parameter INPUT_BUFFER_DEPTH = 3;
        parameter DICTIONARY_DEPTH = 16,
		parameter LOOK_AHEAD_BUFF_DEPTH = 8,
		parameter CNT_WIDTH = clogb2(LOOK_AHEAD_BUFF_DEPTH),     // The counter size must be changed according to the maximum match length
		parameter DICTIONARY_DEPTH_LOG = clogb2(DICTIONARY_DEPTH) 
	 )
    (
    // Module inputs
    input clk,	
    input rst_n,
    input data_valid,
    input [DATA_WIDTH-1:0] input_data,	

    // Module outputs 
    output [DICTIONARY_DEPTH_LOG-1:0] match_position,
	//output match_valid,	
	output reg [CNT_WIDTH-1:0]        match_length,
	output [DATA_WIDTH-1:0]           next_symbol,
	output output_enable	

    );
  
    // Parameters
    //parameter [4:0] IDLE    = 5'd0,
    //                SHIFT   = 5'd1,
	//				ENCODE  = 5'd2;
                    					
	
    // Registers
    //reg [DATA_WIDTH-1:0] next_symbol_ff;
	
    // Combinational logic
    wire match_global;
	wire set_match;
	wire match_position_valid;
	wire [DATA_WIDTH*DICTIONARY_DEPTH-1:0] out_reg_PE;  // wires to connect the processing elements
	wire [DICTIONARY_DEPTH-1:0] match_PE;
	
    //reg [4:0] next_state;
 	//reg shift_en;
	
    // This register is used for buffering the input data. The length of the max_match is given by the reset value of the counter
    /*always @(posedge clk, negedge rst_n)
        if (!rst_n) next_symbol_ff <= 8'b0;
        else        next_symbol_ff <= input_data;*/
	
	//assign next_symbol = next_symbol_ff;
	assign next_symbol = input_data;
	
	// The search array is a parameterizable module used to create the sliding dictionary and to return the match positions
	
    genvar i;     
    generate
        for (i=0; i < DICTIONARY_DEPTH; i=i+1) begin : SLD_WIN
		    if (i==0)
                reg_PE REG_PE (.clk, .rst_n,
	                           .in_reg_PE(next_symbol[7:0]), .in_cmp_data(input_data[7:0]),
                               .shift_en(data_valid), .set_match,
                               .out_reg_PE(out_reg_PE[7:0]),  .match(match_PE[i]));					
			else 			
				reg_PE REG_PE (.clk, .rst_n,
	                           .in_reg_PE(out_reg_PE[i*8-1:(i-1)*8]), .in_cmp_data(input_data[7:0]),
                               .shift_en(data_valid), .set_match,
                               .out_reg_PE(out_reg_PE[(i+1)*8-1:i*8]), .match(match_PE[i]));
        end
    endgenerate
	
	assign match_global = |match_PE[DICTIONARY_DEPTH-1:0];    // big OR gate used for match detection
	
	// The match calculation will function without data_valid=1 but the downstream modules must not see 
	// the output_enable signal set when no data is processed.
    assign output_enable = data_valid & ~match_global;

	
    // Createa a counter which will count the matching length. 
	// At each positive edge if match=1 and data_valid=1 then the counter will increment.
		
	always @(posedge clk or negedge rst_n)
	begin
	    if(!rst_n)                           match_length <= 0;
		else if (match_global && data_valid) match_length <= match_length + 1;      // the counter must not increment but will preserve its value
        else                                 match_length <= 0;
		//if(match_length>0) $display($time, " << match_length = %d >>", match_length);
        //$monitor("t=%3d x=%d,y=%d,z=%d \n",$time,x,y,z, );
	end
	
	// Until the first match occurs, the PEs need the match_ff high.
	// When the output_enable signal is set, it means data is outputed and the search for a new match should start again.
	assign set_match = output_enable;


	/////////////////////////////////////////// Priority encoder which returns the biggest match position in decimal ///////////////////////////////////////////	
    priority_enc 
       #(
    	    .ENCODER_DEPTH(DICTIONARY_DEPTH),
			.log2N(DICTIONARY_DEPTH_LOG)
    	)
		PRIO_ENC
    	(
		    .rst_n,
			.clk,
    	    .A_IN(match_PE),              // Input Vector
    	    .P(match_position),           // High Priority Index
    	    .F(match_position_valid)      // This is used when the match is on position 0
    	);
		
	
	/////////////////////////////////////////// State machine used to command the data processing elements ///////////////////////////////////////////
	
	
	
/*	// Sequential part of the state machine
	always @(posedge clk or negedge rst_n)
	begin
	    if (rst_n) state <= 5'd0;
		else       state <= next_state;
	end
	
	// Combinational part of the state machine
	always @(*)
	begin
	    shift_en = 0;
		next_state = IDLE;
	    case(state)
	        IDLE   :
                begin 
				    if (data_valid) next_state = SHIFT;
					shift_en = 0;
				end 
			SHIFT  : 
			    begin 
				    if (!data_valid) next_state = IDLE;
				    shift_en = 1;				
				end
			//ENCODE :
			default : next_state = IDLE;
	    endcase
	end  */
	
	
	
	
	

	
endmodule




