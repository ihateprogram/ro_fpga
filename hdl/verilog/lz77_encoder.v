/*  
Title:            Sliding window algorithm for LZ77 encoder
Author:                                     Ovidiu Plugariu

Description:   Using this module the LZ77 encoder calculates the maximum length match 
            between the characters present in the search_buffer and in the dictionary.
            This module has the following characteristics:
            1. Parametrizable depth for search_buffer and dictionary (powers of 2).
            2. The input shift data has a 8bit width and shifts characters from the search dictionary 1 byte at a time.
            3. The input search data has a 8bit width and when the search function is enabled, the module returns the address where the specific data has been found.
               This is a SHIFTABLE CAM behaviour.            
            4. The module outputs: A. the match_next_symbol that should be encoded  
                                   B. the match_position (position pointer) where the string match starts (starts from 0)
                                   C. the match_length of the string that has been recognized 
								   D. the match_valid signal shows the other outputs of the module are valid
*/


//`include "functions.v"

module lz77_encoder
    #( 
     	parameter DATA_WIDTH = 8,
        parameter DICTIONARY_DEPTH = 512,
		parameter DICTIONARY_DEPTH_LOG = 9,
		parameter LOOK_AHEAD_BUFF_DEPTH = 66,
		parameter CNT_WIDTH = 7     // The counter size must be changed according to the maximum match length
	 )
    (
    // Clock/Reset inputs
    input clk,	
    input rst_n,

    // Data inputs
    input input_valid,
    input [DATA_WIDTH-1:0] input_data,
    input input_last,

    // Symbol outputs 
    output reg [DICTIONARY_DEPTH_LOG:0]   match_position,
	output reg [CNT_WIDTH-1:0]            match_length,
	output reg [DATA_WIDTH-1:0]           match_next_symbol,
	output reg                            match_valid,
    output reg                            output_valid,
    output reg                            output_last

    );

    //check parameters
    initial begin
        if(2**DICTIONARY_DEPTH_LOG != DICTIONARY_DEPTH) begin
            $display("Please make sure DICTIONARY_DEPTH is equal to 2^DICTIONARY_DEPTH_LOG");
            $finish();
        end
    end
    initial begin
        if(2**CNT_WIDTH <= LOOK_AHEAD_BUFF_DEPTH) begin
            $display("Please make sure LOOK_AHEAD_BUFF_DEPTH is smaller than 2^CNT_WIDTH");
            $finish();
        end
    end

    wire [DICTIONARY_DEPTH_LOG:0]   match_position_wire;
	reg  [CNT_WIDTH-1:0]            match_length_reg;
	reg  [CNT_WIDTH-1:0]            match_length_reg2;
	wire                            match_valid_wire;	
	reg                             match_valid_reg;
	reg  [DATA_WIDTH-1:0]           match_next_symbol_reg;
    reg                             output_valid_reg;
    reg                             output_last_reg;
    

    // Combinational logic
    wire match_global;
	wire set_match;
	wire match_position_valid;
	(* dont_touch = "{true}" *) wire [DATA_WIDTH-1:0] out_reg_PE [0:DICTIONARY_DEPTH-1];  // wires to connect the processing elements
	(* dont_touch = "{true}" *) wire [DICTIONARY_DEPTH-1:0] match_PE;
	(* dont_touch = "{true}" *) reg [DICTIONARY_DEPTH-1:0] serial_enable; 
	wire match_length_max;

    always @(posedge clk or negedge rst_n)
    begin
	   if(!rst_n) begin
	      match_position <= 0;
          match_length_reg2 <= 0;
          match_length <= 0;
          match_valid_reg <= 0;
          match_valid <= 0;
          match_next_symbol_reg <= 0;
          match_next_symbol <= 0;
          output_valid_reg <= 0;
          output_valid <= 0;
          output_last_reg <= 0;
          output_last <= 0;
	   end
	   else begin
	      match_position <= match_position_wire;
          match_length_reg2 <= match_length_reg;
          match_length <= match_length_reg2;
          match_valid_reg <= match_valid_wire;
          match_valid <= match_valid_reg;
          match_next_symbol_reg <= input_data;
          match_next_symbol <= match_next_symbol_reg;
          output_valid_reg <= input_valid;
          output_valid <= output_valid_reg;
          output_last_reg <= input_last;
          output_last <= output_last_reg;
	   end 
	end

	// This is used to disable the PE until the first valid byte reaches that cell (removes 0x00 fake pointers) 
    always @(posedge clk or negedge rst_n)
	begin
	   if(!rst_n) begin
	      serial_enable[0]                    <= 0;
		  serial_enable[DICTIONARY_DEPTH-1:1] <= 0;
	   end
	   else if (input_valid == 1) begin
	      serial_enable[DICTIONARY_DEPTH-1:0] <= (serial_enable[DICTIONARY_DEPTH-1:0] << 1) | 1'b1; // enable cells one by one
	   end 
	end
	
	
	// The search array is a parameterizable module used to create the sliding dictionary and to return the match positions	
    genvar i;     
    generate
        for (i=0; i < DICTIONARY_DEPTH; i=i+1) begin : SLD_WIN
		    if ( i==0 )			      
                reg_PE REG_PE_i (.clk, .rst_n,
	                           .in_reg_PE(input_data[7:0]), .in_cmp_data(input_data[7:0]),
                               .shift_en(input_valid), .set_match(set_match & serial_enable[i]),
                               .out_reg_PE(out_reg_PE[i]),  .match(match_PE[i]));					
			else 			
				reg_PE REG_PE_i (.clk, .rst_n,
	                           .in_reg_PE(out_reg_PE[i-1]), .in_cmp_data(input_data[7:0]),
                               .shift_en(input_valid), .set_match(set_match & serial_enable[i]),
                               .out_reg_PE(out_reg_PE[i]), .match(match_PE[i]));
        end
    endgenerate

	
	assign match_global = |match_PE[DICTIONARY_DEPTH-1:0];    // big OR gate used for match detection
	
	// The match calculation will function without input_valid=1 but the downstream modules must not see 
	// the match_valid signal set when no data is processed.
    assign match_valid_wire = (input_valid & ~match_global) | match_length_max;

	// Create the signal that shows the maximum value of the counter
	assign match_length_max = (match_length_reg == LOOK_AHEAD_BUFF_DEPTH-1);
	
    // Createa a counter which will count the matching length. 
	// At each positive edge if match=1 and input_valid=1 then the counter will increment.		
	always @(posedge clk or negedge rst_n)
	begin
	    if(!rst_n)                                               match_length_reg <= 0;
		else if (match_global && input_valid && match_length_max) match_length_reg <= 0;                     // the counter should reset if max value is reached
		else if (match_global && input_valid)                     match_length_reg <= match_length_reg + 1;      // the counter must not increment but will preservi its value
        else                                                     match_length_reg <= 0;
	end
	
	// Until the first match occurs, the PEs need the match_ff high.
	// When the match_valid signal is set, it means data is outputed and the search for a new match should start again.
	assign set_match = match_valid_wire;
	
	
	/////////////////////////////////////////// Priority encoder which returns the biggest match position in decimal ///////////////////////////////////////////
    wire [DICTIONARY_DEPTH_LOG-3:0] match_position_0;
    wire [DICTIONARY_DEPTH_LOG-3:0] match_position_1;
    wire [DICTIONARY_DEPTH_LOG-3:0] match_position_2;
    wire [DICTIONARY_DEPTH_LOG-3:0] match_position_3;
    reg [DICTIONARY_DEPTH_LOG-3:0] match_position_0_reg;
    reg [DICTIONARY_DEPTH_LOG-3:0] match_position_1_reg;
    reg [DICTIONARY_DEPTH_LOG-3:0] match_position_2_reg;
    reg [DICTIONARY_DEPTH_LOG-3:0] match_position_3_reg;
    wire match_position_valid_0;
    wire match_position_valid_1;
    wire match_position_valid_2;
    wire match_position_valid_3;
    reg match_position_valid_0_reg;
    reg match_position_valid_1_reg;
    reg match_position_valid_2_reg;
    reg match_position_valid_3_reg;

    priority_enc 
       #(
    	    .ENCODER_DEPTH(DICTIONARY_DEPTH/4),
			.log2N(DICTIONARY_DEPTH_LOG-2)
    	)
		PRIO_ENC_i0
    	(
		    .rst_n,
			.clk,
    	    .A_IN(match_PE[DICTIONARY_DEPTH/4-1:0]),  // Input Vector
    	    .P(match_position_0),                          // High Priority Index
    	    .F(match_position_valid_0)                     // This is used when the match is on position 0
    	);

    priority_enc 
       #(
    	    .ENCODER_DEPTH(DICTIONARY_DEPTH/4),
			.log2N(DICTIONARY_DEPTH_LOG-2)
    	)
		PRIO_ENC_i1
    	(
		    .rst_n,
			.clk,
    	    .A_IN(match_PE[2*DICTIONARY_DEPTH/4-1:DICTIONARY_DEPTH/4]),  // Input Vector
    	    .P(match_position_1),                          // High Priority Index
    	    .F(match_position_valid_1)                     // This is used when the match is on position 0
    	);

    priority_enc 
       #(
    	    .ENCODER_DEPTH(DICTIONARY_DEPTH/4),
			.log2N(DICTIONARY_DEPTH_LOG-2)
    	)
		PRIO_ENC_i2
    	(
		    .rst_n,
			.clk,
    	    .A_IN(match_PE[3*DICTIONARY_DEPTH/4-1:2*DICTIONARY_DEPTH/4]),  // Input Vector
    	    .P(match_position_2),                          // High Priority Index
    	    .F(match_position_valid_2)                     // This is used when the match is on position 0
    	);

    priority_enc 
       #(
    	    .ENCODER_DEPTH(DICTIONARY_DEPTH/4),
			.log2N(DICTIONARY_DEPTH_LOG-2)
    	)
		PRIO_ENC_i3
    	(
		    .rst_n,
			.clk,
    	    .A_IN(match_PE[DICTIONARY_DEPTH-1:3*DICTIONARY_DEPTH/4]),  // Input Vector
    	    .P(match_position_3),                          // High Priority Index
    	    .F(match_position_valid_3)                     // This is used when the match is on position 0
    	);
		
    always @(posedge clk)
        if(!rst_n) begin
            match_position_0_reg <= 0;
            match_position_1_reg <= 0;
            match_position_2_reg <= 0;
            match_position_3_reg <= 0;
            match_position_valid_0_reg <= 0;
            match_position_valid_1_reg <= 0;
            match_position_valid_2_reg <= 0;
            match_position_valid_3_reg <= 0;
        end else begin
            match_position_0_reg <= match_position_0;
            match_position_1_reg <= match_position_1;
            match_position_2_reg <= match_position_2;
            match_position_3_reg <= match_position_3;
            match_position_valid_0_reg <= match_position_valid_0;
            match_position_valid_1_reg <= match_position_valid_1;
            match_position_valid_2_reg <= match_position_valid_2;
            match_position_valid_3_reg <= match_position_valid_3;
        end

    assign match_position_valid =  match_position_valid_3_reg | match_position_valid_2_reg | match_position_valid_1_reg | match_position_valid_0_reg;
    
    reg [DICTIONARY_DEPTH_LOG-3:0] match_position_mux;
    reg [DICTIONARY_DEPTH_LOG-1:0] match_position_add;

    always @*
        casex({match_position_valid_3_reg,match_position_valid_2_reg,match_position_valid_1_reg,match_position_valid_0_reg})
            4'b1xxx: match_position_mux = match_position_3_reg;
            4'b01xx: match_position_mux = match_position_2_reg;
            4'b001x: match_position_mux = match_position_1_reg;
            4'b0001: match_position_mux = match_position_0_reg;
            default: match_position_mux = 0;//{(DICTIONARY_DEPTH_LOG-2){1'bx}};
        endcase

    always @*
        casex({match_position_valid_3_reg,match_position_valid_2_reg,match_position_valid_1_reg,match_position_valid_0_reg})
            4'b1xxx: match_position_add = 3*DICTIONARY_DEPTH/4;
            4'b01xx: match_position_add = 2*DICTIONARY_DEPTH/4;
            4'b001x: match_position_add = 1*DICTIONARY_DEPTH/4;
            4'b0001: match_position_add = 0;
            default: match_position_add = 0;//{(DICTIONARY_DEPTH_LOG-2){1'bx}};
        endcase

    assign match_position_wire = match_position_mux + match_position_add + 1;
		
endmodule
