/*  
Title:       Syncronization module for Read/Write registers and CDC
Author:                                                             Ovidiu Plugariu

Description:  This module is used to pass read/write register values using a 8bit RAM memory with 32 locations.
            It passes values between Xillybus and Gzip clock domains.              

*/


module sync_registers
  #(      	
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
    output reg [7:0]  user_r_mem_8_data,
    output            user_r_mem_8_eof,
    output            user_r_mem_8_open,
	// CPU to FPGA signals:
    input             user_w_mem_8_wren,
    output            user_w_mem_8_full,
    input      [7:0]  user_w_mem_8_data,
    output            user_w_mem_8_open,
    input      [4:0]  user_mem_8_addr,
    input             user_mem_8_addr_update,	
	
	// Signals from GZIP to Xillybus
	input      [95:0] debug_reg,
	
	// Module outputs - in GZIP clock domain
    output gzip_rst_n,
	output [1:0] btype		
    );
 	
   // Memory array
   reg [7:0] mem_array[0:31];

   // Module registers
   reg rst_n_src_ff;
   reg [1:0] rst_n_dst_ff;       // two stage buffer for RST_N
   
   reg [1:0] btype_src_ff;
   reg [1:0] btype_dst_ff[0:1]; // two stage buffer for BTYPE
   
   reg [95:0] debug_reg_src_ff[0:1];   // two stage buffer for debug registers from GZIP domain to Xillybus domain
   
   // A simple inferred RAM in Xillybus clock domain
   // Add extra logic to Read/Write the GZIP core registers 
    always @(posedge clk_src)
    begin
	    if (user_w_mem_8_wren)
	      mem_array[user_mem_8_addr] <= user_w_mem_8_data;
	    
	    if (user_r_mem_8_rden)
	      user_r_mem_8_data <= mem_array[user_mem_8_addr];
        
            if (user_r_mem_8_rden) begin   
                if     ( user_mem_8_addr == 5'd0 ) user_r_mem_8_data <= {7'b0,mem_array[0][0]};     // RST_N bit
	        	else if( user_mem_8_addr == 5'd1 ) user_r_mem_8_data <= {6'b0,mem_array[1][1:0]};   // BTYPE[1:0]
				
	        	else if( user_mem_8_addr == 5'd2 ) user_r_mem_8_data <= debug_reg_src_ff[1][8*1-1:   0]  ;  // gzip_done, btype_error, block_size_error
				
	        	else if( user_mem_8_addr == 5'd3 ) user_r_mem_8_data <= debug_reg_src_ff[1][8*5-1: 8*4]  ;  // ISIZE[31:24]
	        	else if( user_mem_8_addr == 5'd4 ) user_r_mem_8_data <= debug_reg_src_ff[1][8*4-1: 8*3]  ;  // ISIZE[23:16]
	        	else if( user_mem_8_addr == 5'd5 ) user_r_mem_8_data <= debug_reg_src_ff[1][8*3-1: 8*2]  ;  // ISIZE[15: 8] 
	        	else if( user_mem_8_addr == 5'd6 ) user_r_mem_8_data <= debug_reg_src_ff[1][8*2-1: 8*1]  ;  // ISIZE[7 : 0]
				
	        	else if( user_mem_8_addr == 5'd7 ) user_r_mem_8_data <= debug_reg_src_ff[1][8*9-1: 8*8]  ;  // CRC32[31:24]
	        	else if( user_mem_8_addr == 5'd8 ) user_r_mem_8_data <= debug_reg_src_ff[1][8*8-1: 8*7]  ;  // CRC32[23:16]
	        	else if( user_mem_8_addr == 5'd9 ) user_r_mem_8_data <= debug_reg_src_ff[1][8*7-1: 8*6]  ;  // CRC32[15: 8]
	        	else if( user_mem_8_addr == 5'd10) user_r_mem_8_data <= debug_reg_src_ff[1][8*6-1: 8*5]  ;  // CRC32[7 : 0] 
				
	        	else if( user_mem_8_addr == 5'd11) user_r_mem_8_data <= debug_reg_src_ff[1][8*12-1: 8*11] ; // block_size[23:16]  
	        	else if( user_mem_8_addr == 5'd12) user_r_mem_8_data <= debug_reg_src_ff[1][8*11-1: 8*10] ; // block_size[15: 8]  
	        	else if( user_mem_8_addr == 5'd13) user_r_mem_8_data <= debug_reg_src_ff[1][8*10-1: 8*9]  ; // block_size[7 : 0]
				
	        	else if( user_mem_8_addr == 5'd14) user_r_mem_8_data <= DEVICE_ID;                          // DEV_ID  	
				
	            else                               user_r_mem_8_data <= mem_array[user_mem_8_addr];
           end
    end
	
    assign  user_r_mem_8_empty = 0;
    assign  user_r_mem_8_eof = 0;
    assign  user_w_mem_8_full = 0;

   
    //////// Create a flip-flop which stores the value of the RST_N bit and passes it from one clk domain to another
    always @(posedge clk_src)
    begin
        rst_n_src_ff <= mem_array[0][0];   // store the reset value before passing it to the xillybus clock domain   
    end

	// Use a simple two stage pipeline to sync the reset value from one domain to another
    always @(posedge clk_dst)
    begin
        rst_n_dst_ff[0] <= rst_n_src_ff;
        rst_n_dst_ff[1] <= rst_n_dst_ff[0]; 
    end    
    assign gzip_rst_n = rst_n_dst_ff[1];
    
    
    //////// Store the value of BTYPE in the clk_src clock domain and then pass it in the clk_dst clock domain	
	always @(posedge clk_src)
	begin
	    btype_src_ff <= mem_array[1][1:0];	
	end
   
    always @(posedge clk_dst)
    begin
        btype_dst_ff[0][1:0] <= btype_src_ff[1:0];
        btype_dst_ff[1][1:0] <= btype_dst_ff[0][1:0];
    end    
    assign btype[1:0] = btype_dst_ff[1][1:0];   
   
    /////// Sync the value of the DEBUG registers from GZIP clock domain to Xillybus clock domain
    always @(posedge clk_src)
    begin
        debug_reg_src_ff[0][95:0] <= debug_reg;
        debug_reg_src_ff[1][95:0] <= debug_reg_src_ff[0][95:0];
    end    
	
	
endmodule