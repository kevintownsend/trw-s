all : inputToPgm outputToPgm cyBeliefPropagation tardis.o

inputToPgm : inputToPgm.cpp
	g++ -o inputToPgm inputToPgm.cpp

outputToPgm : outputToPgm.cpp
	g++ -o outputToPgm outputToPgm.cpp

cyBeliefPropagation : cyBeliefPropagation.cpp tardis.o
	g++ -fopenmp -lrt -Ofast -o cyBeliefPropagation cyBeliefPropagation.cpp tardis.o

check :
	time cyBeliefPropagation

tardis.o :
	g++ -c tardis.cpp

clean :
	rm inputToPgm outputToPgm cyBeliefPropagation tardis.o
