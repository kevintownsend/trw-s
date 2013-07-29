////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: P.68d
//  \   \         Application: netgen
//  /   /         Filename: std_fifo_xst.v
// /___/   /\     Timestamp: Sun Jul 28 21:44:06 2013
// \   \  /  \ 
//  \___\/\___\
//             
// Command	: -w -ofmt verilog std_fifo.ngc std_fifo_xst.v 
// Device	: xc5vlx330-2
// Input file	: std_fifo.ngc
// Output file	: std_fifo_xst.v
// # of Modules	: 1
// Design Name	: std_fifo
// Xilinx        : /remote/Xilinx/14.6/ISE/
//             
// Purpose:    
//     This verilog netlist is a verification model and uses simulation 
//     primitives which may not represent the true implementation of the 
//     device, however the netlist is functionally correct and should not 
//     be modified. This file cannot be synthesized and should only be used 
//     with supported simulation tools.
//             
// Reference:  
//     Command Line Tools User Guide, Chapter 23 and Synthesis and Simulation Design Guide, Chapter 6
//             
////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns/1 ps

module std_fifo (
  rst, clk, push, pop, full, empty, almost_empty, almost_full, d, q, count
);
  input rst;
  input clk;
  input push;
  input pop;
  output full;
  output empty;
  output almost_empty;
  output almost_full;
  input [7 : 0] d;
  output [7 : 0] q;
  output [6 : 0] count;
  wire d_7_IBUF_0;
  wire d_6_IBUF_1;
  wire d_5_IBUF_2;
  wire d_4_IBUF_3;
  wire d_3_IBUF_4;
  wire d_2_IBUF_5;
  wire d_1_IBUF_6;
  wire d_0_IBUF_7;
  wire rst_IBUF_8;
  wire clk_BUFGP_9;
  wire push_IBUF_10;
  wire pop_IBUF_11;
  wire _n0040;
  wire _n0042;
  wire count_6_OBUF_30;
  wire count_5_OBUF_31;
  wire count_4_OBUF_32;
  wire count_3_OBUF_33;
  wire count_2_OBUF_34;
  wire count_1_OBUF_35;
  wire count_0_OBUF_36;
  wire empty_OBUF_37;
  wire almost_empty_OBUF_38;
  wire almost_full_OBUF_39;
  wire full_OBUF_40;
  wire N0;
  wire N1;
  wire \Result<0>1 ;
  wire \Result<1>1 ;
  wire \Result<2>1 ;
  wire \Result<3>1 ;
  wire \Result<4>1 ;
  wire \Result<5>1 ;
  wire \Result<6>1 ;
  wire N5;
  wire empty711_86;
  wire empty712_87;
  wire \Msub_count_lut<6>1_119 ;
  wire NLW_Mram_ram1_DOD_UNCONNECTED;
  wire NLW_Mram_ram2_DOD_UNCONNECTED;
  wire NLW_Mram_ram32_SPO_UNCONNECTED;
  wire NLW_Mram_ram31_SPO_UNCONNECTED;
  wire [7 : 0] _n0038;
  wire [7 : 0] r_q;
  wire [6 : 0] Result;
  wire [5 : 0] Msub_count_lut;
  wire [5 : 0] Msub_count_cy;
  wire [6 : 0] r_beg;
  wire [4 : 4] Mcount_r_beg_cy;
  wire [6 : 0] r_end;
  wire [4 : 4] Mcount_r_end_cy;
  VCC   XST_VCC (
    .P(N0)
  );
  GND   XST_GND (
    .G(N1)
  );
  FD   r_q_0 (
    .C(clk_BUFGP_9),
    .D(_n0038[0]),
    .Q(r_q[0])
  );
  FD   r_q_1 (
    .C(clk_BUFGP_9),
    .D(_n0038[1]),
    .Q(r_q[1])
  );
  FD   r_q_2 (
    .C(clk_BUFGP_9),
    .D(_n0038[2]),
    .Q(r_q[2])
  );
  FD   r_q_3 (
    .C(clk_BUFGP_9),
    .D(_n0038[3]),
    .Q(r_q[3])
  );
  FD   r_q_4 (
    .C(clk_BUFGP_9),
    .D(_n0038[4]),
    .Q(r_q[4])
  );
  FD   r_q_5 (
    .C(clk_BUFGP_9),
    .D(_n0038[5]),
    .Q(r_q[5])
  );
  FD   r_q_6 (
    .C(clk_BUFGP_9),
    .D(_n0038[6]),
    .Q(r_q[6])
  );
  FD   r_q_7 (
    .C(clk_BUFGP_9),
    .D(_n0038[7]),
    .Q(r_q[7])
  );
  RAM64M #(
    .INIT_A ( 64'h0000000000000000 ),
    .INIT_B ( 64'h0000000000000000 ),
    .INIT_C ( 64'h0000000000000000 ),
    .INIT_D ( 64'h0000000000000000 ))
  Mram_ram1 (
    .WCLK(clk_BUFGP_9),
    .WE(push_IBUF_10),
    .DIA(d_0_IBUF_7),
    .DIB(d_1_IBUF_6),
    .DIC(d_2_IBUF_5),
    .DID(N1),
    .DOA(_n0038[0]),
    .DOB(_n0038[1]),
    .DOC(_n0038[2]),
    .DOD(NLW_Mram_ram1_DOD_UNCONNECTED),
    .ADDRA({r_end[5], r_end[4], r_end[3], r_end[2], r_end[1], r_end[0]}),
    .ADDRB({r_end[5], r_end[4], r_end[3], r_end[2], r_end[1], r_end[0]}),
    .ADDRC({r_end[5], r_end[4], r_end[3], r_end[2], r_end[1], r_end[0]}),
    .ADDRD({r_beg[5], r_beg[4], r_beg[3], r_beg[2], r_beg[1], r_beg[0]})
  );
  RAM64M #(
    .INIT_A ( 64'h0000000000000000 ),
    .INIT_B ( 64'h0000000000000000 ),
    .INIT_C ( 64'h0000000000000000 ),
    .INIT_D ( 64'h0000000000000000 ))
  Mram_ram2 (
    .WCLK(clk_BUFGP_9),
    .WE(push_IBUF_10),
    .DIA(d_3_IBUF_4),
    .DIB(d_4_IBUF_3),
    .DIC(d_5_IBUF_2),
    .DID(N1),
    .DOA(_n0038[3]),
    .DOB(_n0038[4]),
    .DOC(_n0038[5]),
    .DOD(NLW_Mram_ram2_DOD_UNCONNECTED),
    .ADDRA({r_end[5], r_end[4], r_end[3], r_end[2], r_end[1], r_end[0]}),
    .ADDRB({r_end[5], r_end[4], r_end[3], r_end[2], r_end[1], r_end[0]}),
    .ADDRC({r_end[5], r_end[4], r_end[3], r_end[2], r_end[1], r_end[0]}),
    .ADDRD({r_beg[5], r_beg[4], r_beg[3], r_beg[2], r_beg[1], r_beg[0]})
  );
  RAM64X1D #(
    .INIT ( 64'h0000000000000000 ))
  Mram_ram32 (
    .A0(r_beg[0]),
    .A1(r_beg[1]),
    .A2(r_beg[2]),
    .A3(r_beg[3]),
    .A4(r_beg[4]),
    .A5(r_beg[5]),
    .D(d_7_IBUF_0),
    .DPRA0(r_end[0]),
    .DPRA1(r_end[1]),
    .DPRA2(r_end[2]),
    .DPRA3(r_end[3]),
    .DPRA4(r_end[4]),
    .DPRA5(r_end[5]),
    .WCLK(clk_BUFGP_9),
    .WE(push_IBUF_10),
    .SPO(NLW_Mram_ram32_SPO_UNCONNECTED),
    .DPO(_n0038[7])
  );
  RAM64X1D #(
    .INIT ( 64'h0000000000000000 ))
  Mram_ram31 (
    .A0(r_beg[0]),
    .A1(r_beg[1]),
    .A2(r_beg[2]),
    .A3(r_beg[3]),
    .A4(r_beg[4]),
    .A5(r_beg[5]),
    .D(d_6_IBUF_1),
    .DPRA0(r_end[0]),
    .DPRA1(r_end[1]),
    .DPRA2(r_end[2]),
    .DPRA3(r_end[3]),
    .DPRA4(r_end[4]),
    .DPRA5(r_end[5]),
    .WCLK(clk_BUFGP_9),
    .WE(push_IBUF_10),
    .SPO(NLW_Mram_ram31_SPO_UNCONNECTED),
    .DPO(_n0038[6])
  );
  FDRE   r_beg_0 (
    .C(clk_BUFGP_9),
    .CE(push_IBUF_10),
    .D(Result[0]),
    .R(_n0040),
    .Q(r_beg[0])
  );
  FDRE   r_beg_1 (
    .C(clk_BUFGP_9),
    .CE(push_IBUF_10),
    .D(Result[1]),
    .R(_n0040),
    .Q(r_beg[1])
  );
  FDRE   r_beg_2 (
    .C(clk_BUFGP_9),
    .CE(push_IBUF_10),
    .D(Result[2]),
    .R(_n0040),
    .Q(r_beg[2])
  );
  FDRE   r_beg_3 (
    .C(clk_BUFGP_9),
    .CE(push_IBUF_10),
    .D(Result[3]),
    .R(_n0040),
    .Q(r_beg[3])
  );
  FDRE   r_beg_4 (
    .C(clk_BUFGP_9),
    .CE(push_IBUF_10),
    .D(Result[4]),
    .R(_n0040),
    .Q(r_beg[4])
  );
  FDRE   r_beg_5 (
    .C(clk_BUFGP_9),
    .CE(push_IBUF_10),
    .D(Result[5]),
    .R(_n0040),
    .Q(r_beg[5])
  );
  FDRE   r_beg_6 (
    .C(clk_BUFGP_9),
    .CE(push_IBUF_10),
    .D(Result[6]),
    .R(_n0040),
    .Q(r_beg[6])
  );
  FDRE   r_end_0 (
    .C(clk_BUFGP_9),
    .CE(pop_IBUF_11),
    .D(\Result<0>1 ),
    .R(_n0042),
    .Q(r_end[0])
  );
  FDRE   r_end_1 (
    .C(clk_BUFGP_9),
    .CE(pop_IBUF_11),
    .D(\Result<1>1 ),
    .R(_n0042),
    .Q(r_end[1])
  );
  FDRE   r_end_2 (
    .C(clk_BUFGP_9),
    .CE(pop_IBUF_11),
    .D(\Result<2>1 ),
    .R(_n0042),
    .Q(r_end[2])
  );
  FDRE   r_end_3 (
    .C(clk_BUFGP_9),
    .CE(pop_IBUF_11),
    .D(\Result<3>1 ),
    .R(_n0042),
    .Q(r_end[3])
  );
  FDRE   r_end_4 (
    .C(clk_BUFGP_9),
    .CE(pop_IBUF_11),
    .D(\Result<4>1 ),
    .R(_n0042),
    .Q(r_end[4])
  );
  FDRE   r_end_5 (
    .C(clk_BUFGP_9),
    .CE(pop_IBUF_11),
    .D(\Result<5>1 ),
    .R(_n0042),
    .Q(r_end[5])
  );
  FDRE   r_end_6 (
    .C(clk_BUFGP_9),
    .CE(pop_IBUF_11),
    .D(\Result<6>1 ),
    .R(_n0042),
    .Q(r_end[6])
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  \Msub_count_lut<0>  (
    .I0(r_beg[0]),
    .I1(r_end[0]),
    .O(Msub_count_lut[0])
  );
  MUXCY   \Msub_count_cy<0>  (
    .CI(N0),
    .DI(r_beg[0]),
    .S(Msub_count_lut[0]),
    .O(Msub_count_cy[0])
  );
  XORCY   \Msub_count_xor<0>  (
    .CI(N0),
    .LI(Msub_count_lut[0]),
    .O(count_0_OBUF_36)
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  \Msub_count_lut<1>  (
    .I0(r_beg[1]),
    .I1(r_end[1]),
    .O(Msub_count_lut[1])
  );
  MUXCY   \Msub_count_cy<1>  (
    .CI(Msub_count_cy[0]),
    .DI(r_beg[1]),
    .S(Msub_count_lut[1]),
    .O(Msub_count_cy[1])
  );
  XORCY   \Msub_count_xor<1>  (
    .CI(Msub_count_cy[0]),
    .LI(Msub_count_lut[1]),
    .O(count_1_OBUF_35)
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  \Msub_count_lut<2>  (
    .I0(r_beg[2]),
    .I1(r_end[2]),
    .O(Msub_count_lut[2])
  );
  MUXCY   \Msub_count_cy<2>  (
    .CI(Msub_count_cy[1]),
    .DI(r_beg[2]),
    .S(Msub_count_lut[2]),
    .O(Msub_count_cy[2])
  );
  XORCY   \Msub_count_xor<2>  (
    .CI(Msub_count_cy[1]),
    .LI(Msub_count_lut[2]),
    .O(count_2_OBUF_34)
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  \Msub_count_lut<3>  (
    .I0(r_beg[3]),
    .I1(r_end[3]),
    .O(Msub_count_lut[3])
  );
  MUXCY   \Msub_count_cy<3>  (
    .CI(Msub_count_cy[2]),
    .DI(r_beg[3]),
    .S(Msub_count_lut[3]),
    .O(Msub_count_cy[3])
  );
  XORCY   \Msub_count_xor<3>  (
    .CI(Msub_count_cy[2]),
    .LI(Msub_count_lut[3]),
    .O(count_3_OBUF_33)
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  \Msub_count_lut<4>  (
    .I0(r_beg[4]),
    .I1(r_end[4]),
    .O(Msub_count_lut[4])
  );
  MUXCY   \Msub_count_cy<4>  (
    .CI(Msub_count_cy[3]),
    .DI(r_beg[4]),
    .S(Msub_count_lut[4]),
    .O(Msub_count_cy[4])
  );
  XORCY   \Msub_count_xor<4>  (
    .CI(Msub_count_cy[3]),
    .LI(Msub_count_lut[4]),
    .O(count_4_OBUF_32)
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  \Msub_count_lut<5>  (
    .I0(r_beg[5]),
    .I1(r_end[5]),
    .O(Msub_count_lut[5])
  );
  MUXCY   \Msub_count_cy<5>  (
    .CI(Msub_count_cy[4]),
    .DI(r_beg[5]),
    .S(Msub_count_lut[5]),
    .O(Msub_count_cy[5])
  );
  XORCY   \Msub_count_xor<5>  (
    .CI(Msub_count_cy[4]),
    .LI(Msub_count_lut[5]),
    .O(count_5_OBUF_31)
  );
  XORCY   \Msub_count_xor<6>  (
    .CI(Msub_count_cy[5]),
    .LI(\Msub_count_lut<6>1_119 ),
    .O(count_6_OBUF_30)
  );
  LUT2 #(
    .INIT ( 4'h4 ))
  _n00401 (
    .I0(push_IBUF_10),
    .I1(rst_IBUF_8),
    .O(_n0040)
  );
  LUT2 #(
    .INIT ( 4'h4 ))
  _n00421 (
    .I0(pop_IBUF_11),
    .I1(rst_IBUF_8),
    .O(_n0042)
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \Mcount_r_beg_xor<1>11  (
    .I0(r_beg[1]),
    .I1(r_beg[0]),
    .O(Result[1])
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \Mcount_r_end_xor<1>11  (
    .I0(r_end[1]),
    .I1(r_end[0]),
    .O(\Result<1>1 )
  );
  LUT6 #(
    .INIT ( 64'h0000000000000001 ))
  almost_empty1 (
    .I0(count_6_OBUF_30),
    .I1(count_5_OBUF_31),
    .I2(count_4_OBUF_32),
    .I3(count_3_OBUF_33),
    .I4(count_2_OBUF_34),
    .I5(count_1_OBUF_35),
    .O(almost_empty_OBUF_38)
  );
  LUT3 #(
    .INIT ( 8'h6A ))
  \Mcount_r_beg_xor<6>11  (
    .I0(r_beg[6]),
    .I1(r_beg[5]),
    .I2(Mcount_r_beg_cy[4]),
    .O(Result[6])
  );
  LUT3 #(
    .INIT ( 8'h6A ))
  \Mcount_r_end_xor<6>11  (
    .I0(r_end[6]),
    .I1(r_end[5]),
    .I2(Mcount_r_end_cy[4]),
    .O(\Result<6>1 )
  );
  LUT3 #(
    .INIT ( 8'h6A ))
  \Mcount_r_beg_xor<2>11  (
    .I0(r_beg[2]),
    .I1(r_beg[0]),
    .I2(r_beg[1]),
    .O(Result[2])
  );
  LUT4 #(
    .INIT ( 16'h6AAA ))
  \Mcount_r_beg_xor<3>11  (
    .I0(r_beg[3]),
    .I1(r_beg[0]),
    .I2(r_beg[1]),
    .I3(r_beg[2]),
    .O(Result[3])
  );
  LUT5 #(
    .INIT ( 32'h80000000 ))
  \Mcount_r_beg_cy<4>11  (
    .I0(r_beg[4]),
    .I1(r_beg[3]),
    .I2(r_beg[2]),
    .I3(r_beg[1]),
    .I4(r_beg[0]),
    .O(Mcount_r_beg_cy[4])
  );
  LUT5 #(
    .INIT ( 32'h6AAAAAAA ))
  \Mcount_r_beg_xor<4>11  (
    .I0(r_beg[4]),
    .I1(r_beg[0]),
    .I2(r_beg[1]),
    .I3(r_beg[2]),
    .I4(r_beg[3]),
    .O(Result[4])
  );
  LUT3 #(
    .INIT ( 8'h6A ))
  \Mcount_r_end_xor<2>11  (
    .I0(r_end[2]),
    .I1(r_end[0]),
    .I2(r_end[1]),
    .O(\Result<2>1 )
  );
  LUT4 #(
    .INIT ( 16'h6AAA ))
  \Mcount_r_end_xor<3>11  (
    .I0(r_end[3]),
    .I1(r_end[0]),
    .I2(r_end[1]),
    .I3(r_end[2]),
    .O(\Result<3>1 )
  );
  LUT5 #(
    .INIT ( 32'h80000000 ))
  \Mcount_r_end_cy<4>11  (
    .I0(r_end[4]),
    .I1(r_end[3]),
    .I2(r_end[2]),
    .I3(r_end[1]),
    .I4(r_end[0]),
    .O(Mcount_r_end_cy[4])
  );
  LUT5 #(
    .INIT ( 32'h6AAAAAAA ))
  \Mcount_r_end_xor<4>11  (
    .I0(r_end[4]),
    .I1(r_end[0]),
    .I2(r_end[1]),
    .I3(r_end[2]),
    .I4(r_end[3]),
    .O(\Result<4>1 )
  );
  LUT2 #(
    .INIT ( 4'h8 ))
  almost_full1_SW0 (
    .I0(count_1_OBUF_35),
    .I1(count_0_OBUF_36),
    .O(N5)
  );
  LUT6 #(
    .INIT ( 64'hFFFFFFFF80000000 ))
  almost_full1 (
    .I0(count_5_OBUF_31),
    .I1(count_4_OBUF_32),
    .I2(count_3_OBUF_33),
    .I3(count_2_OBUF_34),
    .I4(N5),
    .I5(count_6_OBUF_30),
    .O(almost_full_OBUF_39)
  );
  LUT6 #(
    .INIT ( 64'h9009000000009009 ))
  empty711 (
    .I0(r_beg[1]),
    .I1(r_end[1]),
    .I2(r_beg[5]),
    .I3(r_end[5]),
    .I4(r_beg[4]),
    .I5(r_end[4]),
    .O(empty711_86)
  );
  LUT6 #(
    .INIT ( 64'h9009000000009009 ))
  empty712 (
    .I0(r_beg[0]),
    .I1(r_end[0]),
    .I2(r_beg[3]),
    .I3(r_end[3]),
    .I4(r_beg[2]),
    .I5(r_end[2]),
    .O(empty712_87)
  );
  IBUF   d_7_IBUF (
    .I(d[7]),
    .O(d_7_IBUF_0)
  );
  IBUF   d_6_IBUF (
    .I(d[6]),
    .O(d_6_IBUF_1)
  );
  IBUF   d_5_IBUF (
    .I(d[5]),
    .O(d_5_IBUF_2)
  );
  IBUF   d_4_IBUF (
    .I(d[4]),
    .O(d_4_IBUF_3)
  );
  IBUF   d_3_IBUF (
    .I(d[3]),
    .O(d_3_IBUF_4)
  );
  IBUF   d_2_IBUF (
    .I(d[2]),
    .O(d_2_IBUF_5)
  );
  IBUF   d_1_IBUF (
    .I(d[1]),
    .O(d_1_IBUF_6)
  );
  IBUF   d_0_IBUF (
    .I(d[0]),
    .O(d_0_IBUF_7)
  );
  IBUF   rst_IBUF (
    .I(rst),
    .O(rst_IBUF_8)
  );
  IBUF   push_IBUF (
    .I(push),
    .O(push_IBUF_10)
  );
  IBUF   pop_IBUF (
    .I(pop),
    .O(pop_IBUF_11)
  );
  OBUF   q_7_OBUF (
    .I(r_q[7]),
    .O(q[7])
  );
  OBUF   q_6_OBUF (
    .I(r_q[6]),
    .O(q[6])
  );
  OBUF   q_5_OBUF (
    .I(r_q[5]),
    .O(q[5])
  );
  OBUF   q_4_OBUF (
    .I(r_q[4]),
    .O(q[4])
  );
  OBUF   q_3_OBUF (
    .I(r_q[3]),
    .O(q[3])
  );
  OBUF   q_2_OBUF (
    .I(r_q[2]),
    .O(q[2])
  );
  OBUF   q_1_OBUF (
    .I(r_q[1]),
    .O(q[1])
  );
  OBUF   q_0_OBUF (
    .I(r_q[0]),
    .O(q[0])
  );
  OBUF   count_6_OBUF (
    .I(count_6_OBUF_30),
    .O(count[6])
  );
  OBUF   count_5_OBUF (
    .I(count_5_OBUF_31),
    .O(count[5])
  );
  OBUF   count_4_OBUF (
    .I(count_4_OBUF_32),
    .O(count[4])
  );
  OBUF   count_3_OBUF (
    .I(count_3_OBUF_33),
    .O(count[3])
  );
  OBUF   count_2_OBUF (
    .I(count_2_OBUF_34),
    .O(count[2])
  );
  OBUF   count_1_OBUF (
    .I(count_1_OBUF_35),
    .O(count[1])
  );
  OBUF   count_0_OBUF (
    .I(count_0_OBUF_36),
    .O(count[0])
  );
  OBUF   full_OBUF (
    .I(full_OBUF_40),
    .O(full)
  );
  OBUF   empty_OBUF (
    .I(empty_OBUF_37),
    .O(empty)
  );
  OBUF   almost_empty_OBUF (
    .I(almost_empty_OBUF_38),
    .O(almost_empty)
  );
  OBUF   almost_full_OBUF (
    .I(almost_full_OBUF_39),
    .O(almost_full)
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  \Msub_count_lut<6>1  (
    .I0(r_beg[6]),
    .I1(r_end[6]),
    .O(\Msub_count_lut<6>1_119 )
  );
  LUT6 #(
    .INIT ( 64'h6AAAAAAAAAAAAAAA ))
  \Mcount_r_beg_xor<5>11  (
    .I0(r_beg[5]),
    .I1(r_beg[4]),
    .I2(r_beg[3]),
    .I3(r_beg[2]),
    .I4(r_beg[1]),
    .I5(r_beg[0]),
    .O(Result[5])
  );
  LUT6 #(
    .INIT ( 64'h6AAAAAAAAAAAAAAA ))
  \Mcount_r_end_xor<5>11  (
    .I0(r_end[5]),
    .I1(r_end[4]),
    .I2(r_end[3]),
    .I3(r_end[2]),
    .I4(r_end[1]),
    .I5(r_end[0]),
    .O(\Result<5>1 )
  );
  LUT4 #(
    .INIT ( 16'h6000 ))
  full1 (
    .I0(r_beg[6]),
    .I1(r_end[6]),
    .I2(empty711_86),
    .I3(empty712_87),
    .O(full_OBUF_40)
  );
  LUT4 #(
    .INIT ( 16'h9000 ))
  empty72 (
    .I0(r_beg[6]),
    .I1(r_end[6]),
    .I2(empty711_86),
    .I3(empty712_87),
    .O(empty_OBUF_37)
  );
  BUFGP   clk_BUFGP (
    .I(clk),
    .O(clk_BUFGP_9)
  );
  INV   \Mcount_r_beg_xor<0>11_INV_0  (
    .I(r_beg[0]),
    .O(Result[0])
  );
  INV   \Mcount_r_end_xor<0>11_INV_0  (
    .I(r_end[0]),
    .O(\Result<0>1 )
  );
endmodule


`ifndef GLBL
`define GLBL

`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;

    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (weak1, weak0) GSR = GSR_int;
    assign (weak1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule

`endif

