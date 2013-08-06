EXEC = SequencialBeliefPropagationApp.exe
SWMODEL = ../sim/CaeSimPers

all:	$(EXEC) $(SWMODEL) cnyCySbp

clean:
	rm -f $(EXEC)
	make --directory=../sim clean
	rm -f initial_memory.dat final_memory.dat output
	rm -f cnyCySbp *.pgm section*

$(EXEC):	SequencialBeliefPropagationApp.cpp cpSequencialBeliefPropagation.s ../../source/mrf.o ../../source/trw-s.o ../../source/tardis.o
	cnyCC -g -I ../../source -lrt SequencialBeliefPropagationApp.cpp cpSequencialBeliefPropagation.s ../../source/trw-s.o ../../source/mrf.o ../../source/tardis.o -o SequencialBeliefPropagationApp.exe

$(SWMODEL): ../Makefile.include ../sim/CaeIsaSequencialBeliefPropagation.cpp
	make -C ../sim

cnyCySbp : cnyCySbp.cpp ../../source/trw-s.o ../../source/tardis.o cpSequencialBeliefPropagation.s
	cnyCC -fopenmp -lrt -I ../../source -o cnyCySbp cnyCySbp.cpp ../../source/tardis.o ../../source/trw-s.o cpSequencialBeliefPropagation.s

