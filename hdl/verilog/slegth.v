
/*  
Title:            Static Length Huffman tree
Author:                                     Ovidiu Plugariu

Description:  This file is a Static Length Huffman Tree. These codes represent the length values between 0-258
            which are Huffman encoded. The final value of the code is a concatenation between the huffman ecoded value and the binary 
            value given by the offset of the distance in the lenght ranges.
            Minimum decoded length is 3 and the maximum is 258.
            We will use a lower range because for normal english texts the the length of a sequence rarely exceeds 64.
            Synthesys will remove the unused logic from the table if the maximum length is smaller than 258.
*/



// Codes from 257-279 have 7 bits
// Codes from 280-287 have 8 bits 
`define LEN_CODE257	8'd1
`define LEN_CODE258	8'd2
`define LEN_CODE259	8'd3
`define LEN_CODE260	8'd4
`define LEN_CODE261	8'd5
`define LEN_CODE262	8'd6
`define LEN_CODE263	8'd7
`define LEN_CODE264	8'd8
`define LEN_CODE265	8'd9
`define LEN_CODE266	8'd10
`define LEN_CODE267	8'd11
`define LEN_CODE268	8'd12
`define LEN_CODE269	8'd13
`define LEN_CODE270	8'd14
`define LEN_CODE271	8'd15
`define LEN_CODE272	8'd16
`define LEN_CODE273	8'd17
`define LEN_CODE274	8'd18
`define LEN_CODE275	8'd19
`define LEN_CODE276	8'd20
`define LEN_CODE277	8'd21
`define LEN_CODE278	8'd22
`define LEN_CODE279	8'd23
`define LEN_CODE280 8'd192
`define LEN_CODE281 8'd193
`define LEN_CODE282 8'd194
`define LEN_CODE283 8'd195
`define LEN_CODE284 8'd196
`define LEN_CODE285 8'd197
`define LEN_CODE286 8'd198
`define LEN_CODE287 8'd199


module slength
    (
    // Module inputs
    input  clk,	
    input  rst_n,	
	input  [8:0] match_length_in,              // 9bits: 3 <= match_length  <= 258
	
    // Module outputs
	output [12:0] slength_data_out,        // 13 bits {5 extra bit binary code, <7/8bit Huffman>} , Huffman codes are bit reversed
    output [3 :0] slength_valid_bits       // this output says how many binary encoded bits are valid from the output of the decoder 
    );
	
	// Module registers
	reg [8 :0]  slength_extra_bits_val;        // 5 bits extra value binary encoded - only 13 bits are used because of the distance ranges
	reg [2 :0]  slength_extra_bits_no;         // number of extra binary bits used for address encoding
	reg [7 :0]  slength_huff;
	wire[7 :0]  slength_huff_rev;              // the reversed value of the Huffman length value
    wire        slength_huff_shift_right;      // this si used to show if the length Huffman code has to be shifted 1 bit to the right
	
	reg [8 :0]  match_length_in_buff; 

	// Combinational logic
    wire [3:0] slength_huff_len;
	
    //====================================================================================================================	
	//===================================== Create Huffman codes LUT for lengths =========================================
	//====================================================================================================================
    always @(posedge clk)
	begin
	    if (!rst_n) begin
		    slength_huff           <= `LEN_CODE257;
            slength_extra_bits_no  <= 0;
            slength_extra_bits_val <= 0;
		end
		else begin
            case ( 1 )		
		        //inbetween(match_length_in, 9'd3, 9'd3)  : begin
		        (match_length_in == 9'd3): begin
		    	            slength_huff           <= `LEN_CODE257;
                            slength_extra_bits_no  <= 0;
                            slength_extra_bits_val <= 0;							
    	    	        end	
		    			
                //inbetween(match_length_in, 9'd4, 9'd4)    : begin
                (match_length_in == 9'd4): begin			
		    	            slength_huff           <= `LEN_CODE258;
                            slength_extra_bits_no  <= 0;
                            slength_extra_bits_val <= 0;							
    	    	        end	
		    			
                //inbetween(match_length_in, 9'd5, 9'd5)    : begin
		    	(match_length_in == 9'd5): begin
		    	            slength_huff           <= `LEN_CODE259;
                            slength_extra_bits_no  <= 0;
                            slength_extra_bits_val <= 0;							
    	    	        end	
            
                //inbetween(match_length_in, 9'd6, 9'd6)    : begin
                (match_length_in == 9'd6): begin			
		    	            slength_huff           <= `LEN_CODE260;
                            slength_extra_bits_no  <= 0;
                            slength_extra_bits_val <= 0;							
    	    	        end	
    	    				
                //inbetween(match_length_in, 9'd7, 9'd7)    : begin
		    	(match_length_in == 9'd7): begin
		    	            slength_huff           <= `LEN_CODE261;
                            slength_extra_bits_no  <= 0;
                            slength_extra_bits_val <= 0;							
    	    	        end	
    	    				
                //inbetween(match_length_in, 9'd8, 9'd8)    : begin
		    	(match_length_in == 9'd8): begin
		    	            slength_huff           <= `LEN_CODE262;
                            slength_extra_bits_no  <= 0;
		    	            slength_extra_bits_val <= 0;					
    	    	        end	
            
                //inbetween(match_length_in, 9'd9, 9'd9)    : begin
		    	(match_length_in == 9'd9): begin
		    	            slength_huff           <= `LEN_CODE263;
                            slength_extra_bits_no  <= 0;
                            slength_extra_bits_val <= 0;							
    	    	        end
		    
    	    	//inbetween(match_length_in, 9'd10, 9'd10)    : begin
		    	(match_length_in == 9'd10): begin
		    	            slength_huff           <= `LEN_CODE264;
                            slength_extra_bits_no  <= 0;
                            slength_extra_bits_val <= 0;		  					
    	    	        end
		    
    	    	//inbetween(match_length_in, 9'd11, 9'd12)   : begin
    	    	(match_length_in == 9'd11 || match_length_in == 9'd12): begin
		    	            slength_huff           <= `LEN_CODE265;
                            slength_extra_bits_no  <= 1;
                            slength_extra_bits_val <= match_length_in - 4'd11;	   // XAPP215 - you have to take in consideration the width of the subtraction operators to obtain best sintesys results					
    	    	        end  
		    
                //inbetween(match_length_in, 9'd13, 9'd14)  : begin
                (match_length_in == 9'd13 || match_length_in == 9'd14): begin			
		    	            slength_huff           <= `LEN_CODE266;
                            slength_extra_bits_no  <= 1;
                            slength_extra_bits_val <= match_length_in - 4'd13;							
    	    	        end 
            
                //inbetween(match_length_in, 9'd15, 9'd16)  : begin
		    	(match_length_in == 9'd15 || match_length_in == 9'd16): begin
		    	            slength_huff           <= `LEN_CODE267;
                            slength_extra_bits_no  <= 1;
                            slength_extra_bits_val <= match_length_in - 4'd15;							
    	    	        end 						
            
                //inbetween(match_length_in, 9'd17, 9'd18)  : begin
		    	(match_length_in == 9'd17 || match_length_in == 9'd18): begin
		    	            slength_huff           <= `LEN_CODE268;
                            slength_extra_bits_no  <= 1;
                            slength_extra_bits_val <= match_length_in - 5'd17;						
    	    	        end						
            
                inbetween(match_length_in, 9'd19, 9'd22)  : begin
		    	            slength_huff           <= `LEN_CODE269;
                            slength_extra_bits_no  <= 2;
                            slength_extra_bits_val <= match_length_in - 5'd19;							
    	    	        end	
            
                inbetween(match_length_in, 9'd23, 9'd26)  : begin
		    	            slength_huff           <= `LEN_CODE270;
                            slength_extra_bits_no  <= 2;
                            slength_extra_bits_val <= match_length_in - 5'd23;							
    	    	        end	
            
                inbetween(match_length_in, 9'd27, 9'd30)  : begin
		    	            slength_huff           <= `LEN_CODE271;
                            slength_extra_bits_no  <= 2;	
                            slength_extra_bits_val <= match_length_in - 5'd27;							
    	    	        end	
            
                inbetween(match_length_in, 9'd31, 9'd34)  : begin
		    	            slength_huff           <= `LEN_CODE272;
                            slength_extra_bits_no  <= 2;	
                            slength_extra_bits_val <= match_length_in - 5'd31;							
    	    	        end
                
                inbetween(match_length_in, 9'd35, 9'd42)  : begin
		    	            slength_huff           <= `LEN_CODE273;
                            slength_extra_bits_no  <= 3;
                            slength_extra_bits_val <= match_length_in - 6'd35;						
    	    	        end
            
                inbetween(match_length_in, 9'd43, 9'd50)  : begin
		    	            slength_huff           <= `LEN_CODE274;
                            slength_extra_bits_no  <= 3;
                            slength_extra_bits_val <= match_length_in - 6'd43;							
    	    	        end
            
                inbetween(match_length_in, 9'd51, 9'd58)  : begin
		    	            slength_huff           <= `LEN_CODE275;
                            slength_extra_bits_no  <= 3;
                            slength_extra_bits_val <= match_length_in - 6'd51;					
    	    	        end
            
                inbetween(match_length_in, 9'd59, 9'd66)  : begin
		    	            slength_huff           <= `LEN_CODE276;
                            slength_extra_bits_no  <= 3;
                            slength_extra_bits_val <= match_length_in - 6'd59;							
    	    	        end
						
                inbetween(match_length_in, 9'd67, 9'd82)  : begin
		    	            slength_huff           <= `LEN_CODE277;
                            slength_extra_bits_no  <= 4;
                            slength_extra_bits_val <= match_length_in - 7'd67;							
    	    	        end
            
                inbetween(match_length_in, 9'd83, 9'd98)  : begin
		    	            slength_huff           <= `LEN_CODE278;
                            slength_extra_bits_no  <= 4;
                            slength_extra_bits_val <= match_length_in - 7'd83;							
    	    	        end	
		    
                inbetween(match_length_in, 9'd99, 9'd114)  : begin
		    	            slength_huff           <= `LEN_CODE279;
                            slength_extra_bits_no  <= 4;
                            slength_extra_bits_val <= match_length_in - 7'd99;						
    	    	        end
            
                inbetween(match_length_in, 9'd115, 9'd130)  : begin
		    	            slength_huff           <= `LEN_CODE280;
                            slength_extra_bits_no  <= 4;
                            slength_extra_bits_val <= match_length_in - 7'd115;							
    	    	        end
            
                inbetween(match_length_in, 9'd131, 9'd162)  : begin
		    	            slength_huff           <= `LEN_CODE281;
                            slength_extra_bits_no  <= 5;
                            slength_extra_bits_val <= match_length_in - 8'd131;						
    	    	        end						
            
                inbetween(match_length_in, 9'd163, 9'd194)  : begin
		    	            slength_huff           <= `LEN_CODE282;
                            slength_extra_bits_no  <= 5;
                            slength_extra_bits_val <= match_length_in - 8'd163;						
    	    	        end
            
                inbetween(match_length_in, 9'd195, 9'd226)  : begin
		    	            slength_huff           <= `LEN_CODE283;
                            slength_extra_bits_no  <= 5;
                            slength_extra_bits_val <= match_length_in - 8'd195;						
    	    	        end
            
                inbetween(match_length_in, 9'd227, 9'd257)  : begin
		    	            slength_huff           <= `LEN_CODE284;
                            slength_extra_bits_no  <= 5;
                            slength_extra_bits_val <= match_length_in - 8'd227;						
    	    	        end

                (match_length_in == 9'd258)  : begin
		    	            slength_huff           <= `LEN_CODE285; 
                            slength_extra_bits_no  <= 0;
                            slength_extra_bits_val <= 0;							
    	    	        end  

				default : begin
		    	            slength_huff           <= `LEN_CODE257;
                            slength_extra_bits_no  <= 0;
                            slength_extra_bits_val <= 0;							
    	    	        end
            endcase
		end
    end 			


    function inbetween (input [8:0] match_length_in, input [8:0] low, input [8:0] high);
	begin
	    inbetween = (match_length_in >= low && match_length_in <= high) ? 1'b1 : 1'b0;
	end	
	endfunction	


	// This pipeline stage is used to calculate slength_huff_len and correlate it with the slength_huff output value
    always @( posedge clk)
    begin
    	if (!rst_n) match_length_in_buff <= 0;       
	    else        match_length_in_buff <= match_length_in;		
    end	
    
	// According to the slength_extra_bits_no and slength_extra_bits_val we have to output a triplet:
	// (slength_valid_bits, slength_huff, slength_extra_bits_val)
	
	// If the length is smaller than 114 then the Huffman code has 7 bits, else it has 8 bits
	assign slength_huff_len = inbetween(match_length_in_buff, 9'd0, 9'd114) ? 4'd7 : 4'd8;
	assign slength_huff_shift_right = inbetween(match_length_in_buff, 9'd0, 9'd114) ? 1'b1 : 1'b0;
	assign slength_valid_bits = slength_huff_len + slength_extra_bits_no;
	
	// Reverse the value of the Huffman length code. For the 7 bit values is has to shifted 1 bit to the right. RFC 1951 requirement
	genvar i; 
    generate 
       for( i=0; i<=7; i=i+1 ) 
       begin : reverse_huffman_length_bits
          assign slength_huff_rev[i] = slength_huff[7-i];
       end 
    endgenerate		
		
	assign slength_data_out = (slength_extra_bits_val << slength_huff_len) | (slength_huff_rev >> slength_huff_shift_right);
	

endmodule
