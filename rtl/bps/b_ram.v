module b_ram(clk, d_in, d_out, wr_en, addr);
    parameter WIDTH = 64;
    parameter DEPTH = 512;
    parameter ADDR_WIDTH = 9;
    input clk;
    input [WIDTH-1:0] d_in;
    output reg [WIDTH-1:0] d_out;
    input wr_en;
    input [ADDR_WIDTH-1:0] addr;

    reg [WIDTH-1:0] ram [0:DEPTH-1];

    always @(posedge clk) begin
        if(wr_en)
            ram[addr] <= d_in;
        d_out <= ram[addr];
    end
endmodule
