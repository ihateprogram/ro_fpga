/*  
Title:                       Deflate compressor
Author:                                        Ovidiu Plugariu

Description:   This top module contains a synchronization module, used to pass register values between clock domains,
            and a Deflate core.
*/


module gzip
    #(      	
        parameter DICTIONARY_DEPTH = 1024,	  // the size of the GZIP window -32k
		parameter DICTIONARY_DEPTH_LOG = 10,
	    parameter LOOK_AHEAD_BUFF_DEPTH = 66,     // the max length of the GZIP match
		parameter CNT_WIDTH = 7,                  // The counter size must be changed according to the maximum match length	
        parameter DEVICE_ID = 8'hBD
	)
    (
    // Module inputs
	input core_clock,

    input bus_reset,

    //AXI4-Lite interface
    input           axi4l_aclk,
    input           axi4l_aresetn,
    output          axi4l_awready,
    input           axi4l_awvalid,
    input [7:0]     axi4l_awaddr,
    input [2:0]     axi4l_awprot,
    output          axi4l_wready,
    input           axi4l_wvalid,
    input [31:0]    axi4l_wdata,
    input [3:0]     axi4l_wstrb,
    input           axi4l_bready,
    output          axi4l_bvalid,
    output  [1:0]   axi4l_bresp,
    output          axi4l_arready,
    input           axi4l_arvalid,
    input [7:0]     axi4l_araddr,
    input [2:0]     axi4l_arprot,
    input           axi4l_rready,
    output          axi4l_rvalid,
    output  [1:0]   axi4l_rresp,
    output  [31:0]  axi4l_rdata,

    output          irq,

    //input/output FIFO signals
    input         s_axis_aclk,
    input  [31:0] s_axis_tdata,
    input         s_axis_tvalid,
    output        s_axis_tready,
    input         s_axis_tlast,
    input         s_axis_tuser,

    input         m_axis_aclk,
    output [31:0] m_axis_tdata,
    output        m_axis_tvalid,
    input         m_axis_tready,
    output        m_axis_tlast,
    output        m_axis_tuser

    );

	// Internal logic
	reg gzip_rst_n;
    reg rev_endianness;
	reg [1:0] btype;
    wire [127:0] debug_reg;
	
    reg out_tvalid;
    wire [31:0] out_tdata;
    wire out_tready;
    wire out_tlast;

    reg [31:0] out_fifo_data_r;
    reg out_fifo_last_r;
    reg out_fifo_rden_r;

    wire        in_fifo_full;
	wire [31:0] in_fifo_data;
	wire        in_fifo_wren;

	wire        out_fifo_empty; 
	wire        out_fifo_rden;                     
	wire [31:0] out_fifo_data;

    //register access interface
    wire            reg_wren;
    wire [3:0]      reg_wstrb;
    wire            reg_rden;
    reg  [31:0]     reg_rd_data;
    wire [31:0]     reg_wr_data;
    wire [7:0]      reg_addr;
    reg             reg_rd_ack;
    reg             reg_wr_ack;

    reg  irq_enable;
    wire irq_int;

    //AXI4-Lite Slave Attachment
    axi4lite_slave #(
        .ADDR_WIDTH(8),
        .DATA_WIDTH(32)
    ) axi4l_slave (
        //system signals
        .axi4l_aclk,
        .axi4l_aresetn,
        //Write channels
        //write address
        .axi4l_awready,
        .axi4l_awvalid,
        .axi4l_awaddr,
        .axi4l_awprot,
        //write data
        .axi4l_wready,
        .axi4l_wvalid,
        .axi4l_wdata,
        .axi4l_wstrb,
        //burst response
        .axi4l_bready,
        .axi4l_bvalid,
        .axi4l_bresp,
        //Read channels
        //read address
        .axi4l_arready,
        .axi4l_arvalid,
        .axi4l_araddr,
        .axi4l_arprot,
        //read data
        .axi4l_rready,
        .axi4l_rvalid,
        .axi4l_rresp,
        .axi4l_rdata,
        //IP-side interface
        .ip_clk(core_clock),
        .ip_ren(reg_rden),
        .ip_wen(reg_wren),
        .ip_addr(reg_addr),
        .ip_wstrb(reg_wstrb),
        .ip_wdata(reg_wr_data),
        .ip_wack(reg_wr_ack),
        .ip_rack(reg_rd_ack),
        .ip_rdata(reg_rd_data),
        .ip_error(1'b0)//TODO: implment error checking
    );

    assign irq = irq_int & irq_enable;

   //=============================================================================================================
   //======================================== Configuration Registers ============================================
   //=============================================================================================================
    always @(posedge core_clock) begin
        reg_wr_ack <= reg_wren;
	    if(reg_wren)
            case(reg_addr[7:2])
                0:  gzip_rst_n  <= reg_wr_data[0];
                1:  {irq_enable,rev_endianness,btype} <= reg_wr_data[3:0];
            endcase
    end

    always @(posedge core_clock) begin
        reg_rd_ack <= reg_rden;
	    if(reg_rden)
            case(reg_addr[7:2])
                0:  reg_rd_data <= {31'd0,gzip_rst_n};
                1:  reg_rd_data <= {28'd0,irq_enable,rev_endianness,btype};
                2:  reg_rd_data <= {29'd0,debug_reg[2:0]};  // gzip_done, btype_error, block_size_error
                3:  reg_rd_data <= debug_reg[39:8];         // ISIZE
                4:  reg_rd_data <= debug_reg[71:40];        // CRC32
                5:  reg_rd_data <= debug_reg[95:72];        // block_size (24 bits)
                6:  reg_rd_data <= debug_reg[127:96];       // size of output stream in bits; NOTE: core pads with zeros up to a multiple of 64 bits on AXI interface
                default: reg_rd_data <= DEVICE_ID;
            endcase
    end
	
   //====================================================================================================================	
   //=========================================== Instantiate the GZIP core ==============================================
   //====================================================================================================================
   gzip_top
       #(      	
        .DICTIONARY_DEPTH(DICTIONARY_DEPTH),	                 // the size of the GZIP window
    	.DICTIONARY_DEPTH_LOG(DICTIONARY_DEPTH_LOG)           		
        )
      gzip_top_i0
       (
       // Module inputs 
       .xilly_clk       (core_clock),	// Xillybus clk signal  
       .clk             (core_clock),	// clk signal for all the GZIP logic  
       .rst_n           (gzip_rst_n),   // reset for the GZIP core
    
       .reset_fifo      (bus_reset),   // reset for the FIFOs	
       .wr_en_fifo_in   (in_fifo_wren & ~in_fifo_full), // write_enable for the input FIFO
       .din_fifo_in     (in_fifo_data), // 32 bit data input
       .rd_en_fifo_out  (out_fifo_rden),// read_enable for the output FIFO
	   .rev_endianess_in(rev_endianness),// Changes the endianess on I/O FIFOs
       .btype_in        (btype),        // Compression mode:   00 - no compression
                                        //                     01 - compressed with fixed Huffman codes
       // Module outputs
       .debug_reg       (debug_reg),
       .full_in_fifo    (in_fifo_full), // shows that we cannot write data in the input FIFO
       .dout_out_fifo_32(out_fifo_data),// 32 bit data output
       .last_out_fifo_32(out_fifo_last),// signals last word in output
       .empty_out_fifo  (out_fifo_empty),// shows that we CAN read from the output FIFO
       .irq             (irq_int)
       ); 

    //input AXIS adapter
    axis_async_fifo
    #(
        .DEPTH_LOG(10),
        .TDATA_SIZE(32),
        .TUSER_SIZE(1)
    )
    input_axis_adapter
    (
        .aresetn(~bus_reset),

        .s_axis_aclk(s_axis_aclk),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),
        .s_axis_tlast(s_axis_tlast),
        .s_axis_tuser(s_axis_tuser),
        
        .m_axis_aclk(core_clock),
        .m_axis_tdata(in_fifo_data),
        .m_axis_tvalid(in_fifo_wren),
        .m_axis_tready(~in_fifo_full),
        .m_axis_tlast(),
        .m_axis_tuser()
    );

    //output AXIS adapter
    axis_async_fifo
    #(
        .DEPTH_LOG(10),
        .TDATA_SIZE(32),
        .TUSER_SIZE(1)
    )
    output_axis_adapter
    (
        .aresetn(~bus_reset),

        .s_axis_aclk(core_clock),
        .s_axis_tdata(out_tdata),
        .s_axis_tvalid(out_tvalid),
        .s_axis_tready(out_tready),
        .s_axis_tlast(out_tlast),
        .s_axis_tuser(1'b0),
        
        .m_axis_aclk(m_axis_aclk),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready),
        .m_axis_tlast(m_axis_tlast),
        .m_axis_tuser(m_axis_tuser)
    );

    //adaptor logic to transfer from gzip to output AXIS FIFO
    assign out_fifo_rden = out_tready & ~out_fifo_empty;
    assign out_tdata = out_fifo_rden_r ? out_fifo_data : out_fifo_data_r;
    assign out_tlast = out_fifo_rden_r ? out_fifo_last : out_fifo_last_r;

    always @(posedge core_clock) begin
        out_fifo_rden_r <= out_fifo_rden;
        if(out_fifo_rden_r) begin
            out_fifo_data_r <= out_fifo_data;
            out_fifo_last_r <= out_fifo_last;
        end
        if(out_fifo_rden) begin
            out_tvalid <= 1;
        end else if(out_tready) begin
            out_tvalid <= 0;
        end
    end

endmodule
