module bps(rst, clk, stall, opcode, addr_base, mc_req_ld, mc_req_st, mc_req_vadr, mc_req_wrd_rdctl, mc_req_stall, mc_rsp_rdctl, mc_rsp_data, mc_rsp_push, mc_rsp_stall, up_in, up_out, down_in, down_out);
    `include "log2.vh"
    parameter FIELD_WIDTH = 128;
    parameter FIELD_HEIGHT = 128;
    parameter LABELS = 16;
    parameter MESSAGE_WIDTH = 6;
    parameter DATA_WIDTH = 8;
    parameter STRIDE = 1;
    parameter MEMORY_ADDR_WIDTH = log2(FIELD_WIDTH * FIELD_HEIGHT - 1);
    parameter LOG2_LABELS = log2(LABELS-1);
    input rst;
    input clk;
    output reg stall;
    input [2:0] opcode;
    `define OP_IDLE 0
    `define OP_LOAD 1
    `define OP_DOWN 2
    `define OP_UP 3
    `define OP_STORE_DOWN 4
    `define OP_STORE_UP 5
    input [63:0] addr_base;
    output reg mc_req_ld;
    output reg mc_req_st;
    output reg [47:0] mc_req_vadr;
    output reg [63:0] mc_req_wrd_rdctl;
    input mc_req_stall;
    input [31:0] mc_rsp_rdctl;
    input [63:0] mc_rsp_data;
    input mc_rsp_push;
    output mc_rsp_stall;
    input [LABELS*MESSAGE_WIDTH-1:0] up_in;
    output [LABELS*MESSAGE_WIDTH-1:0] up_out;
    input [LABELS*MESSAGE_WIDTH-1:0] down_in;
    output [LABELS*MESSAGE_WIDTH-1:0] down_out;
    //TODO: memorys data horizontal_messages vertical_messages
    reg [2:0] state, next_state;
    `define IDLE_STATE 0
    `define LOAD_FIELD_PACKAGE_STATE 1
    `define SET_POINTERS_STATE 2
    `define LOAD_DATA_STATE 3
    `define DOWN_STATE 4
    `define UP_STATE 5
    `define STORE_DOWN_STATE 6
    `define STORE_UP_STATE 7
    reg [63:0] data_pointer;
    reg [63:0] message_pointer;
    reg [63:0] assignments_pointer;
    reg [47:0] current_pointer, next_current_pointer;
    reg up_down;
    reg next_mc_req_ld, next_mc_req_st;
    reg [47:0] next_mc_req_vadr;
    reg [63:0] next_mc_req_wrd_rdctl;

    reg [DATA_WIDTH*LABELS-1:0] data_memory_d_in, next_data_memory_d_in;
    wire [DATA_WIDTH*LABELS-1:0] data_memory_d_out;
    reg [MEMORY_ADDR_WIDTH:0] data_memory_addr, next_data_memory_addr;
    reg [MESSAGE_WIDTH*LABELS-1:0] vertical_message_memory_d_in, next_vertical_message_memory_d_in;
    wire [MESSAGE_WIDTH*LABELS-1:0] vertical_message_memory_d_out;
    reg [MEMORY_ADDR_WIDTH - 1:0] vertical_message_memory_addr, next_vertical_message_memory_addr;
    reg vertical_message_memory_write, next_vertical_message_memory_write;
    reg [MESSAGE_WIDTH*LABELS-1:0] horizontal_message_memory_d_in, next_horizontal_message_memory_d_in;
    wire [MESSAGE_WIDTH*LABELS-1:0] horizontal_message_memory_d_out;
    reg [MEMORY_ADDR_WIDTH:0] horizontal_message_memory_addr_a, next_horizontal_message_memory_addr_a;
    reg [MEMORY_ADDR_WIDTH:0] horizontal_message_memory_addr_b, next_horizontal_message_memory_addr_b;
    reg [MEMORY_ADDR_WIDTH:0] horizontal_message_memory_addr_buffer[0:1], next_horizontal_message_memory_addr_buffer[0:1];
    reg horizontal_message_memory_write, next_horizontal_message_memory_write;
    reg [63:0] addr_base_reg;
    always @* begin
        addr_base_reg = addr_base;
        data_pointer = addr_base_reg + {8'H5, 3'b0};
        message_pointer = addr_base_reg + {8'H5, 3'b0} + 2 * 8 * FIELD_WIDTH * FIELD_HEIGHT;
        assignments_pointer = addr_base_reg + {8'H5, 3'b0} + 2 * 5 * 8 * FIELD_WIDTH * FIELD_HEIGHT;
        
    end
    assign mc_rsp_stall = 0;
    reg [63:0] addr_reg;
    reg data_memory_write, next_data_memory_write;
    b_ram #(DATA_WIDTH*LABELS, FIELD_WIDTH*FIELD_HEIGHT, MEMORY_ADDR_WIDTH) data_memory (clk, data_memory_d_in, data_memory_d_out, data_memory_write, data_memory_addr);
    b_ram #(MESSAGE_WIDTH*LABELS, FIELD_WIDTH*FIELD_HEIGHT, MEMORY_ADDR_WIDTH) vertical_message_memory (clk, vertical_message_memory_d_in, vertical_message_memory_d_out, vertical_message_memory_write, vertical_message_memory_addr);
    simple_dual_port_b_ram #(MESSAGE_WIDTH*LABELS, FIELD_WIDTH*FIELD_HEIGHT, MEMORY_ADDR_WIDTH) horizontal_message_memory (clk, horizontal_message_memory_d_in, horizontal_message_memory_d_out, horizontal_message_memory_write, horizontal_message_memory_addr_a, horizontal_message_memory_addr_b);
    //TODO: message passer
    reg [LABELS * MESSAGE_WIDTH - 1:0] smp_horizontal_message_forward, next_smp_horizontal_message_forward;
    reg [LABELS * MESSAGE_WIDTH - 1:0] smp_horizontal_message_backward, next_smp_horizontal_message_backward;
    reg [LABELS * MESSAGE_WIDTH - 1:0] smp_vertical_message_forward, next_smp_vertical_message_forward;
    reg [LABELS * MESSAGE_WIDTH - 1:0] smp_vertical_message_backward, next_smp_vertical_message_backward; reg [LABELS * DATA_WIDTH - 1:0] smp_data, next_smp_data;
    reg smp_push, next_smp_push;
    reg [1:0] smp_push_delay, next_smp_push_delay;
    wire smp_valid;
    wire [LABELS * MESSAGE_WIDTH - 1:0] smp_horizontal_out;
    wire [LABELS * MESSAGE_WIDTH - 1:0] smp_vertical_out;

    sequencial_message_passer #(LABELS, MESSAGE_WIDTH, DATA_WIDTH, DATA_WIDTH+1, LOG2_LABELS) smp(clk, smp_horizontal_message_forward, smp_horizontal_message_backward, smp_vertical_message_forward, smp_vertical_message_backward, smp_data, smp_push, smp_valid, smp_horizontal_out, smp_vertical_out);
    reg [2:0] line, next_line;
    reg [7:0] active_lines, next_active_lines;
    reg [MEMORY_ADDR_WIDTH:0] phase_addr [0:7];
    reg phase_addr_wr;
    wire [MEMORY_ADDR_WIDTH:0] phase_addr_out;
    reg [MEMORY_ADDR_WIDTH:0] phase_addr_in;
    assign phase_addr_out = phase_addr[line];
    always @(posedge clk) begin
        phase_addr[line] <= phase_addr_in;
    end

    reg [31:0] counter, next_counter;
    //TODO: output fifo
    reg output_fifo_push, output_fifo_pop;
    wire [63:0] output_fifo_q;
    reg [127:0] output_fifo_d;
    wire output_fifo_full;
    wire output_fifo_empty;
    wire [5:0] output_fifo_count;
    wire output_fifo_almost_empty;
    wire output_fifo_almost_full;
    reg output_fifo_valid, next_output_fifo_valid;
    reg [48 * 2 - 1:0] output_address_fifo_d;
    wire [47:0] output_address_fifo_q;

    different_widths_fifo #(128, 64, 5, 1, 4) output_fifo(rst, clk, output_fifo_push, output_fifo_pop, output_fifo_d, output_fifo_q, output_fifo_full, output_fifo_empty, output_fifo_count, output_fifo_almost_empty, output_fifo_almost_full);
    different_widths_fifo #(48 * 2, 48, 5, 1, 4) output_address_fifo(rst, clk, output_fifo_push, output_fifo_pop, output_address_fifo_d, output_address_fifo_q, , , , , );
    integer i;
    wire [47:0] current_pointer_plus_one;
    assign current_pointer_plus_one = current_pointer + 8;
    wire [MEMORY_ADDR_WIDTH:0] horizontal_message_memory_addr_buffer_0;
    wire [MEMORY_ADDR_WIDTH:0] horizontal_message_memory_addr_buffer_1;
    assign horizontal_message_memory_addr_buffer_0 = horizontal_message_memory_addr_buffer[0];
    assign horizontal_message_memory_addr_buffer_1 = horizontal_message_memory_addr_buffer[1];
    always @* begin
        next_current_pointer = current_pointer;
        next_state = state;
        next_mc_req_ld = 0;
        next_mc_req_st = 0;
        next_mc_req_vadr = 0;
        next_mc_req_wrd_rdctl = 0;
        next_data_memory_addr = -1;
        next_data_memory_d_in = 0;
        next_data_memory_write = 0;
        next_line = 0;
        phase_addr_in = 0;
        phase_addr_wr = 1;
        next_active_lines = 0;
        next_vertical_message_memory_d_in = 0;
        next_vertical_message_memory_write = 0;
        next_vertical_message_memory_addr = 0;
        next_horizontal_message_memory_d_in = 0;
        next_horizontal_message_memory_write = 0;
        next_horizontal_message_memory_addr_b = horizontal_message_memory_addr_b;
        next_horizontal_message_memory_addr_a = horizontal_message_memory_addr_a;
        next_smp_push = smp_push_delay[1];
        next_smp_push_delay[1] = smp_push_delay[0];
        next_smp_push_delay[0] = 0;
        next_smp_horizontal_message_forward = 0;
        next_smp_horizontal_message_backward = 0;
        next_smp_vertical_message_forward = 0;
        next_smp_vertical_message_backward = 0;
        next_smp_data = 0;
        next_output_fifo_valid = 0;
        output_fifo_pop = 0;
        output_fifo_push = 0;
        output_fifo_d = 0;
        next_counter = 0;
        next_horizontal_message_memory_addr_buffer[0] = 0;
        next_horizontal_message_memory_addr_buffer[1] = horizontal_message_memory_addr_buffer_0;

        if(rst) begin 
            next_state = `IDLE_STATE;
            next_current_pointer = 0;
        end else begin
            case(state)
                `IDLE_STATE: begin
                    next_current_pointer = 0;
                    if(opcode == `OP_LOAD) begin
                        next_current_pointer = data_pointer;
                        next_state = `LOAD_DATA_STATE;
                        next_data_memory_addr = -1;
                        next_horizontal_message_memory_addr_a = -1;
                        next_vertical_message_memory_addr = -1;
                        next_counter = 0;
                    end else if(opcode == `OP_STORE_DOWN) begin
                        next_current_pointer = message_pointer;
                        next_horizontal_message_memory_addr_b = 0;
                        next_state = `STORE_DOWN_STATE;
                    end else if(opcode == `OP_DOWN) begin
                        next_horizontal_message_memory_addr_b = 0;
                        next_horizontal_message_memory_addr_a = 0;
                        next_state = `DOWN_STATE;
                        next_active_lines = 1;
                        next_line = 0;
                    end else if(opcode == `OP_UP)
                        next_state = `UP_STATE;
                end
                `LOAD_FIELD_PACKAGE_STATE: begin
                end
                `SET_POINTERS_STATE: begin
                end
                `LOAD_DATA_STATE: begin
                    next_line = line + 1;
                    if(data_memory_addr != FIELD_WIDTH * FIELD_HEIGHT - 1)
                        next_state = `LOAD_DATA_STATE;
                    else
                        next_state = `IDLE_STATE;
                    if(mc_req_stall || !(current_pointer < message_pointer))begin
                    end else begin
                        if(current_pointer < message_pointer) begin
                            next_current_pointer = current_pointer + 8;
                            next_mc_req_ld = 1;
                            next_horizontal_message_memory_write = 1;
                            next_vertical_message_memory_write = 1;
                        end
                        next_horizontal_message_memory_addr_a = horizontal_message_memory_addr_a + 1;
                        next_vertical_message_memory_addr = vertical_message_memory_addr + 1;
                        next_mc_req_vadr = current_pointer;
                    end
                    next_data_memory_addr = data_memory_addr;
                    next_data_memory_d_in = data_memory_d_in;
                    if(mc_rsp_push) begin
                        next_counter = counter + 1;
                        if(counter[0]) begin
                            next_data_memory_addr = data_memory_addr + 1;
                            next_data_memory_d_in[127:64] = mc_rsp_data;
                            next_data_memory_write = 1;
                        end else begin
                            next_data_memory_addr = data_memory_addr;
                            next_data_memory_d_in[63:0] = mc_rsp_data;
                        end
                    end else begin
                        next_counter = counter;
                        next_data_memory_addr = data_memory_addr;
                    end

                end
                `DOWN_STATE: begin
                    next_data_memory_addr = phase_addr_out;
                    next_vertical_message_memory_addr = phase_addr_out;
                    next_horizontal_message_memory_addr_b = phase_addr_out;
                    next_active_lines = active_lines;
                    next_line = line + 1;
                    next_state = `DOWN_STATE;
                    if(active_lines[line]) begin
                        next_smp_push_delay[0] = 1;
                        phase_addr_wr = 1;
                        phase_addr_in = phase_addr_out + 1;

                    end else
                        phase_addr_wr = 0;
                    if(smp_push_delay[1])
                        next_smp_data = data_memory_d_out;
                    next_horizontal_message_memory_addr_buffer[0] = horizontal_message_memory_addr_b;
                    next_horizontal_message_memory_addr_a = horizontal_message_memory_addr_buffer_1;

                    if(next_horizontal_message_memory_addr_a < FIELD_WIDTH)
                        next_horizontal_message_memory_write = smp_valid;
                    next_horizontal_message_memory_d_in = smp_horizontal_out;
                    if(horizontal_message_memory_addr_a >= FIELD_WIDTH)
                        next_state = `IDLE_STATE;

                    //next_state = `IDLE_STATE;
                    //TODO: count down timer
                    //TODO: 8bit on vector
                end
                `UP_STATE: begin
                end
                `STORE_DOWN_STATE: begin
                        if(counter == 4 || counter == 3)begin
                            if(output_fifo_almost_full || horizontal_message_memory_addr_b == FIELD_WIDTH)
                                next_counter = 4;
                            else 
                                next_counter = 0;
                        end else begin
                            next_counter = counter + 1;
                        end
                        if(counter == 2)
                            next_horizontal_message_memory_addr_b = horizontal_message_memory_addr_b + 1;
                        else
                            next_horizontal_message_memory_addr_b = horizontal_message_memory_addr_b;
                        case(counter)
                            0:begin
                                for(i = 0; i < 16; i = i + 1) begin
                                    output_fifo_d[(i+1)*8-1 -:8] = {2'H0, horizontal_message_memory_d_out[(i+1)*6 - 1 -:6]};
                                end
                                output_fifo_push = 1;
                                next_current_pointer = current_pointer + 8 * 4;
                                output_address_fifo_d = {current_pointer_plus_one, current_pointer};
                            end
                            1:begin
                                output_fifo_d = 0;
                                output_fifo_push = 1;
                                next_current_pointer = current_pointer + 8 * 4;
                                output_address_fifo_d = {current_pointer_plus_one, current_pointer};
                            end
                            2:begin
                            end
                            3:begin
                            end
                            default:begin
                            end
                        endcase

                    if(!output_fifo_empty && !mc_req_stall)begin
                        next_output_fifo_valid = 1;
                        output_fifo_pop = 1;
                    end
                    if(output_fifo_valid) begin
                        next_mc_req_wrd_rdctl = output_fifo_q;
                        next_mc_req_st = 1;
                        next_mc_req_vadr = output_address_fifo_q;
                    end
                    if(output_fifo_valid || !output_fifo_empty || horizontal_message_memory_addr_b != FIELD_WIDTH)
                        next_state = `STORE_DOWN_STATE;
                    else
                        next_state = `IDLE_STATE;
                end
                `STORE_UP_STATE: begin
                end
                
            endcase
        end
        
    end



    always @(posedge clk) begin
        horizontal_message_memory_addr_buffer[0] <= next_horizontal_message_memory_addr_buffer[0];
        horizontal_message_memory_addr_buffer[1] <= next_horizontal_message_memory_addr_buffer[1];
        smp_push_delay <= next_smp_push_delay;
        smp_push <= next_smp_push;
        smp_horizontal_message_forward <= next_smp_horizontal_message_forward;
        smp_horizontal_message_backward <= next_smp_horizontal_message_backward;
        smp_vertical_message_forward <= next_smp_vertical_message_forward;
        smp_vertical_message_backward <= next_smp_vertical_message_backward;
        smp_data <= next_smp_data;
        current_pointer <= next_current_pointer;
        state <= next_state;
        mc_req_vadr <= next_mc_req_vadr;
        mc_req_ld <= next_mc_req_ld;
        mc_req_wrd_rdctl <= next_mc_req_wrd_rdctl;
        mc_req_st <= next_mc_req_st;
        output_fifo_valid <= next_output_fifo_valid;
        data_memory_addr <= next_data_memory_addr;
        data_memory_d_in <= next_data_memory_d_in;
        data_memory_write <= next_data_memory_write;
        vertical_message_memory_addr <= next_vertical_message_memory_addr;
        vertical_message_memory_d_in <= next_vertical_message_memory_d_in;
        vertical_message_memory_write <= next_vertical_message_memory_write;
        horizontal_message_memory_addr_a <= next_horizontal_message_memory_addr_a;
        horizontal_message_memory_addr_b <= next_horizontal_message_memory_addr_b;
        horizontal_message_memory_d_in <= next_horizontal_message_memory_d_in;
        horizontal_message_memory_write <= next_horizontal_message_memory_write;
        active_lines <= next_active_lines;
        line <= next_line;
        counter <= next_counter;
    end
    always @* begin
        stall = !(state == `IDLE_STATE);
    end
    always @(posedge clk) begin
        if(opcode == `OP_LOAD)begin
            $display("opcode load");
            $display("current_pointer: %H", current_pointer);
            $display("next_current_pointer: %H", next_current_pointer);
            $display("data_pointer: %H", data_pointer);
        end
            
        if(state == `LOAD_DATA_STATE) begin
            $display("Load data state time: %d", $time);
            $display("mc_req_ld: %d", mc_req_ld);
            $display("mc_req_stall: %d", mc_req_stall);
            $display("current_pointer: %H", current_pointer);
            $display("message_pointer: %H", message_pointer);
            $display("data_pointer: %H", data_pointer);
        end
        if(data_memory_write)begin
            $display("writing %H to data at %H", data_memory_d_in, data_memory_addr);
        end
        if(state == `STORE_DOWN_STATE) begin
            $display("store down state time: %d", $time);
            $display("horizontal_memory: %H, data: %H", horizontal_message_memory_addr_b, horizontal_message_memory_d_out);
            if(output_fifo_push)
                $display("output_fifo_push: %H", output_fifo_d);
        end
        if(state == `DOWN_STATE) begin
            $display("down state time: %d", $time);
            $display(horizontal_message_memory_addr_a);
            $display(horizontal_message_memory_addr_b);
            $display(horizontal_message_memory_addr_buffer[1]);
            $display("phase: %H, addr: %H", phase_addr_out, line);

            if(horizontal_message_memory_write)
                $display("writing horizontal memory: %H at %H", horizontal_message_memory_d_in, horizontal_message_memory_addr_a);
            if(smp_valid)begin
                $display("smp_horizontal_out: %H", smp_horizontal_out);
            end
            if(active_lines[line]) begin
                $display("address: %H", phase_addr_out);
            end
            if(smp_push)begin
                $display("smp_push, data: %H", smp_data);
                //$display("data[1]: %H", data_memory.ram[1]);
            end
            if(smp_push_delay[0])begin
                $display("data address: %H", data_memory_addr);
            end
        end
    end


endmodule
