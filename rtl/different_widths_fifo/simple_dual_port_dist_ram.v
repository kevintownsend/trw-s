module simple_dual_port_dist_ram(clk, d_in, d_out, wr_en, addr_a, addr_b);
    parameter WIDTH = 64;
    parameter ADDR_WIDTH = 6;
    parameter DEPTH = 1<<ADDR_WIDTH;
    input clk;
    input [WIDTH-1:0] d_in;
    output reg [WIDTH-1:0] d_out;
    input wr_en;
    input [ADDR_WIDTH-1:0] addr_a;
    input [ADDR_WIDTH-1:0] addr_b;

    reg [WIDTH-1:0] ram [0:DEPTH-1];

    always @(posedge clk) begin
        if(wr_en)
            ram[addr_a] <= d_in;
    end
    always @*
        d_out <= ram[addr_b];
endmodule
