/*  
Title:        Double stage synchronization-and-toggle protocol 
Author:                                                                  Ovidiu Plugariu

Description:  This module is used to pass a pulse from one clock domain to another, and is based on passing the transition
            not on sampling the logical level. It is used to pass signal from the Xillybus clock domain to GZIP core clock domain. 
		
Source:
    "Practical design for transferring signals between clock domains" - Michael Crew

*/

module sync_toggle
    (
    // Module inputs
	input clk_src,
	input clk_dst,
	input rst_n,     // reset is asynchronous
	input start_pl,

	// Module outputs
	output take_it_pl,
	output got_it_pl
    );
 	
	// Module registers
	reg pulse2toggle_ff;
	reg toggle2pulse_ff;
	reg [1:0] synchronizer_take_ff;

	reg got_it_tg_ff;
	reg got_it_pl_ff;
	reg [1:0] synchronizer_got_ff;
		
	// Combiational logic 
	wire take_it_tg;
	wire got_it_tg; 

	wire take_it_mux;
	wire got_it_mux;
	
	////////////////////////////////////////  Construct the upper part from SRC -> DST  ////////////////////////////////////////
	assign take_it_mux = start_pl ? ~take_it_tg : take_it_tg;
	
    always @(posedge clk_src or negedge rst_n) begin
        if (!rst_n) begin
		    pulse2toggle_ff <= 1'b0; 
        end		
        else begin
      		pulse2toggle_ff <= take_it_mux;
		end
    end
	 
	assign take_it_tg = pulse2toggle_ff;
	
    // Create the synchronizer stage
    always @(posedge clk_dst or negedge rst_n) begin
        if (!rst_n) begin
		    synchronizer_take_ff[1:0] <= 2'b0;
            toggle2pulse_ff           <= 1'b0;			
        end		
        else begin
      		synchronizer_take_ff[0] <= take_it_tg;
      		synchronizer_take_ff[1] <= synchronizer_take_ff[0];
			toggle2pulse_ff         <= synchronizer_take_ff[1];
		end
    end
	
	// Create the output pulse
    assign take_it_pl = toggle2pulse_ff ^ synchronizer_take_ff[1];
	
	
	////////////////////////////////////////  Construct the lower part from DST -> SRC  ////////////////////////////////////////
	
	assign got_it_mux = take_it_pl ? ~got_it_tg_ff : got_it_tg_ff;
	
    always @(posedge clk_dst or negedge rst_n) begin
        if (!rst_n) begin
		    got_it_tg_ff <= 1'b0; 
        end		
        else begin
      		got_it_tg_ff <= got_it_mux;
		end
    end
	 
	assign got_it_tg = got_it_tg_ff;	
	
    // Create the synchronizer stage
    always @(posedge clk_src or negedge rst_n) begin
        if (!rst_n) begin
		    synchronizer_got_ff[1:0] <= 2'b0;
            got_it_pl_ff             <= 1'b0;			
        end		
        else begin
      		synchronizer_got_ff[0] <= got_it_tg;
      		synchronizer_got_ff[1] <= synchronizer_got_ff[0];
			got_it_pl_ff           <= synchronizer_got_ff[1];
		end
    end
	
	// Create the output pulse
    assign got_it_pl = got_it_pl_ff ^ synchronizer_got_ff[1];
	
	
endmodule