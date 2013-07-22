vsim_bps_tb = work/bps_tb
vsim_bps = work/bps
vsim_b_ram = work/b_ram
vsim_sequencial_message_passer = work/sequencial_message_passer
all : work $(vsim_b_ram) $(vsim_bps) $(vsim_bps_tb) $(vsim_sequencial_message_passer)

work :
	vlib work

$(vsim_b_ram) : b_ram.v
	vlog -work work b_ram.v

$(vsim_bps) : bps.v
	vlog -work work bps.v +incdir+../.

$(vsim_bps_tb) : bps_tb.v
	vlog -work work bps_tb.v +incdir+../.

$(vsim_sequencial_message_passer) : ../sequencial_message_passer/sequencial_message_passer.v
	vlog -work work ../sequencial_message_passer/sequencial_message_passer.v +incdir+../.

vsim :
	vsim < test.do > vsim.out

xst :
	xst < bps.xst > xst.out

clean :
	rm -rf work *.lso *.ngc *.xrpt out transcript *.out _xmsgs xst
