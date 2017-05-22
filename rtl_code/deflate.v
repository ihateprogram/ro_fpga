/*  
Title:                       Deflate compressor
Author:                                        Ovidiu Plugariu

Description:   This top module contains control logic for the LZ77 module in order to output data
            compatible with RFC1951, or Deflate algorithm. The data is fed into the FPGA by a GZIP driver
            wich uses Xillybus to transmit/receive data in order to compress data according to RFC 1952, or 
            GZIP format. 

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

		    II) Encoded data blocks in the "deflate" format consist of sequences of symbols drawn from three conceptually
            distinct alphabets: either literal bytes, from the alphabet of byte values (0..255), or <length, backward distance> pairs,
            where the length is drawn from (3..258) and the distance is drawn from (1..32,768).  In fact, the literal and length
            alphabets are merged into a single alphabet (0..285), where values 0..255 represent literal bytes, the value 256 indicates
            end-of-block, and values 257..285 represent length codes.		
				
				
            After all data blocks are in the output stream this block adds
			
                  0   1   2   3   4   5   6   7
                +---+---+---+---+---+---+---+---+
                |     CRC32     |     ISIZE     |
                +---+---+---+---+---+---+---+---+
				
                CRC32 = applied to input data stream compliant with ISO 3309
			    ISIZE = This contains the size of the original (uncompressed) input data modulo 2^32.

*/

//`include "../rtl_code/functions.v"


//`define REMOVE_ME

module deflate
    #(      	
        parameter DICTIONARY_DEPTH = 4096,	  // the size of the GZIP window -32k
		parameter DICTIONARY_DEPTH_LOG = 12,
	    parameter LOOK_AHEAD_BUFF_DEPTH = 66,     // the max length of the GZIP match
		parameter CNT_WIDTH = 7,                   // The counter size must be changed according to the maximum match length
        parameter DATA_WIDTH = 8		
	)
    (
    // Module inputs
    input  clk,	
    input  rst_n,
    input  load_data_in,
    input  [DATA_WIDTH-1:0] gzip_data_in,
	input  gzip_last_symbol,
	
    // Module outputs 
    output        lz77_filt_valid,  
    output [5 :0] lz77_filt_size,     // maximum length can be 32 bits
	output [31:0] lz77_filt_data,      // 32 bits of data
	output [ 2:0] lz77_filt_pad_bits
    );

    // Sequential logic section
    reg [DICTIONARY_DEPTH_LOG-1:0] match_position_buf0;  // The _buff0 signals are the first stage of buffers and go in _buff1 flops
	reg [CNT_WIDTH-1:0]            match_length_buf0;
	reg [DATA_WIDTH-1:0]           next_symbol_buf0;
	reg                            output_enable_buf0;
    reg                            gzip_last_symbol_buf0;
	
    reg [DICTIONARY_DEPTH_LOG-1:0] match_position_buf1;
	reg [CNT_WIDTH-1:0]            match_length_buf1;
	reg [DATA_WIDTH-1:0]           next_symbol_buf1;
	reg                            output_enable_buf1;
    reg                            gzip_last_symbol_buf1;	
	
	//reg [DATA_WIDTH-1:0] data_in_buff ;
	//reg load_data_in_lz77  ;
	
	// Combinational logic section
    wire [DICTIONARY_DEPTH_LOG-1:0] match_position;
	wire [CNT_WIDTH-1:0]            match_length;
	wire [DATA_WIDTH-1:0]           next_symbol;
	wire output_enable;		


	
	//====================================================================================================================
	//========================= Pipeline stage between control logic and LZ77 encoder ====================================
	//====================================================================================================================
	
    /*always @(posedge clk or negedge rst_n)
	begin
	    if (!rst_n) begin 
		    load_data_in_lz77 <= 0;
		end 
	    else begin          // The LZ77 encoder should shift data in only in FIXED_HUFFMAN mode
   		    load_data_in_lz77 <= load_data_in;
	    end
    end		
   	
	// We need 2 sets of buffers to limit the fanout of the registers that provide signals to the CRC32 and LZ77 encoder
    always @(posedge clk or negedge rst_n)
	begin
	    if (!rst_n) begin
         	data_in_buff     <= 0;			
		end
	    else if (load_data_in) begin 
		    data_in_buff     <= gzip_data_in;
		end
    end */
 
	
	//====================================================================================================================
	//=========================================== Instantiate the LZ77 encoder ===========================================
	//====================================================================================================================

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
        .data_valid(load_data_in),
        .input_data(gzip_data_in),	
    
        // Module outputs
        .match_position,
    	.match_length,
    	.next_symbol,
    	.output_enable    
        );

    // Add 2 pipeline stages to limit the combinational path for between the LZ77 encoder and the match filter
    always @(posedge clk or negedge rst_n)
	begin
	    if(!rst_n) begin
            match_position_buf0 <= 0;
            match_length_buf0   <= 0;
            next_symbol_buf0    <= 0;
            output_enable_buf0  <= 0;
			gzip_last_symbol_buf0 <=0;
	    end 
	    else begin
            match_position_buf0 <= match_position; 
            match_length_buf0   <= match_length  ;
            next_symbol_buf0    <= next_symbol   ;
            output_enable_buf0  <= output_enable ;
			gzip_last_symbol_buf0 <= gzip_last_symbol;
	    end
	end
	
    always @(posedge clk or negedge rst_n)
	begin
	    if(!rst_n) begin
            match_position_buf1 <= 0;
            match_length_buf1   <= 0;
            next_symbol_buf1    <= 0;
            output_enable_buf1  <= 0;
			gzip_last_symbol_buf1 <= 0;
	    end 
	    else begin
            match_position_buf1 <= match_position_buf0 + 1; // The addition is performed here to limit the size of the combinational circuit
            match_length_buf1   <= match_length_buf0  ;
            next_symbol_buf1    <= next_symbol_buf0   ;
            output_enable_buf1  <= output_enable_buf0 ;
			gzip_last_symbol_buf1 <= gzip_last_symbol_buf0;
	    end
	end	
	
	
    //====================================================================================================================	
	//============================================ Instantiate the LZ77 filter ===========================================
    //====================================================================================================================
	
    lz77_match_filter
        #( 
            .DATA_WIDTH          (DATA_WIDTH          ),
            .CNT_WIDTH           (CNT_WIDTH           ),
            .DICTIONARY_DEPTH_LOG(DICTIONARY_DEPTH_LOG)
	    )
	    lz_filt_i0
        (
        // Module inputs
        .clk,	
        .rst_n,		
        .match_position  (match_position_buf1),
	    .match_length    (match_length_buf1  ),
	    .next_symbol     (next_symbol_buf1   ),
	    .output_enable_in(output_enable_buf1 ),
        .gzip_last_symbol(gzip_last_symbol_buf1),		
		
        // Module outputs
		.lz77_filt_pad_bits,
        .lz77_filt_valid,
        .lz77_filt_size,
	    .lz77_filt_data 
        );

	

endmodule
