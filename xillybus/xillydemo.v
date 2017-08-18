module xillydemo
  (
   input  PCIE_PERST_B_LS,
   input  PCIE_REFCLK_N,
   input  PCIE_REFCLK_P,
   input [3:0] PCIE_RX_N,
   input [3:0] PCIE_RX_P,
   output [3:0] GPIO_LED,
   output [3:0] PCIE_TX_N,
   output [3:0] PCIE_TX_P
   );
   // Clock and quiesce
   wire 	bus_clk;
   wire 	quiesce;
   
   // Memory array
   reg [7:0] 	demoarray[0:31];

   
   // Wires related to /dev/xillybus_mem_8
   wire       user_r_mem_8_rden;
   wire       user_r_mem_8_empty;
   reg [7:0]  user_r_mem_8_data;
   wire       user_r_mem_8_eof;
   wire       user_r_mem_8_open;
   wire       user_w_mem_8_wren;
   wire       user_w_mem_8_full;
   wire [7:0] user_w_mem_8_data;
   wire       user_w_mem_8_open;
   wire [4:0] user_mem_8_addr;
   wire       user_mem_8_addr_update;

   // Wires related to /dev/xillybus_read_32
   wire       user_r_read_32_rden;
   wire       user_r_read_32_empty;
   wire [31:0] user_r_read_32_data;
   wire        user_r_read_32_eof;
   wire        user_r_read_32_open;

   // Wires related to /dev/xillybus_read_8
   wire        user_r_read_8_rden;
   wire        user_r_read_8_empty;
   wire [7:0]  user_r_read_8_data;
   wire        user_r_read_8_eof;
   wire        user_r_read_8_open;

   // Wires related to /dev/xillybus_write_32
   wire        user_w_write_32_wren;
   wire        user_w_write_32_full;
   wire [31:0] user_w_write_32_data;
   wire        user_w_write_32_open;

   // Wires related to /dev/xillybus_write_8
   wire        user_w_write_8_wren;
   wire        user_w_write_8_full;
   wire [7:0]  user_w_write_8_data;
   wire        user_w_write_8_open;

   // Wires used to connect with the GZIP core
   wire [24+32+32+8-1:0] debug_reg;
   wire [1 :0] btype_in;
   
   xillybus xillybus_ins (

			  // Ports related to /dev/xillybus_mem_8
			  // FPGA to CPU signals:
			  .user_r_mem_8_rden(user_r_mem_8_rden),
			  .user_r_mem_8_empty(user_r_mem_8_empty),
			  .user_r_mem_8_data(user_r_mem_8_data),
			  .user_r_mem_8_eof(user_r_mem_8_eof),
			  .user_r_mem_8_open(user_r_mem_8_open),

			  // CPU to FPGA signals:
			  .user_w_mem_8_wren(user_w_mem_8_wren),
			  .user_w_mem_8_full(user_w_mem_8_full),
			  .user_w_mem_8_data(user_w_mem_8_data),
			  .user_w_mem_8_open(user_w_mem_8_open),

			  // Address signals:
			  .user_mem_8_addr(user_mem_8_addr),
			  .user_mem_8_addr_update(user_mem_8_addr_update),


			  // Ports related to /dev/xillybus_read_32
			  // FPGA to CPU signals:
			  .user_r_read_32_rden(user_r_read_32_rden),
			  .user_r_read_32_empty(user_r_read_32_empty),
			  .user_r_read_32_data(user_r_read_32_data),
			  .user_r_read_32_eof(user_r_read_32_eof),
			  .user_r_read_32_open(user_r_read_32_open),

			  // Ports related to /dev/xillybus_write_32
			  // CPU to FPGA signals:
			  .user_w_write_32_wren(user_w_write_32_wren),
			  .user_w_write_32_full(user_w_write_32_full),
			  .user_w_write_32_data(user_w_write_32_data),
			  .user_w_write_32_open(user_w_write_32_open),

			  // Ports related to /dev/xillybus_read_8
			  // FPGA to CPU signals:
			  .user_r_read_8_rden(user_r_read_8_rden),
			  .user_r_read_8_empty(user_r_read_8_empty),
			  .user_r_read_8_data(user_r_read_8_data),
			  .user_r_read_8_eof(user_r_read_8_eof),
			  .user_r_read_8_open(user_r_read_8_open),

			  // Ports related to /dev/xillybus_write_8
			  // CPU to FPGA signals:
			  .user_w_write_8_wren(user_w_write_8_wren),
			  .user_w_write_8_full(user_w_write_8_full),
			  .user_w_write_8_data(user_w_write_8_data),
			  .user_w_write_8_open(user_w_write_8_open),


			  // Signals to top level
			  .PCIE_PERST_B_LS(PCIE_PERST_B_LS),
			  .PCIE_REFCLK_N(PCIE_REFCLK_N),
			  .PCIE_REFCLK_P(PCIE_REFCLK_P),
			  .PCIE_RX_N(PCIE_RX_N),
			  .PCIE_RX_P(PCIE_RX_P),
			  .GPIO_LED(GPIO_LED),
			  .PCIE_TX_N(PCIE_TX_N),
			  .PCIE_TX_P(PCIE_TX_P),
			  .bus_clk(bus_clk),
			  .quiesce(quiesce)
			  );

   // A simple inferred RAM
   // Add extra logic to Read/Write the GZIP core registers 
    always @(posedge bus_clk)
    begin
	    if (user_w_mem_8_wren)
	      demoarray[user_mem_8_addr] <= user_w_mem_8_data;
	    
	    if (user_r_mem_8_rden)
	      user_r_mem_8_data <= demoarray[user_mem_8_addr];
        
            if (user_r_mem_8_rden) begin   
                if     ( user_mem_8_addr == 5'd0 ) user_r_mem_8_data <= {7'b0,demoarray[0][0]};     // RESETN bit
	        	else if( user_mem_8_addr == 5'd1 ) user_r_mem_8_data <= {6'b0,demoarray[1][1:0]};   // BTYPE[1:0]
				
	        	else if( user_mem_8_addr == 5'd2 ) user_r_mem_8_data <= debug_reg[8*1-1:   0]  ;  // gzip_done, btype_error, block_size_error
				
	        	else if( user_mem_8_addr == 5'd3 ) user_r_mem_8_data <= debug_reg[8*5-1: 8*4]  ;  // ISIZE[31:24]
	        	else if( user_mem_8_addr == 5'd4 ) user_r_mem_8_data <= debug_reg[8*4-1: 8*3]  ;  // ISIZE[23:16]
	        	else if( user_mem_8_addr == 5'd5 ) user_r_mem_8_data <= debug_reg[8*3-1: 8*2]  ;  // ISIZE[15: 8] 
	        	else if( user_mem_8_addr == 5'd6 ) user_r_mem_8_data <= debug_reg[8*2-1: 8*1]  ;  // ISIZE[7 : 0]
				
	        	else if( user_mem_8_addr == 5'd7 ) user_r_mem_8_data <= debug_reg[8*9-1: 8*8]  ;  // CRC32[31:24]
	        	else if( user_mem_8_addr == 5'd8 ) user_r_mem_8_data <= debug_reg[8*8-1: 8*7]  ;  // CRC32[23:16]
	        	else if( user_mem_8_addr == 5'd9 ) user_r_mem_8_data <= debug_reg[8*7-1: 8*6]  ;  // CRC32[15: 8]
	        	else if( user_mem_8_addr == 5'd10) user_r_mem_8_data <= debug_reg[8*6-1: 8*5]  ;  // CRC32[7 : 0] 
				
	        	else if( user_mem_8_addr == 5'd11) user_r_mem_8_data <= debug_reg[8*12-1: 8*11] ;   // block_size[23:16]  
	        	else if( user_mem_8_addr == 5'd12) user_r_mem_8_data <= debug_reg[8*11-1: 8*10] ;   // block_size[15: 8]  
	        	else if( user_mem_8_addr == 5'd13) user_r_mem_8_data <= debug_reg[8*10-1: 8*9]  ;   // block_size[7 : 0]
				
	        	else if( user_mem_8_addr == 5'd14) user_r_mem_8_data <= 8'hB5;  // DEV_ID  	
				
	            else                               user_r_mem_8_data <= demoarray[user_mem_8_addr];
           end
    end
   assign  user_r_mem_8_empty = 0;
   assign  user_r_mem_8_eof = 0;
   assign  user_w_mem_8_full = 0;

   
   //====================================================================================================================	
   //=========================================== Instantiate the GZIP core ==============================================
   //====================================================================================================================

   
   gzip_top
       #(      	
        .DICTIONARY_DEPTH(512),	                 // the size of the GZIP window
    	.DICTIONARY_DEPTH_LOG(9)           		
        )
      gzip_top_i0
       (
       // Module inputs 
       .clk           (bus_clk        ),	         // clk signal for all the logic  
       .rst_n         (demoarray[0][0]),             // reset for the GZIP core
    
       .reset_fifo    (!user_w_write_32_open && !user_r_read_32_open), // reset for the FIFOs	
       .wr_en_fifo_in (user_w_write_32_wren),        // write_enable for the input FIFO
       .din_fifo_in   (user_w_write_32_data),        // 32 bit data input
       .rd_en_fifo_out(user_r_read_32_rden),         // read_enable for the output FIFO
       .btype_in      (demoarray[1][1:0]),           // Compression mode:	00 - no compression
                                                     //                     01 - compressed with fixed Huffman codes
       // Module outputs
       .debug_reg,
       .full_in_fifo    (user_w_write_32_full),      // shows that we cannot write data in the input FIFO
       .dout_out_fifo_32(user_r_read_32_data),       // 32 bit data output
       .empty_out_fifo  (user_r_read_32_empty)       // shows that we CAN read from the output FIFO
       );
	
	
   
   // 32-bit loopback
   /* fifo_32x512 fifo_32
     (
      .clk(bus_clk),
      .srst(!user_w_write_32_open && !user_r_read_32_open),
      .din(user_w_write_32_data),
      .wr_en(user_w_write_32_wren),
      .rd_en(user_r_read_32_rden),
      .dout(user_r_read_32_data),
      .full(user_w_write_32_full),
      .empty(user_r_read_32_empty)
      ); */

   assign  user_r_read_32_eof = 0;        // FIXME - read about how to use this signal
   
   // 8-bit loopback
   fifo_8x2048 fifo_8
     (
      .clk(bus_clk),
      .srst(!user_w_write_8_open && !user_r_read_8_open),
      .din(user_w_write_8_data),
      .wr_en(user_w_write_8_wren),
      .rd_en(user_r_read_8_rden),
      .dout(user_r_read_8_data),
      .full(user_w_write_8_full),
      .empty(user_r_read_8_empty)
      );

   assign  user_r_read_8_eof = 0;
   
endmodule
