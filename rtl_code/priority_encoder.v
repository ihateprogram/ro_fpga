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
	//wire [ENCODER_DEPTH-1:0] A;

	always @(posedge clk or negedge rst_n)
	begin
	    if(!rst_n)  A <= 0;
		else        A <= A_IN;
	end 
	
	//assign A = A_IN;
	
    function [log2N:0] priority_enc;
    input [ENCODER_DEPTH-1:0] A;
    reg F;
    integer I;
    begin
        F = 1'b0;
        priority_enc = 0; //{ENCODER_DEPTH{1'b0}};
        for (I=0; I<ENCODER_DEPTH; I=I+1)
            if (A[I])
            begin
                F = 1'b1;
                priority_enc = {I, F}; // Override previous index
            end
        end
    endfunction

    always @(A)
    begin
        {P, F} <= priority_enc(A);
    end
	
endmodule