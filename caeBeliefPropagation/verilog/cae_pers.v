/*****************************************************************************/
//
// Module      : cae_pers.v
// Revision    : $Revision: 1.4.1.4 $
// Last Modified On: $Date: 2012/03/07 15:41:55 $
// Last Modified By: $Author: ktown $
//
//-----------------------------------------------------------------------------
//
// Original Author : gedwards
// Created On      : Wed Oct 10 09:26:08 2007
// TODO: add author information
//-----------------------------------------------------------------------------
//
// Description     : BeliefPropagation personality
//
//                   Top-level of BeliefPropagation personality.  For a complete list of 
//                   optional ports, see 
//                   /opt/convey/pdk/<rev>/<platform>/doc/cae_pers.v
//
//-----------------------------------------------------------------------------
//
// Copyright (c) 2007-2011 : created by Convey Computer Corp. This model is the
// confidential and proprietary property of Convey Computer Corp.
//
/*****************************************************************************/
/* $Id: cae_pers.v,v 1.4.1.4 2012/03/07 15:41:55 ktown Exp ktown $ */

`timescale 1 ns / 1 ps

`include "pdk_fpga_defines.vh"

(* keep_hierarchy = "true" *)
module cae_pers (
   input        clk_csr,
   input        clk,
   input        clk2x,
   input        i_reset,
   input        i_csr_reset_n,
   input  [1:0]     i_aeid,

   input        ppll_reset,
   output       ppll_locked,
   output       clk_per,

   //
   // Dispatch Interface
   //
   input  [31:0]    cae_inst,
   input  [63:0]    cae_data,
   input        cae_inst_vld,

   output [17:0]    cae_aeg_cnt,
   output [15:0]    cae_exception,
   output [63:0]    cae_ret_data,
   output       cae_ret_data_vld,
   output       cae_idle,
   output       cae_stall,

   //
   // MC Interface(s)
   //
   output       mc0_req_ld_e, mc0_req_ld_o,
   output       mc0_req_st_e, mc0_req_st_o,
   output [1:0]     mc0_req_size_e, mc0_req_size_o,
   output [47:0]    mc0_req_vadr_e, mc0_req_vadr_o,
   output [63:0]    mc0_req_wrd_rdctl_e, mc0_req_wrd_rdctl_o,
   output       mc0_rsp_stall_e, mc0_rsp_stall_o,
   input        mc0_rd_rq_stall_e, mc0_rd_rq_stall_o,
   input        mc0_wr_rq_stall_e, mc0_wr_rq_stall_o,
   input  [63:0]    mc0_rsp_data_e, mc0_rsp_data_o,
   input        mc0_rsp_push_e, mc0_rsp_push_o,
   input  [31:0]    mc0_rsp_rdctl_e, mc0_rsp_rdctl_o,
   output       mc1_req_ld_e, mc1_req_ld_o,
   output       mc1_req_st_e, mc1_req_st_o,
   output [1:0]     mc1_req_size_e, mc1_req_size_o,
   output [47:0]    mc1_req_vadr_e, mc1_req_vadr_o,
   output [63:0]    mc1_req_wrd_rdctl_e, mc1_req_wrd_rdctl_o,
   output       mc1_rsp_stall_e, mc1_rsp_stall_o,
   input        mc1_rd_rq_stall_e, mc1_rd_rq_stall_o,
   input        mc1_wr_rq_stall_e, mc1_wr_rq_stall_o,
   input  [63:0]    mc1_rsp_data_e, mc1_rsp_data_o,
   input        mc1_rsp_push_e, mc1_rsp_push_o,
   input  [31:0]    mc1_rsp_rdctl_e, mc1_rsp_rdctl_o,
   output       mc2_req_ld_e, mc2_req_ld_o,
   output       mc2_req_st_e, mc2_req_st_o,
   output [1:0]     mc2_req_size_e, mc2_req_size_o,
   output [47:0]    mc2_req_vadr_e, mc2_req_vadr_o,
   output [63:0]    mc2_req_wrd_rdctl_e, mc2_req_wrd_rdctl_o,
   output       mc2_rsp_stall_e, mc2_rsp_stall_o,
   input        mc2_rd_rq_stall_e, mc2_rd_rq_stall_o,
   input        mc2_wr_rq_stall_e, mc2_wr_rq_stall_o,
   input  [63:0]    mc2_rsp_data_e, mc2_rsp_data_o,
   input        mc2_rsp_push_e, mc2_rsp_push_o,
   input  [31:0]    mc2_rsp_rdctl_e, mc2_rsp_rdctl_o,
   output       mc3_req_ld_e, mc3_req_ld_o,
   output       mc3_req_st_e, mc3_req_st_o,
   output [1:0]     mc3_req_size_e, mc3_req_size_o,
   output [47:0]    mc3_req_vadr_e, mc3_req_vadr_o,
   output [63:0]    mc3_req_wrd_rdctl_e, mc3_req_wrd_rdctl_o,
   output       mc3_rsp_stall_e, mc3_rsp_stall_o,
   input        mc3_rd_rq_stall_e, mc3_rd_rq_stall_o,
   input        mc3_wr_rq_stall_e, mc3_wr_rq_stall_o,
   input  [63:0]    mc3_rsp_data_e, mc3_rsp_data_o,
   input        mc3_rsp_push_e, mc3_rsp_push_o,
   input  [31:0]    mc3_rsp_rdctl_e, mc3_rsp_rdctl_o,
   output       mc4_req_ld_e, mc4_req_ld_o,
   output       mc4_req_st_e, mc4_req_st_o,
   output [1:0]     mc4_req_size_e, mc4_req_size_o,
   output [47:0]    mc4_req_vadr_e, mc4_req_vadr_o,
   output [63:0]    mc4_req_wrd_rdctl_e, mc4_req_wrd_rdctl_o,
   output       mc4_rsp_stall_e, mc4_rsp_stall_o,
   input        mc4_rd_rq_stall_e, mc4_rd_rq_stall_o,
   input        mc4_wr_rq_stall_e, mc4_wr_rq_stall_o,
   input  [63:0]    mc4_rsp_data_e, mc4_rsp_data_o,
   input        mc4_rsp_push_e, mc4_rsp_push_o,
   input  [31:0]    mc4_rsp_rdctl_e, mc4_rsp_rdctl_o,
   output       mc5_req_ld_e, mc5_req_ld_o,
   output       mc5_req_st_e, mc5_req_st_o,
   output [1:0]     mc5_req_size_e, mc5_req_size_o,
   output [47:0]    mc5_req_vadr_e, mc5_req_vadr_o,
   output [63:0]    mc5_req_wrd_rdctl_e, mc5_req_wrd_rdctl_o,
   output       mc5_rsp_stall_e, mc5_rsp_stall_o,
   input        mc5_rd_rq_stall_e, mc5_rd_rq_stall_o,
   input        mc5_wr_rq_stall_e, mc5_wr_rq_stall_o,
   input  [63:0]    mc5_rsp_data_e, mc5_rsp_data_o,
   input        mc5_rsp_push_e, mc5_rsp_push_o,
   input  [31:0]    mc5_rsp_rdctl_e, mc5_rsp_rdctl_o,
   output       mc6_req_ld_e, mc6_req_ld_o,
   output       mc6_req_st_e, mc6_req_st_o,
   output [1:0]     mc6_req_size_e, mc6_req_size_o,
   output [47:0]    mc6_req_vadr_e, mc6_req_vadr_o,
   output [63:0]    mc6_req_wrd_rdctl_e, mc6_req_wrd_rdctl_o,
   output       mc6_rsp_stall_e, mc6_rsp_stall_o,
   input        mc6_rd_rq_stall_e, mc6_rd_rq_stall_o,
   input        mc6_wr_rq_stall_e, mc6_wr_rq_stall_o,
   input  [63:0]    mc6_rsp_data_e, mc6_rsp_data_o,
   input        mc6_rsp_push_e, mc6_rsp_push_o,
   input  [31:0]    mc6_rsp_rdctl_e, mc6_rsp_rdctl_o,
   output       mc7_req_ld_e, mc7_req_ld_o,
   output       mc7_req_st_e, mc7_req_st_o,
   output [1:0]     mc7_req_size_e, mc7_req_size_o,
   output [47:0]    mc7_req_vadr_e, mc7_req_vadr_o,
   output [63:0]    mc7_req_wrd_rdctl_e, mc7_req_wrd_rdctl_o,
   output       mc7_rsp_stall_e, mc7_rsp_stall_o,
   input        mc7_rd_rq_stall_e, mc7_rd_rq_stall_o,
   input        mc7_wr_rq_stall_e, mc7_wr_rq_stall_o,
   input  [63:0]    mc7_rsp_data_e, mc7_rsp_data_o,
   input        mc7_rsp_push_e, mc7_rsp_push_o,
   input  [31:0]    mc7_rsp_rdctl_e, mc7_rsp_rdctl_o,

   //
   // Write flush
   //
   output       mc0_req_flush_e, mc0_req_flush_o,
   input        mc0_rsp_flush_cmplt_e, mc0_rsp_flush_cmplt_o,
   output       mc1_req_flush_e, mc1_req_flush_o,
   input        mc1_rsp_flush_cmplt_e, mc1_rsp_flush_cmplt_o,
   output       mc2_req_flush_e, mc2_req_flush_o,
   input        mc2_rsp_flush_cmplt_e, mc2_rsp_flush_cmplt_o,
   output       mc3_req_flush_e, mc3_req_flush_o,
   input        mc3_rsp_flush_cmplt_e, mc3_rsp_flush_cmplt_o,
   output       mc4_req_flush_e, mc4_req_flush_o,
   input        mc4_rsp_flush_cmplt_e, mc4_rsp_flush_cmplt_o,
   output       mc5_req_flush_e, mc5_req_flush_o,
   input        mc5_rsp_flush_cmplt_e, mc5_rsp_flush_cmplt_o,
   output       mc6_req_flush_e, mc6_req_flush_o,
   input        mc6_rsp_flush_cmplt_e, mc6_rsp_flush_cmplt_o,
   output       mc7_req_flush_e, mc7_req_flush_o,
   input        mc7_rsp_flush_cmplt_e, mc7_rsp_flush_cmplt_o,

   //
   // AE-to-AE Interface not used
   //

   //
   // Management/Debug Interface
   //
   input  [3:0]     cae_ring_ctl_in,
   input  [15:0]    cae_ring_data_in,
   output [3:0]     cae_ring_ctl_out,
   output [15:0]    cae_ring_data_out,

   input        csr_31_31_intlv_dis
);

initial $display("starting cae personality aeid:%d\n", i_aeid);

`include "pdk_fpga_param.vh"

   //
   // Local clock generation
   //
   (* KEEP = "true" *) wire reset_per;
   cae_clock clock (
      .clk(clk),
      .i_reset(i_reset),
      .ppll_reset(ppll_reset),

      .clk_per(clk_per),
      .ppll_locked(ppll_locked),
      .reset_per(reset_per)
   );


     //
     // Instruction decode
     //
     wire [4:0]   inst_caep;
     wire [17:0]  inst_aeg_idx;
     instdec dec (
        .cae_inst(cae_inst),
        .cae_data(cae_data),
        .cae_inst_vld(cae_inst_vld),

        .inst_val(inst_val),
        .inst_caep(inst_caep),
        .inst_aeg_wr(inst_aeg_wr),
        .inst_aeg_rd(inst_aeg_rd),
        .inst_aeg_idx(inst_aeg_idx),
        .err_unimpl(err_unimpl)
    );


   //**************************************************************************
   //              PERSONALITY SPECIFIC LOGIC
   //**************************************************************************

   //
   // AEG[0..NA-1] Registers
   //
    localparam NA = 51;
    localparam NB = 6;       // Number of bits to represent NAEG

    assign cae_aeg_cnt = NA;

    //output of aeg registers
    wire [63:0]  w_aeg[NA-1:0];

    genvar g;
    generate for (g=0; g<NA; g=g+1) begin : g0
      reg [63:0] c_aeg, r_aeg;

      always @* begin
        case (g)
//TODO: add cases for registers to be written to
            default: c_aeg = r_aeg;
        endcase
      end

      wire c_aeg_we = inst_aeg_wr && inst_aeg_idx[NB-1:0] == g;

      always @(posedge clk) begin
        if (c_aeg_we) begin
            r_aeg <= cae_data;
            $display("writing: %x", cae_data);
        end
        else
            r_aeg <= c_aeg;
        end
      assign w_aeg[g] = r_aeg;
    end endgenerate

   reg      r_ret_val, r_err_unimpl, r_err_aegidx;
   reg [63:0]   r_ret_data;

   wire c_val_aegidx = inst_aeg_idx < NA;

    //return logic
   always @(posedge clk) begin
      r_ret_val    <= inst_aeg_rd && c_val_aegidx;
      r_ret_data   <= w_aeg[inst_aeg_idx[NB-1:0]];
      r_err_aegidx <= (inst_aeg_wr || inst_aeg_rd) && !c_val_aegidx;
//TODO: add logic to decide which instructions are implemented
      r_err_unimpl <= err_unimpl || (inst_val && (inst_caep !== 'd0/* && inst_caep !== 'd1 && inst_caep !== 'd2*/)); 
   end
   assign cae_ret_data_vld = r_ret_val;
   assign cae_ret_data     = r_ret_data;

   assign cae_exception[1:0] = {r_err_aegidx, r_err_unimpl};

   // ISE can have issues with global wires attached to D(flop)/I(lut) inputs
   wire r_reset;
   FDSE rst (.C(clk_per),.S(reset_per),.CE(r_reset),.D(!r_reset),.Q(r_reset));

   //logic for using cae IMPORTANT. cae_idle should be 0 when executing a custom instruction and 1 otherwise.
   //cae_stall should be 1 when when exectuting a custom instruction and 0 otherwise.
   assign cae_idle  = 1'b1;
   assign cae_stall = 1'b0;


   //
   // default state
   //
assign cae_ring_ctl_out = cae_ring_ctl_in;
assign cae_ring_data_out = cae_ring_data_in;

assign mc0_req_ld_e = 1'b0;
assign mc0_req_st_e = 1'b0;
assign mc0_req_wrd_rdctl_e = 64'd0;
assign mc0_req_vadr_e = 48'd0;
assign mc0_req_size_e = 2'd0;
assign mc0_req_flush_e = 1'b0;
assign mc0_rsp_stall_e = 1'b0;
assign mc0_req_ld_o = 1'b0;
assign mc0_req_st_o = 1'b0;
assign mc0_req_wrd_rdctl_o = 64'd0;
assign mc0_req_vadr_o = 48'd0;
assign mc0_req_size_o = 2'd0;
assign mc0_req_flush_o = 1'b0;
assign mc0_rsp_stall_o = 1'b0;
assign mc1_req_ld_e = 1'b0;
assign mc1_req_st_e = 1'b0;
assign mc1_req_wrd_rdctl_e = 64'd0;
assign mc1_req_vadr_e = 48'd0;
assign mc1_req_size_e = 2'd0;
assign mc1_req_flush_e = 1'b0;
assign mc1_rsp_stall_e = 1'b0;
assign mc1_req_ld_o = 1'b0;
assign mc1_req_st_o = 1'b0;
assign mc1_req_wrd_rdctl_o = 64'd0;
assign mc1_req_vadr_o = 48'd0;
assign mc1_req_size_o = 2'd0;
assign mc1_req_flush_o = 1'b0;
assign mc1_rsp_stall_o = 1'b0;
assign mc2_req_ld_e = 1'b0;
assign mc2_req_st_e = 1'b0;
assign mc2_req_wrd_rdctl_e = 64'd0;
assign mc2_req_vadr_e = 48'd0;
assign mc2_req_size_e = 2'd0;
assign mc2_req_flush_e = 1'b0;
assign mc2_rsp_stall_e = 1'b0;
assign mc2_req_ld_o = 1'b0;
assign mc2_req_st_o = 1'b0;
assign mc2_req_wrd_rdctl_o = 64'd0;
assign mc2_req_vadr_o = 48'd0;
assign mc2_req_size_o = 2'd0;
assign mc2_req_flush_o = 1'b0;
assign mc2_rsp_stall_o = 1'b0;
assign mc3_req_ld_e = 1'b0;
assign mc3_req_st_e = 1'b0;
assign mc3_req_wrd_rdctl_e = 64'd0;
assign mc3_req_vadr_e = 48'd0;
assign mc3_req_size_e = 2'd0;
assign mc3_req_flush_e = 1'b0;
assign mc3_rsp_stall_e = 1'b0;
assign mc3_req_ld_o = 1'b0;
assign mc3_req_st_o = 1'b0;
assign mc3_req_wrd_rdctl_o = 64'd0;
assign mc3_req_vadr_o = 48'd0;
assign mc3_req_size_o = 2'd0;
assign mc3_req_flush_o = 1'b0;
assign mc3_rsp_stall_o = 1'b0;
assign mc4_req_ld_e = 1'b0;
assign mc4_req_st_e = 1'b0;
assign mc4_req_wrd_rdctl_e = 64'd0;
assign mc4_req_vadr_e = 48'd0;
assign mc4_req_size_e = 2'd0;
assign mc4_req_flush_e = 1'b0;
assign mc4_rsp_stall_e = 1'b0;
assign mc4_req_ld_o = 1'b0;
assign mc4_req_st_o = 1'b0;
assign mc4_req_wrd_rdctl_o = 64'd0;
assign mc4_req_vadr_o = 48'd0;
assign mc4_req_size_o = 2'd0;
assign mc4_req_flush_o = 1'b0;
assign mc4_rsp_stall_o = 1'b0;
assign mc5_req_ld_e = 1'b0;
assign mc5_req_st_e = 1'b0;
assign mc5_req_wrd_rdctl_e = 64'd0;
assign mc5_req_vadr_e = 48'd0;
assign mc5_req_size_e = 2'd0;
assign mc5_req_flush_e = 1'b0;
assign mc5_rsp_stall_e = 1'b0;
assign mc5_req_ld_o = 1'b0;
assign mc5_req_st_o = 1'b0;
assign mc5_req_wrd_rdctl_o = 64'd0;
assign mc5_req_vadr_o = 48'd0;
assign mc5_req_size_o = 2'd0;
assign mc5_req_flush_o = 1'b0;
assign mc5_rsp_stall_o = 1'b0;
assign mc6_req_ld_e = 1'b0;
assign mc6_req_st_e = 1'b0;
assign mc6_req_wrd_rdctl_e = 64'd0;
assign mc6_req_vadr_e = 48'd0;
assign mc6_req_size_e = 2'd0;
assign mc6_req_flush_e = 1'b0;
assign mc6_rsp_stall_e = 1'b0;
assign mc6_req_ld_o = 1'b0;
assign mc6_req_st_o = 1'b0;
assign mc6_req_wrd_rdctl_o = 64'd0;
assign mc6_req_vadr_o = 48'd0;
assign mc6_req_size_o = 2'd0;
assign mc6_req_flush_o = 1'b0;
assign mc6_rsp_stall_o = 1'b0;
assign mc7_req_ld_e = 1'b0;
assign mc7_req_st_e = 1'b0;
assign mc7_req_wrd_rdctl_e = 64'd0;
assign mc7_req_vadr_e = 48'd0;
assign mc7_req_size_e = 2'd0;
assign mc7_req_flush_e = 1'b0;
assign mc7_rsp_stall_e = 1'b0;
assign mc7_req_ld_o = 1'b0;
assign mc7_req_st_o = 1'b0;
assign mc7_req_wrd_rdctl_o = 64'd0;
assign mc7_req_vadr_o = 48'd0;
assign mc7_req_size_o = 2'd0;
assign mc7_req_flush_o = 1'b0;
assign mc7_rsp_stall_o = 1'b0;


    always @(posedge clk_per) begin
        if(inst_caep == 5'd0 && inst_val) begin
            //TODO: add start logic for custom instruction
            //TODO: if more than one cycle long add cae_idle and cae_stall logic
            $display("@simulation:Hello World from simulated ae%d", i_aeid);
        end
    end
   
    /* ---------- debug & synopsys off blocks  ---------- */

    // synopsys translate_off

    // Parameters: 1-Severity: Don't Stop, 2-start check only after negedge of reset
    //assert_never #(1, 2, "***ERROR ASSERT: unimplemented instruction cracked") a0 (.clk(clk), .reset_n(~reset), .test_expr(r_unimplemented_inst));

    // synopsys translate_on

endmodule // cae_pers
