// simple priority encoder


module priority_enc
    #(
	    parameter ENCODER_DEPTH = 4,
		parameter log2N = 2
	)
	(
		input rst_n,
		input clk,
	    input  [ENCODER_DEPTH-1:0] A_IN,   //Input Vector
	    output reg [log2N-1:0] P,       // High Priority Index
	    output reg F	                // Found a one?
	);
    
	// Register the input that goes in the priority encoder
	reg [ENCODER_DEPTH-1:0] A;

	always @(posedge clk)
	begin
	    if(!rst_n)  A <= 0;
		else        A <= A_IN;
	end 
	
	
    function [log2N:0] priority_enc;
    input [ENCODER_DEPTH-1:0] A;
    integer I;
    begin
        priority_enc = 0; //{ENCODER_DEPTH{1'b0}};
        for (I=0; I<ENCODER_DEPTH; I=I+1)
            if (A[I])
            begin
                priority_enc = I; // Override previous index
            end
        end
    endfunction

    always @*
    begin
        P = priority_enc(A);
        F = |A;
    end
	
endmodule
