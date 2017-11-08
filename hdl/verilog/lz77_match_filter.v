// This module has a 3 level pipeline to make the LZ77 encoder output only matches
// greater than 3 characters in the data stream.

//`include "functions.v"

//`define MAX_LENGTH 9'd258

//`define REMOVE_ME

module lz77_match_filter
    #( 
     	parameter DATA_WIDTH = 8,
		parameter DICTIONARY_DEPTH_LOG = 16,
		parameter CNT_WIDTH = 9     // The counter size must be changed according to the maximum match length
	)
    (
    // Module inputs
    input clk,	
    input rst_n,
    input [DICTIONARY_DEPTH_LOG-1:0] match_position,
	input [CNT_WIDTH-1:0]            match_length,
	input [DATA_WIDTH-1:0]           next_symbol,
	input output_enable_in,	
    input gzip_last_symbol,
	
    // Module outputs 
	output reg [2 :0] lz77_filt_pad_bits, // after all data is written in the output module then the control state machine should pad with zeros until byte boundary
    output reg        lz77_filt_valid,  
    //output reg        lz77_filt_last,
    output reg [6 :0] lz77_filt_size,     // maximum length can be 32 bits
	output reg [63:0] lz77_filt_data      // 64 bits of data (maximum 40/36 will be used one time)
    );

	// Module parameters
	localparam [4:0] IDLE          = 6'b000001,
	                 MATCH_LENGTH0 = 6'b000010,
	                 MATCH_LENGTH1 = 6'b000100,
	                 MATCH_LENGTH2 = 6'b001000,
                     MATCH_LENGTH3 = 6'b010000,
                     MATCH_EOF     = 6'b100000;
					
    localparam MATCH_POS_ZEROS = 16 - DICTIONARY_DEPTH_LOG;
    localparam MATCH_LEN_ZEROS = 9 - CNT_WIDTH;
	
    `ifdef REMOVE_ME
        reg [8*12:1] text_lz77_filter = "nimic";
    `endif
	
					
	// Registers 
	reg [DICTIONARY_DEPTH_LOG-1:0] match_position_buff0; 
	reg [CNT_WIDTH-1:0]            match_length_buff0;
	reg [DATA_WIDTH-1:0]           next_symbol_buff0, next_symbol_buff1, next_symbol_buff2;
    reg [5:0] state;
    reg [5:0] next_state, next_state_decoder;
	//reg [1:0] cnt_states, cnt_states_next;
	reg output_enable;
	 
	reg [8:0] sliteral_data_buff1;
	reg [8:0] sliteral_data_buff2;
	reg [3:0] sliteral_valid_bits_buff1;
	reg [3:0] sliteral_valid_bits_buff2;
	
	reg gzip_last_symbol_buff;
	reg output_enable_in_buff;
	reg match_length_eq3_with_string;
	
	reg previous_match_length3_ff;
	reg [8:0] previous_match_length3_sliteral_buff;
	reg [3:0] previous_match_length3_sliteral_valid_bits_buff;
	
	wire [4:0] sliteral_valid_bits_sum; 
	
	// Combinational logic
	wire match_length_eq0;
	wire match_length_eq1;
	wire match_length_eq2;
	wire match_length_eq3;
	
	//wire  [8:0] sliteral_in,                    // 9bits 
	//input  literal_valid_in,                    // literal_valid_in is used to enable the conversion of the lengths
	wire         slength_valid_out;
	wire [12:0]  slength_data_out;
	wire [3:0]   slength_valid_bits; 
	
	wire         sdht_data_valid_out;
	wire [17:0]  sdht_data_merged;   
	wire [4 :0]  sdht_valid_bits;
	
    // Module outputs
	wire        slit_i0_valid_out;
	wire [8:0]  slit_i0_data;                     // 9 bits Huffman
    wire [3:0]  slit_i0_valid_bits; 	

	
	// These other signals are used to determine if the encoder should output the data unencoded
	assign match_length_eq0     = (match_length == 0);
    assign match_length_eq1     = (match_length == 1);
    assign match_length_eq2     = (match_length == 2);
    assign match_length_eq3     = ~(match_length_eq0 | match_length_eq1 | match_length_eq2);  // you are in the 3'rd state if 0, 1 and 2 are inactive


	//====================================================================================================================
	//========================= Static Huffman trees for literals, distance and lengths ==================================
	//====================================================================================================================

    //========================= Huffman static literals tree =========================
    sliteral sliteral_i0
    (
    // Module inputs
    .clk,	
    .rst_n,	
	.literal_in         ( next_symbol      ),  // 9bits
	//.literal_valid_in   ( 1'b1             ),  // literal_valid_in is used to enable the conversion of the lengths. always enabled to have the past two values calculated if needed
    .gzip_last_symbol,	
	
    // Module outputs
	//.sliteral_valid_out (slit_i0_valid_out ),
	//.sliteral_valid_out (  ),                  // leave this unconnected because we don't need it
	.sliteral_data      (slit_i0_data      ),  // 9 bits Huffman
    .sliteral_valid_bits(slit_i0_valid_bits)   // this output says how many binary encoded bits are valid from the output of the decoder 
    );

	// Make 2 buffers for the SLITERAL values and data widths. These will be used to memorize the last 2 values.
    always @(posedge clk or negedge rst_n)
	begin
	    if(!rst_n) begin                           
		    sliteral_data_buff1       <= 0;
		    sliteral_data_buff2       <= 0;
			sliteral_valid_bits_buff1 <= 0;
			sliteral_valid_bits_buff2 <= 0;	
		end
		else begin
		    sliteral_data_buff1       <= slit_i0_data;
		    sliteral_data_buff2       <= sliteral_data_buff1;
			sliteral_valid_bits_buff1 <= slit_i0_valid_bits;
			sliteral_valid_bits_buff2 <= sliteral_valid_bits_buff1;
		end
	end	
	  

	//assign sliteral_valid_bits_sum = sliteral_valid_bits_buff1 + slit_i0_valid_bits; // OLD version
	assign sliteral_valid_bits_sum = sliteral_valid_bits_buff1 + sliteral_valid_bits_buff2; 
	
	// Make 1 buffer for gzip_last_symbol to cover the MATCH_LENGTH3 case. (a match >= 3 is the last and no character comes after it)
    always @(posedge clk or negedge rst_n)
	begin
	    if(!rst_n) begin                           
		    gzip_last_symbol_buff <= 0;
			output_enable_in_buff <= 0;
		end
		else begin
		    gzip_last_symbol_buff <= gzip_last_symbol;
			output_enable_in_buff <= output_enable_in;
		end
	end		
	
	//========================= Huffman static lengths tree =========================
    slength slength_i0
    (
    // Module inputs
    .clk,	
    .rst_n,	
	.match_length_in      ( { {MATCH_LEN_ZEROS{1'b0}} ,match_length } ),                      // 9bits: 3 <= match_length  <= 258   
	//.match_length_valid_in( next_state_decoder == MATCH_LENGTH3 ),    // This module is enabled only when match_length >= 3 
	
    // Module outputs
	//.slength_valid_out  (   ),
	.slength_data_out,                          // 13 bits { <7/8bit Huffman>, 5 extra bit binary code}
    .slength_valid_bits                            // this output says how many binary encoded bits are valid from the output of the decoder 
    );	
	
	
	//========================= Huffman static distance tree =========================
    sdht sdht_i0                                   // FIXME - there is a problem with huffman decoders
    (
    // Module inputs
    .clk,	
    .rst_n,
	.match_pos_in      ( { {MATCH_POS_ZEROS{1'b0}}, match_position } ),
	//.match_pos_valid_in( next_state_decoder == MATCH_LENGTH3 ),  
	
    // Module outputs
	//.sdht_data_valid_out(   ),             // unconnected
	.sdht_data_merged,                     // 18 bits { <5bit Huffman>, 13 bit binary code}
    .sdht_valid_bits                       // this output says how many binary encoded bits are valid from the output of the decoder 
    );	
	
	//========================= Flip-Flops used to buffer internal logic  =========================
	// This flop is set only when we have a MATCH_LENGTH3 state and the output_en was set 
    always @(posedge clk or negedge rst_n)
	begin
	    if(!rst_n)                          
		    match_length_eq3_with_string <= 0;
		else if ((state == MATCH_LENGTH3) && output_enable_in_buff)
		    match_length_eq3_with_string <= 1;
        else if (state == IDLE || state == MATCH_LENGTH0)                            
            match_length_eq3_with_string <= 0;
	end	

	
	//====================================================================================================================
	//============================================ State machine sequencing ==============================================
	//====================================================================================================================	
	// Combinational logic for output selection
	// The output corner cases are :   out_en   |   match_length     | Result
	//                                    0     |        x           | next_symbol[n]
	//                                    1     |        0           | Output next_symbol[n]  
	//                                    1     |        1           | Output next_symbol[n], next_symbol[n-1]
	//                                    1     |        2           | Output next_symbol[n], next_symbol[n-1], next_symbol[n-2]
	//                                    1     |        >= 3        | Output next_symbol[n], match_position, match_position_valid=1
	//                                    1     |        =MAX_SIZE   | Output next_symbol[n], match_position, match_position_valid=1 -- FIXME - not sure	
	
    // Sequential part of the state machine
	always @(posedge clk or negedge rst_n)
	begin
	    if (!rst_n) state <= IDLE;
	    else        state <= next_state;
	end

	// Combinational next_state decoder
	always @(*)
	begin
		//if (output_enable_in | gzip_last_symbol) begin
		if (gzip_last_symbol) begin
		    if      (match_length_eq1) next_state_decoder = MATCH_LENGTH1;  // this is used for the case when the text ends with a match of 1 or 2 and 7'b0 has to be appended
		    else if (match_length_eq2) next_state_decoder = MATCH_LENGTH2;
		    else if (match_length_eq3) next_state_decoder = MATCH_LENGTH3;
		    else                       next_state_decoder = MATCH_EOF;
		end
		else if (output_enable_in) begin
		       if      (match_length_eq0) next_state_decoder = MATCH_LENGTH0;
		       else if (match_length_eq1) next_state_decoder = MATCH_LENGTH1; 
		       else if (match_length_eq2) next_state_decoder = MATCH_LENGTH2; 
 		       else                       next_state_decoder = MATCH_LENGTH3; 
            end
        else 
            next_state_decoder = IDLE;		    
	end
	
    // Combinational part of the state machine	
	always @(*)
    begin
	    next_state           = IDLE;
	
        lz77_filt_valid      = 0;
        lz77_filt_size       = 0;
        lz77_filt_data       = 0;
		
	    //cnt_states_next      = 0;
		
        case (state)
		    IDLE          : begin	

			    `ifdef REMOVE_ME text_lz77_filter ="IDLE"; `endif
	            next_state = next_state_decoder;
				
			end
			
            MATCH_LENGTH0 : begin                    // This treats the case when a character is new in the dictionary
			
			    `ifdef REMOVE_ME text_lz77_filter ="MATCH_LENGTH0"; `endif
				lz77_filt_valid    = 1;
				
				lz77_filt_size     = match_length_eq3_with_string ? slit_i0_valid_bits + sliteral_valid_bits_buff1                    : slit_i0_valid_bits;
				lz77_filt_data     = match_length_eq3_with_string ? (slit_i0_data << sliteral_valid_bits_buff1) | sliteral_data_buff1 : slit_i0_data;		
				
				next_state         = next_state_decoder;
				
			end

			MATCH_LENGTH1 : begin                   // This treats the case when a character has occured 1 time in the dictionary (even if it is found at multiple positions)
				
				`ifdef REMOVE_ME text_lz77_filter ="MATCH_LENGTH1"; `endif
				lz77_filt_valid   = 1;				
				if (previous_match_length3_ff) begin // Used for Pointer -> MATCH_LENGTH1 transitions
                   lz77_filt_size = slit_i0_valid_bits + sliteral_valid_bits_buff1 + previous_match_length3_sliteral_valid_bits_buff;
				   lz77_filt_data = (((slit_i0_data << sliteral_valid_bits_buff1) | sliteral_data_buff1) << previous_match_length3_sliteral_valid_bits_buff)
				                    | previous_match_length3_sliteral_buff;	
				end
				else begin
				   lz77_filt_size = slit_i0_valid_bits + sliteral_valid_bits_buff1;
				   lz77_filt_data = (slit_i0_data << sliteral_valid_bits_buff1) | sliteral_data_buff1;				
				end 
				next_state        = next_state_decoder;
				
			end
			
            MATCH_LENGTH2 : begin                   // This treats the case when a 2 character string is found in the dictionary 
			
			    `ifdef REMOVE_ME text_lz77_filter ="MATCH_LENGTH2"; `endif
				lz77_filt_valid   = 1;
				if (previous_match_length3_ff) begin  // Used for Pointer -> MATCH_LENGTH2 transitions
                   lz77_filt_size = slit_i0_valid_bits + sliteral_valid_bits_buff1 + sliteral_valid_bits_buff2 + previous_match_length3_sliteral_valid_bits_buff;
				   lz77_filt_data = (((slit_i0_data << sliteral_valid_bits_sum) | (sliteral_data_buff1 << sliteral_valid_bits_buff2) | sliteral_data_buff2) 
				                    << previous_match_length3_sliteral_valid_bits_buff) | previous_match_length3_sliteral_buff;
				end
				else begin
                   lz77_filt_size = slit_i0_valid_bits + sliteral_valid_bits_buff1 + sliteral_valid_bits_buff2;
				   lz77_filt_data = (slit_i0_data << sliteral_valid_bits_sum) | (sliteral_data_buff1 << sliteral_valid_bits_buff2) | sliteral_data_buff2;	
				end 
				next_state = next_state_decoder;
	
			end
			
			MATCH_LENGTH3 : begin                   // If more than 3 characters are found to match then a <length, backward distance> pair is output, 
			                                        // length is drawn from (3..258) and the distance is drawn from (1 ... 32,768)
				`ifdef REMOVE_ME text_lz77_filter = "MATCH_LENGTH3"; `endif									 
                lz77_filt_valid    = 1;
				if (previous_match_length3_ff) begin  // Used for Pointer -> Pointer transitions
				    lz77_filt_size = sdht_valid_bits + slength_valid_bits + previous_match_length3_sliteral_valid_bits_buff;
					lz77_filt_data = (((sdht_data_merged << slength_valid_bits) | slength_data_out) << previous_match_length3_sliteral_valid_bits_buff) 
					                 | previous_match_length3_sliteral_buff;
			    end 
				else begin
     				lz77_filt_size = sdht_valid_bits + slength_valid_bits; 											  
				    lz77_filt_data = (sdht_data_merged << slength_valid_bits) | slength_data_out;											  
                end
				
				if (gzip_last_symbol_buff) 
				    next_state = MATCH_EOF;
			    else
				    next_state = next_state_decoder;
			    
			end  

            MATCH_EOF : begin                    // This treats the case when the EOF character has to be inserted (EOF = 256 or 7'b0 Huffman code) 
			
			    `ifdef REMOVE_ME text_lz77_filter = "MATCH_EOF"; `endif
				lz77_filt_valid    = 1;
                lz77_filt_size     = match_length_eq3_with_string ? sliteral_valid_bits_buff1 + 7             : 7;
				lz77_filt_data     = match_length_eq3_with_string ? (slit_i0_data  << sliteral_valid_bits_buff1) | sliteral_data_buff1 : 7'b0;
				
				next_state         = IDLE;
				
			end
              
		    default : next_state = IDLE;
			
        endcase
    end	
	
	// This flop is used for treating the output scenario when 2 pointers are consecutive: MATCH_LENGTH3 -> IDLE -> MATCH_LENGTH3
	always @(posedge clk or negedge rst_n)
	begin
	    if (!rst_n) begin 
      		previous_match_length3_ff  <= 1'b0;
		end 		
		else if (state == MATCH_LENGTH3) begin
         	previous_match_length3_ff <= 1'b1;
	    end 
	    else if (state != MATCH_LENGTH3 && state != IDLE) begin
		    previous_match_length3_ff <= 1'b0;
	    end
	end	

	// These buffers are liked with previous_match_length3_ff for storing the value of the LITERAL from the previous pointer
	always @(posedge clk or negedge rst_n)
	begin
	    if (!rst_n) begin 
	        previous_match_length3_sliteral_buff            <= 9'd0;
			previous_match_length3_sliteral_valid_bits_buff <= 4'b0;
		end 		
		else if (state == MATCH_LENGTH3) begin
			previous_match_length3_sliteral_buff            <= slit_i0_data;      // update this value each time a new pointer is detected
			previous_match_length3_sliteral_valid_bits_buff <= slit_i0_valid_bits;
	    end
	end	

	
	// This is used to count the remainder of all lz77_filt_size during the compression process
	always @(posedge clk or negedge rst_n)
	begin
	    if (!rst_n)               lz77_filt_pad_bits[2:0] <= 3'd3;      // the reset value is 3 because of the 3 bits of BTYPE, BFINAL which are not aligned to a byte boundary
	    else if (lz77_filt_valid) lz77_filt_pad_bits[2:0] <= lz77_filt_pad_bits[2:0] + lz77_filt_size[2:0];
	end

	
	
endmodule
