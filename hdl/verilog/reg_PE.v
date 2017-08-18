//`include "gzip_pkg.v"
//import gzip_pkg::*;

module reg_PE
   #(
    parameter DATA_WIDTH = 8
    )
    (
    // Module inputs
	input clk,
	input rst_n,
	input [DATA_WIDTH-1:0] in_reg_PE,
    input [DATA_WIDTH-1:0] in_cmp_data,
    input shift_en,
	input set_match,

	// Module outputs
	output reg [DATA_WIDTH-1:0] out_reg_PE,
    output match
    );

	// Combinational logic
	wire compare_result;
	
	// Registers
    reg match_ff;
	
	// This registers copies the input data if shift_en is set
    always @(posedge clk or negedge rst_n)
        if (!rst_n)        out_reg_PE[DATA_WIDTH-1:0] <= 8'b0;
        else if (shift_en) out_reg_PE[DATA_WIDTH-1:0] <= in_reg_PE[DATA_WIDTH-1:0];

	// This element creates the match signal. If the compare data equals the input data and if the output_en is 0 
	assign compare_result = (in_cmp_data == out_reg_PE);
	
    always @(posedge clk or negedge rst_n)
        if (!rst_n)          match_ff <= 0;
	    else if (set_match)  match_ff <= 1;
		else                 match_ff <= match;  // hold the value of the previous match result
		
	assign match = compare_result & match_ff;
	 
endmodule