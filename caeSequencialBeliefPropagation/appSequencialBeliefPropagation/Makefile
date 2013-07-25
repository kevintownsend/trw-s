EXEC = SequencialBeliefPropagationApp.exe
SWMODEL = ../sim/CaeSimPers

all:	$(EXEC) $(SWMODEL)

clean:
	rm -f $(EXEC)
	make --directory=../sim clean
	rm -f initial_memory.dat final_memory.dat output

$(EXEC):	SequencialBeliefPropagationApp.cpp cpSequencialBeliefPropagation.s ../../source/mrf.o ../../source/trw-s.o
	cnyCC -g -I ../../source SequencialBeliefPropagationApp.cpp cpSequencialBeliefPropagation.s ../../source/trw-s.o ../../source/mrf.o -o SequencialBeliefPropagationApp.exe

$(SWMODEL): ../Makefile.include ../sim/CaeIsaSequencialBeliefPropagation.cpp
	make -C ../sim
