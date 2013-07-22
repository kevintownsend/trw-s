vsim_path_sequencial_message_passer = work/sequencial_message_passer
vsim_path_sequencial_message_passer_tb = work/sequencial_message_passer_tb
all : $(vsim_path_sequencial_message_passer) $(vsim_path_sequencial_message_passer_tb)


work :
	vlib work

$(vsim_path_sequencial_message_passer) : sequencial_message_passer.v
	vlog -work work sequencial_message_passer.v

$(vsim_path_sequencial_message_passer_tb) : sequencial_message_passer_tb.v
	vlog -work work sequencial_message_passer_tb.v

vsim :
	vsim < test.do

xst : sequencial_message_passer.v
	xst < sequencial_message_passer.xst > xst.out

clean :
	rm -rf work *.ngc *.xrpt transcript _xmsgs xst
