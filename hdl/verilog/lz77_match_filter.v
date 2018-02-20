// This module has a 3 level pipeline to make the LZ77 encoder output only matches
// greater than 3 characters in the data stream.

module lz77_match_filter
    #( 
     	parameter DATA_WIDTH = 8,
		parameter DICTIONARY_DEPTH_LOG = 16,
		parameter CNT_WIDTH = 9     // The counter size must be changed according to the maximum match length
	)
    (
    // Module inputs
    input clk,	
    input rst_n,

    input [DICTIONARY_DEPTH_LOG:0] input_match_position,
	input [CNT_WIDTH-1:0]          input_match_length,
	input [DATA_WIDTH-1:0]         input_match_next_symbol,
	input                          input_match_valid,
    input                          input_valid_symbol,
    input                          input_last_symbol,
	
    // Module outputs 
    output reg [DICTIONARY_DEPTH_LOG:0] output_match_position,
	output reg [CNT_WIDTH-1:0]          output_match_length,
	output reg [DATA_WIDTH-1:0]         output_match_next_symbol,
	output reg                          output_match_valid,
    output reg                          output_last_symbol
    );

reg [DICTIONARY_DEPTH_LOG:0] pipe_match_position[1:0];
reg [CNT_WIDTH-1:0]          pipe_match_length[1:0];
reg [DATA_WIDTH-1:0]         pipe_match_next_symbol[1:0];
reg                          pipe_match_valid[1:0];
reg                          pipe_valid_symbol[1:0];
reg                          pipe_last_symbol[1:0];

reg [DATA_WIDTH-1:0]         side_pipe_symbol[1:0];


wire detect_match1;//asserted when a length-1 match is in the pipeline
wire detect_match2;//asserted when a length-2 match is in the pipeline

//push non-matching literals into the side-pipe, if they are valid
always @(posedge clk)
    if(input_valid_symbol & ~input_match_valid) begin
        side_pipe_symbol[0] <= input_match_next_symbol;
        side_pipe_symbol[1] <= side_pipe_symbol[0];
    end

always @(posedge clk) begin
    pipe_last_symbol[0] <= input_last_symbol;
    pipe_last_symbol[1] <= pipe_last_symbol[0];
    output_last_symbol  <= pipe_last_symbol[1];

    pipe_match_position[0] <= (detect_match1 | detect_match2) ? 1 : input_match_position;
    pipe_match_position[1] <= (detect_match1 | detect_match2) ? 1 : pipe_match_position[0];
    output_match_position  <= (detect_match2) ? 1 : pipe_match_position[1];

    pipe_match_length[0] <= (detect_match1 | detect_match2) ? 0 : input_match_length;
    pipe_match_length[1] <= (detect_match1 | detect_match2) ? 0 : pipe_match_length[0];
    output_match_length  <= (detect_match2) ? 0 : pipe_match_length[1];

    pipe_match_next_symbol[0] <= input_match_next_symbol;
    pipe_match_next_symbol[1] <= (detect_match1 | detect_match2) ? side_pipe_symbol[0] : pipe_match_next_symbol[0];
    output_match_next_symbol  <= (detect_match2) ? side_pipe_symbol[1] : pipe_match_next_symbol[1];

    pipe_match_valid[0] <= input_match_valid;
    pipe_match_valid[1] <= (detect_match1 | detect_match2) ? 1 : pipe_match_valid[0];
    output_match_valid  <= (detect_match2) ? 1 : pipe_match_valid[1];
end

assign detect_match1 = (input_match_valid & input_valid_symbol & (input_match_length == 1));
assign detect_match2 = (input_match_valid & input_valid_symbol & (input_match_length == 2));

endmodule
