module word_merge(
    // Module inputs
    input clock,
    input reset,    
    input in_valid,
    input in_last,
    input [5:0]  in_size,
    input [31:0] in_data,
	
	// Module outputs
    output reg out_valid,
    output reg out_last,
    output reg [3:0] out_bvalid,
    output reg [31:0] out_data
);

reg [31:0] a;
reg [5:0] size_a;
reg [31:0] b;
reg [5:0] size_b;
reg [31:0] b_mask;

reg [31:0] remainder;
reg [5:0] size_remainder;

reg [31:0] merged_word;
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
    
always @(posedge clock) begin
    if(reset) begin
	    out_data   <= 0;
	    out_valid  <= 0;
	    out_last   <= 0;
	    out_bvalid <= 0;	
	end
	else begin
        out_data  <= merged_word;
        out_valid <= merged_valid | flush;
        out_last  <= flush;
        if((size_a+size_b) > 24) out_bvalid <= 4'b1111;
        else if((size_a+size_b) > 16) out_bvalid <= 4'b1110;
        else if((size_a+size_b) > 8) out_bvalid <= 4'b1100;
        else out_bvalid <= 4'b1000;
	end
end
    
always @* begin
    //merged_word = a | (b >> size_a);
    merged_word = a | ((b & b_mask )<< size_a);                // aducem ce e nou dupa bitii ocupati de a
    merged_valid = (size_a+size_b) >= 32;
    //remainder = b << (32-size_a);            
    remainder = b >> (32-size_a);                   // restul e ce este peste 32 de biti si e aliniat la dreapta
    size_remainder = size_a + size_b - (merged_valid ? 32 : 0);
end

// This decoder is used to load in merged_word the exact number of bits size_b has
// if b is bigger than size_b then this could load the last word with false bits
always @(*)
begin
    case(size_b)
        6'd0 : b_mask <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
        6'd1 : b_mask <= 32'b0000_0000_0000_0000_0000_0000_0000_0001;
        6'd2 : b_mask <= 32'b0000_0000_0000_0000_0000_0000_0000_0011;
        6'd3 : b_mask <= 32'b0000_0000_0000_0000_0000_0000_0000_0111;
        6'd4 : b_mask <= 32'b0000_0000_0000_0000_0000_0000_0000_1111;
        6'd5 : b_mask <= 32'b0000_0000_0000_0000_0000_0000_0001_1111;
        6'd6 : b_mask <= 32'b0000_0000_0000_0000_0000_0000_0011_1111;
        6'd7 : b_mask <= 32'b0000_0000_0000_0000_0000_0000_0111_1111;
        6'd8 : b_mask <= 32'b0000_0000_0000_0000_0000_0000_1111_1111;
        6'd9 : b_mask <= 32'b0000_0000_0000_0000_0000_0001_1111_1111;
		             
        6'd10: b_mask <= 32'b0000_0000_0000_0000_0000_0011_1111_1111;
        6'd11: b_mask <= 32'b0000_0000_0000_0000_0000_0111_1111_1111;
        6'd12: b_mask <= 32'b0000_0000_0000_0000_0000_1111_1111_1111;
        6'd13: b_mask <= 32'b0000_0000_0000_0000_0001_1111_1111_1111;
        6'd14: b_mask <= 32'b0000_0000_0000_0000_0011_1111_1111_1111;
        6'd15: b_mask <= 32'b0000_0000_0000_0000_0111_1111_1111_1111;
        6'd16: b_mask <= 32'b0000_0000_0000_0000_1111_1111_1111_1111;
        6'd17: b_mask <= 32'b0000_0000_0000_0001_1111_1111_1111_1111;
        6'd18: b_mask <= 32'b0000_0000_0000_0011_1111_1111_1111_1111;
        6'd19: b_mask <= 32'b0000_0000_0000_0111_1111_1111_1111_1111;
                   
        6'd20: b_mask <= 32'b0000_0000_0000_1111_1111_1111_1111_1111;
        6'd21: b_mask <= 32'b0000_0000_0001_1111_1111_1111_1111_1111;
        6'd22: b_mask <= 32'b0000_0000_0011_1111_1111_1111_1111_1111;
        6'd23: b_mask <= 32'b0000_0000_0111_1111_1111_1111_1111_1111;
        6'd24: b_mask <= 32'b0000_0000_1111_1111_1111_1111_1111_1111;
        6'd25: b_mask <= 32'b0000_0001_1111_1111_1111_1111_1111_1111;
        6'd26: b_mask <= 32'b0000_0011_1111_1111_1111_1111_1111_1111;
        6'd27: b_mask <= 32'b0000_0111_1111_1111_1111_1111_1111_1111;
        6'd28: b_mask <= 32'b0000_1111_1111_1111_1111_1111_1111_1111;
        6'd29: b_mask <= 32'b0001_1111_1111_1111_1111_1111_1111_1111;
		
        6'd30: b_mask <= 32'b0011_1111_1111_1111_1111_1111_1111_1111;
        6'd31: b_mask <= 32'b0111_1111_1111_1111_1111_1111_1111_1111;
        6'd32: b_mask <= 32'b1111_1111_1111_1111_1111_1111_1111_1111;
		
        default : b_mask <= 32'b0;
		
    endcase
end


    
endmodule
