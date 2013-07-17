all : inputToPgm outputToPgm cyBeliefPropagation tardis.o cyTrw-s

inputToPgm : inputToPgm.cpp
	g++ -o inputToPgm inputToPgm.cpp

outputToPgm : outputToPgm.cpp
	g++ -o outputToPgm outputToPgm.cpp

cyBeliefPropagation : cyBeliefPropagation.cpp tardis.o
	g++ -fopenmp -lrt -O3 -o cyBeliefPropagation cyBeliefPropagation.cpp tardis.o

check :
	time cyBeliefPropagation
	outputToPgm 148 196 < section0 > section0.pgm
	outputToPgm 148 196 < section1 > section1.pgm
	outputToPgm 148 196 < section2 > section2.pgm
	outputToPgm 148 196 < section3 > section3.pgm
	outputToPgm < output_labels.txt > output.pgm

tardis.o :
	g++ -c tardis.cpp

trw-s.o : trw-s.cpp
	g++ -c trw-s.cpp

cyTrw-s : cyTrw-s.cpp trw-s.o tardis.o
	g++ -fopenmp -lrt -o cyTrw-s cyTrw-s.cpp tardis.o trw-s.o
checkTrw :
	time cyTrw-s
	outputToPgm 148 196 < section0 > section0.pgm
	outputToPgm 148 196 < section1 > section1.pgm
	outputToPgm 148 196 < section2 > section2.pgm
	outputToPgm 148 196 < section3 > section3.pgm
	outputToPgm < output_labels.txt > output.pgm

clean :
	rm -rf inputToPgm outputToPgm cyBeliefPropagation cyTrw-s *.pgm *.o section*
