#vlog -reportprogress 300 -work work /home/ktown/rtl/std_fifo/std_fifo.v
#vlog -reportprogress 300 -work work /home/ktown/rtl/std_fifo/std_fifo_tb.v
vsim -novopt work.std_fifo_tb
run -all
