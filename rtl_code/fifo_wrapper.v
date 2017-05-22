   
//  FIFO36E1   : In order to incorporate this function into the design,
//   Verilog   : the following instance declaration needs to be placed
//  instance   : in the body of the design code.  The instance name
// declaration : (FIFO36E1_inst) and/or the port declarations within the
//    code     : parenthesis may be changed to properly reference and
//             : connect this function to the design.  All inputs
//             : and outputs must be connected.

//  <-----Cut code below this line---->

   // FIFO36E1: 36Kb FIFO (First-In-First-Out) Block RAM Memory
   //           Artix-7
   // Xilinx HDL Language Template, version 14.4

//  <-----Cut code below this line---->

   // FIFO_SYNC_MACRO: Synchronous First-In, First-Out (FIfor) RAM Buffer
   //                  Artix-7
   // Xilinx HDL Language Template, version 14.4
   
   /////////////////////////////////////////////////////////////////
   // DATA_WIDTH | FIFO_SIZE | FIfor Depth | RDCOUNT/WRCOUNT Width //
   // ===========|===========|============|=======================//
   //   37-72    |  "36Kb"   |     512    |         9-bit         //
   //   19-36    |  "36Kb"   |    1024    |        10-bit         //
   //   19-36    |  "18Kb"   |     512    |         9-bit         //
   //   10-18    |  "36Kb"   |    2048    |        11-bit         //
   //   10-18    |  "18Kb"   |    1024    |        10-bit         //
   //    5-9     |  "36Kb"   |    4096    |        12-bit         //
   //    5-9     |  "18Kb"   |    2048    |        11-bit         //
   //    1-4     |  "36Kb"   |    8192    |        13-bit         //
   //    1-4     |  "18Kb"   |    4096    |        12-bit         //
   /////////////////////////////////////////////////////////////////

   
module fifo_wrapper(
    // Module inputs
	clk,
	rst,
	din,
	wr_en,
	rd_en,
    // Module outputs	
	dout,
	full,
	empty
	);


input clk;
input rst;
input [31 : 0] din;
input wr_en;
input rd_en;
output [31 : 0] dout;
output full;
output empty;        
   



					

endmodule   