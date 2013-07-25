`timescale 1ns/1ps
module sequencial_message_passer_tb();
    `define DATA_WIDTH 8
    `define LABELS 16
    `define MESSAGE_WIDTH 6
    reg rst, clk;
    reg [`LABELS*`MESSAGE_WIDTH-1:0] horizontal_message_forward;
    reg [`LABELS*`MESSAGE_WIDTH-1:0] horizontal_message_backward;
    reg [`LABELS*`MESSAGE_WIDTH-1:0] vertical_message_forward;
    reg [`LABELS*`MESSAGE_WIDTH-1:0] vertical_message_backward;
    reg [`LABELS*`DATA_WIDTH-1:0] data;
    reg push;
    wire valid;
    wire [`LABELS*`MESSAGE_WIDTH-1:0] horizontal_out;
    wire [`LABELS*`MESSAGE_WIDTH-1:0] vertical_out;
    
    sequencial_message_passer #(`LABELS, `MESSAGE_WIDTH, `DATA_WIDTH) dut(clk, horizontal_message_forward, horizontal_message_backward, vertical_message_forward, vertical_message_backward, data, push, valid, horizontal_out, vertical_out);

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    reg [`MESSAGE_WIDTH-1:0] horizontal_message_forward_2d [0:`LABELS-1];
    reg [`MESSAGE_WIDTH-1:0] horizontal_message_backward_2d [0:`LABELS-1];
    reg [`MESSAGE_WIDTH-1:0] vertical_message_forward_2d [0:`LABELS-1];
    reg [`MESSAGE_WIDTH-1:0] vertical_message_backward_2d [0:`LABELS-1];
    reg [`DATA_WIDTH-1:0] data_2d [0:`LABELS-1];
    reg [`MESSAGE_WIDTH-1:0] horizontal_out_2d [0:`LABELS-1];
    reg [`MESSAGE_WIDTH-1:0] vertical_out_2d [0:`LABELS-1];
    integer i;
    genvar g;
    generate
        for(g = 0; g < `LABELS; g = g + 1) begin
            always @(horizontal_message_forward_2d[g])
                horizontal_message_forward[(g+1)*`MESSAGE_WIDTH-1 -:`MESSAGE_WIDTH] = horizontal_message_forward_2d[g];
            always @(horizontal_message_backward_2d[g])
                horizontal_message_backward[(g+1)*`MESSAGE_WIDTH-1 -:`MESSAGE_WIDTH] = horizontal_message_backward_2d[g];
            always @(vertical_message_forward_2d[g])
                vertical_message_forward[(g+1)*`MESSAGE_WIDTH-1 -:`MESSAGE_WIDTH] = vertical_message_forward_2d[g];
            always @(vertical_message_backward_2d[g])
                vertical_message_backward[(g+1)*`MESSAGE_WIDTH-1 -:`MESSAGE_WIDTH] = vertical_message_backward_2d[g];
            always @(data_2d[g])
                data[(g+1)*`DATA_WIDTH-1 -:`DATA_WIDTH] = data_2d[g];
        end
    endgenerate

    always @* begin
        for(i = 0; i < `LABELS; i = i + 1) begin
            horizontal_out_2d[i] = horizontal_out[(i+1)*`MESSAGE_WIDTH-1 -:`MESSAGE_WIDTH];
            vertical_out_2d[i] = vertical_out[(i+1)*`MESSAGE_WIDTH-1 -:`MESSAGE_WIDTH];
        end
    end

    initial begin
        $display("testing sequencial_message_passer");
        rst = 1;
        for(i = 0; i < `LABELS; i = i + 1) begin
            data_2d[i] = 0;
            vertical_message_forward_2d[i] = 0;
            vertical_message_backward_2d[i] = 0;
            horizontal_message_forward_2d[i] = 0;
            horizontal_message_backward_2d[i] = 0;
        end 
        push = 0;
        #101 rst = 0;
        #100 push = 1;
        for(i = 0; i < `LABELS; i = i + 1) begin
            data_2d[i] = 1;
            vertical_message_forward_2d[i] = 1 + i;
            vertical_message_backward_2d[i] = 1 + i;
            horizontal_message_forward_2d[i] = 1 + i;
            horizontal_message_backward_2d[i] = 1 + i;
        end
        vertical_message_forward_2d[1] = 32;
        #10 push = 0;
        for(i = 0; i < `LABELS; i = i + 1) begin
            data_2d[i] = 0;
            vertical_message_forward_2d[i] = 0;
            vertical_message_backward_2d[i] = 0;
            horizontal_message_forward_2d[i] = 0;
            horizontal_message_backward_2d[i] = 0;
        end
        #10
        for(i = 0; i < `LABELS; i = i + 1) begin
            data_2d[i] = 0;
            vertical_message_forward_2d[i] = 0;
            vertical_message_backward_2d[i] = 0;
            horizontal_message_forward_2d[i] = 0;
            horizontal_message_backward_2d[i] = 0;
        end
        #100 push = 1;
        for(i = 0; i < `LABELS; i = i + 1) begin
            data_2d[i] = 1 + i;
            vertical_message_forward_2d[i] = 1 + i;
            vertical_message_backward_2d[i] = 1 + i + i;
            horizontal_message_forward_2d[i] = 1 + i;
            horizontal_message_backward_2d[i] = 1 + i;
        end
        data_2d[0] = 200;
        vertical_message_forward_2d[1] = 32;
        #10 push = 0;
        for(i = 0; i < `LABELS; i = i + 1) begin
            data_2d[i] = 0;
            vertical_message_forward_2d[i] = 0;
            vertical_message_backward_2d[i] = 0;
            horizontal_message_forward_2d[i] = 0;
            horizontal_message_backward_2d[i] = 0;
        end
        #10
        for(i = 0; i < `LABELS; i = i + 1) begin
            data_2d[i] = 0;
            vertical_message_forward_2d[i] = 0;
            vertical_message_backward_2d[i] = 0;
            horizontal_message_forward_2d[i] = 0;
            horizontal_message_backward_2d[i] = 0;
        end

        #100 $finish;
    end

    always @(posedge clk) begin
        if(valid) begin
            $display("vertical_out:");
            for(i = 0; i < `LABELS; i = i + 1)
                $display(vertical_out_2d[i]);
            $display("horizontal_out:");
            for(i = 0; i < `LABELS; i = i + 1)
                $display(horizontal_out_2d[i]);
        end 
    end
endmodule
