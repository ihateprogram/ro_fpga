/*  
Title:             Deflate compressor with CDC
Author:                                        Ovidiu Plugariu

Description:   This top module contains a synchronization module, used to pass register values between clock domains,
            and a Deflate core.
*/


module gzip_sync_reg_top
    #(      	
        parameter DICTIONARY_DEPTH = 1024,	  // the size of the GZIP window -32k
		parameter DICTIONARY_DEPTH_LOG = 10,
	    parameter LOOK_AHEAD_BUFF_DEPTH = 66,     // the max length of the GZIP match
		parameter CNT_WIDTH = 7,                  // The counter size must be changed according to the maximum match length	
        parameter DEVICE_ID = 8'hB9		
	)
    (
    // Module inputs
	input clk_src,         // the 2 clock signals
	input clk_dst,
	
    // Signals related to the RAM
    // FPGA to CPU signals:	
    input user_r_mem_8_rden,
    output            user_r_mem_8_empty,
    output     [7:0]  user_r_mem_8_data,
    output            user_r_mem_8_eof,
    output            user_r_mem_8_open,
	// CPU to FPGA signals:
    input             user_w_mem_8_wren,
    output            user_w_mem_8_full,
    input      [7:0]  user_w_mem_8_data,
    output            user_w_mem_8_open,
    input      [4:0]  user_mem_8_addr,
    input             user_mem_8_addr_update,	

	input             user_w_write_32_open,    // The FIFOs need a special reset to communicate with the Xillybus core independent of the GZIP reset bit	
	input             user_r_read_32_open, 
	input             wr_en_fifo_in,
	input [31:0]      din_fifo_in,
	input             rd_en_fifo_out,                      
	
    // Module outputs 
    output full_in_fifo,
	output [31:0] dout_out_fifo_32,  
	output empty_out_fifo
    );

	// Internal logic
	wire gzip_rst_n;
	wire [1:0] btype;	
    wire [95:0] debug_reg;
	wire reset_fifo;
	
   //====================================================================================================================	
   //======================================== Instantiate the Sync Registers ============================================
   //====================================================================================================================
   
    sync_registers
       #(      	
          .DEVICE_ID(DEVICE_ID)		
	    )
	    sync_registers_i0
       (
       // Module inputs
	   .clk_src,         // the 2 clock signals
	   .clk_dst,
	   
       // Signals related to the RAM
       // FPGA to CPU signals:	
       .user_r_mem_8_rden,
       .user_r_mem_8_empty,
       .user_r_mem_8_data,
       .user_r_mem_8_eof,
       .user_r_mem_8_open,
	   // CPU to FPGA signals:
       .user_w_mem_8_wren,
       .user_w_mem_8_full,
       .user_w_mem_8_data,
       .user_w_mem_8_open,
       .user_mem_8_addr,
       .user_mem_8_addr_update,
	   
	   // Signals from GZIP to Xillybus
	   .debug_reg,
	   
	   // Module outputs - in GZIP clock domain
       .gzip_rst_n,
	   .btype		                             // Shows how data is compressed
	                                             //     00 - no compression
                                                 //     01 - compressed with fixed Huffman codes
    );	 
	
	
   //====================================================================================================================	
   //=========================================== Instantiate the GZIP core ==============================================
   //====================================================================================================================
   
   assign reset_fifo = ~user_w_write_32_open & ~user_r_read_32_open;
   
   gzip_top
       #(      	
        .DICTIONARY_DEPTH(DICTIONARY_DEPTH),	                 // the size of the GZIP window
    	.DICTIONARY_DEPTH_LOG(DICTIONARY_DEPTH_LOG),
        .LOOK_AHEAD_BUFF_DEPTH(LOOK_AHEAD_BUFF_DEPTH),
        .CNT_WIDTH(CNT_WIDTH)		
        )
      gzip_top_i0
       (
       // Module inputs 
       .xilly_clk     (clk_src        ),	          // Xillybus clk signal  
       .clk           (clk_dst        ),	          // clk signal for all the GZIP logic  
       .rst_n         (gzip_rst_n     ),              // reset for the GZIP core
    
       .reset_fifo    , // reset for the FIFOs	
       .wr_en_fifo_in ,        // write_enable for the input FIFO
       .din_fifo_in   ,        // 32 bit data input
       .rd_en_fifo_out,        // read_enable for the output FIFO
       .btype_in      (btype),                       // Compression mode:	00 - no compression
                                                     //                     01 - compressed with fixed Huffman codes
       // Module outputs
       .debug_reg,
       .full_in_fifo    ,      // shows that we cannot write data in the input FIFO
       .dout_out_fifo_32,      // 32 bit data output
       .empty_out_fifo         // shows that we CAN read from the output FIFO
       );
		

endmodule
