module bps_tb();
    `define LABELS 16
    `define MESSAGE_WIDTH 6
    reg rst;
    reg clk;
    wire stall;
    reg [2:0] opcode;
    `define OP_IDLE 0
    `define OP_LOAD 1
    `define OP_DOWN 2
    `define OP_UP 3
    `define OP_STORE 4
    reg [63:0] addr_base;
    wire mc_req_ld;
    wire mc_req_st;
    wire [47:0] mc_req_vadr;
    wire [63:0] mc_req_wrd_rdctl;
    reg mc_req_stall;
    reg [31:0] mc_rsp_rdctl;
    reg [63:0] mc_rsp_data;
    reg mc_rsp_push;
    wire mc_rsp_stall;
    reg [`LABELS*`MESSAGE_WIDTH-1:0] up_in;
    wire [`LABELS*`MESSAGE_WIDTH-1:0] up_out;
    reg [`LABELS*`MESSAGE_WIDTH-1:0] down_in;
    wire [`LABELS*`MESSAGE_WIDTH-1:0] down_out;

    reg [63:0] memory [0: 5 + 2 * 6 * 128 * 128 - 1];
    reg [63:0] memory_check [0: 5 + 2 * 6 * 128 * 128 - 1];

    bps dut(rst, clk, stall, opcode, addr_base, mc_req_ld, mc_req_st, mc_req_vadr, mc_req_wrd_rdctl, mc_req_stall, mc_rsp_rdctl, mc_rsp_data, mc_rsp_push, mc_rsp_stall, up_in, up_out, down_in, down_out);

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $readmemh("../initial_memory.dat", memory);
        rst = 1;
        opcode = 0;
        addr_base = 0;
        mc_req_stall = 0;
        #100 rst = 0;
        #100 opcode = `OP_LOAD;
        #10 opcode = `OP_IDLE;
        while(stall) #10; //$display("stall: %d", stall);
        opcode = `OP_DOWN;
        #10 opcode = `OP_IDLE;
        #1000 $finish;
    end

    initial #1000000 $finish;
    always @(posedge clk) begin
        mc_rsp_rdctl <= 0;
        mc_rsp_data <= 0;
        mc_rsp_push <= 0;
        if(mc_req_ld) begin
            //$display("%d: mc_req_ld %h", $time, memory[mc_req_vadr/8]);
            mc_rsp_push <= 1;
            mc_rsp_rdctl <= mc_req_wrd_rdctl;
            mc_rsp_data <= memory[mc_req_vadr/8];
        end
        if(mc_req_st) begin
            $display("%d: mc_req_st %h", $time, mc_req_wrd_rdctl);
            memory[mc_req_vadr/8] <= mc_req_wrd_rdctl;
        end
    end

    always @(posedge clk) begin
        up_in <= 0;
        down_in <= 0;
    end
    always @(posedge clk) begin
        //$display($time);
    end

endmodule
