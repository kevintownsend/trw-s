module bps(rst, clk, stall, opcode, addr_base, mc_req_ld, mc_req_st, mc_req_vadr, mc_req_wrd_rdctl, mc_req_stall, mc_rsp_rdctl, mc_rsp_data, mc_rsp_push, mc_rsp_stall, up_in, up_out, down_in, down_out, push_debug, debug0, debug1, debug2, debug3, debug4, debug5);
    `include "log2.vh"
    parameter FIELD_WIDTH = 4;
    parameter FIELD_HEIGHT = 4;
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
    output reg [LABELS*MESSAGE_WIDTH-1:0] up_out;
    input [LABELS*MESSAGE_WIDTH-1:0] down_in;
    output reg [LABELS*MESSAGE_WIDTH-1:0] down_out;
    output reg [0:5] push_debug;
    output reg [63:0] debug0, debug1, debug2, debug3, debug4, debug5;
    //TODO: memorys data horizontal_messages vertical_messages
    reg [0:5] next_push_debug;
    reg [63:0] next_debug0, next_debug1, next_debug2, next_debug3, next_debug4, next_debug5;
    reg [63:0] r_mc_rsp_data;
    reg r_mc_rsp_push;
    always @(posedge clk) begin
        r_mc_rsp_data <= mc_rsp_data;
        r_mc_rsp_push <= mc_rsp_push;
    end
    reg [3:0] state, next_state;
    `define IDLE_STATE 0
    `define LOAD_FIELD_PACKAGE_STATE 1
    `define SET_POINTERS_STATE 2
    `define LOAD_DATA_STATE 3
    `define DOWN_STATE 4
    `define UP_STATE 5
    `define STORE_STATE 6
    `define STORE_UP_STATE 7
    `define INIT_UP_STATE 8
    `define INIT_DOWN_STATE 9
    reg [63:0] data_pointer;
    reg [63:0] message_pointer;
    reg [63:0] assignments_pointer;
    reg [47:0] current_pointer, next_current_pointer;
    reg up_down;
    reg next_mc_req_ld, next_mc_req_st;
    reg [47:0] next_mc_req_vadr;
    reg [63:0] next_mc_req_wrd_rdctl;
    reg [63:0] inter_next_mc_req_wrd_rdctl;

    reg [DATA_WIDTH*LABELS-1:0] data_memory_d_in, next_data_memory_d_in;
    wire [DATA_WIDTH*LABELS-1:0] data_memory_d_out;
    reg [MEMORY_ADDR_WIDTH:0] data_memory_addr, next_data_memory_addr;
    reg [MEMORY_ADDR_WIDTH:0] vertical_message_memory_addr_buffer[0:1], next_vertical_message_memory_addr_buffer[0:1];
    reg [MESSAGE_WIDTH*LABELS-1:0] vertical_message_memory_d_in, next_vertical_message_memory_d_in;
    wire [MESSAGE_WIDTH*LABELS-1:0] vertical_message_memory_d_out;
    reg [MEMORY_ADDR_WIDTH:0] vertical_message_memory_addr_b, next_vertical_message_memory_addr_b;
    reg [MEMORY_ADDR_WIDTH:0] vertical_message_memory_addr_a, next_vertical_message_memory_addr_a;
    reg vertical_message_memory_write, next_vertical_message_memory_write;
    reg [MESSAGE_WIDTH*LABELS-1:0] horizontal_message_memory_d_in, next_horizontal_message_memory_d_in;
    wire [MESSAGE_WIDTH*LABELS-1:0] horizontal_message_memory_d_out;
    reg [MEMORY_ADDR_WIDTH:0] horizontal_message_memory_addr_a, next_horizontal_message_memory_addr_a;
    reg [MEMORY_ADDR_WIDTH:0] horizontal_message_memory_addr_b, next_horizontal_message_memory_addr_b;
    reg [MEMORY_ADDR_WIDTH:0] horizontal_message_memory_addr_buffer[0:1], next_horizontal_message_memory_addr_buffer[0:1];
    reg horizontal_message_memory_write, next_horizontal_message_memory_write;
    reg [63:0] addr_base_reg;
    always @(posedge clk) begin
        addr_base_reg <= addr_base;
        data_pointer <= addr_base_reg + 8*5;
        message_pointer <= data_pointer + 2 * 8 * FIELD_WIDTH * FIELD_HEIGHT;
        assignments_pointer <= message_pointer + 2 * 4 * 8 * FIELD_WIDTH * FIELD_HEIGHT;
    end
    assign mc_rsp_stall = 0;
    reg [63:0] addr_reg;
    reg data_memory_write, next_data_memory_write;
    b_ram #(DATA_WIDTH*LABELS, FIELD_WIDTH*FIELD_HEIGHT, MEMORY_ADDR_WIDTH) data_memory (clk, data_memory_d_in, data_memory_d_out, data_memory_write, data_memory_addr);
    simple_dual_port_b_ram #(MESSAGE_WIDTH*LABELS, FIELD_WIDTH*FIELD_HEIGHT, MEMORY_ADDR_WIDTH) vertical_message_memory (clk, vertical_message_memory_d_in, vertical_message_memory_d_out, vertical_message_memory_write, vertical_message_memory_addr_a, vertical_message_memory_addr_b);
    simple_dual_port_b_ram #(MESSAGE_WIDTH*LABELS, FIELD_WIDTH*FIELD_HEIGHT, MEMORY_ADDR_WIDTH) horizontal_message_memory (clk, horizontal_message_memory_d_in, horizontal_message_memory_d_out, horizontal_message_memory_write, horizontal_message_memory_addr_a, horizontal_message_memory_addr_b);
    //TODO: message passer
    reg [LABELS * MESSAGE_WIDTH - 1:0] smp_horizontal_message_forward, next_smp_horizontal_message_forward;
    reg [LABELS * MESSAGE_WIDTH - 1:0] smp_horizontal_message_backward, next_smp_horizontal_message_backward;
    reg [LABELS * MESSAGE_WIDTH - 1:0] smp_vertical_message_forward, next_smp_vertical_message_forward;
    reg [LABELS * MESSAGE_WIDTH - 1:0] smp_vertical_message_backward, next_smp_vertical_message_backward;
    reg [LABELS * DATA_WIDTH - 1:0] smp_data, next_smp_data;
    reg smp_push, next_smp_push;
    reg [1:0] smp_push_delay, next_smp_push_delay;
    wire smp_valid;
    wire [LABELS * MESSAGE_WIDTH - 1:0] smp_horizontal_out;
    wire [LABELS * MESSAGE_WIDTH - 1:0] smp_vertical_out;

    sequencial_message_passer #(LABELS, MESSAGE_WIDTH, DATA_WIDTH, DATA_WIDTH+1, LOG2_LABELS) smp(clk, next_smp_horizontal_message_forward, smp_horizontal_message_backward, next_smp_vertical_message_forward, smp_vertical_message_backward, smp_data, smp_push, smp_valid, smp_horizontal_out, smp_vertical_out);
    reg [2:0] line, next_line;
    reg [7:0] active_lines, next_active_lines;
    reg [MEMORY_ADDR_WIDTH:0] phase_addr [0:7];
    reg phase_addr_wr;
    wire [MEMORY_ADDR_WIDTH:0] phase_addr_out;
    reg [MEMORY_ADDR_WIDTH:0] phase_addr_in;
    assign phase_addr_out = phase_addr[line];
    always @(posedge clk) begin
        if(phase_addr_wr)
            phase_addr[line] <= phase_addr_in;
    end

    reg [31:0] counter, next_counter;
    //TODO: output fifo
    reg output_fifo_pop;
    reg r_output_fifo_push, next_r_output_fifo_push;
    wire [63:0] output_fifo_q;
    reg [127:0] r_output_fifo_d, next_r_output_fifo_d, inter_next_r_output_fifo_d;
    wire output_fifo_full;
    wire output_fifo_empty;
    wire [5:0] output_fifo_count;
    wire output_fifo_almost_empty;
    wire output_fifo_almost_full;
    reg output_fifo_valid, next_output_fifo_valid;
    reg [48 * 2 - 1:0] r_output_address_fifo_d, next_r_output_address_fifo_d;
    wire [47:0] output_address_fifo_q;

    different_widths_fifo #(128, 64, 5, 1, 4) output_fifo(rst, clk, r_output_fifo_push, output_fifo_pop, r_output_fifo_d, output_fifo_q, output_fifo_full, output_fifo_empty, output_fifo_count, output_fifo_almost_empty, output_fifo_almost_full);
    different_widths_fifo #(48 * 2, 48, 5, 1, 4) output_address_fifo(rst, clk, r_output_fifo_push, output_fifo_pop, r_output_address_fifo_d, output_address_fifo_q, , , , , );
    integer i;
    reg [47:0] current_pointer_plus_one;
    always @*
        current_pointer_plus_one <= current_pointer + 8;
    wire [MEMORY_ADDR_WIDTH:0] horizontal_message_memory_addr_buffer_0;
    wire [MEMORY_ADDR_WIDTH:0] horizontal_message_memory_addr_buffer_1;
    assign horizontal_message_memory_addr_buffer_0 = horizontal_message_memory_addr_buffer[0];
    assign horizontal_message_memory_addr_buffer_1 = horizontal_message_memory_addr_buffer[1];
    wire [MEMORY_ADDR_WIDTH:0] vertical_message_memory_addr_buffer_0;
    wire [MEMORY_ADDR_WIDTH:0] vertical_message_memory_addr_buffer_1;
    assign vertical_message_memory_addr_buffer_0 = vertical_message_memory_addr_buffer[0];
    assign vertical_message_memory_addr_buffer_1 = vertical_message_memory_addr_buffer[1];
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
        phase_addr_in = line * FIELD_WIDTH;
        phase_addr_wr = 1;
        next_active_lines = 0;
        next_vertical_message_memory_d_in = 0;
        next_vertical_message_memory_write = 0;
        next_vertical_message_memory_addr_a = vertical_message_memory_addr_a;
        next_vertical_message_memory_addr_b = 0; //vertical_message_memory_addr_b;
        next_vertical_message_memory_addr_buffer[0] = 0;
        next_vertical_message_memory_addr_buffer[1] = vertical_message_memory_addr_buffer_0;
        next_horizontal_message_memory_d_in = 0;
        next_horizontal_message_memory_write = 0;
        next_horizontal_message_memory_addr_b = 0; //horizontal_message_memory_addr_b;
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
        next_r_output_fifo_push = 0;
        next_r_output_fifo_d = 0;
        next_counter = 0;
        next_horizontal_message_memory_addr_buffer[0] = 0;
        next_horizontal_message_memory_addr_buffer[1] = horizontal_message_memory_addr_buffer_0;
        next_r_output_address_fifo_d = 0;
        down_out = 0;
        up_out = 0;
        next_push_debug = 0;
        next_debug0 = 0;
        next_debug1 = 0;
        next_debug2 = debug2;
        next_debug3 = 0;
        next_debug4 = 0;
        next_debug5 = 0;
        if(rst) begin 
            next_state = `IDLE_STATE;
            next_current_pointer = 0;
            next_debug2 = 0;
            next_push_debug[2] = 1;
            next_push_debug[1] = 1;
            next_debug1 = 42;
            next_push_debug[3] = 1;
            next_push_debug[4] = 1;
            next_debug3 = 42;
            next_debug4 = 42;
            next_debug5 = 42;
            next_push_debug[5] = 1;
        end else begin
            case(state)
                `IDLE_STATE: begin
                    next_current_pointer = 0;
                    if(opcode == `OP_LOAD) begin
                        next_current_pointer = data_pointer;
                        next_state = `LOAD_DATA_STATE;
                        next_data_memory_addr = -1;
                        next_horizontal_message_memory_addr_a = -1;
                        next_vertical_message_memory_addr_a = -1;
                        next_counter = 0;
                    end else if(opcode == `OP_STORE_DOWN) begin
                        next_current_pointer = message_pointer;
                        next_horizontal_message_memory_addr_b = 0;
                        next_vertical_message_memory_addr_b = 0;
                        next_state = `STORE_STATE;
                    end else if(opcode == `OP_STORE_UP) begin
                        next_current_pointer = message_pointer + 16;
                        next_horizontal_message_memory_addr_b = 0;
                        next_vertical_message_memory_addr_b = 0;
                        next_state = `STORE_STATE;
                    end else if(opcode == `OP_DOWN) begin
                        next_vertical_message_memory_addr_b = 0;
                        next_vertical_message_memory_addr_a = 0;
                        next_horizontal_message_memory_addr_b = 0;
                        next_horizontal_message_memory_addr_a = 0;
                        next_state = `INIT_DOWN_STATE;
                        next_active_lines = 1;
                        next_line = 0;
                        next_counter = 0;
                    end else if(opcode == `OP_UP) begin
                        next_state = `INIT_UP_STATE;
                        next_line = 0;
                    end
                end
                `LOAD_FIELD_PACKAGE_STATE: begin
                end
                `SET_POINTERS_STATE: begin
                end
                `LOAD_DATA_STATE: begin
                    next_line = line + 1;
                    if(data_memory_addr != FIELD_WIDTH * FIELD_HEIGHT - 1)
                        next_state = `LOAD_DATA_STATE;
                    else begin
                        next_state = `IDLE_STATE;
                    end
                    if(mc_req_stall || !(current_pointer < message_pointer))begin
                    end else begin
                        if(current_pointer < message_pointer) begin
                            next_current_pointer = current_pointer + 8;
                            next_mc_req_ld = 1;
                            next_horizontal_message_memory_write = 1;
                            next_vertical_message_memory_write = 1;
                        end
                        next_horizontal_message_memory_addr_a = horizontal_message_memory_addr_a + 1;
                        next_vertical_message_memory_addr_a = vertical_message_memory_addr_a + 1;
                        next_mc_req_vadr = current_pointer;
                    end
                    next_data_memory_addr = data_memory_addr;
                    next_data_memory_d_in = data_memory_d_in;
                    if(r_mc_rsp_push) begin
                        next_counter = counter + 1;
                        if(counter[0]) begin
                            next_data_memory_addr = data_memory_addr + 1;
                            next_data_memory_d_in[127:64] = r_mc_rsp_data;
                            next_data_memory_write = 1;
                        end else begin
                            next_data_memory_addr = data_memory_addr;
                            next_data_memory_d_in[63:0] = r_mc_rsp_data;
                        end
                    end else begin
                        next_counter = counter;
                        next_data_memory_addr = data_memory_addr;
                    end

                end
                `INIT_DOWN_STATE: begin
                    next_line = line + 1;
                    phase_addr_in = (line) * FIELD_WIDTH;
                    phase_addr_wr = 1;
                    if(line == 7) begin
                        next_state = `DOWN_STATE;
                        next_active_lines = 1;
                        next_counter = 0;
                        phase_addr_wr = 0;
                    end
                    else
                        next_state = `INIT_DOWN_STATE;
                end
                `DOWN_STATE: begin
                    next_data_memory_addr = phase_addr_out;
                    next_vertical_message_memory_addr_b = phase_addr_out;
                    next_horizontal_message_memory_addr_b = phase_addr_out;
                    next_active_lines = active_lines;
                    next_line = line + 1;
                    next_state = `DOWN_STATE;
                    next_counter = counter + 1;
                    for(i = 1; i < 4; i = i + 1) begin 
                        if(counter == (8 + 1) * i - 2)
                            next_active_lines[i] = 1;
                    end
                    for(i = 0; i < 4; i = i + 1) begin
                        if(counter == (FIELD_WIDTH - 1) * 8 + i * (9))
                            next_active_lines[i] = 0;
                    end
                    if(counter == 8*8)
                        next_state = `IDLE_STATE;
                    //TODO: change from phase_addr_out to buffer_1
                    if((horizontal_message_memory_addr_buffer_0 + 1) % FIELD_WIDTH)
                        next_smp_horizontal_message_forward = smp_horizontal_out;
                    else
                        next_smp_horizontal_message_forward = 0;
                    if(vertical_message_memory_addr_buffer_0 < FIELD_WIDTH)
                        next_smp_vertical_message_forward = 0;
                    else
                        next_smp_vertical_message_forward = up_in;
                    down_out = smp_vertical_out;
                    if(active_lines[line]) begin
                        next_smp_push_delay[0] = 1;
                        phase_addr_wr = 1;
                        phase_addr_in = phase_addr_out + 1;

                    end else
                        phase_addr_wr = 0;
                    if(smp_push_delay[1]) begin
                        next_smp_data = data_memory_d_out;
                        next_smp_horizontal_message_backward = horizontal_message_memory_d_out;
                        next_smp_vertical_message_backward = vertical_message_memory_d_out;
                    end
                    next_vertical_message_memory_addr_buffer[0] = vertical_message_memory_addr_b;
                    next_vertical_message_memory_addr_a = vertical_message_memory_addr_buffer_1;
                    next_horizontal_message_memory_addr_buffer[0] = horizontal_message_memory_addr_b;
                    next_horizontal_message_memory_addr_a = horizontal_message_memory_addr_buffer_1;

                    next_horizontal_message_memory_write = smp_push;
                    if((next_horizontal_message_memory_addr_a) % FIELD_WIDTH)
                        next_horizontal_message_memory_d_in = smp_horizontal_out;
                    else
                        next_horizontal_message_memory_d_in = 0;
                    
                    next_vertical_message_memory_write = smp_push; //valid || (counter == 12);
                    //print when address is 5
                    //|| ((counter%8) == 2);
                    next_vertical_message_memory_d_in = up_in;
                    //next_state = `IDLE_STATE;
                    //TODO: count down timer
                    //TODO: 8bit on vector
                    if(horizontal_message_memory_addr_a == 1)begin
                        next_push_debug[5] = 1;
                        next_debug5 = horizontal_message_memory_d_in[63:0];
                    end
                end
                `INIT_UP_STATE: begin
                    next_line = line + 1;
                    phase_addr_in = (line + 1) * FIELD_WIDTH - 1;
                    if(line == 7) begin
                        next_state = `UP_STATE;
                        next_active_lines = 0;
                        next_active_lines[3] = 1;
                        next_counter = 0;
                        phase_addr_wr = 0;
                    end
                    else
                        next_state = `INIT_UP_STATE;
                end
                `UP_STATE: begin
                    next_data_memory_addr = phase_addr_out;
                    next_vertical_message_memory_addr_b = phase_addr_out;
                    next_horizontal_message_memory_addr_b = phase_addr_out;
                    next_active_lines = active_lines;
                    next_line = line - 1;
                    next_state = `UP_STATE;
                    next_counter = counter + 1;
                    for(i = 1; i < 4; i = i + 1) begin 
                        if(counter == (8 + 1) * (i) - 2)
                            next_active_lines[3 - i] = 1;
                    end
                    for(i = 0; i < 4; i = i + 1) begin
                        if(counter == (FIELD_WIDTH - 1) * 8 + (i) * (9) + 8)
                            next_active_lines[3 - i] = 0;
                    end
                    if(counter == 8*8)
                        next_state = `IDLE_STATE;
                    if((horizontal_message_memory_addr_buffer_0 % FIELD_WIDTH) == (FIELD_WIDTH - 1))
                        next_smp_horizontal_message_forward = 0;
                    else
                        next_smp_horizontal_message_forward = smp_horizontal_out;
                    if(vertical_message_memory_addr_buffer_1 > (FIELD_HEIGHT - 1) * FIELD_WIDTH)
                        next_smp_vertical_message_forward = 0;
                    else
                        next_smp_vertical_message_forward = down_in;
                    up_out = smp_vertical_out;
                    if(active_lines[line]) begin
                        next_smp_push_delay[0] = 1;
                        phase_addr_wr = 1;
                        phase_addr_in = phase_addr_out - 1;
                    end else
                        phase_addr_wr = 0;
                    if(smp_push_delay[1]) begin
                        next_smp_data = data_memory_d_out;
                        next_smp_horizontal_message_backward = horizontal_message_memory_d_out;
                        next_smp_vertical_message_backward = vertical_message_memory_d_out;
                    end
                    next_vertical_message_memory_addr_buffer[0] = vertical_message_memory_addr_b;
                    next_vertical_message_memory_addr_a = vertical_message_memory_addr_buffer_1;
                    next_horizontal_message_memory_addr_buffer[0] = horizontal_message_memory_addr_b;
                    next_horizontal_message_memory_addr_a = horizontal_message_memory_addr_buffer_1;

                    next_horizontal_message_memory_write = smp_push;
                    if(((next_horizontal_message_memory_addr_a) % FIELD_WIDTH) != FIELD_WIDTH - 1)
                        next_horizontal_message_memory_d_in = smp_horizontal_out;
                    else
                        next_horizontal_message_memory_d_in = 0;
                        
                    next_vertical_message_memory_write = smp_push; //valid || (counter == 12);
                    //print when address is 5
                    //|| ((counter%8) == 2);
                    next_vertical_message_memory_d_in = down_in;
                    //next_state = `IDLE_STATE;
                    //TODO: count down timer
                    //TODO: 8bit on vector
                end
                `STORE_STATE: begin
                    next_push_debug[0] = 0;
                    next_data_memory_addr = 0;
                    next_debug0 = data_memory_d_out;
                        if(counter == 4 || counter == 3)begin
                            if(mc_req_stall || output_fifo_almost_full || horizontal_message_memory_addr_b == FIELD_WIDTH * FIELD_HEIGHT)
                                next_counter = 4;
                            else 
                                next_counter = 0;
                        end else begin
                            next_counter = counter + 1;
                        end
                        if(counter == 2) begin
                            next_horizontal_message_memory_addr_b = horizontal_message_memory_addr_b + 1;
                            next_vertical_message_memory_addr_b = vertical_message_memory_addr_b + 1;
                        end else begin
                            next_horizontal_message_memory_addr_b = horizontal_message_memory_addr_b;
                            next_vertical_message_memory_addr_b = vertical_message_memory_addr_b;
                        end
                        case(counter)
                            0:begin
                                for(i = 0; i < 16; i = i + 1) begin
                                    inter_next_r_output_fifo_d[(i+1)*8-1 -:8] = {2'H0, horizontal_message_memory_d_out[(i+1)*6 - 1 -:6]};
                                end
                                next_r_output_fifo_d = inter_next_r_output_fifo_d;
                                next_r_output_fifo_push = 1;
                                next_current_pointer = current_pointer + 8 * 4;
                                next_r_output_address_fifo_d[48*2-1 : 48] = current_pointer_plus_one;
                                next_r_output_address_fifo_d[47:0] = current_pointer;
                                for(i = 0; i < 8; i = i + 1) begin
                                    inter_next_mc_req_wrd_rdctl[(i+1)*8-1 -:8] = {2'H0, horizontal_message_memory_d_out[(i+1)*6 - 1 -:6]};
                                end
                                /*next_mc_req_wrd_rdctl = inter_next_mc_req_wrd_rdctl;
                                next_mc_req_st = 1;
                                next_mc_req_vadr = current_pointer;*/
                            end
                            1:begin
                                for(i = 0; i < 8; i = i + 1) begin
                                    inter_next_mc_req_wrd_rdctl[(i+1)*8-1 -:8] = {2'H0, horizontal_message_memory_d_out[(i+1 + 8)*6 - 1 -:6]};
                                end
                                /*next_mc_req_wrd_rdctl = inter_next_mc_req_wrd_rdctl;
                                next_mc_req_st = 1;
                                next_mc_req_vadr = current_pointer_plus_one;*/
                            end
                            2:begin
                                for(i = 0; i < 16; i = i + 1) begin
                                    inter_next_r_output_fifo_d[(i+1)*8-1 -:8] = {2'H0, vertical_message_memory_d_out[(i+1)*6 - 1 -:6]};
                                end
                                next_r_output_fifo_d = inter_next_r_output_fifo_d;
                                next_r_output_fifo_push = 1;
                                next_current_pointer = current_pointer + 8 * 4;
                                next_r_output_address_fifo_d[48*2-1 : 48] = current_pointer_plus_one;
                                next_r_output_address_fifo_d[47:0] = current_pointer;
                                for(i = 0; i < 8; i = i + 1) begin
                                    inter_next_mc_req_wrd_rdctl [(i+1)*8-1 -:8] = {2'H0, vertical_message_memory_d_out[(i+1)*6 - 1 -:6]};
                                end
                                /*next_mc_req_wrd_rdctl = inter_next_mc_req_wrd_rdctl;
                                next_mc_req_st = 1;
                                next_mc_req_vadr = current_pointer;*/
                            end
                            3:begin
                                for(i = 0; i < 8; i = i + 1) begin
                                    inter_next_mc_req_wrd_rdctl[(i+1)*8-1 -:8] = {2'H0, vertical_message_memory_d_out[(i+1 + 8)*6 - 1 -:6]};
                                end
                                /*next_mc_req_wrd_rdctl = inter_next_mc_req_wrd_rdctl;
                                next_mc_req_st = 1;
                                next_mc_req_vadr = current_pointer_plus_one;*/
                            end
                            default:begin
                            end
                        endcase

                    if(!output_fifo_empty && !mc_req_stall)begin
                        next_output_fifo_valid = 1;
                        output_fifo_pop = 1;
                        next_push_debug[3] = 1;
                        next_debug3 = message_pointer;
                        next_push_debug[4] = 1;
                        next_debug4 = current_pointer;
                    end
                    if(output_fifo_valid) begin
                        next_mc_req_wrd_rdctl = output_fifo_q;
                        if(output_address_fifo_q >= message_pointer && output_address_fifo_q < assignments_pointer)begin
                            next_mc_req_st = 1;
                            next_mc_req_vadr = output_address_fifo_q;
                        end else begin
                            next_push_debug[1] = 1;
                            next_debug1 = output_address_fifo_q;
                            next_push_debug[2] = 1;
                            next_debug2 = debug2 + 1;
                        end
                    end
                    if(output_fifo_valid || !output_fifo_empty || horizontal_message_memory_addr_b != FIELD_WIDTH * FIELD_HEIGHT)
                        next_state = `STORE_STATE;
                    else
                        next_state = `IDLE_STATE;
                end
                `STORE_UP_STATE: begin
                end
                
            endcase
        end
        
    end



    always @(posedge clk) begin
        r_output_address_fifo_d <= next_r_output_address_fifo_d;
        vertical_message_memory_addr_buffer[0] <= next_vertical_message_memory_addr_buffer[0];
        vertical_message_memory_addr_buffer[1] <= next_vertical_message_memory_addr_buffer[1];
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
        vertical_message_memory_addr_a <= next_vertical_message_memory_addr_a;
        vertical_message_memory_addr_b <= next_vertical_message_memory_addr_b;
        vertical_message_memory_d_in <= next_vertical_message_memory_d_in;
        vertical_message_memory_write <= next_vertical_message_memory_write;
        horizontal_message_memory_addr_a <= next_horizontal_message_memory_addr_a;
        horizontal_message_memory_addr_b <= next_horizontal_message_memory_addr_b;
        horizontal_message_memory_d_in <= next_horizontal_message_memory_d_in;
        horizontal_message_memory_write <= next_horizontal_message_memory_write;
        active_lines <= next_active_lines;
        line <= next_line;
        counter <= next_counter;
        r_output_fifo_d <= next_r_output_fifo_d;
        r_output_fifo_push <= next_r_output_fifo_push;
        push_debug <= next_push_debug;
        debug0 <= next_debug0;
        debug1 <= next_debug1;
        debug2 <= next_debug2;
        debug3 <= next_debug3;
        debug4 <= next_debug4;
        debug5 <= next_debug5;
    end
    always @* begin
        stall = !(state == `IDLE_STATE);
    end
    always @(posedge clk) begin
        /*
        if(opcode == `OP_LOAD)begin
            $display("opcode load");
            $display("current_pointer: %H", current_pointer);
            $display("next_current_pointer: %H", next_current_pointer);
            $display("data_pointer: %H", data_pointer);
        end
        */
        if(state == `STORE_STATE) begin
            $display("store state time: %d", $time);
            $display("vertical_memory: %H, data: %H", vertical_message_memory_addr_b, vertical_message_memory_d_out);
            $display("horizontal_memory: %H, data: %H", horizontal_message_memory_addr_b, horizontal_message_memory_d_out);
            if(r_output_fifo_push) begin
                $display("output_fifo_push: %H", r_output_fifo_d);
                $display("output_fifo_address: %H", r_output_address_fifo_d);
            end
            if(output_fifo_valid)
                $display("store to memory: %H, %H", output_address_fifo_q, next_mc_req_wrd_rdctl);
            $display("dump:");
            $display("%H, %H, %H, %H, %H, %H, %H, %H, %H", r_output_fifo_push, output_fifo_pop, r_output_fifo_d, output_fifo_q, output_fifo_full, output_fifo_empty, output_fifo_count, output_fifo_almost_empty, output_fifo_almost_full);
            //    different_widths_fifo #(48 * 2, 48, 5, 1, 4) output_address_fifo(rst, clk, r_output_fifo_push, output_fifo_pop, r_output_address_fifo_d, output_address_fifo_q, , , , , );

        end
        if(state == `INIT_UP_STATE) begin
            $display("INIT_UP_STATE: %d", $time);
        end
        if(state == `DOWN_STATE) begin
            $display("up state time: %d", $time);
            if(vertical_message_memory_addr_a == 4)
                $display("vertical_message_memory_addr_b=5, counter = %d", counter);
            if(up_in)
                $display("up_in value:%H, at %H", up_in, counter);
            $display("phase: %H, addr: %H", phase_addr_out, line);
            
            if(horizontal_message_memory_write)
                $display("writing horizontal memory: %H at %H", horizontal_message_memory_d_in, horizontal_message_memory_addr_a);
            if(vertical_message_memory_write)
                $display("writing vertical memory: %H at %H", vertical_message_memory_d_in, vertical_message_memory_addr_a);
            if(smp_valid)begin
                $display("smp_horizontal_out: %H", smp_horizontal_out);
                $display("smp_vertical_out: %H", smp_vertical_out);
            end
            if(active_lines[line]) begin
                $display("address: %H", phase_addr_out);
            end
            if(smp_push)begin
                $display("smp_push, data: %H", smp_data);
                $display("smp_vectors: %H, %H, %H, %H", next_smp_horizontal_message_forward, smp_horizontal_message_backward, next_smp_vertical_message_forward, smp_vertical_message_backward);
            end
            if(smp_push_delay[0])begin
                $display("data address: %H", data_memory_addr);
            end
        end
    end


endmodule
