SWMODEL = ../sim/CaeSimPers

all : inputToPgm outputToPgm cyBeliefPropagation tardis.o cnyBeliefPropagation.o $(SWMODEL)

inputToPgm : inputToPgm.cpp
	g++ -o inputToPgm inputToPgm.cpp

outputToPgm : outputToPgm.cpp
	g++ -o outputToPgm outputToPgm.cpp

cyBeliefPropagation : cyBeliefPropagation.cpp tardis.o
	g++ -fopenmp -lrt -O3 -o cyBeliefPropagation cyBeliefPropagation.cpp tardis.o

check :
	time cyBeliefPropagation

tardis.o :
	g++ -c tardis.cpp

clean :
	rm inputToPgm outputToPgm cyBeliefPropagation tardis.o cnyBeliefPropagation.o
	make --directory=../sim clean

cnyBeliefPropagation.o : cnyBeliefPropagation.cpp cpBeliefPropagation.s
	cnyCC -c cnyBeliefPropagation.cpp cpBeliefPropagation.s

$(SWMODEL): ../Makefile.include ../sim/CaeIsaBeliefPropagation.cpp
	make -C ../sim
