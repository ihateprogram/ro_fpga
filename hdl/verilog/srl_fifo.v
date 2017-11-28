module srl_fifo
#(
    parameter WIDTH = 1,
    parameter DEPTH_LOG = 3,
    parameter FALLTHROUGH = "true"
)
(
    input clock,
    input reset,
    
    input push,
    input [WIDTH-1:0] din,
    output full,
    
    input pop,
    output reg [WIDTH-1:0] dout,
    output empty
);

//check parameter sanity
initial begin
    if((FALLTHROUGH != "true") & (FALLTHROUGH != "false")) begin
        $display("Incorrect setting for FALLTHROUGH parameter, please set to true/false");
        $finish();
    end
end

reg [WIDTH-1:0] mem[0:2**DEPTH_LOG-1];
reg [DEPTH_LOG:0] count;

integer i;

//SRL shift register, we shift new data in on push
always @(posedge clock)
    if(push) begin
        mem[0] <= din;
        for(i=1;i<2**DEPTH_LOG;i=i+1) begin
            mem[i] <= mem[i-1];
        end
    end

//output from SRL
generate if(FALLTHROUGH == "true") begin: out_comb
    always @(*)
        dout = mem[count];
end else if(FALLTHROUGH == "false") begin: out_reg
    always @(posedge clock)
        if(pop)
            dout <= mem[count];
end
endgenerate
    
//modify count on push or pop
always @(posedge clock)
    if(reset)
        count <= {(DEPTH_LOG+1){1'b1}};
    else if(pop & ~push)
        count <= count - 1;
    else if(push & ~pop)
        count <= count + 1;
    
assign empty = count[DEPTH_LOG];
assign full = ~count[DEPTH_LOG] & &count[DEPTH_LOG-1:0];  
    
endmodule
