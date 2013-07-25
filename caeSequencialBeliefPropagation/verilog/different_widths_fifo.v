`timescale 1ns/1ps
module different_widths_fifo(rst, clk, push, pop, d, q, full, empty, count, almost_empty, almost_full);
    parameter INPUT_WIDTH = 8;
    parameter OUTPUT_WIDTH = 4;
    parameter DEPTH = 6;
    parameter ALMOST_EMPTY_COUNT = 1;
    parameter ALMOST_FULL_COUNT = 1;
    parameter WIDTH_RATIO = INPUT_WIDTH / OUTPUT_WIDTH;
    input rst;
    input clk;
    input push;
    input pop;
    input [INPUT_WIDTH-1:0] d;
    output [OUTPUT_WIDTH-1:0] q;
    output full;
    output empty;
    output [DEPTH:0]count;
    output almost_empty;
    output almost_full;

reg [OUTPUT_WIDTH-1:0] r_q;
reg [DEPTH + INPUT_WIDTH / OUTPUT_WIDTH - 1:0] r_end;
reg [DEPTH:0] r_beg;
reg r_empty, r_full;
wire [DEPTH:0] upper_r_end;
assign upper_r_end = r_end[DEPTH + WIDTH_RATIO - 1 -: DEPTH+1];

reg [INPUT_WIDTH-1:0] ram [(2**DEPTH)-1:0];
always @(posedge clk) begin
    if(rst) begin
        r_end <= 0;
        r_beg <= 0;
    end
    r_q <= ram[r_end[DEPTH + WIDTH_RATIO - 2 -: DEPTH]][(r_end[WIDTH_RATIO - 2 :0] + 1) * OUTPUT_WIDTH - 1 -: OUTPUT_WIDTH];
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
assign empty = (upper_r_end == r_beg);
assign full = (upper_r_end[DEPTH-1:0] == r_beg[DEPTH-1:0]) && (upper_r_end[DEPTH] != r_beg[DEPTH]);
assign count = r_beg - upper_r_end;
assign almost_empty = (count < (1+ALMOST_EMPTY_COUNT));
assign almost_full = (count > (2**DEPTH-1-ALMOST_FULL_COUNT));

endmodule
