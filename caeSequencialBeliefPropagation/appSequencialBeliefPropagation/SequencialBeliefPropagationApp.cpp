//TODO: add header information
#include <convey/usr/cny_comp.h>
#include <iostream>
#include "mrf.h"
#include "trw-s.h"
#include <fstream>
#include <cstring>
#include <inttypes.h>
#include <ctime>
#include "tardis.h"
#undef DEBUG
#define COPROCESSOR 2
using namespace std;

typedef unsigned long long uint64;

//TODO: replace with new assembly function
extern "C" void bps();
extern "C" void custom0();
extern "C" void loadAeg0();
extern "C" void load_data();
extern "C" void belief_down();
extern "C" void belief_up();
extern "C" void store_down();
extern "C" void store_up();
extern "C" long get_aeg();

int main(int argc, char *argv[])
{
  // check command line args
//TODO: change number of arguments accepted and add usage message
    char inputFile[100] = "vdata_in.txt";
    char outputFile[100] = "memory.dat";
    if(argc == 3) {
        strcpy(inputFile, argv[1]);
        strcpy(outputFile, argv[2]);
    }else if(argc == 2)
        strcpy(inputFile, argv[1]);
    else if (argc != 1)
        return 0;

    //set runs
    int runs = 40;

  // Get personality signature
  // The "pdk" personality is the PDK sample vadd personality
  cny_image_t        sig2;
  cny_image_t        sig;
  int stat;
  if (cny_get_signature)
    cny_get_signature((char*)"SequencialBeliefPropagation", &sig, &sig2, &stat);
  else 
    fprintf(stderr,"ERROR:  cny_get_signature not found\n");

  if (stat) {
    printf("***ERROR: cny_get_signature() Failure: %d\n", stat);
    exit(1);
  }

  // check interleave
  // this example requires binary interleave
  if (cny_cp_interleave() == CNY_MI_3131) {
    printf("ERROR - interleave set to 3131, this personality requires binary interleave\n");
    exit (1);
  }

    //TODO: create 64x64 image
    Field mrf;
    FieldPackage* fp;
    fp = InitGraph(inputFile, mrf);
    int size = fp->size;
    cerr << "size: " << size << endl;
    ofstream initialMemory("initial_memory.dat");
    initialMemory << hex;
    for(int i = 0; i < size/8; i++){
        initialMemory << ((uint64_t*)fp)[i] << " ";
        if(i%10 == 0)
            initialMemory << endl;
    }
    initialMemory << dec;
    initialMemory.close();
    //TODO: move image to coprocessor
    //TODO: option for coprocessor or local
    if(COPROCESSOR == 1){
    FieldPackage* cnyFp = (FieldPackage*)cny_cp_malloc(size);
    cny_cp_memcpy(cnyFp, fp, size);
    //TODO: process image
    cerr << "Calling coprocessor." << endl;
    //copcall_fmt(sig, bps, "A", (uint64_t)cnyFp);
    copcall_fmt(sig, loadAeg0, "A", (uint64_t)cnyFp);
    cerr << "custom instruction" << endl;
    copcall_fmt(sig, load_data, "");
    cout << "@host:part1" << endl;
    stealTardis();
    for(int i = 0; i < runs - 1; i++){
        copcall_fmt(sig, belief_down, "");
        cout << "@host:part2" << endl;
        copcall_fmt(sig, belief_up, "");
        cout << "@host:part4" << endl;
    }
    copcall_fmt(sig, belief_down, "");
    cout << "@host:part2" << endl;
    copcall_fmt(sig, store_down, "");
    cout << "@host:part3" << endl;
    copcall_fmt(sig, belief_up, "");
    cout << "@host:part4" << endl;
    copcall_fmt(sig, store_up, "");
    cout << "@host:part5" << endl;
    returnTardis();
    cerr << "Returing from coprocessor." << endl;

    uint64_t errorRtn;
    cout << "@host: cnyFP: " << (uint64_t)cnyFp << endl;
    errorRtn = l_copcall_fmt(sig, get_aeg, "A", (uint64_t)0);
    cout << "@host:error:"  << errorRtn << endl;
    errorRtn = l_copcall_fmt(sig, get_aeg, "A", (uint64_t)1);
    cout << hex <<  "@host:error:"  << errorRtn << endl << dec;
    errorRtn = l_copcall_fmt(sig, get_aeg, "A", (uint64_t)2);
    cout << "@host:error:"  << errorRtn << endl;
    errorRtn = l_copcall_fmt(sig, get_aeg, "A", (uint64_t)3);
    cout << "@host:error:"  << errorRtn << endl;
    errorRtn = l_copcall_fmt(sig, get_aeg, "A", (uint64_t)4);
    cout << "@host:error:"  << errorRtn << endl;
    errorRtn = l_copcall_fmt(sig, get_aeg, "A", (uint64_t)5);
    cout << "@host:error:"  << errorRtn << endl;
    cout << "@host: idk:" << errorRtn - (uint64_t)cnyFp << endl;
    if(errorRtn >= cnyFp->array + (uint64_t)cnyFp && cnyFp->assignment + (uint64_t)cnyFp >= errorRtn)
        cout << "errorRtn in proper place " << endl;
    else
        cout << "errorRtn not in proper place " << endl;
    errorRtn = l_copcall_fmt(sig, get_aeg, "A", (uint64_t)6);
    cout << hex << "@host:error:"  << errorRtn << endl << dec;
    //TODO: read back from coprocessor
    clock_t t = clock();
    while(clock() - t < CLOCKS_PER_SEC);
    cny_cp_memcpy(fp, cnyFp, size);
    }else if(COPROCESSOR == 0){
        for(int i = 0; i < runs; i++)
            trws(mrf);
    }else if(COPROCESSOR == 2){
    FieldPackage* cnyFp = (FieldPackage*)cny_cp_malloc(size);
    cny_cp_memcpy(cnyFp, fp, size);
    //TODO: process image
    cerr << "Calling coprocessor." << endl;
    stealTardis();
    copcall_fmt(sig, bps, "AA", (uint64_t)cnyFp, (uint64_t)runs);
    returnTardis();
    cerr << "Returing from coprocessor." << endl;

    uint64_t errorRtn;
    cout << "@host: cnyFP: " << (uint64_t)cnyFp << endl;
    errorRtn = l_copcall_fmt(sig, get_aeg, "A", (uint64_t)0);
    cout << "@host:error:"  << errorRtn << endl;
    errorRtn = l_copcall_fmt(sig, get_aeg, "A", (uint64_t)1);
    cout << hex <<  "@host:error:"  << errorRtn << endl << dec;
    errorRtn = l_copcall_fmt(sig, get_aeg, "A", (uint64_t)2);
    cout << "@host:error:"  << errorRtn << endl;
    errorRtn = l_copcall_fmt(sig, get_aeg, "A", (uint64_t)3);
    cout << "@host:error:"  << errorRtn << endl;
    errorRtn = l_copcall_fmt(sig, get_aeg, "A", (uint64_t)4);
    cout << "@host:error:"  << errorRtn << endl;
    errorRtn = l_copcall_fmt(sig, get_aeg, "A", (uint64_t)5);
    cout << "@host:error:"  << errorRtn << endl;
    cout << "@host: idk:" << errorRtn - (uint64_t)cnyFp << endl;
    if(errorRtn >= cnyFp->array + (uint64_t)cnyFp && cnyFp->assignment + (uint64_t)cnyFp >= errorRtn)
        cout << "errorRtn in proper place " << endl;
    else
        cout << "errorRtn not in proper place " << endl;
    errorRtn = l_copcall_fmt(sig, get_aeg, "A", (uint64_t)6);
    cout << hex << "@host:error:"  << errorRtn << endl << dec;
    //TODO: read back from coprocessor
    clock_t t = clock();
    while(clock() - t < CLOCKS_PER_SEC);
    cny_cp_memcpy(fp, cnyFp, size);
    }
    ofstream finalMemory("final_memory.dat");
    finalMemory << hex;
    for(int i = 0; i < size/8; i++){
        finalMemory << ((uint64_t*)fp)[i] << " ";
        if(i%10 == 0)
            finalMemory << endl;
    }
    finalMemory << dec;
    finalMemory.close();
    cerr << "first left arrow" << endl;
    for(int i = 0; i < 16; i++){
        printf("wtf:%d", (int)(mrf.array[1].left[i]));
    }
    int energy = MAP(mrf);
    cout << endl;
    cout << "Energy: " << energy << endl;
    for(int i = 15; i >= 0; i--)
        printf("%02x", (int)mrf.array[12343].up[i]);
    cout << endl;
    for(int i = 15; i >= 0; i--)
        printf("%02x", (int)mrf.array[12343].left[i]);
    cout << endl;
    cout << hex << "checking data: " << endl;
    for(int i = 15; i >= 0; i--)
        printf("%02x", (int)mrf.data[12343][i]);
    cout << endl;
    for(int i = 15; i >= 0; i--)
        printf("%02x", (int)mrf.array[12344].left[i]);
    cout << endl;
    WriteResultsRaw("output_labels.txt", mrf);
    //TODO: MAP and write results

//TODO: replace with own cp call
/*
    cout << "@user:calling coprocessor" << endl;
    copcall_fmt(sig, cpTalk, "");
    cout << "@user:returned from coprocessor" << endl;
*/
    return 0;
}
