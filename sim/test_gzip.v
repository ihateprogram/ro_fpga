
`timescale 1 ns / 10 ps

`define NO_COMRESSION      2'b00
`define FIXED_HUFFMAN      2'b01


module test_gzip;

parameter DATA_WIDTH = 8;
parameter SEARCH_BUFFER_DEPTH = 8;
parameter DICTIONARY_DEPTH = 512;
parameter DICTIONARY_DEPTH_LOG = $clog2(DICTIONARY_DEPTH);
parameter LOOK_AHEAD_BUFF_DEPTH = 258;
parameter CNT_WIDTH = $clog2(LOOK_AHEAD_BUFF_DEPTH);
parameter DEVICE_ID = 8'hB9;

parameter INPUT_FILE = "input.bin";//compress this file
parameter OUTPUT_FILE = "output.bin";

//signals
reg bus_clock;         // the 2 clock signals
reg core_clock;
reg reg_clk;
reg bus_reset;

//AXI4-Lite Register interface signals
wire          axi4l_aresetn;
wire          axi4l_awready;
wire          axi4l_awvalid;
wire [7:0]    axi4l_awaddr;
wire [2:0]    axi4l_awprot;
wire          axi4l_wready;
wire          axi4l_wvalid;
wire [31:0]   axi4l_wdata;
wire [3:0]    axi4l_wstrb;
wire          axi4l_bready;
wire          axi4l_bvalid;
wire  [1:0]   axi4l_bresp;
wire          axi4l_arready;
wire          axi4l_arvalid;
wire [7:0]    axi4l_araddr;
wire [2:0]    axi4l_arprot;
wire          axi4l_rready;
wire          axi4l_rvalid;
wire  [1:0]   axi4l_rresp;
wire  [31:0]  axi4l_rdata;

//reg FIFO signals
wire          s_axis_tready;
wire [31:0]   s_axis_tdata;
wire          s_axis_tvalid;

//wire FIFO signals
wire          m_axis_tvalid; 
wire          m_axis_tready;                     
wire [31:0]   m_axis_tdata;  

wire config_done, source_done, sink_done;


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

initial begin
    bus_reset = 0;
    #100
    bus_reset = 1;
    #100
    bus_reset = 0;
    @((config_done & source_done & sink_done) == 1);
    #100
    $finish;
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
    .axi4l_aresetn(~bus_reset),
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

axi4lite_master_bfm #(      	
    .COMMAND_FILE("cmd.txt"),
    .ADDR_WIDTH(8)
)
config_master 
(
    // Register interface signals
    .axi4l_aclk(reg_clk),
    .axi4l_aresetn(~bus_reset),
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

    .done(config_done)
);

axis_master_bfm
#(
    .INPUT_FILE(INPUT_FILE),
    .TDATA_SIZE(32),
    .ENDIANNESS("little")
)
axis_source
(
    .aresetn(~(bus_reset | (config_done == 0))),
    .m_axis_aclk(bus_clock),
    .m_axis_tdata(s_axis_tdata),
    .m_axis_tvalid(s_axis_tvalid),
    .m_axis_tready(s_axis_tready),
    .m_axis_tlast(),
    .m_axis_tuser(),

    .done(source_done)
);

axis_slave_bfm
#(
    .OUTPUT_FILE(OUTPUT_FILE),
    .TDATA_SIZE(32),
    .ENDIANNESS("little")
)
axis_sink
(
    .aresetn(~(bus_reset | (config_done == 0))),
    .s_axis_aclk(bus_clock),
    .s_axis_tdata(m_axis_tdata),
    .s_axis_tvalid(m_axis_tvalid),
    .s_axis_tready(m_axis_tready),
    .s_axis_tlast(),
    .s_axis_tuser(),

    .done(sink_done)
);

endmodule
