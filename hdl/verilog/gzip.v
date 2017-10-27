/*  
Title:                       Deflate compressor
Author:                                        Ovidiu Plugariu

Description:   This top module contains a synchronization module, used to pass register values between clock domains,
            and a Deflate core.
*/


module gzip
    #(      	
        parameter DICTIONARY_DEPTH = 1024,	  // the size of the GZIP window -32k
		parameter DICTIONARY_DEPTH_LOG = 10,
	    parameter LOOK_AHEAD_BUFF_DEPTH = 66,     // the max length of the GZIP match
		parameter CNT_WIDTH = 7,                  // The counter size must be changed according to the maximum match length	
        parameter DEVICE_ID = 8'hB9,
        parameter REG_INTF_TYPE = 0             //can be 0 (XILLY_LITE) or 1 (XILLY_MEM)	
	)
    (
    // Module inputs
	input bus_clock,         // the 2 clock signals
	input core_clock,
	
    // Register interface signals (only one is used, according to REG_INTF_TYPE)
    //Xillybus Lite interface
    input           reg_clk,
    input           reg_wren,
    input           reg_wstrb,
    input           reg_rden,
    output [31:0]   reg_rd_data,
    input [31:0]    reg_wr_data,
    input [31:0]    reg_addr,
    output          reg_irq,

    //Xillybus Mem interface
    input             user_r_mem_8_rden,
    output            user_r_mem_8_empty,
    output reg [7:0]  user_r_mem_8_data,
    output            user_r_mem_8_eof,
    output            user_r_mem_8_open,
    input             user_w_mem_8_wren,
    output            user_w_mem_8_full,
    input      [7:0]  user_w_mem_8_data,
    output            user_w_mem_8_open,
    input      [4:0]  user_mem_8_addr,
    input             user_mem_8_addr_update,

    //input FIFO signals
	input             in_fifo_open,    // The FIFOs need a special reset to communicate with the Xillybus core independent of the GZIP reset bit	
    output            in_fifo_full,
	input [31:0]      in_fifo_data,
	input             in_fifo_wren,

    //output FIFO signals
	input             out_fifo_open,
	output            out_fifo_empty, 
	input             out_fifo_rden,                      
	output [31:0]     out_fifo_data,
    output            out_fifo_eof

    );

	// Internal logic
	wire gzip_rst_n;
	wire [1:0] btype;	
    wire [95:0] debug_reg;
	wire reset_fifo;
	
   //====================================================================================================================	
   //======================================== Instantiate the Sync Registers ============================================
   //====================================================================================================================
    generate 
    if(REG_INTF_TYPE == 0) begin: reg_xilly_lite
        sync_registers #(      	
            .DEVICE_ID(DEVICE_ID)		
	    ) sync_registers_i0 (
           // the 2 clock signals
	       .clk_dst(core_clock),
           .clk_src(reg_clk),
            //interface to host	(in register interface clock domain)
           .user_r_mem_8_rden(reg_rden),
           .user_r_mem_8_empty(),
           .user_r_mem_8_data(reg_rd_data[7:0]),
           .user_r_mem_8_eof(),
           .user_r_mem_8_open(),
           .user_w_mem_8_wren(reg_wren),
           .user_w_mem_8_full(),
           .user_w_mem_8_data(reg_wr_data[7:0]),
           .user_w_mem_8_open(),
           .user_mem_8_addr(reg_addr[4:0]),
           .user_mem_8_addr_update(),
           //interface to compressor (in compressor clock domain)
	       .debug_reg(debug_reg),
           .gzip_rst_n(gzip_rst_n),
	       .btype(btype)		     // Shows how data is compressed
	                                 //     00 - no compression
                                     //     01 - compressed with fixed Huffman codes
        );
        assign reg_rd_data[31:8] = 0;
        assign reg_irq = 0;
    end else if(REG_INTF_TYPE == 1) begin: reg_xilly_mem
        sync_registers #(      	
            .DEVICE_ID(DEVICE_ID)		
	    ) sync_registers_i0 (
           // the 2 clock signals
	       .clk_dst(core_clock),
           .clk_src(bus_clock),
            //interface to host	(in register interface clock domain)
           .user_r_mem_8_rden,
           .user_r_mem_8_empty,
           .user_r_mem_8_data,
           .user_r_mem_8_eof,
           .user_r_mem_8_open,
           .user_w_mem_8_wren,
           .user_w_mem_8_full,
           .user_w_mem_8_data,
           .user_w_mem_8_open,
           .user_mem_8_addr,
           .user_mem_8_addr_update,
           //interface to compressor (in compressor clock domain)
	       .debug_reg(debug_reg),
           .gzip_rst_n(gzip_rst_n),
	       .btype(btype)		     // Shows how data is compressed
	                                 //     00 - no compression
                                     //     01 - compressed with fixed Huffman codes
        );
    end
    endgenerate
	
   //====================================================================================================================	
   //=========================================== Instantiate the GZIP core ==============================================
   //====================================================================================================================
   
   assign reset_fifo = ~in_fifo_open & ~out_fifo_open;
   
   gzip_top
       #(      	
        .DICTIONARY_DEPTH(DICTIONARY_DEPTH),	                 // the size of the GZIP window
    	.DICTIONARY_DEPTH_LOG(DICTIONARY_DEPTH_LOG)           		
        )
      gzip_top_i0
       (
       // Module inputs 
       .xilly_clk       (bus_clock),	// Xillybus clk signal  
       .clk             (core_clock),	// clk signal for all the GZIP logic  
       .rst_n           (gzip_rst_n),   // reset for the GZIP core
    
       .reset_fifo      (reset_fifo),   // reset for the FIFOs	
       .wr_en_fifo_in   (in_fifo_wren), // write_enable for the input FIFO
       .din_fifo_in     (in_fifo_data), // 32 bit data input
       .rd_en_fifo_out  (out_fifo_rden),// read_enable for the output FIFO
       .btype_in        (btype),        // Compression mode:   00 - no compression
                                        //                     01 - compressed with fixed Huffman codes
       // Module outputs
       .debug_reg       (debug_reg),
       .full_in_fifo    (in_fifo_full), // shows that we cannot write data in the input FIFO
       .dout_out_fifo_32(out_fifo_data),// 32 bit data output
       .empty_out_fifo  (out_fifo_empty)// shows that we CAN read from the output FIFO
       );

   assign out_fifo_eof = 0; 

endmodule
