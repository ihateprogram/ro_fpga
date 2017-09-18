/*  
Title:         Word_merge64
Author:                          Ovidiu Plugariu

Description:   This module is used to merge data of size between 1 and 63 bits into 32 bits chunks. 

*/

module word_merge64(
    // Module inputs
    input clock,
    input reset,    
    input in_valid,
    input in_last,
    input [6:0]  in_size,
    input [63:0] in_data,
	
	// Module outputs
    output reg out_valid,
    output reg out_last,
    //output reg [3:0] out_bvalid,
    output reg [63:0] out_data
);

reg [63:0] a;
reg [6:0] size_a;
reg [63:0] b;
reg [6:0] size_b;
//reg [31:0] b_mask;

reg [63:0] remainder;
reg [6:0] size_remainder;

reg [63:0] merged_word;
reg merged_valid;

reg in_last_r;
reg in_last_rr;
reg flush;


//B is always updated from the input
always @(posedge clock)
    if(~in_valid | reset | flush) begin
        b <= 0;
        size_b <= 0;
    end else begin                               // copiaza ce e la intrare cand in_valid e 1
        b <= in_data;
        size_b <= in_size;
    end
    
//A stores the remainder of the merge operation
always @(posedge clock)
    if(reset | flush) begin
        size_a <= 0;
        a <= 0;
    end else begin
        size_a <= size_remainder;
        if(merged_valid)
            a <= remainder;
        else
            a <= merged_word;
    end

always @(posedge clock) begin
    if(reset) begin
	    in_last_r  <= 0;
	    in_last_rr <= 0;
	    flush      <= 0;
	end
	else begin
        in_last_r  <= in_last;
        in_last_rr <= in_last_r;
        flush      <= in_last_rr;
	end
end
 
always @* begin
    //merged_word = a | (b >> size_a);
    merged_word = a | (b << size_a);                // aducem ce e nou dupa bitii ocupati de a
    merged_valid = (size_a+size_b) >= 64;
    //remainder = b << (32-size_a);            
    remainder = b >> (64-size_a);                   // restul e ce este peste 64 de biti si e aliniat la dreapta
    size_remainder = size_a + size_b - (merged_valid ? 64 : 0);
end

always @(posedge clock) begin
    if(reset) begin
	    out_data   <= 0;
	    out_valid  <= 0;
	    out_last   <= 0;
	end
	else begin
        out_data  <= merged_word;
        out_valid <= merged_valid | flush;
        out_last  <= flush;
	end
end

    
endmodule
