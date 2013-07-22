module sequencial_message_passer(clk, horizontal_message_forward, horizontal_message_backward, vertical_message_forward, vertical_message_backward, data, push, valid, horizontal_out, vertical_out);
    parameter LABELS = 16;
    parameter MESSAGE_WIDTH = 6;
    parameter DATA_WIDTH = 8;
    parameter INTERNAL_WIDTH = DATA_WIDTH + 1;
    parameter LOG2_LABELS = 4;
    //TODO: add parameters
    input clk;
    input [LABELS*MESSAGE_WIDTH-1:0] horizontal_message_forward;
    input [LABELS*MESSAGE_WIDTH-1:0] horizontal_message_backward;
    input [LABELS*MESSAGE_WIDTH-1:0] vertical_message_forward;
    input [LABELS*MESSAGE_WIDTH-1:0] vertical_message_backward;
    input [LABELS*DATA_WIDTH-1:0] data;
    input push;
    output valid;
    output [LABELS*MESSAGE_WIDTH-1:0] horizontal_out;
    output [LABELS*MESSAGE_WIDTH-1:0] vertical_out;

    reg [MESSAGE_WIDTH-1:0] horizontal_message_forward_stg0 [0:LABELS-1];
    reg [MESSAGE_WIDTH-1:0] vertical_message_forward_stg0 [0:LABELS-1];
    reg [DATA_WIDTH-1:0] data_stg0 [0:LABELS-1];
    reg [MESSAGE_WIDTH-1:0] horizontal_message_backward_stg1 [0:LABELS-1];
    reg [MESSAGE_WIDTH-1:0] vertical_message_backward_stg1 [0:LABELS-1];

    genvar g;
    integer i, j, k;
    always @(posedge clk) begin
        for(i = 0; i < LABELS; i = i + 1) begin
            horizontal_message_forward_stg0[i] <= horizontal_message_forward[(i+1)*MESSAGE_WIDTH-1 -:MESSAGE_WIDTH];
            vertical_message_forward_stg0[i] <= vertical_message_forward[(i+1)*MESSAGE_WIDTH-1 -:MESSAGE_WIDTH];
            data_stg0[i] <= data[(i+1)*DATA_WIDTH-1 -:DATA_WIDTH];
        end
    end
    reg [INTERNAL_WIDTH-1:0] partial_sum_stg1 [0:LABELS-1];
    always @(posedge clk) begin
        for(i = 0; i < LABELS; i = i + 1) begin
            partial_sum_stg1[i] <= horizontal_message_forward_stg0[i] + vertical_message_forward_stg0[i] + data_stg0[i];
        end
        for(i = 0; i < LABELS; i = i + 1) begin
            horizontal_message_backward_stg1[i] <= horizontal_message_backward[(i+1)*MESSAGE_WIDTH-1 -:MESSAGE_WIDTH];
            vertical_message_backward_stg1[i] <= vertical_message_backward[(i+1)*MESSAGE_WIDTH-1 -:MESSAGE_WIDTH];
        end
    end

    reg [INTERNAL_WIDTH-1:0] horizontal_out_stg2 [0:LABELS-1];
    reg [INTERNAL_WIDTH-1:0] vertical_out_stg2 [0:LABELS-1];
    always @(posedge clk) begin
        for(i = 0; i < LABELS; i = i + 1) begin
            horizontal_out_stg2[i] <= partial_sum_stg1[i] + vertical_message_backward_stg1[i];
            vertical_out_stg2[i] <= partial_sum_stg1[i] + horizontal_message_backward_stg1[i];
        end 
    end

    //horizontal_out
    reg [INTERNAL_WIDTH-1:0] horizontal_min_calc_stg3 [0:LABELS-1][1:LOG2_LABELS];
    reg [INTERNAL_WIDTH-1:0] horizontal_min_stg3;
    always @(posedge clk) begin
        for(j = 0; j < LABELS; j = j + 2) begin
            if(horizontal_out_stg2[j] < horizontal_out_stg2[j+1])
                horizontal_min_calc_stg3[j][1] <= horizontal_out_stg2[j];
            else
                horizontal_min_calc_stg3[j][1] <= horizontal_out_stg2[j+1];
        end
        k = 1;
        for(i = 2; i < LABELS; i = 2*i) begin
            for(j = 0; j < LABELS; j = j + 2*i) begin
                if(horizontal_min_calc_stg3[j][k] < horizontal_min_calc_stg3[j+i][k])
                    horizontal_min_calc_stg3[j][k+1] <= horizontal_min_calc_stg3[j][k];
                else
                    horizontal_min_calc_stg3[j][k+1] <= horizontal_min_calc_stg3[j+i][k];
            end
            k = k + 1;
        end
    end
    always @*
        horizontal_min_stg3 = horizontal_min_calc_stg3[0][LOG2_LABELS];

    reg [INTERNAL_WIDTH-1:0] horizontal_smooth_stg3_1 [0:LABELS-1];
    reg [INTERNAL_WIDTH-1:0] horizontal_smooth_stg3_2 [0:LABELS-1];
    reg [INTERNAL_WIDTH-1:0] horizontal_smooth_stg3_3 [0:LABELS-1];
    reg [INTERNAL_WIDTH-1:0] horizontal_smooth_stg3_4 [0:LABELS-1];
    reg [INTERNAL_WIDTH-1:0] horizontal_smooth_high_stg3_1 [0:LABELS-1];
    reg [INTERNAL_WIDTH-1:0] horizontal_smooth_high_stg3_2 [0:LABELS-1];
    always @(posedge clk) begin
        for(i = 0; i < LABELS; i = i + 1) begin
            horizontal_smooth_high_stg3_1[i] <= horizontal_out_stg2[i] + 16;
            horizontal_smooth_stg3_1[i] <= horizontal_out_stg2[i];
        end
    end
    always @(posedge clk) begin
        horizontal_smooth_stg3_2[0] <= horizontal_smooth_stg3_1[0];
        for(i = 0; i < LABELS; i = i + 1)
            horizontal_smooth_high_stg3_2[i] <= horizontal_smooth_high_stg3_1[i];
        for(i = 1; i < LABELS; i = i + 1) begin
            if(horizontal_smooth_high_stg3_1[i-1] < horizontal_smooth_stg3_1[i])
                horizontal_smooth_stg3_2[i] <= horizontal_smooth_high_stg3_1[i-1];
            else
                horizontal_smooth_stg3_2[i] <= horizontal_smooth_stg3_1[i];
        end
    end
    always @(posedge clk) begin
        horizontal_smooth_stg3_3[LABELS-1] <= horizontal_smooth_stg3_2[LABELS-1];
        for(i = 0; i < LABELS-1; i = i + 1) begin
            if(horizontal_smooth_high_stg3_2[i+1] < horizontal_smooth_stg3_2[i])
                horizontal_smooth_stg3_3[i] <= horizontal_smooth_high_stg3_2[i+1];
            else
                horizontal_smooth_stg3_3[i] <= horizontal_smooth_stg3_2[i];
        end
    end
    always @(posedge clk)
        for(i = 0; i < LABELS; i = i + 1)
            horizontal_smooth_stg3_4[i] <= horizontal_smooth_stg3_3[i];

    reg [INTERNAL_WIDTH-1:0] horizontal_out_stg4 [0:LABELS-1];
    reg [INTERNAL_WIDTH-1:0] tmp_stg4;
    always @(posedge clk) begin
        for(i = 0; i < LABELS; i = i + 1) begin
            tmp_stg4 = horizontal_smooth_stg3_4[i] - horizontal_min_stg3;
            if(tmp_stg4 > 32)
                horizontal_out_stg4[i] <= 32;
            else
                horizontal_out_stg4[i] <= tmp_stg4;
        end
    end
    
    generate
        for(g = 0; g < LABELS; g = g + 1) begin
            assign horizontal_out[(g+1)*MESSAGE_WIDTH-1 -:MESSAGE_WIDTH] = horizontal_out_stg4[g];
        end
    endgenerate

    //vertical_out
    reg [INTERNAL_WIDTH-1:0] vertical_min_calc_stg3 [0:LABELS-1][1:LOG2_LABELS];
    reg [INTERNAL_WIDTH-1:0] vertical_min_stg3;
    always @(posedge clk) begin
        for(j = 0; j < LABELS; j = j + 2) begin
            if(vertical_out_stg2[j] < vertical_out_stg2[j+1])
                vertical_min_calc_stg3[j][1] <= vertical_out_stg2[j];
            else
                vertical_min_calc_stg3[j][1] <= vertical_out_stg2[j+1];
        end
        k = 1;
        for(i = 2; i < LABELS; i = 2*i) begin
            for(j = 0; j < LABELS; j = j + 2*i) begin
                if(vertical_min_calc_stg3[j][k] < vertical_min_calc_stg3[j+i][k])
                    vertical_min_calc_stg3[j][k+1] <= vertical_min_calc_stg3[j][k];
                else
                    vertical_min_calc_stg3[j][k+1] <= vertical_min_calc_stg3[j+i][k];
            end
            k = k + 1;
        end
        vertical_min_stg3 = vertical_min_calc_stg3[0][LOG2_LABELS];
    end

    reg [INTERNAL_WIDTH-1:0] vertical_smooth_stg3_1 [0:LABELS-1];
    reg [INTERNAL_WIDTH-1:0] vertical_smooth_stg3_2 [0:LABELS-1];
    reg [INTERNAL_WIDTH-1:0] vertical_smooth_stg3_3 [0:LABELS-1];
    reg [INTERNAL_WIDTH-1:0] vertical_smooth_stg3_4 [0:LABELS-1];
    reg [INTERNAL_WIDTH-1:0] vertical_smooth_high_stg3_1 [0:LABELS-1];
    reg [INTERNAL_WIDTH-1:0] vertical_smooth_high_stg3_2 [0:LABELS-1];
    always @(posedge clk) begin
        for(i = 0; i < LABELS; i = i + 1) begin
            vertical_smooth_high_stg3_1[i] <= vertical_out_stg2[i] + 16;
            vertical_smooth_stg3_1[i] <= vertical_out_stg2[i];
        end
    end
    always @(posedge clk) begin
        vertical_smooth_stg3_2[0] <= vertical_smooth_stg3_1[0];
        for(i = 0; i < LABELS; i = i + 1)
            vertical_smooth_high_stg3_2[i] <= vertical_smooth_high_stg3_1[i];
        for(i = 1; i < LABELS; i = i + 1) begin
            if(vertical_smooth_high_stg3_1[i-1] < vertical_smooth_stg3_1[i])
                vertical_smooth_stg3_2[i] <= vertical_smooth_high_stg3_1[i-1];
            else
                vertical_smooth_stg3_2[i] <= vertical_smooth_stg3_1[i];
        end
    end
    always @(posedge clk) begin
        vertical_smooth_stg3_3[LABELS-1] <= vertical_smooth_stg3_2[LABELS-1];
        for(i = 0; i < LABELS-1; i = i + 1) begin
            if(vertical_smooth_high_stg3_2[i+1] < vertical_smooth_stg3_2[i])
                vertical_smooth_stg3_3[i] <= vertical_smooth_high_stg3_2[i+1];
            else
                vertical_smooth_stg3_3[i] <= vertical_smooth_stg3_2[i];
        end
    end
    always @(posedge clk)
        for(i = 0; i < LABELS; i = i + 1)
            vertical_smooth_stg3_4[i] <= vertical_smooth_stg3_3[i];

    reg [INTERNAL_WIDTH-1:0] vertical_out_stg4 [0:LABELS-1];
    //reg [INTERNAL_WIDTH-1:0] tmp_stg4;
    always @(posedge clk) begin
        for(i = 0; i < LABELS; i = i + 1) begin
            tmp_stg4 = vertical_smooth_stg3_4[i] - vertical_min_stg3;
            if(tmp_stg4 > 32)
                vertical_out_stg4[i] <= 32;
            else
                vertical_out_stg4[i] <= tmp_stg4;
        end
    end
    
    generate
        for(g = 0; g < LABELS; g = g + 1) begin
            assign vertical_out[(g+1)*MESSAGE_WIDTH-1 -:MESSAGE_WIDTH] = vertical_out_stg4[g];
        end
    endgenerate

    reg [0:7] valid_pipe;
    always @(posedge clk) begin
        valid_pipe[0] <= push;
        valid_pipe[1:7] <= valid_pipe[0:6];
    end
    assign valid = valid_pipe[7];
    /*
    always @(posedge clk) begin
        if(horizontal_min_stg3)
            $display("min calced at %d, min: %d", $time, horizontal_min_stg3);
        if(valid_pipe[6]) begin
            $display("min_calc: %d", horizontal_min_stg3);
            $display("horizontal_smooth_stg3:");
            for(i = 0; i < LABELS; i = i + 1) begin
                $display(horizontal_smooth_stg3_4[i]);
            end
        end
        if(valid_pipe[2]) begin
            $display("horizontal_out_stg2[0]: %d", horizontal_out_stg2[0]);
            for(i = 0; i < LABELS; i = i + 1) begin
                $display(horizontal_out_stg2[i]);
            end
        end
        if(valid_pipe[1])begin
            $display("vertical_backward_stg1");
            for(i = 0; i < LABELS; i = i + 1) begin
                $display(vertical_message_backward_stg1[i]);
            end
        end
    end
    */
endmodule
