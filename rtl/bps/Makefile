vsim_bps_tb = work/bps_tb
vsim_bps = work/bps
vsim_b_ram = work/b_ram
vsim_sequencial_message_passer = work/sequencial_message_passer
vsim_simple_dual_port_b_ram = work/simple_dual_port_b_ram
vsim_std_fifo = work/std_fifo
vsim_different_widths_fifo = work/different_widths_fifo
vsim_bps_master = work/bps_master
vsim_bps_master_tb = work/bps_master_tb
all : work $(vsim_b_ram) $(vsim_bps) $(vsim_bps_tb) $(vsim_sequencial_message_passer) $(vsim_simple_dual_port_b_ram) $(vsim_std_fifo) $(vsim_different_widths_fifo) $(vsim_bps_master) $(vsim_bps_master_tb)

work :
	vlib work

$(vsim_b_ram) : b_ram.v
	vlog -work work b_ram.v

$(vsim_simple_dual_port_b_ram) : simple_dual_port_b_ram.v
	vlog -work work simple_dual_port_b_ram.v

$(vsim_bps) : bps.v
	vlog -work work bps.v +incdir+../.

$(vsim_bps_tb) : bps_tb.v
	vlog -work work bps_tb.v +incdir+../.

$(vsim_sequencial_message_passer) : ../sequencial_message_passer/sequencial_message_passer.v
	vlog -work work ../sequencial_message_passer/sequencial_message_passer.v +incdir+../.

$(vsim_std_fifo) : ../std_fifo/std_fifo.v
	vlog -work work ../std_fifo/std_fifo.v +incdir+../.

$(vsim_different_widths_fifo) : ../different_widths_fifo/different_widths_fifo.v
	vlog -work work ../different_widths_fifo/different_widths_fifo.v +incdir+../.

$(vsim_bps_master) : bps_master.v
	vlog -work work bps_master.v

$(vsim_bps_master_tb) : bps_master_tb.v
	vlog -work work bps_master_tb.v

vsim_master :
	vsim < test_master.do > vsim.out

vsim :
	vsim < test.do > vsim.out

xst :
	xst < bps.xst > xst.out

clean :
	rm -rf work *.lso *.ngc *.xrpt out transcript *.out _xmsgs xst
