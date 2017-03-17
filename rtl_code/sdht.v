/*  
    Title:            Static Distance Huffman tree for LZ77 encoder
    Author:                                         Ovidiu Plugariu
    
// This file is a Static Distance Huffman Tree. 
// The first 5 bits from the table are 30 distance values encoded
// with a Huffman tree, and the next 13 represent the extra bits needed 
// to represent the actual distance value. The 13 bits are binary encoded.
// The module can decode distances between 1 and 32768.

*/




`define DIST_CODE0	5'b00000
`define DIST_CODE1	5'b00001
`define DIST_CODE2	5'b00010
`define DIST_CODE3	5'b00011
`define DIST_CODE4	5'b00100
`define DIST_CODE5	5'b00101
`define DIST_CODE6	5'b00110
`define DIST_CODE7	5'b00111
`define DIST_CODE8	5'b01000
`define DIST_CODE9	5'b01001
`define DIST_CODE10	5'b01010
`define DIST_CODE11	5'b01011
`define DIST_CODE12	5'b01100
`define DIST_CODE13	5'b01101
`define DIST_CODE14	5'b01110
`define DIST_CODE15	5'b01111
`define DIST_CODE16	5'b10000
`define DIST_CODE17	5'b10001
`define DIST_CODE18	5'b10010
`define DIST_CODE19	5'b10011
`define DIST_CODE20	5'b10100
`define DIST_CODE21	5'b10101
`define DIST_CODE22	5'b10110
`define DIST_CODE23	5'b10111
`define DIST_CODE24	5'b11000
`define DIST_CODE25	5'b11001
`define DIST_CODE26	5'b11010
`define DIST_CODE27	5'b11011
`define DIST_CODE28	5'b11100
`define DIST_CODE29	5'b11101



module sdht
    #(      	
        parameter DATA_WIDTH = 8,
        parameter DICTIONARY_DEPTH_LOG = 16		
	)
    (
    // Module inputs
    input  clk,	
    input  rst_n,	
	//input  match_pos_valid_in,
	input  [DICTIONARY_DEPTH_LOG-1:0]  match_pos_in,
	
    // Module outputs
    //output reg [4 :0]  sdht_dist,        // 5 bit distance huffman code
	//output reg         sdht_data_valid_out,
	output reg [17:0]  sdht_data_merged,   // 18 bits { <5bit Huffman>, 13 bit binary code}
    output     [4 :0]  sdht_valid_bits     // this output says how many binary encoded bits are valid from the output of the decoder 
    );
	
	// Module registers
	reg [DICTIONARY_DEPTH_LOG-1:0] sdht_extra_bits_val;     // 16 bits extra value binary encoded - only 13 bits are used because of the distance ranges
	reg [3 :0]  sdht_extra_bits_no;                         // number of extra binary bits used for address encoding
	reg [4 :0]  sdht_dist;
	reg [4 :0]  sdht_dist_buff;

	reg [DICTIONARY_DEPTH_LOG-1:0] sdht_extra_bits_val_buff;     // 16 bits extra value binary encoded - only 13 bits are used because of the distance ranges
	reg [3 :0]  sdht_extra_bits_no_buff;                         // number of extra binary bits used for address encoding
	//reg [4 :0]  sdht_dist_buff;	
	
	
    //====================================================================================================================	
	//================================= Create Huffman codes LUT for input distances =====================================
	//====================================================================================================================

    always @(posedge clk)
	begin
	    if (!rst_n) begin
		    sdht_dist           <= `DIST_CODE0;
			sdht_extra_bits_no  <= 0;
			sdht_extra_bits_val <= 0;			
	    end 
		else begin 
            case ( 1 )
		    
		        //inbetween(match_pos_in, 16'd0, 16'd0)  : begin
		        /*(match_pos_in == 16'd0)  : begin
		    	            sdht_dist           <= `DIST_CODE0;
                            sdht_extra_bits_no  <= 0;
                            sdht_extra_bits_val <= 0;							
    	    	        end	
		    			
                //inbetween(match_pos_in, 16'd1, 16'd1)    : begin
		        (match_pos_in == 16'd1)  : begin
		    	            sdht_dist           <= `DIST_CODE0;
                            sdht_extra_bits_no  <= 0;
                            sdht_extra_bits_val <= 0;							
    	    	        end	*/                               // covered by default case
		    			
                //inbetween(match_pos_in, 16'd2, 16'd2)    : begin
		       (match_pos_in == 16'd2)  : begin
		    	            sdht_dist           <= `DIST_CODE1;
                            sdht_extra_bits_no  <= 0;
                            sdht_extra_bits_val <= 0;							
    	    	        end	
            
                //inbetween(match_pos_in, 16'd3, 16'd3)    : begin
                (match_pos_in == 16'd3)  : begin			
		    	            sdht_dist           <= `DIST_CODE2;
                            sdht_extra_bits_no  <= 0;
                            sdht_extra_bits_val <= 0;							
    	    	        end	
    	    				
                //inbetween(match_pos_in, 16'd4, 16'd4)    : begin
		    	(match_pos_in == 16'd4)  : begin
		    	            sdht_dist           <= `DIST_CODE3;
                            sdht_extra_bits_no  <= 0;
                            sdht_extra_bits_val <= 0;							
    	    	        end	
    	    				
                //inbetween(match_pos_in, 16'd5, 16'd6)    : begin
                (match_pos_in == 16'd5 || match_pos_in == 16'd6)  : begin
		    	            sdht_dist           <= `DIST_CODE4;
                            sdht_extra_bits_no  <= 1;
		    	            sdht_extra_bits_val <= match_pos_in - 3'd5;					
    	    	        end	
            
                //inbetween(match_pos_in, 16'd7, 16'd8)    : begin
                (match_pos_in == 16'd7 || match_pos_in == 16'd8)  : begin
		    	            sdht_dist           <= `DIST_CODE5;
                            sdht_extra_bits_no  <= 1;
                            sdht_extra_bits_val <= match_pos_in - 3'd7;							
    	    	        end
		    
    	    	inbetween(match_pos_in, 16'd9, 16'd12)    : begin
		    	            sdht_dist           <= `DIST_CODE6;
                            sdht_extra_bits_no  <= 2;
                            sdht_extra_bits_val <= match_pos_in - 4'd9;		   // XAPP215 - you have to take in consideration the width of the subtraction operators to obtain best sintesys results					
    	    	        end
		    
    	    	inbetween(match_pos_in, 16'd13, 16'd16)   : begin
		    	            sdht_dist           <= `DIST_CODE7;
                            sdht_extra_bits_no  <= 2;
                            sdht_extra_bits_val <= match_pos_in - 4'd13;						
    	    	        end  
		    
                inbetween(match_pos_in, 16'd17, 16'd24)  : begin         
		    	            sdht_dist           <= `DIST_CODE8;
                            sdht_extra_bits_no  <= 3;
                            sdht_extra_bits_val <= match_pos_in - 5'd17;							
    	    	        end 
            
                inbetween(match_pos_in, 16'd25, 16'd32)  : begin
		    	            sdht_dist           <= `DIST_CODE9;
                            sdht_extra_bits_no  <= 3;
                            sdht_extra_bits_val <= match_pos_in - 5'd25;							
    	    	        end 						
            
                inbetween(match_pos_in, 16'd33, 16'd48)  : begin
		    	            sdht_dist           <= `DIST_CODE10;
                            sdht_extra_bits_no  <= 4;
                            sdht_extra_bits_val <= match_pos_in - 6'd33;						
    	    	        end						
            
                inbetween(match_pos_in, 16'd49, 16'd64)  : begin
		    	            sdht_dist           <= `DIST_CODE11;
                            sdht_extra_bits_no  <= 4;
                            sdht_extra_bits_val <= match_pos_in - 6'd49;							
    	    	        end	
            
                inbetween(match_pos_in, 16'd65, 16'd96)  : begin
		    	            sdht_dist           <= `DIST_CODE12;
                            sdht_extra_bits_no  <= 5;
                            sdht_extra_bits_val <= match_pos_in - 7'd65;							
    	    	        end	
            
                inbetween(match_pos_in, 16'd97, 16'd128)  : begin
		    	            sdht_dist           <= `DIST_CODE13;
                            sdht_extra_bits_no  <= 5;	
                            sdht_extra_bits_val <= match_pos_in - 7'd97;							
    	    	        end	
            
                inbetween(match_pos_in, 16'd129, 16'd192)  : begin
		    	            sdht_dist           <= `DIST_CODE14;
                            sdht_extra_bits_no  <= 6;	
                            sdht_extra_bits_val <= match_pos_in - 8'd129;							
    	    	        end
            
                inbetween(match_pos_in, 16'd193, 16'd256)  : begin
		    	            sdht_dist           <= `DIST_CODE15;
                            sdht_extra_bits_no  <= 6;
                            sdht_extra_bits_val <= match_pos_in - 8'd193;							
    	    	        end
            
                inbetween(match_pos_in, 16'd257, 16'd384)  : begin
		    	            sdht_dist           <= `DIST_CODE16;
                            sdht_extra_bits_no  <= 7;
                            sdht_extra_bits_val <= match_pos_in - 9'd257;							
    	    	        end
            
                inbetween(match_pos_in, 16'd385, 16'd512)  : begin
		    	            sdht_dist           <= `DIST_CODE17;
                            sdht_extra_bits_no  <= 7;
                            sdht_extra_bits_val <= match_pos_in - 9'd385;					
    	    	        end
            
                inbetween(match_pos_in, 16'd513, 16'd768)  : begin
		    	            sdht_dist           <= `DIST_CODE18;
                            sdht_extra_bits_no  <= 8;
                            sdht_extra_bits_val <= match_pos_in - 10'd513;							
    	    	        end
		    
                inbetween(match_pos_in, 16'd769, 16'd1024)  : begin
		    	            sdht_dist          <= `DIST_CODE19;
                            sdht_extra_bits_no <= 8;
                            sdht_extra_bits_val <= match_pos_in - 10'd769;							
    	    	        end
            
                inbetween(match_pos_in, 16'd1025, 16'd1536)  : begin
		    	            sdht_dist          <= `DIST_CODE20;
                            sdht_extra_bits_no <= 9;
                            sdht_extra_bits_val <= match_pos_in - 11'd1025;							
    	    	        end	
		    
                inbetween(match_pos_in, 16'd1537, 16'd2048)  : begin
		    	            sdht_dist           <= `DIST_CODE21;
                            sdht_extra_bits_no  <= 9;
                            sdht_extra_bits_val <= match_pos_in - 11'd1537;							
    	    	        end
            
                inbetween(match_pos_in, 16'd2049, 16'd3072)  : begin
		    	            sdht_dist           <= `DIST_CODE22;
                            sdht_extra_bits_no  <= 10;
                            sdht_extra_bits_val <= match_pos_in - 12'd2049;							
    	    	        end
            
                inbetween(match_pos_in, 16'd3073, 16'd4096)  : begin
		    	            sdht_dist           <= `DIST_CODE23;
                            sdht_extra_bits_no  <= 10;
                            sdht_extra_bits_val <= match_pos_in - 12'd3073;						
    	    	        end						
            
                inbetween(match_pos_in, 16'd4097, 16'd6144)  : begin
		    	            sdht_dist          <= `DIST_CODE24;
                            sdht_extra_bits_no <= 11;
                            sdht_extra_bits_val <= match_pos_in - 13'd4097;						
    	    	        end
            
                inbetween(match_pos_in, 16'd6145, 16'd8192)  : begin
		    	            sdht_dist           <= `DIST_CODE25;
                            sdht_extra_bits_no  <= 11;
                            sdht_extra_bits_val <= match_pos_in - 13'd6145;							
    	    	        end
            
                inbetween(match_pos_in, 16'd8193, 16'd12288)  : begin
		    	            sdht_dist           <= `DIST_CODE26;
                            sdht_extra_bits_no  <= 12;
                            sdht_extra_bits_val <= match_pos_in - 14'd8193;							
    	    	        end
            
                inbetween(match_pos_in, 16'd12289, 16'd16384)  : begin
		    	            sdht_dist           <= `DIST_CODE27;
                            sdht_extra_bits_no  <= 12;
                            sdht_extra_bits_val <= match_pos_in - 14'd12289;							
    	    	        end
            
                inbetween(match_pos_in, 16'd16385, 16'd24576)  : begin
		    	            sdht_dist           <= `DIST_CODE28;
                            sdht_extra_bits_no  <= 13;
                            sdht_extra_bits_val <= match_pos_in - 15'd16385;							
    	    	        end
            
                inbetween(match_pos_in, 16'd24577, 16'd32768)  : begin
		    	            sdht_dist           <= `DIST_CODE29;
                            sdht_extra_bits_no  <= 13;
                            sdht_extra_bits_val <= match_pos_in - 15'd24577;							
    	    	        end
		    
    	    	default     : begin
		    	            sdht_dist           <= `DIST_CODE0;
                            sdht_extra_bits_no  <= 0;
                            sdht_extra_bits_val <= 0;							
    	    	        end  
            endcase
		end 
    end 			

    function inbetween (input [DICTIONARY_DEPTH_LOG-1:0] match_pos_in, input [DICTIONARY_DEPTH_LOG-1:0] low, input [DICTIONARY_DEPTH_LOG-1:0] high);
	begin
	    inbetween = (match_pos_in >= low && match_pos_in <= high) ? 1'b1 : 1'b0;
	end	
	endfunction	

	// Store the values of the combinational process in a set of registers
    /*always @( posedge clk or negedge rst_n)
    begin
    	if (!rst_n) begin
			sdht_extra_bits_no_buff  <= 0;
			sdht_extra_bits_val_buff <= 0;
			sdht_dist_buff           <= 0;
		end     
	    else begin      
			sdht_extra_bits_no_buff  <= sdht_extra_bits_no ;
			sdht_extra_bits_val_buff <= sdht_extra_bits_val;
			sdht_dist_buff           <= sdht_dist;
        end			
    end */

	//assign sdht_valid_bits = 5 + sdht_extra_bits_no_buff; // 5 bits come from Huffman code and the rest of the bits are given according with the current distance
	assign sdht_valid_bits = 5 + sdht_extra_bits_no; // 5 bits come from Huffman code and the rest of the bits are given according with the current distance
	
	// The 13 bits of 0 are used to pad the unused bits from the total bit vector
	always @(*)
	begin
	    //sdht_data_merged <= (18'b0 << sdht_valid_bits) | (sdht_dist_buff << sdht_extra_bits_no_buff) | sdht_extra_bits_val_buff;	
	    sdht_data_merged <= (18'b0 << sdht_valid_bits) | (sdht_dist << sdht_extra_bits_no) | sdht_extra_bits_val;	
	end
	
	
endmodule
