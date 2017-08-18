/*  
Title:            Deflate output module
Author:                                     Ovidiu Plugariu

Description:  This module takes data from the gzip_top module and packs it according to RFC1952.
            Each block of compressed data begins with 3 header bits containing the following data:
                first bit       BFINAL
                next 2 bits     BTYPE

            Note that the header bits do not necessarily begin on a byte boundary, since a block does not 
			necessarily occupy an integral number of bytes.
			
            I) Uncompressed data (btype = 00) has the following format:
				
                  0   1   2   3   4...
                +---+---+---+---+================================+
                |  LEN  | NLEN  |... LEN bytes of literal data...|
                +---+---+---+---+================================+
                
                LEN is the number of data bytes in the block.  NLEN is the
                one's complement of LEN.	


            After all data blocks are in the output stream this block adds
              0   1   2   3   4   5   6   7
            +---+---+---+---+---+---+---+---+
            |     CRC32     |     ISIZE     |
            +---+---+---+---+---+---+---+---+
            CRC32 = applied to input data stream compliant with ISO 3309
			ISIZE = This contains the size of the original (uncompressed) input data modulo 2^32.
*/


//`include "functions.v"

`define IDLE              7'b000_0001
`define START_OF_BLOCK    7'b000_0010

`define BLOCK_LEN         7'b000_0100
`define UNCOMP_DATA       7'b000_1000


`define CRC32             7'b010_0000
`define ISIZE             7'b100_0000

`define NO_COMRESSION      2'b00
`define FIXED_HUFFMAN      2'b01

`define REMOVE_ME 

module gzip_output
 /*   #( 
     	parameter DATA_WIDTH = 8,
        //parameter INPUT_BUFFER_DEPTH = 3;
        parameter DICTIONARY_DEPTH = 16,
		parameter DICTIONARY_DEPTH_LOG = 4,
		parameter LOOK_AHEAD_BUFF_DEPTH = 8,
		parameter CNT_WIDTH = 3     // The counter size must be changed according to the maximum match length

	) */
    (
    // Module inputs
    input        clk,	
    input        rst_n,
    input        bfinal,                              // Inputs used for both types of supported blocks
    input [1 :0] btype,
    input [15:0] block_size,	
	input        state_load_byte,                     // This state shows that 8bits of data are processed from input FIFO	         
    input [7 :0] data_in_no_compress,                 // Input for data in umcompressed mode
    input [31:0] crc32,  
	input [31:0] isize,
	input        state_get_block_header,              // state decoders from gzip_top
	input        state_end_of_block,
	

    // Module outputs
	output reg    gzip_out_ready,                     // used to synchronize the gzip_top module
    output [31:0] gzip_data_out,
    output        wr_en_fifo_out               
    );

    `ifdef REMOVE_ME
        reg [8*15:1] text = "nimic";
    `endif	

	// Module registers
	reg [6:0] state;
	reg [6:0] next_state;
	reg word_merge_in_valid;
	reg word_merge_in_last;
	reg [5:0]  word_merge_in_size;
    reg [31:0] word_merge_in_data; 
	reg isize_stay;

	// Combinational logic
	wire state_isize      ;
	wire state_start_block;
	
	
	// The input data must be reordered and put inside a 4x8bit shift register to be fed to the LZ77_encoder/decoder
    //// Create the state sequencer
    always @(posedge clk or negedge rst_n)
	begin
        if(!rst_n)
    	    state <= `IDLE;
    	else
    	    state <= next_state;
	end
 

    //// Create the next_state sequencer
    always @( * )
    begin
        next_state          <= `IDLE;
        //wr_en             <= 0;            // write_en for the output FIFO
		word_merge_in_valid <= 0;
		word_merge_in_last  <= 0;
		word_merge_in_size  <= 0;
		word_merge_in_data  <= 0;
		
        case ( state )
            `IDLE           : begin 
    		                    `ifdef REMOVE_ME text <= "IDLE" ; `endif 
								
                                if      (state_get_block_header) next_state <= `START_OF_BLOCK;   // every type of block has to start with the 3 bits of data  
                                else if (state_load_byte) begin
								    word_merge_in_valid   <= 1;                                   // we need to load the first data byte already in the IDLE state
							    	word_merge_in_size    <= 6'd8;
								    word_merge_in_data    <= {24'b0, data_in_no_compress};	
									
								    next_state            <= `UNCOMP_DATA;									
                                end									
    		                end

            `START_OF_BLOCK : begin
			                    `ifdef REMOVE_ME text <= "START_OF_BLOCK" ; `endif 
								
							    word_merge_in_valid   <= 1;
								word_merge_in_size    <= (btype == `NO_COMRESSION) ? 6'd8 : 6'd3; // For blocks in STORED mode (BTYPE==00) you have to go to a byte boundary
								word_merge_in_data    <= {29'b0,{btype, bfinal}};
                                next_state            <= `BLOCK_LEN;
			                end
            
			`BLOCK_LEN      : begin
			                    `ifdef REMOVE_ME text <= "BLOCK_LEN" ; `endif                     // We should go in IDLE after this state
								
								word_merge_in_valid   <= 1;
								word_merge_in_size    <= 6'd32;
								word_merge_in_data    <= {block_size, ~block_size};
                                if (state_load_byte)  next_state <= `UNCOMP_DATA;									
			                end
			
			`UNCOMP_DATA    : begin
                                `ifdef REMOVE_ME text <= "UNCOMP_DATA" ; `endif
								
								word_merge_in_valid   <= 1;
								word_merge_in_size    <= 6'd8;
								word_merge_in_data    <= {24'b0, data_in_no_compress};
								
                                if (state_load_byte)         next_state <= `UNCOMP_DATA;
								else if (state_end_of_block) next_state <= `CRC32;        // if the input block has been processed then the CRC32 and ISIZE can be output
			                end
			
			`CRC32          : begin
                                `ifdef REMOVE_ME text <= "CRC32" ; `endif
								
								word_merge_in_valid   <= 1;
								word_merge_in_size    <= 6'd32;
								word_merge_in_data    <= crc32;	
								
                                next_state            <= `ISIZE;
			                end
			
			`ISIZE         : begin
                                `ifdef REMOVE_ME text <= "ISIZE" ; `endif

								if (isize_stay)  next_state <= `IDLE;
                                else  begin          
								    word_merge_in_last    <= 1;
								    word_merge_in_valid   <= 1;
								    word_merge_in_size    <= 6'd32;
								    word_merge_in_data    <= isize;	

                                    next_state <= `ISIZE;									
								end
			                end			
						
						
    		default : begin   next_state <= `IDLE ;end    
        endcase		
    end
	
	// State decoders used in various places
	assign state_isize       = (state == `ISIZE);
	assign state_start_block = (state == `START_OF_BLOCK);	
	
	
    // This flop is used by the ISIZE state to stay 2 clock cycles to write in the output FIFO all data from word_merge
    always @(posedge clk or negedge rst_n)
	begin
        if(!rst_n) begin
             isize_stay <= 0;			
        end		   
        else if (state_isize) begin            
			 isize_stay <= ~isize_stay;
		end
		else isize_stay <= 0;
    end		

	// The GZIP top module must stop the dataflow for 2 clock cycles in order to transmit the start of block. 
	// After the START_OF_BLOCK if sent the gzip_out module can accept 8 bits of data at each clock cyle.
    always @(posedge clk or negedge rst_n)
	begin
        if(!rst_n)                  gzip_out_ready <= 0;	       
        else if (state_start_block) gzip_out_ready <= 1;            
        else                        gzip_out_ready <= 0;
    end		

	
    //====================================================================================================================	
	//========================================== Instantiate word_merge module ===========================================
	//====================================================================================================================

    word_merge word_merge_i0(
        // Module inputs
        .clock(clk),
        .reset(!rst_n),    
        .in_valid(word_merge_in_valid),
        .in_last (word_merge_in_last ), 
        .in_size (word_merge_in_size ),
        .in_data (word_merge_in_data ),
     	
     	// Module outputs
        .out_valid(wr_en_fifo_out),
        .out_last(),
        .out_bvalid(),
        .out_data(gzip_data_out)
        );
	
endmodule




