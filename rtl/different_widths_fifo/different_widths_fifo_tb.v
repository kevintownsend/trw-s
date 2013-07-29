`timescale 1ns/1ps
module different_widths_fifo_tb;

reg rst, clk;
reg push, pop;
reg [7:0] d;
wire [3:0] q;
wire full, empty;


different_widths_fifo #(8,4) dut(
    rst,
    clk,
    push,
    pop,
    d,
    q,
    full,
    empty);
integer i;

initial begin
    rst = 1;
    push = 0; pop = 0;
    d = 0;

    #100 rst = 0;
    #11 if(empty != 1) begin
        $display("test1:failed");
    end else begin
        $display("test1:passed");
    end
    #10 push <=1;
    d <= 1;
    if(empty == 0)
        $display("test2:failed");
    if(full == 1)
        $display("test2:failed full high");
    for(i = 2; i < 64; i = i + 1) begin
        #10 push <=1;
        d <= i;
        if(empty == 1) begin
            $display("test3:failed empty high, round %d", i);
        end
        if(full == 1)
            $display("test3:failed full high");
    end
    #10 push <= 1;
    d <= 64;
    if(empty == 1)
        $display("error");
    if(full == 1)
        $display("error");
    #10 if(full == 1)
        $display("test4:passed");
    else
        $display("test4:error");
    push <= 0;
    pop <= 1;
    for(i = 1; i < 65; i = i + 1) begin
        #10 
        if(q != i % 16) begin
            $display("ERROR: %H", i);
        end
        #10 
        if(q != i / 16) begin
            $display("ERROR:");
        end

    end
    pop <= 0;
    #10 
    if(empty != 1)
        $display("ERROR:");
    else
        $display("test5:passed");
    if(full != 0)
        $display("ERROR:");
    #100 $finish;

    //TODO: check empty
end

initial begin
    clk = 1;
    forever #5 clk=~clk;
end

endmodule
