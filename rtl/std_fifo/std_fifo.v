`timescale 1ns/1ps
module std_fifo(rst, clk, push, pop, d, q, full, empty, count, almost_empty, almost_full);
    parameter WIDTH = 8;
    parameter DEPTH = 6;
    parameter ALMOST_EMPTY_COUNT = 1;
    parameter ALMOST_FULL_COUNT = 1;
    input rst;
    input clk;
    input push;
    input pop;
    input [WIDTH-1:0] d;
    output [WIDTH-1:0] q;
    output full;
    output empty;
    output [DEPTH:0]count;
    output almost_empty;
    output almost_full;

reg [WIDTH-1:0] r_q;
reg [DEPTH:0] r_end;
reg [DEPTH:0] r_beg;
reg r_empty, r_full;

reg [WIDTH-1:0] ram [(2**DEPTH)-1:0];
always @(posedge clk) begin
    if(rst) begin
        r_end <= 0;
        r_beg <= 0;
    end
    r_q <= ram[r_end];
    if(pop)
        r_end <= r_end + 1;
    if(push) begin
        r_beg <= r_beg + 1;
        ram[r_beg] <= d;
    end
    //TODO: make correct
    r_empty <= 1;
    r_full <= 1;
end
assign q = r_q;
assign empty = (r_end == r_beg);
assign full = (r_end[DEPTH-1:0] == r_beg[DEPTH-1:0]) && (r_end[DEPTH] != r_beg[DEPTH]);
assign count = r_beg - r_end;
assign almost_empty = (count < (1+ALMOST_EMPTY_COUNT));
assign almost_full = (count > (2**DEPTH-1-ALMOST_FULL_COUNT));

endmodule
