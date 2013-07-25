module bps_master(rst, clk, start, stall, bps_opcode, bps_stall);
    input rst;
    input clk;
    input start;
    output reg stall;
    output reg [2:0] bps_opcode;
    `define OP_IDLE 0
    `define OP_LOAD 1
    `define OP_DOWN 2
    `define OP_UP 3
    `define OP_STORE_DOWN 4
    `define OP_STORE_UP 5
    input bps_stall;
    
    reg [2:0] state;
    `define IDLE 0
    `define LOAD_DATA 1
    `define LOAD_DATA_WAIT 2
    `define DOWN_BPS 3
    `define DOWN_BPS_WAIT 4
    `define STORE_DOWN 5
    `define STORE_DOWN_WAIT 6
    always @(posedge clk) begin
        if(rst) begin
            state <= `IDLE;
        end else begin
            case(state)
                `IDLE:
                    if(start)
                        state <= `LOAD_DATA;
                `LOAD_DATA: begin
                    $display("LOADING Data");
                    state <= `LOAD_DATA_WAIT;
                end
                `LOAD_DATA_WAIT:
                    if(!bps_stall)
                        state <= `DOWN_BPS;
                `DOWN_BPS:begin
                    state <= `DOWN_BPS_WAIT;
                    $display("Downward BP-S");
                 end
                `DOWN_BPS_WAIT:
                    if(!bps_stall)
                        state <= `STORE_DOWN;
                `STORE_DOWN: begin
                    state <= `STORE_DOWN_WAIT;
                    $display("Storing downward");
                end
                `STORE_DOWN_WAIT:
                    if(!bps_stall)
                        state <= `IDLE;
            endcase
        end
    end
    always @* begin
        stall = 1;
        bps_opcode = `OP_IDLE;
        case(state)
            `IDLE:
                stall = 0;
            `LOAD_DATA:
                bps_opcode = `OP_LOAD;
            `LOAD_DATA_WAIT: begin
            end
            `DOWN_BPS:
                bps_opcode = `OP_DOWN;
            `DOWN_BPS_WAIT: begin
            end
            `STORE_DOWN:
                bps_opcode  = `OP_STORE_DOWN;
            `STORE_DOWN_WAIT: begin
            end
        endcase
    end

endmodule
