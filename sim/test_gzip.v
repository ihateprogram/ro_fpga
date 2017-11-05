
`timescale 1 ns / 10 ps

`define NO_COMRESSION      2'b00
`define FIXED_HUFFMAN      2'b01


module test_gzip;

parameter DATA_WIDTH = 8;
parameter SEARCH_BUFFER_DEPTH = 8;
parameter DICTIONARY_DEPTH = 16;
parameter DICTIONARY_DEPTH_LOG = $clog2(DICTIONARY_DEPTH);
parameter LOOK_AHEAD_BUFF_DEPTH = 8;
parameter CNT_WIDTH = $clog2(LOOK_AHEAD_BUFF_DEPTH);
parameter DEVICE_ID = 8'hB9;

parameter INPUT_FILE = "test_gzip.v";//compress this file
parameter OUTPUT_FILE = "test_gzip.gz";

//signals
reg bus_clock;         // the 2 clock signals
reg core_clock;

// Register interface signals (only one is used, according to REG_INTF_TYPE)
//Xillybus Lite interface
reg           reg_clk;
reg           reg_wren;
reg           reg_wstrb;
reg           reg_rden;
wire [31:0]   reg_rd_data;
reg [31:0]    reg_wr_data;
reg [31:0]    reg_addr;
wire          reg_irq;

//reg FIFO signals
reg           in_fifo_open;    // The FIFOs need a special reset to communicate with the Xillybus core independent of the GZIP reset bit	
wire          in_fifo_full;
reg [31:0]    in_fifo_data;
reg           in_fifo_wren;

//wire FIFO signals
reg           out_fifo_open;
wire          out_fifo_empty; 
reg           out_fifo_rden;                     
wire [31:0]   out_fifo_data;
wire          out_fifo_eof;    

integer config_done = 0;

//file handles
integer in_file, out_file;

//variables to hold bytes read
integer nbytes;
reg [7:0] byte_read;
integer i;

integer read_timeout;

//generate clocks
initial begin
    reg_clk = 0;
    forever #10 reg_clk = ~reg_clk; //50MHz register interface clock
end
initial begin
    bus_clock = 0;
    forever #5 bus_clock = ~bus_clock; //100MHz FIFO interface clock
end
initial begin
    core_clock = 0;
    forever #4 core_clock = ~core_clock; //125MHz compressor clock
end

gzip #(      	
    .DICTIONARY_DEPTH(DICTIONARY_DEPTH),	  // the size of the GZIP window -32k
	.DICTIONARY_DEPTH_LOG(DICTIONARY_DEPTH_LOG),
    .LOOK_AHEAD_BUFF_DEPTH(LOOK_AHEAD_BUFF_DEPTH),     // the max length of the GZIP match
	.CNT_WIDTH(CNT_WIDTH),                  // The counter size must be changed according to the maximum match length	
    .DEVICE_ID(DEVICE_ID),
    .REG_INTF_TYPE(0)             //can be 0 (XILLY_LITE) or 1 (XILLY_MEM)	
) dut (
    // Module regs
    .bus_clock,         // the 2 clock signals
    .core_clock,

    // Register interface signals (only one is used, according to REG_INTF_TYPE)
    //Xillybus Lite interface
    .reg_clk,
    .reg_wren,
    .reg_wstrb,
    .reg_rden,
    .reg_rd_data,
    .reg_wr_data,
    .reg_addr,
    .reg_irq,

    //reg FIFO signals
    .in_fifo_open,    // The FIFOs need a special reset to communicate with the Xillybus core independent of the GZIP reset bit	
    .in_fifo_full,
    .in_fifo_data,
    .in_fifo_wren,

    //wire FIFO signals
    .out_fifo_open,
    .out_fifo_empty, 
    .out_fifo_rden,                      
    .out_fifo_data,
    .out_fifo_eof
);

//program the core
initial begin
    reg_wren = 0;
    reg_wstrb = 4'b1111;
    reg_rden = 0;
    reg_wr_data = 0;
    reg_addr = 0;
    //check register interface by reading device ID
    #100
    @(negedge reg_clk);
    reg_addr = 14;
    reg_rden = 1;
    @(negedge reg_clk);
    reg_addr = 0;
    reg_rden = 0;  
    if(reg_rd_data[7:0] != DEVICE_ID) begin
        $display("Incorrect DEVICE ID read");
        $finish;
    end
    //program BTYPE
    @(negedge reg_clk);
    reg_addr = 1;
    reg_wren = 1;
    reg_wr_data = `FIXED_HUFFMAN;
    @(negedge reg_clk);
    reg_addr = 0;
    reg_wren = 0;
    reg_wr_data = 0;
    //reset and de-reset core
    @(negedge reg_clk);
    reg_addr = 0;
    reg_wren = 1;
    reg_wr_data = 0;
    @(negedge reg_clk);
    reg_addr = 0;
    reg_wren = 0;
    reg_wr_data = 0;
    #100
    @(negedge reg_clk);
    reg_addr = 0;
    reg_wren = 1;
    reg_wr_data = 1;
    @(negedge reg_clk);
    reg_addr = 0;
    reg_wren = 0;
    reg_wr_data = 0;
    //signal end of configuration sequence
    #1000
    config_done = 1;
end

//input data
initial begin
    in_fifo_open = 0;
    in_fifo_data = 0;
    in_fifo_wren = 0;
    @(posedge config_done);
    //open input file
    in_file = $fopen(INPUT_FILE,"rb");
    $display("Opened input file: %s %d",INPUT_FILE,in_file);
    //signal FIFO open
    @(negedge bus_clock);
    in_fifo_open = 1;
    //read and push into FIFO
    nbytes = 1;
    @(negedge bus_clock);
    while(nbytes != 0) begin
        if(in_fifo_full) begin
            in_fifo_wren = 0;
        end else begin
            in_fifo_wren = 1;
            repeat(4) begin
                nbytes = $fread(byte_read,in_file);
                in_fifo_data = {in_fifo_data[23:0],(nbytes != 0)?byte_read:8'd0};
            end
        end
        @(negedge bus_clock);
    end
    in_fifo_wren = 0;
    //close input file
    $fclose(in_file);
end

//output results
initial begin
    out_fifo_open = 0;
    out_fifo_rden = 0;
    @(posedge config_done);
    //open output file
    out_file = $fopen(OUTPUT_FILE,"wb");
    $display("Opened output file: %s %d",OUTPUT_FILE,out_file);
    //signal FIFO open
    @(negedge bus_clock);
    out_fifo_open = 1;
    forever begin
        @(negedge bus_clock);
        if(~out_fifo_empty) begin
            out_fifo_rden = 1;
            $fwriteb(out_file,"%c%c%c%c",out_fifo_data[7:0],out_fifo_data[15:8],out_fifo_data[23:16],out_fifo_data[31:24]);
            $fflush(out_file);
            read_timeout = 0;
        end else
            out_fifo_rden = 0;
            read_timeout = read_timeout + 1;
        if(read_timeout == 1000) begin
            $fclose(out_file);
            #1000
            $finish;
        end
    end
end

endmodule
