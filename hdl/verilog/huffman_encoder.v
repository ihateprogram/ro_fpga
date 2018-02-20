
module huffman_encoder
#( 
 	parameter DATA_WIDTH = 8,
	parameter DICTIONARY_DEPTH_LOG = 16,
	parameter CNT_WIDTH = 9     // The counter size must be changed according to the maximum match length
)
(
    input clk,
    input rst_n,

    input match_valid,
    input match_last,
    input [DATA_WIDTH-1:0] match_literal,
    input [CNT_WIDTH-1:0] match_length,
    input [DICTIONARY_DEPTH_LOG:0] match_distance,

    output reg [63:0] code,
    output reg [6:0] code_length,
    output reg code_valid
);

    // There are separate encoders for literals, lengths and distances 

	// literal encoder
    wire [8:0] huffman_literal_code;
    wire [3:0] huffman_literal_code_length;

    sliteral slit
    (
        // Module inputs
        .clk                (clk),	
        .rst_n              (rst_n),	
	    .literal_in         (match_literal), // 8 bits input literal
	    .gzip_last_symbol   (match_last),
	
        // Module outputs
	   .sliteral_data       (huffman_literal_code),        // 7-9 bits Huffman code (only 7-bit code is for EOF)
       .sliteral_valid_bits (huffman_literal_code_length)  // this output says how many binary encoded bits are valid from the output of the decoder 
    );

    //length encoder
    wire [12:0] huffman_length_code;
    wire [3:0] huffman_length_code_length;

    slength slen
    (
        // Module inputs
        .clk                (clk),	
        .rst_n              (rst_n),
	    .match_length_in    ({{(9-CNT_WIDTH){1'b0}},match_length}),      // 9bits: 3 <= match_length  <= 258
	
        // Module outputs
	    .slength_data_out   (huffman_length_code),         // 13 bits {5 extra bit binary code, <7/8bit Huffman>} , Huffman codes are bit reversed
        .slength_valid_bits (huffman_length_code_length)   // this output says how many binary encoded bits are valid from the output of the decoder 
    );

    //distance (position) encoder
    wire [17:0] huffman_distance_code;
    wire [4:0] huffman_distance_code_length;

    sdht
    #(      	
        .DATA_WIDTH             (DATA_WIDTH),
        .DICTIONARY_DEPTH_LOG   (DICTIONARY_DEPTH_LOG)	
	)
    sdist
    (
        // Module inputs
        .clk                (clk),	
        .rst_n              (rst_n),
	    .match_pos_in       (match_distance),
	
        // Module outputs
	    .sdht_data_merged   (huffman_distance_code),        // 18 bits { <5bit Huffman>, 13 bit binary code}
        .sdht_valid_bits    (huffman_distance_code_length)  // this output says how many binary encoded bits are valid from the output of the decoder 
    );

    //when length of match is zero, then output the literal code and its length
    //otherwise, output a length+distance+literal code and the sum of lengths
    reg match_length_is_zero;
    always @(posedge clk) begin
        match_length_is_zero <= match_valid & (match_length == 0);
        //first mix the length/literal codes
        if(match_length_is_zero) begin
            code <= huffman_literal_code;
            code_length <= huffman_literal_code_length;
        end else begin
            code <= huffman_length_code | ((huffman_distance_code | (huffman_literal_code << huffman_distance_code_length)) << huffman_length_code_length);
            code_length <= huffman_length_code_length + huffman_distance_code_length + huffman_literal_code_length;
        end
    end

    reg valid_int;

    always @(posedge clk)
        if(!rst_n) begin
            valid_int <= 0;
            code_valid <= 0;
        end else begin
            valid_int <= match_valid;
            code_valid <= valid_int;
        end

endmodule
