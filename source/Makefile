all : inputToPgm outputToPgm cyBeliefPropagation tardis.o cyTrw-s mrf.o splitMergeCheck bp.o rotateVdataIn rotateTruth eval_sig fmrf.o

inputToPgm : inputToPgm.cpp
	g++ -o inputToPgm inputToPgm.cpp

outputToPgm : outputToPgm.cpp
	g++ -o outputToPgm outputToPgm.cpp

cyBeliefPropagation : cyBeliefPropagation.cpp tardis.o
	g++ -O3 -fopenmp -lrt -o cyBeliefPropagation cyBeliefPropagation.cpp tardis.o

check :
	time cyBeliefPropagation
	outputToPgm 148 196 < section0 > section0.pgm
	outputToPgm 148 196 < section1 > section1.pgm
	outputToPgm 148 196 < section2 > section2.pgm
	outputToPgm 148 196 < section3 > section3.pgm
	outputToPgm < output_labels.txt > output.pgm

tardis.o : tardis.cpp
	g++ -c tardis.cpp

trw-s.o : trw-s.cpp
	g++ -O3 -c trw-s.cpp

cyTrw-s : cyTrw-s.cpp trw-s.o tardis.o
	g++ -O3 -fopenmp -lrt -o cyTrw-s cyTrw-s.cpp tardis.o trw-s.o

checkTrw :
	time cyTrw-s
	outputToPgm 148 196 < section0 > section0.pgm
	outputToPgm 148 196 < section1 > section1.pgm
	outputToPgm 148 196 < section2 > section2.pgm
	outputToPgm 148 196 < section3 > section3.pgm
	outputToPgm < output_labels.txt > output.pgm

mrf.o : mrf.cpp
	g++ -c mrf.cpp

fmrf.o : fmrf.cpp
	g++ -c fmrf.cpp

ftrws.o : ftwrs.cpp
	g++ -c ftwrs.cpp

splitMergeCheck : splitMergeCheck.cpp
	g++ -O3 -lrt -o splitMergeCheck splitMergeCheck.cpp tardis.o trw-s.o

check_smc :
	splitMergeCheck

bp.o : bp.cpp
	g++ -c bp.cpp

rotateVdataIn : rotateVdataIn.cpp
	g++ -o rotateVdataIn rotateVdataIn.cpp

checkRot :
	rotateVdataIn < vdata_in.txt

rotateTruth : rotateTruth.cpp
	g++ -o rotateTruth rotateTruth.cpp

eval_sig : eval_sig.cpp
	g++ -o eval_sig eval_sig.cpp

clean :
	rm -rf inputToPgm outputToPgm cyBeliefPropagation cyTrw-s *.pgm *.o section*
