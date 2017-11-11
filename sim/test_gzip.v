
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
reg reg_clk;
reg bus_reset;

//AXI4-Lite Register interface signals
reg           axi4l_aresetn;
wire          axi4l_awready;
reg           axi4l_awvalid;
reg [7:0]     axi4l_awaddr;
reg [2:0]     axi4l_awprot;
wire          axi4l_wready;
reg           axi4l_wvalid;
reg [31:0]    axi4l_wdata;
reg [3:0]     axi4l_wstrb;
reg           axi4l_bready;
wire          axi4l_bvalid;
wire  [1:0]   axi4l_bresp;
wire          axi4l_arready;
reg           axi4l_arvalid;
reg [7:0]     axi4l_araddr;
reg [2:0]     axi4l_arprot;
reg           axi4l_rready;
wire          axi4l_rvalid;
wire  [1:0]   axi4l_rresp;
wire  [31:0]  axi4l_rdata;

//reg FIFO signals
wire          s_axis_tready;
reg [31:0]    s_axis_tdata;
reg           s_axis_tvalid;

//wire FIFO signals
wire          m_axis_tvalid; 
reg           m_axis_tready;                     
wire [31:0]   m_axis_tdata;  

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
    .DEVICE_ID(DEVICE_ID)
) dut (
    // Module regs
    .bus_reset(bus_reset),
    .core_clock(core_clock),

    // Register interface signals
    .axi4l_aclk(reg_clk),
    .axi4l_aresetn(axi4l_aresetn),
    .axi4l_awready(axi4l_awready),
    .axi4l_awvalid(axi4l_awvalid),
    .axi4l_awaddr(axi4l_awaddr),
    .axi4l_awprot(axi4l_awprot),
    .axi4l_wready(axi4l_wready),
    .axi4l_wvalid(axi4l_wvalid),
    .axi4l_wdata(axi4l_wdata),
    .axi4l_wstrb(axi4l_wstrb),
    .axi4l_bready(axi4l_bready),
    .axi4l_bvalid(axi4l_bvalid),
    .axi4l_bresp(axi4l_bresp),
    .axi4l_arready(axi4l_arready),
    .axi4l_arvalid(axi4l_arvalid),
    .axi4l_araddr(axi4l_araddr),
    .axi4l_arprot(axi4l_arprot),
    .axi4l_rready(axi4l_rready),
    .axi4l_rvalid(axi4l_rvalid),
    .axi4l_rresp(axi4l_rresp),
    .axi4l_rdata(axi4l_rdata),

    //reg FIFO signals
    .s_axis_aclk(bus_clock),
    .s_axis_tready(s_axis_tready),
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tuser(1'b0),
    .s_axis_tlast(1'b0),

    //wire FIFO signals
    .m_axis_aclk(bus_clock),
    .m_axis_tvalid(m_axis_tvalid), 
    .m_axis_tready(m_axis_tready),                      
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tuser(),
    .m_axis_tlast()
);

//program the core
initial begin
    axi4l_aresetn = 0;
    axi4l_arvalid = 0;
    axi4l_awvalid = 0;
    axi4l_wvalid = 0;
    axi4l_bready = 1;
    axi4l_rready = 1;

    #100
    @(negedge reg_clk);
    axi4l_aresetn = 1;

    //check register interface by reading device ID
    #100
    @(negedge reg_clk);
    fork
        begin
            axi4l_arvalid = 1;
            axi4l_araddr = 6<<2;
            axi4l_awprot = 0;
            @(posedge axi4l_arready);
            @(negedge reg_clk);
            axi4l_arvalid = 0;
        end
        begin
            @(posedge axi4l_rvalid);
            @(negedge reg_clk);
            if(axi4l_rdata[7:0] != DEVICE_ID) begin
                $display("Incorrect DEVICE ID read");
                $finish;
            end
        end
    join
    //program BTYPE
    @(negedge reg_clk);
    axi4l_awaddr = 1<<2;
    axi4l_awvalid = 1;
    axi4l_wvalid = 1;
    axi4l_wdata = `FIXED_HUFFMAN;
    axi4l_wstrb = 4'b1111;
    fork
        begin
            @(posedge axi4l_awready);
            @(negedge reg_clk);
            axi4l_awvalid = 0;
        end
        begin
            @(posedge axi4l_wready);
            @(negedge reg_clk);
            axi4l_wvalid = 0;
        end
    join
    //reset and de-reset core
    @(negedge reg_clk);
    axi4l_awaddr = 0;
    axi4l_awvalid = 1;
    axi4l_wvalid = 1;
    axi4l_wdata = 0;
    axi4l_wstrb = 4'b1111;
    fork
        begin
            @(posedge axi4l_awready);
            @(negedge reg_clk);
            axi4l_awvalid = 0;
        end
        begin
            @(posedge axi4l_wready);
            @(negedge reg_clk);
            axi4l_wvalid = 0;
        end
    join
    #100
    @(negedge reg_clk);
    axi4l_awaddr = 0;
    axi4l_awvalid = 1;
    axi4l_wvalid = 1;
    axi4l_wdata = 1;
    axi4l_wstrb = 4'b1111;
    fork
        begin
            @(posedge axi4l_awready);
            @(negedge reg_clk);
            axi4l_awvalid = 0;
        end
        begin
            @(posedge axi4l_wready);
            @(negedge reg_clk);
            axi4l_wvalid = 0;
        end
    join
    //signal end of configuration sequence
    #1000
    config_done = 1;
end

//input data
initial begin
    bus_reset = 1;
    s_axis_tdata = 0;
    s_axis_tvalid = 0;
    @(posedge config_done);
    //open input file
    in_file = $fopen(INPUT_FILE,"rb");
    $display("Opened input file: %s %d",INPUT_FILE,in_file);
    //signal FIFO open
    @(negedge bus_clock);
    bus_reset = 0;
    //read and push into FIFO
    nbytes = 1;
    @(negedge bus_clock);
    while(nbytes != 0) begin
        if(~s_axis_tready) begin
            s_axis_tvalid = 0;
        end else begin
            s_axis_tvalid = 1;
            repeat(4) begin
                nbytes = $fread(byte_read,in_file);
                s_axis_tdata = {s_axis_tdata[23:0],(nbytes != 0)?byte_read:8'd0};
            end
        end
        @(negedge bus_clock);
    end
    s_axis_tvalid = 0;
    //close input file
    $fclose(in_file);
end

//output results
initial begin
    m_axis_tready = 1;
    @(posedge config_done);
    //open output file
    out_file = $fopen(OUTPUT_FILE,"wb");
    $display("Opened output file: %s %d",OUTPUT_FILE,out_file);
    //signal FIFO open
    @(negedge bus_clock);
    forever begin
        @(negedge bus_clock);
        if(m_axis_tvalid) begin
            $fwriteb(out_file,"%c%c%c%c",m_axis_tdata[7:0],m_axis_tdata[15:8],m_axis_tdata[23:16],m_axis_tdata[31:24]);
            $fflush(out_file);
            read_timeout = 0;
        end else
            read_timeout = read_timeout + 1;
        if(read_timeout == 1000) begin
            $fclose(out_file);
            #1000
            $finish;
        end
    end
end

endmodule
