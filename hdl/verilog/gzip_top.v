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

`define IDLE              8'd0
`define START_OF_BLOCK    8'd1
`define BLOCK_LEN         8'd2
`define LOAD_BYTE0        8'd3
`define LOAD_BYTE1        8'd4
`define LOAD_BYTE2        8'd5
`define LOAD_BYTE3        8'd6
`define END_OF_BLOCK      8'd7
`define PAD_WITH_ZEROS    8'd8
`define CRC32             8'd9
`define ISIZE             8'd10

//`define REMOVE_ME

`define NO_COMRESSION      2'b00
`define FIXED_HUFFMAN      2'b01

module gzip_top
    #(      	
        parameter DICTIONARY_DEPTH = 1024,	  // the size of the GZIP window -32k
		parameter DICTIONARY_DEPTH_LOG = 10,
	    parameter LOOK_AHEAD_BUFF_DEPTH = 66,     // the max length of the GZIP match
		parameter CNT_WIDTH = 7                   // The counter size must be changed according to the maximum match length			
	)
    (
    // Module inputs
    input        xilly_clk,                       // Xillybus clock
	input        clk,                             // GZIP core clk
    input        rst_n,
    input        reset_fifo,                      // The FIFOs need a special reset to communicate with the Xillybus core independent of the GZIP reset bit	
	input        wr_en_fifo_in,
	input [31:0] din_fifo_in,
	input        rd_en_fifo_out,
	input        rev_endianess_in,                // Changes the endianess on I/O FIFOs
	input [1 :0] btype_in,                        // Shows how data is compressed
	                                              //     00 - no compression
                                                  //     01 - compressed with fixed Huffman codes
	
    // Module outputs 
    output [95:0] debug_reg,	                  // CRC, ISIZE, other signals
    output full_in_fifo,
	output [31:0] dout_out_fifo_32,  
    output reg last_out_fifo_32,
	output empty_out_fifo,
	output irq
    );

    `ifdef REMOVE_ME
        reg [8*12:1] text_gzip_top = "empty";
    `endif
	
	// Parameter section
	localparam DATA_WIDTH = 8;
	
	// Register section
	reg [DATA_WIDTH-1:0] buff_in3, buff_in2, buff_in1, buff_in0;
	reg [7:0] data_in_buff ;
	reg [7:0] data_in_crc_buff;
	reg load_data_in_crc_buff ;
    reg [7:0] state        ;
    reg [7:0] next_state   ;
    //reg [7:0] next_state_decoder ;
	//reg read_data_word;
	reg rd_en_fifo_in ;
    reg load_data_in  ;
    reg [DATA_WIDTH-1:0] gzip_data_in;
    reg [31:0] byte_counter;

	reg block_header_received;
	reg [31:0] block_header_data;
	reg bfinal;                         // These 3 bits are the first bits in a compressed block
	reg [1:0] btype;                    // Shows how data is compressed
	                                    //     00 - no compression
                                        //     01 - compressed with fixed Huffman codes										
	reg [23:0] block_size;              // 65k for uncompressed blocks and 32k for compressed blocks
	reg [31:0] isize;                   // ISIZE = This contains the size of the original (uncompressed) input data modulo 2^32.
	
	reg word_merge_in_valid;
	reg word_merge_in_last;
	reg [5:0]  word_merge_in_size;
    reg [31:0] word_merge_in_data; 
	reg isize_stay;
	
	reg in_valid       ;
	reg in_last        ;
	reg [6:0]  in_size ;
	reg [63:0] in_data ;
	
	// Registers for debug and status
	reg block_size_error;               // when in Fixed Huffman mode the block size > 32768 or in NO_COMRESSION and > 65536
	reg btype_error;                    // when btype is other type than the 2 suported types
	
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

    //reg [DICTIONARY_DEPTH_LOG-1:0] match_position_buf1;
	reg [CNT_WIDTH-1:0]            match_length_buf2;
	reg [DATA_WIDTH-1:0]           next_symbol_buf2;
	reg                            output_enable_buf2;
    reg                            gzip_last_symbol_buf2;
	
	reg [2:0] end_block_cnt;
	reg load_data_in_lz77;
	reg load_data_in_crc32;
	reg gzip_done;
	reg gzip_last_symbol;
	
	// Combinational logic section
    wire [DICTIONARY_DEPTH_LOG-1:0] match_position;
	wire [CNT_WIDTH-1:0]            match_length;
	wire [DATA_WIDTH-1:0]           next_symbol;
	wire output_enable;		
	
	
	wire [31:0] dout_in_fifo_32;
    wire        read_input_data;
	wire        fifo_in_eof;
	wire        byte_counter_inc;
    wire        byte_counter_max;
	
	wire state_end_of_block;
	wire state_block_len;
	wire state_idle;
    wire state_pad_zeros;
	//wire state_load_byte;
	wire next_state_load_byte0;
	wire next_state_load_byte1;
	wire next_state_load_byte2;
	wire next_state_load_byte3;

	
	wire [31:0] crc32_out;
	wire [63:0] gzip_data_out;
	
	wire state_crc32;
	wire state_isize;
	wire state_start_block;
	wire out_last;
	wire btype_no_compression;
	wire btype_fixed_compression;

    wire        lz77_filt_valid;  
    wire [6 :0] lz77_filt_size;     // maximum length can be 40 bits
	wire [63:0] lz77_filt_data;     // 64 bits of data
	wire [ 2:0] lz77_filt_pad_bits;
	
	wire end_block_cnt_max;
	
	wire [31:0] din_fifo_in_mux;
	reg  [31:0] dout_fifo_out_mux;
	
    //====================================================================================================================	
	//=========================================== Instantiate the Input FIFO =============================================
	//====================================================================================================================
	
    // We can control the endianess of the 32bit FIFO input bus, this is making the IP work on any platform
	assign din_fifo_in_mux = rev_endianess_in ? {din_fifo_in[7:0], din_fifo_in[15:8], din_fifo_in[23:16], din_fifo_in[31:24]} : din_fifo_in;

    // The control logic will take care of this.	
    srl_fifo
    #(
        .WIDTH(32),
        .DEPTH_LOG(5),
        .FALLTHROUGH("false")
    )
    fifo_in_i0
    (
        .clock  (clk),
        .reset  (reset_fifo),

        .push   (wr_en_fifo_in),
        .din    (din_fifo_in_mux),
        .full   (full_in_fifo),

        .pop    (rd_en_fifo_in),
        .dout   (dout_in_fifo_32),
        .empty  (empty_in_fifo)
    );

	
    //====================================================================================================================	
	//====================================== State Machine for the input dataflow ========================================
	//====================================================================================================================
	
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
    always @(*)
    begin
        next_state          = `IDLE;
        rd_en_fifo_in       = 0;      // Logic for the input/output dataflow
    	load_data_in        = 0;
    	gzip_data_in        = 0;
		load_data_in_crc32  = 0;
    	block_header_data   = 0;
		
		word_merge_in_valid = 0;      // Logic for the word_merge module
		word_merge_in_last  = 0;
		word_merge_in_size  = 0;
		word_merge_in_data  = 0;		
		
		gzip_last_symbol    = 0;
		
        case ( state )
            `IDLE       : begin 
    		                `ifdef REMOVE_ME text_gzip_top ="IDLE"; `endif 
    		                if (!empty_in_fifo && !block_header_received) begin      // process the frame block header 
    						    next_state    = `START_OF_BLOCK;
    							rd_en_fifo_in = 1;
    						end	
                            else if (!empty_in_fifo && block_header_received) begin  // we can proceed if we have at least one byte to transmit
    						    next_state    = `LOAD_BYTE0;
    							rd_en_fifo_in = 1; 
                            end
    		            end

            `START_OF_BLOCK : begin
                            `ifdef REMOVE_ME text_gzip_top ="START_OF_BLOCK"; `endif 
							    // bytes must be swapped because they are stored in reversed order in the computer memory
								block_header_data = dout_in_fifo_32;
							    word_merge_in_valid   = 1;
								word_merge_in_size    = btype_no_compression ? 6'd8 : 6'd3; // For blocks in STORED mode (BTYPE==00) you have to go to a byte boundary
								word_merge_in_data    = {29'b0, btype[1:0], dout_in_fifo_32[24]}; // BTYPE, BFINAL - are the first 3 bits in a block
								
								if (btype_no_compression == 1)
								   next_state = `BLOCK_LEN;    //BLOCK_LEN is reached only from STORED mode
                                else 
    						       next_state = `IDLE ;								
                            end
			
			`BLOCK_LEN  :  begin
                            `ifdef REMOVE_ME text_gzip_top = "BLOCK_LEN"; `endif
								word_merge_in_valid   = 1;
								word_merge_in_size    = 6'd32;
								word_merge_in_data    = {~block_size[15:0], block_size[15:0]};
    						    if (!empty_in_fifo) begin                       
    						        next_state    = `LOAD_BYTE0 ;        // if we got more data in the FIFO we can go and transmit another 32 bytes
    						        rd_en_fifo_in = 1;
    						    end
                                else begin
    						        next_state    = `IDLE ;
                                end	
                            end
    		
    	    // If we have data in the input FIFO then we start the compression process
    		`LOAD_BYTE0 : begin 
    		                `ifdef REMOVE_ME text_gzip_top ="LOAD_BYTE0"; `endif
							
							if (btype_no_compression) begin
							    load_data_in_crc32    = 1;              // In uncompressed mode the CRC is updated only when a data byte is processed								
							    word_merge_in_valid   = 1;
							    word_merge_in_size    = 6'd8;
							    word_merge_in_data    = {24'b0, dout_in_fifo_32[7:0]};							   
							end
							else begin
							    load_data_in = 1;
    						    gzip_data_in = dout_in_fifo_32[7:0];
							end

							if (!byte_counter_max) begin                // We send data to the LZ77 encoder until EOF is detected
         					    next_state  = `LOAD_BYTE1 ;
							end                       
							else next_state = `END_OF_BLOCK ; 
    					end	
    					
    		`LOAD_BYTE1 : begin 
    		                `ifdef REMOVE_ME text_gzip_top ="LOAD_BYTE1"; `endif
							
							if (btype_no_compression) begin
							    load_data_in_crc32   = 1;								
							    word_merge_in_valid  = 1;
							    word_merge_in_size   = 6'd8;
							    word_merge_in_data   = {24'b0, dout_in_fifo_32[15:8]};							   
							end
							else begin
							    load_data_in = 1;
    						    gzip_data_in = dout_in_fifo_32[15:8];
							end 
							
							if (!byte_counter_max) begin                 // We send data to the LZ77 encoder until EOF is detected
    		                   next_state   = `LOAD_BYTE2 ;  
							end
							else next_state = `END_OF_BLOCK ;
    					end
    					
    		`LOAD_BYTE2 : begin 
    		                `ifdef REMOVE_ME text_gzip_top <="LOAD_BYTE2"; `endif
							
							if (btype_no_compression) begin
							    load_data_in_crc32    = 1;								
							    word_merge_in_valid   = 1;
							    word_merge_in_size    = 6'd8;
							    word_merge_in_data    = {24'b0, dout_in_fifo_32[23:16]};							   
							end
							else begin
							    load_data_in = 1;
    						    gzip_data_in = dout_in_fifo_32[23:16];
							end 							
							
							if (!byte_counter_max) begin                 // We send data to the LZ77 encoder until EOF is detected
    		                    next_state   = `LOAD_BYTE3;	
							end
							else next_state  = `END_OF_BLOCK ;							
    					end	
    					
    		`LOAD_BYTE3 : begin 
    		                `ifdef REMOVE_ME text_gzip_top ="LOAD_BYTE3"; `endif
							
							if (btype_no_compression) begin
							    load_data_in_crc32    = 1;								
							    word_merge_in_valid   = 1;
							    word_merge_in_size    = 6'd8;
							    word_merge_in_data    = {24'b0, dout_in_fifo_32[31:24]};							   
							end
							else begin
							    load_data_in = 1;
    						    gzip_data_in = dout_in_fifo_32[31:24];
							end
							
                            if (!byte_counter_max) begin                 // We send data to the LZ77 encoder until EOF is detected
								if (!empty_in_fifo) begin                // if we got more data in the FIFO we can go and transmit another 32 bytes
    						        next_state     = `LOAD_BYTE0 ;
    							    rd_en_fifo_in  = 1;
    						    end	
							    else next_state = `IDLE ;               // we to IDLE if we don't have data but the end of block is not reached
							
							end
							else next_state     = `END_OF_BLOCK ;
    					end
						
			`END_OF_BLOCK : begin
                            `ifdef REMOVE_ME text_gzip_top <="END_OF_BLOCK"; `endif
							if (bfinal && btype_no_compression)         next_state = `CRC32; // if we are at the last data block then we can write the CRC and the ISIZE parameters (only for no compression) 
							else if (bfinal && btype_fixed_compression) begin
							    //if (end_block_cnt_max) begin
							    if (end_block_cnt == 3'd1) begin
								   gzip_last_symbol    = 1;
								   next_state          = `END_OF_BLOCK;
								end 
								else if (end_block_cnt_max) next_state = `PAD_WITH_ZEROS;
								else                        next_state = `END_OF_BLOCK;
						    end
                        end		

			`PAD_WITH_ZEROS : begin  // We pad with zeros to byte boundry only if lz77_filt_pad_bits > 0
			                `ifdef REMOVE_ME text_gzip_top ="PAD_WITH_ZEROS"; `endif
							if (lz77_filt_pad_bits != 0) begin        /// XXXX this doesn't work. It needs to add 8 bits 
							   word_merge_in_valid = 1;
							   word_merge_in_size  = 4'd8 - lz77_filt_pad_bits;   
							   word_merge_in_data  = 32'b0;
							end 
							
							next_state = `CRC32;
			  
			            end 
			
			`CRC32      : begin
                            `ifdef REMOVE_ME text_gzip_top = "CRC32" ; `endif
							
							word_merge_in_valid = 1;
							word_merge_in_size  = 6'd32;
							word_merge_in_data  = crc32_out;	
							//word_merge_in_data  = {crc32_out[7:0], crc32_out[15:8], crc32_out[23:16], crc32_out[31:24]}; 	
							
                            next_state          = `ISIZE;
			            end
			
			`ISIZE      : begin
                            `ifdef REMOVE_ME text_gzip_top = "ISIZE" ; `endif

							if (isize_stay)  next_state = `IDLE;
                            else  begin          
							    word_merge_in_last    = 1;
							    word_merge_in_valid   = 1;
							    word_merge_in_size    = 6'd32;
							    word_merge_in_data    = isize;	
							    //word_merge_in_data    = {isize[7:0], isize[15:8], isize[23:16], isize[31:24]};	

                                next_state = `ISIZE;									
							end
			            end					
						
    		default : begin   next_state = `IDLE ;end    
        endcase		
    end
	
	// This counter is used to stay in the END_OF_BLOCK state for 6 clock cycles before writing the CRC in the output FIFO
	assign end_block_cnt_max = (end_block_cnt == 3'd7);
	
	always @(posedge clk or negedge rst_n)
	begin
	    if(!rst_n)                    end_block_cnt <= 0;		
        else if (state_end_of_block)  end_block_cnt <= end_block_cnt + 1;
		else if (end_block_cnt_max)   end_block_cnt <= 0;		
	end
	
	// If the 0x00 of EOF character is recognized the the input file has reached an end
	//assign fifo_in_eof = (dout_in_fifo_32[7:0] == `EOF) | (dout_in_fifo_32[15:8] == `EOF) | (dout_in_fifo_32[23:16] == `EOF) | (dout_in_fifo_32[31:24] == `EOF);  
	
	//====================================================================================================================
	//================================ Combinational state decoders and comparators ======================================
	//====================================================================================================================	
	// These state decoders are used un several areas in the design
	assign state_idle              = (state == `IDLE);
	assign state_block_len         = (state == `BLOCK_LEN);
	assign state_start_block       = (state == `START_OF_BLOCK);
	assign state_end_of_block      = (state == `END_OF_BLOCK);	
	assign state_crc32             = (state == `CRC32);
    assign state_isize             = (state == `ISIZE);
	assign state_pad_zeros         = (state == `PAD_WITH_ZEROS);
	
	assign next_state_load_byte0   = (next_state == `LOAD_BYTE0);
	assign next_state_load_byte1   = (next_state == `LOAD_BYTE1);
	assign next_state_load_byte2   = (next_state == `LOAD_BYTE2);
	assign next_state_load_byte3   = (next_state == `LOAD_BYTE3);
	
	assign btype_no_compression    = (btype == `NO_COMRESSION);
	assign btype_fixed_compression = (btype == `FIXED_HUFFMAN);
	
	
	//====================================================================================================================
	//========================================== Extract block size parameters ===========================================
	//====================================================================================================================	
	
	// This register is set after the frame header is received. After the LEN number of processed bytes this flop is cleared again.
    always @(posedge clk or negedge rst_n)
	begin
        if(!rst_n)
            block_header_received <= 1'b0;		
        else if (state_start_block)        // set this flop if is the first time when the header is received
	    	block_header_received <= 1'b1;
		else if (state_end_of_block)            // clear the flop when the module is   
		    block_header_received <= 1'b0;          
    end		
	
	// Extract the BFINAL and block_size for the incoming data stream
	// Byte no.     |    3   |    2   |    1   |    0   | 
	// Bit no.      |76543210|76543210|76543210|76543210|                     
	//              |xxxxxxxF|xxxxxxxx  BLOCK_LEN[15:0] |
    always @(posedge clk or negedge rst_n)
	begin
        if(!rst_n) begin
            bfinal     <= 0;
            block_size <= 0;			
        end		   
        else if (state_start_block) begin             // load the values from the RX data FIFO
            bfinal     <= block_header_data [24];
		    block_size <= block_header_data [23:0];
		end	
    end		

	// BTYPE should be set by software before operating the module
    always @(posedge clk or negedge rst_n)
	begin
        if(!rst_n) btype <= 0;				   
        else       btype <= btype_in;
    end		
	
	// At each new block updata the value of isize. We will obtain the "<file_data_length> mod 32" value. 
    always @(posedge clk or negedge rst_n)
	begin
        if(!rst_n) begin
            isize <= 0;			
        end		   
        else if (state_start_block) begin            
			isize <= isize + block_header_data [15:0];
		end	
    end		

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
	
	
	//====================================================================================================================
	//==================================== Create a counter for the processed bytes ======================================
	//====================================================================================================================
	// The counter is used to show that a block has ended.
	// When the max value is reached then the counter will be used to insert the end of block symbol. 

	// We check fot the counter maximum value only when we are processing a data byte. 
    assign byte_counter_max = ~(state_idle | state_start_block | state_end_of_block) & (byte_counter == block_size);

	//assign byte_counter_inc = (state == `LOAD_BYTE3) | (state == `LOAD_BYTE2) | (state == `LOAD_BYTE1) | (state == `LOAD_BYTE0);
	assign byte_counter_inc = next_state_load_byte0 | next_state_load_byte1 | next_state_load_byte2 | next_state_load_byte3;
	
    always @(posedge clk or negedge rst_n)
	begin
	    if (!rst_n)                      byte_counter <= 32'h0;           // the reset value must be different that 0 to avoid generating maximum condition
		else if (state_start_block) byte_counter <= 32'h0; 
		else if (byte_counter_max)       byte_counter <= 32'h0;
	    else if (byte_counter_inc)       byte_counter <= byte_counter + 1;		
    end	
	
	
	//====================================================================================================================
	//============================================ Debug and error registers =============================================
	//====================================================================================================================
    
	// Btype = 01 and block_size > 32768 then we have a error regarding block size.
    always @(posedge clk or negedge rst_n)
	begin
	    if (!rst_n)                                                   block_size_error <= 1'b0;
		else if (btype_fixed_compression && (block_size > 16'd32768)) block_size_error <= 1'b1;
        else if (btype_no_compression    && (block_size > 17'd65536)) block_size_error <= 1'b1;
    end	
	
	always @(posedge clk or negedge rst_n)
	begin
	    if (!rst_n)                                                      btype_error <= 1'b0;
		else if ((!btype_fixed_compression) && (!btype_no_compression))  btype_error <= 1'b1;
    end	
	
	// This bit shows that the last block of data has been compressed. This must be software reset.
	always @(posedge clk or negedge rst_n)
	begin
	    if (!rst_n)                  gzip_done <= 1'b0;
		else if (word_merge_in_last) gzip_done <= 1'b1;
    end	
	
	assign debug_reg = {block_size, crc32_out, isize, {5'b0, gzip_done, btype_error, block_size_error}};
	
	
	//====================================================================================================================
	//========================= Pipeline stage between control logic and LZ77 encoder ====================================
	//====================================================================================================================
	
	// The pipeline stage will improve sinthesys results and will decrease the delay through the combinational logic.
    always @(posedge clk or negedge rst_n)
	begin
	    if (!rst_n) load_data_in_crc_buff <= 0;
	    else        load_data_in_crc_buff <= load_data_in | load_data_in_crc32;
    end	

    always @(posedge clk or negedge rst_n)
	begin
	    if (!rst_n) begin 
		    load_data_in_lz77 <= 0;
		end 
	    else if (btype_fixed_compression) begin          // The LZ77 encoder should shift data in only in FIXED_HUFFMAN mode
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
    end

    always @(posedge clk or negedge rst_n)
	begin
	    if (!rst_n)	data_in_crc_buff <= 0;			
	    else        data_in_crc_buff <= btype_no_compression ? word_merge_in_data[7:0] : gzip_data_in;
    end
	
	
	//====================================================================================================================
	//=========================================== Instantiate the CRC32 module ===========================================
	//====================================================================================================================
	
	// All input data is passed through the CRC32 module, regardless if the data will be compressed or uncompressed.
	// NOTE: The user should software reset the whole GZIP compressor after all data is processed.
	crc32 crc32_i0
        (
        // Module inputs
	    .clk,
	    .rst_n,
	    .crc32_in(data_in_crc_buff),
        .crc32_valid_in(load_data_in_crc_buff),
        
	    // Module outputs
	    .crc32_out             // 32 bit value of the CRC
        );
	
	
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
        .data_valid(load_data_in_lz77),
        .input_data(data_in_buff),	
    
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
            match_position_buf0   <= 0;
            match_length_buf0     <= 0;
            next_symbol_buf0      <= 0;
            output_enable_buf0    <= 0;
			gzip_last_symbol_buf0 <= 0;
	    end 
	    else begin
            match_position_buf0   <= match_position; 
            match_length_buf0     <= match_length  ;
            next_symbol_buf0      <= next_symbol   ;
            output_enable_buf0    <= output_enable ;
			gzip_last_symbol_buf0 <= gzip_last_symbol;
	    end
	end
	
    always @(posedge clk or negedge rst_n)
	begin
	    if(!rst_n) begin
            match_position_buf1   <= 0;
            match_length_buf1     <= 0;
            next_symbol_buf1      <= 0;
            output_enable_buf1    <= 0;
			gzip_last_symbol_buf1 <= 0;
	    end 
	    else begin
            match_position_buf1   <= match_position_buf0 + 1; // The addition is performed here to limit the size of the combinational circuit
            match_length_buf1     <= match_length_buf0  ;
            next_symbol_buf1      <= next_symbol_buf0   ;
            output_enable_buf1    <= output_enable_buf0 ;
			gzip_last_symbol_buf1 <= gzip_last_symbol_buf0;
	    end
	end	

	// Add another pipeline stage to preserve coherency between match_position and the other signals. Match position has another pipeline state in the LZ77 encoder
    always @(posedge clk or negedge rst_n)
	begin
	    if(!rst_n) begin
            match_length_buf2     <= 0;
            next_symbol_buf2      <= 0;
            output_enable_buf2    <= 0;
			gzip_last_symbol_buf2 <= 0;
	    end 
	    else begin
            match_length_buf2     <= match_length_buf1   ;
            next_symbol_buf2      <= next_symbol_buf1    ;
            output_enable_buf2    <= output_enable_buf1  ;
			gzip_last_symbol_buf2 <= gzip_last_symbol_buf1;
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
        .match_position  (match_position_buf1  ),
	    .match_length    (match_length_buf2    ),
	    .next_symbol     (next_symbol_buf2     ),
	    .output_enable_in(output_enable_buf2   ),
        .gzip_last_symbol(gzip_last_symbol_buf2),		
		
        // Module outputs
		.lz77_filt_pad_bits,
        .lz77_filt_valid,
        .lz77_filt_size,
	    .lz77_filt_data 
        );

	

    //====================================================================================================================	
	//========================================== Instantiate word_merge module ===========================================
	//====================================================================================================================
	
    // This module gets data either from the LZ77 encoder or from the control state machine and packs it into 32 bit chunks.
	always @(*)
	begin
	    // In the FIXED_COMPRESSION mode the state machine must be able to write the CRC and ISIZE at the end of a block
	    if (btype_fixed_compression) begin
	        in_valid = (state_start_block || state_crc32 || state_isize || state_pad_zeros) ? word_merge_in_valid : lz77_filt_valid ;  
		    in_last  = word_merge_in_last;
		    in_size  = (state_start_block || state_crc32 || state_isize || state_pad_zeros) ? {1'b0 ,word_merge_in_size} : lz77_filt_size ;
	        in_data  = (state_start_block || state_crc32 || state_isize || state_pad_zeros) ? {32'b0,word_merge_in_data} : lz77_filt_data ;
	    end
	    else begin
	        in_valid = word_merge_in_valid;
		    in_last  = word_merge_in_last ;
		    in_size  = {1'b0 ,word_merge_in_size};  // pad because word_merge_in_size is 1 bit smaller than in_size
	        in_data  = {32'b0,word_merge_in_data};  // pad because word_merge_in_data is 32 bits smaller than in_data
	    end
	end
	
    word_merge64 word_merge_i0(
        // Module inputs
        .clock(clk),
        .reset(!rst_n),    
        .in_valid,
        .in_last ,
        .in_size ,
        .in_data ,
     	
     	// Module outputs
        .out_valid (wr_en_fifo_out),
        .out_last  (out_last),
        .out_data  (gzip_data_out)
        );
		

    //====================================================================================================================	
	//========================================== Instantiate the Output FIFO =============================================
	//====================================================================================================================
    wire rd_en_fifo_out_64;
    wire empty_out_fifo_64;
    wire [63:0] dout_out_fifo_64;
    wire out_last_fifo_64;

	srl_fifo
    #(
        .WIDTH(64+1),
        .DEPTH_LOG(4),
        .FALLTHROUGH("true")
    )
    fifo_out_i0
    (
        .clock  (clk),
        .reset  (reset_fifo),

        .push   (wr_en_fifo_out),
        .din    ({out_last,gzip_data_out}),
        .full   (full_out_fifo),

        .pop    (rd_en_fifo_out_64),
        .dout   ({out_last_fifo_64,dout_out_fifo_64}),
        .empty  (empty_out_fifo_64)
    );

    reg dout_out_fifo_64_toggle;

    always @(posedge clk)
        if(reset_fifo)
            dout_out_fifo_64_toggle <= 0;
        else if(rd_en_fifo_out)
            dout_out_fifo_64_toggle <= ~dout_out_fifo_64_toggle;

    always @(posedge clk)
        if(rd_en_fifo_out)
            if(~dout_out_fifo_64_toggle)
                dout_fifo_out_mux <= dout_out_fifo_64[31:0];
            else
                dout_fifo_out_mux <= dout_out_fifo_64[63:32];

    always @(posedge clk)
        last_out_fifo_32 <= rd_en_fifo_out & dout_out_fifo_64_toggle & out_last_fifo_64;

    assign empty_out_fifo = empty_out_fifo_64;
    assign rd_en_fifo_out_64 = dout_out_fifo_64_toggle & rd_en_fifo_out;
	assign dout_out_fifo_32 = rev_endianess_in ? {dout_fifo_out_mux[7:0], dout_fifo_out_mux[15:8], dout_fifo_out_mux[23:16], dout_fifo_out_mux[31:24]} : dout_fifo_out_mux;

	assign irq = gzip_done;

endmodule
