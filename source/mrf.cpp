#include "mrf.h"
#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <cassert>
#include <climits>

using namespace std;

typedef unsigned int TYPE;
const int LAMBDA = 16;
const int SMOOTHNESS_TRUNC = 2;
const int BORDER_SZ = 18;
uint32_t SmoothnessCost(int i, int j);
FieldPackage* InitGraph(const char* vdata_file, Field &mrf) {
    FILE *fp;
    int width, height;

    // Open File
    if( ( fp = fopen( vdata_file, "r" ) ) == NULL ) {
        printf("Can't open file %s\n", vdata_file);
        assert(0);
    } 

    fscanf(fp, "%d", &width);
    fscanf(fp, "%d", &height);

    mrf.width  = width; 
    mrf.height = height; 

    uint32_t pixelCount = width * height;
    uint32_t size = sizeof(FieldPackage) + pixelCount *(sizeof(label_t) + sizeof(Node)) + pixelCount; //TODO: calc size requirements
    // Allocate array of size width x height
    uint32_t tmp = sizeof(FieldPackage);
    cerr << "mrf size:" << sizeof(Field) << endl;
    FieldPackage* fieldPackage = (FieldPackage*)malloc(size);
    fieldPackage->width = width;
    fieldPackage->height = height;
    fieldPackage->data = tmp;
    tmp += pixelCount * sizeof(label_t);
    fieldPackage->array = tmp;
    tmp += pixelCount * sizeof(Node);
    fieldPackage->assignment = tmp;
    tmp += pixelCount;
    fieldPackage->size = size;
    assert(tmp == size);
    mrf.data = (label_t*)((uint8_t*)fieldPackage + fieldPackage->data);
    mrf.array = (Node*)((uint8_t*)fieldPackage + fieldPackage->array);
    mrf.assignment = (uint8_t*)fieldPackage + fieldPackage->assignment;

    // Initialise edge data (messages) to zero
    for(int i=0; i < mrf.width * mrf.height; i++) {
        for(int k=0; k < LABELS; k++) {
            mrf.array[i].left[k] = 0;
            mrf.array[i].right[k] = 0;
            mrf.array[i].up[k] = 0;
            mrf.array[i].down[k] = 0;
        }
    }

    // Initialize vertex data (Data Cost) from given file
    for(int vid=0; vid < mrf.width * mrf.height;vid++) {
        uint32_t levelCosts[LABELS];
        uint32_t tmp = 255;
        uint32_t min = UINT_MAX;
        for(int l=0; l < LABELS; l++) {
            fscanf(fp, "%d", &tmp);
            if(tmp < min)
                min = tmp;
            levelCosts[l]=tmp;
        }
        /*
        for(int l = 0; l < LABELS; l++){
            levelCosts[l] -= min;
        }
        for(int l = 0; l < LABELS; l++){
            if(levelCosts[l] > 32)
                levelCosts[l] = 32;
        }
        if(levelCosts[1] + 16 < levelCosts[0])
            levelCosts[0] = levelCosts[1] + 16;
        if(levelCosts[LABELS-2] + 16 < levelCosts[LABELS-1])
            levelCosts[LABELS-1] = levelCosts[LABELS-2] + 16;
        for(int l = 1; l < LABELS-1; l++){
            if(levelCosts[l+1] + 16 < levelCosts[l])
                levelCosts[l] = levelCosts[l+1] + 16;
            if(levelCosts[l-1] + 16 < levelCosts[l])
                levelCosts[l] = levelCosts[l-1] + 16;
        }
        */
        for(int l = 0; l < LABELS; l++){
            mrf.data[vid][l] = levelCosts[l];
        }

    }

    fclose(fp);
    return fieldPackage;
}

TYPE MAP(Field mrf)
{
    // Finds the MAP assignment as well as calculating the energy

    // MAP assignment
    for(size_t i=0; i < mrf.width * mrf.height; i++) {
        TYPE best = INT_MAX;
        for(int j=0; j < LABELS; j++) {
            TYPE cost = 0;

            cost += mrf.array[i].left[j];
            cost += mrf.array[i].right[j];
            cost += mrf.array[i].up[j];
            cost += mrf.array[i].down[j];
            cost += mrf.data[i][j];

            if(cost < best) {
                best = cost;
                mrf.assignment[i] = j;
            }
        }
    }

    int width = mrf.width;
    int height = mrf.height;

    // Energy
    TYPE energy = 0;
    //BORDER?
    for(int y=0; y < mrf.height; y++) {
        for(int x=0; x < mrf.width; x++) {
            int cur_label = mrf.assignment[y*width+x];

            // Data cost
            energy += mrf.data[y*width+x][cur_label];

            if(x-1 >= 0)     energy += SmoothnessCost(cur_label, mrf.assignment[y*width+x-1]);
            if(x+1 < width)  energy += SmoothnessCost(cur_label, mrf.assignment[y*width+x+1]);
            if(y-1 >= 0)     energy += SmoothnessCost(cur_label, mrf.assignment[(y-1)*width+x]);
            if(y+1 < height) energy += SmoothnessCost(cur_label, mrf.assignment[(y+1)*width+x]);
        }
    }

    return energy;
}

uint32_t SmoothnessCost(int i, int j)
{
    int d = i - j;

    return LAMBDA*std::min(abs(d), SMOOTHNESS_TRUNC);
}
void WriteResultsRaw(const char* edata_file, Field mrf) {
    FILE *fp;

    // Open File
    if( ( fp = fopen( edata_file, "w" ) ) == NULL ) {
        printf("Can't open file %s\n", edata_file);
        assert(0);
    } 

    // First line, write number of entries in file
    fprintf(fp, "%d\n", (mrf.width)*(mrf.height));

     // Write label assignments 
    for(int y=0; y < mrf.height; y++) {
        for(int x=0; x < mrf.width; x++) { 
            fprintf(fp, "%d\n", mrf.assignment[y*mrf.width+x]);
        }
    }

    fclose(fp);
}
void WriteResults(const char* edata_file, Field mrf) {
    FILE *fp;

    // Open File
    if( ( fp = fopen( edata_file, "w" ) ) == NULL ) {
        printf("Can't open file %s\n", edata_file);
        assert(0);
    } 

    // First line, write number of entries in file
    fprintf(fp, "%d\n", (mrf.width-(BORDER_SZ*2))*(mrf.height-(BORDER_SZ*2)));

     // Write label assignments 
    for(int y=BORDER_SZ; y < mrf.height-BORDER_SZ; y++) {
        for(int x=BORDER_SZ; x < mrf.width-BORDER_SZ; x++) { 
            fprintf(fp, "%d\n", mrf.assignment[y*mrf.width+x]);
        }
    }

    fclose(fp);
}
