#include <iostream>
#include <vector>
#include <string>
#include <cstdio>
#include <stdlib.h>
#include <assert.h>
#include <stdint.h>
#include <cmath>
#include <climits>
#include "tardis.h"
#include "trw-s.h"
using namespace std;


enum DIRECTION {LEFT, RIGHT, UP, DOWN, DATA};

typedef unsigned int TYPE;

#define MAX_NUM -1 

const int BP_ITERATIONS = 40;
const int LAMBDA = 16;
const int SMOOTHNESS_TRUNC = 2;
const int BORDER_SZ = 18;


FieldPackage* InitGraph(const char* vdata_file, Field &mrf); 
FieldPackage* splitGraph(Field mrf, int hSplits, int vSplits, Field* fields);
void mergeGraph(Field mrf, int hSplits, int vSplits, Field* fields);
uint32_t SmoothnessCost(int i, int j);
void WriteResults(const char *edata_file, Field mrf); 
void WriteResultsRaw(const char *edata_file, Field mrf);
TYPE MAP(Field mrf);
void BP(Field mrf, DIRECTION direction, int iteration);
//void SendMsg(MRF2D &mrf, int x, int y, DIRECTION direction);

int main(int argc, char* argv[]) {
    Field mrf;
    char buffer[100];

    InitGraph("vdata_in.txt", mrf);
    Field fields[2*2];
    splitGraph(mrf, 2, 2, fields);
    // ------------------------------------------------------
    // FOR THE CONTEST, START IMPLEMENTATION HERE 

//print 8x8 block

    // This loop is where LBP is performed.
    // Runtime measurement starts here
    stealTardis();
    #pragma omp parallel for
    for(int h = 0; h < 2*2; h++){
        for(int i=0; i < 10; i++) {
            cout << "Iteration: " << i << endl;

            //TODO: print each iteration
            trws(fields[h]);
        }
    }
    returnTardis();
    // Runtime measurement ends here 

    // FOR THE CONTEST, END IMPLEMENTATION HERE 
    // ------------------------------------------------------
    for(int i = 0; i < 2*2; i++){
        cerr << "cycle : " << i << endl;
        MAP(fields[i]);
        cerr << "map " << endl;
        sprintf(buffer,"%d",i);
        WriteResultsRaw((string("section") + string(buffer)).c_str(),fields[i]);
    }
    
    mergeGraph(mrf, 2, 2, fields);

    // Assign labels 
    TYPE energy = MAP(mrf);
    
    cout <<  "energy = " << energy << endl;

    WriteResults("output_labels.txt", mrf);

    return 0;
}

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
FieldPackage* splitGraph(Field mrf, int hSplits, int vSplits, Field* fields){
    const int overlap = 4;
    int hCuts[hSplits+1];
    int vCuts[vSplits+1];
    hCuts[0] = overlap;
    hCuts[hSplits] = mrf.height- overlap;
    //fields = (Field*) malloc(sizeof(Field) * hSplits * vSplits);
    for(int i = 1; i < hSplits; i++){
        hCuts[i] = mrf.height* i / hSplits;
    }
    vCuts[0] = overlap;
    vCuts[vSplits] = mrf.width- overlap;
    for(int i = 1; i < vSplits; i++){
        vCuts[i] = mrf.width * i / vSplits;
    }
    int totalSize = 0;
    for(int i = 0; i < hSplits; i++){
        int height= hCuts[i+1] - hCuts[i] + overlap*2;
        for(int j = 0; j < vSplits; j++){
            //TODO: allocate Field package
            int width = vCuts[j+1] - vCuts[j] + overlap*2;
            int pixelCount = height*width;
            totalSize += sizeof(FieldPackage) + pixelCount*(sizeof(label_t) + sizeof(Node)) + pixelCount;
        }
    }
    uint8_t* memory = (uint8_t*)malloc(totalSize);
    uint32_t currentLocation  = 0;
    for(int i = 0; i < hSplits; i++){
        int height = hCuts[i+1] - hCuts[i] + overlap*2;
        for(int j = 0; j < vSplits; j++){
            //TODO: allocate Field package
            int currentField = i * vSplits + j;
            uint32_t subLocation = 0;
            int width = vCuts[j+1] - vCuts[j] + overlap*2;
            int pixelCount = height*width;
            int size = sizeof(FieldPackage) + pixelCount*LABELS*(1+4+1);
            FieldPackage* fp = (FieldPackage*)(memory + currentLocation);
            fp->height = height;
            fp->width = width;
            fields[currentField].height = height;
            fields[currentField].width = width;
            cerr << "height:" << height << endl;
            cerr << "width:" << width << endl;
            subLocation = sizeof(FieldPackage);
            fp->data = subLocation;
            //TODO: setup fields first
            subLocation += pixelCount*sizeof(label_t);
            fp->array = subLocation;
            subLocation += pixelCount*sizeof(Node);
            fp->assignment = subLocation;
            subLocation += pixelCount;
            fp->size = subLocation;
            fields[currentField].data = (label_t*)(memory+currentLocation+fp->data);
            fields[currentField].array = (Node*)(memory+currentLocation+fp->array);
            fields[currentField].assignment = (uint8_t*)(memory+currentLocation+fp->assignment);
            int counter = 0;
            for(int k = hCuts[i] - overlap; k < hCuts[i+1] + overlap; k++){
                for(int l = vCuts[j] - overlap; l < vCuts[j+1] + overlap; l++){
                    int tmp = l + k * mrf.width;
                    for(int m = 0; m < LABELS; m++){
                        fields[currentField].data[counter][m] = mrf.data[tmp][m];
                        fields[currentField].array[counter].left[m] = mrf.array[tmp].left[m];
                        fields[currentField].array[counter].right[m] = mrf.array[tmp].right[m];
                        fields[currentField].array[counter].up[m] = mrf.array[tmp].up[m];
                        fields[currentField].array[counter].down[m] = mrf.array[tmp].down[m];
                    }
                    fields[currentField].assignment[counter] = 0;
                    counter++;
                }
            }
            currentLocation += subLocation;
        }
    }
    return (FieldPackage*)memory;
}
void mergeGraph(Field mrf, int hSplits, int vSplits, Field* fields){
    const int overlap = 4;
    int hCuts[hSplits+1];
    int vCuts[vSplits+1];
    hCuts[0] = overlap;
    hCuts[hSplits] = mrf.height - overlap;
    //fields = (Field*) malloc(sizeof(Field) * hSplits * vSplits);
    for(int i = 1; i < hSplits; i++){
        hCuts[i] = mrf.height* i / hSplits;
    }
    vCuts[0] = overlap;
    vCuts[vSplits] = mrf.width - overlap;
    for(int i = 1; i < vSplits; i++){
        vCuts[i] = mrf.width * i / vSplits;
    }
    int totalSize = 0;
    uint32_t currentLocation  = 0;
    int globalHeight = mrf.height;
    int globalWidth = mrf.width;
    for(int i = 0; i < hSplits; i++){
        for(int j = 0; j < vSplits; j++){
            int currentField = i * vSplits + j;
            int counter = 0;
            int sourceLeft, sourceRight, sourceTop, sourceDown;
            int destLeft, destRight, destTop, destDown;
            int width = fields[currentField].width;
            int height = fields[currentField].height;
            if(j==0){
                sourceLeft = 0;
            }else{
                sourceLeft = overlap;
            }
            if(j==vSplits -1){
                sourceRight = width;
            }else{
                sourceRight = width - overlap;
            }
            if(i==0){
                sourceTop = 0;
            }else{
                sourceTop = overlap;
            }
            if(i == hSplits - 1){
                sourceDown = height;
            }else{
                sourceDown = height - overlap;
            }
            destLeft = globalWidth * j / vSplits;
            destRight = globalWidth * (j+1) / vSplits;
            destTop = globalHeight * i / hSplits;
            destDown = globalHeight * (i+1) / hSplits;
            //TODO: dest
            int sourceX, sourceY, sourceIndex;
            sourceY = sourceTop;
            for(int k = destTop; k < destDown; k++){
                sourceX = sourceLeft;
                for(int l = destLeft; l < destRight; l++){
                    int tmp = l + k * globalWidth;
                    sourceIndex = sourceX + width * sourceY;
                    for(int m = 0; m < LABELS; m++){
                        mrf.array[tmp].left[m] = fields[currentField].array[sourceIndex].left[m];
                        mrf.array[tmp].right[m] = fields[currentField].array[sourceIndex].right[m];
                        mrf.array[tmp].up[m] = fields[currentField].array[sourceIndex].up[m];
                        mrf.array[tmp].down[m] = fields[currentField].array[sourceIndex].down[m];
                    }
                    fields[currentField].assignment[counter] = 0;
                    counter++;
                    sourceX++;
                }
                sourceY++;
            }
        }
    }
    return;
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

/*
void SendMsg(Field mrf, int x, int y, DIRECTION direction)
{
    TYPE new_msg[LABELS];

    int width = mrf.width;

    for(int i=0; i < LABELS; i++) {
        TYPE min_val = MAX_NUM;

        for(int j=0; j < LABELS; j++) {
            TYPE p = 0;

            p += SmoothnessCost(i,j);              // Smoothness Cost
            p += mrf.array[y*width+x].msg[DATA][j]; // Data Cost

            // Exclude the incoming message direction that we are sending to
            if(direction != LEFT) p += mrf.array[y*width+x].msg[LEFT][j];
            if(direction != RIGHT) p += mrf.array[y*width+x].msg[RIGHT][j];
            if(direction != UP) p += mrf.array[y*width+x].msg[UP][j];
            if(direction != DOWN) p += mrf.array[y*width+x].msg[DOWN][j];

            min_val = std::min(min_val, p);
        }

        new_msg[i] = min_val;
    }

    for(int i=0; i < LABELS; i++) {

        switch(direction) {
            case LEFT:
            mrf.array[y*width + x-1].msg[RIGHT][i] = new_msg[i];
            break;

            case RIGHT:
            mrf.array[y*width + x+1].msg[LEFT][i] = new_msg[i];
            break;

            case UP:
            mrf.array[(y-1)*width + x].msg[DOWN][i] = new_msg[i];
            break;

            case DOWN:
            mrf.array[(y+1)*width + x].msg[UP][i] = new_msg[i];
            break;

            default:
            assert(0);
            break;
        }
    }
}
*/

void BP(Field mrf, DIRECTION direction, int iteration)
{
    //float weight = pow(.1,iteration);
    int width = mrf.width;
    int height = mrf.height;
    uint32_t tmp[LABELS];

    switch(direction) {
        case RIGHT:
        for(int x=0; x < width-1; x++) {
            for(int y=0; y < height; y++) {
                int index = y*width+x;
                for(int i = 0; i < LABELS; i++){
                    tmp[i] = 0;
                    tmp[i] += mrf.data[index][i]; //*weight;
                    tmp[i] += mrf.array[index].left[i];
                    tmp[i] += mrf.array[index].up[i];
                    tmp[i] += mrf.array[index].down[i];
                }
                int min = INT_MAX;
                for(int i = 0; i < LABELS; i++)
                    if(tmp[i] < min)
                        min = tmp[i];
                for(int i = 0; i < LABELS; i++){
                    tmp[i] -= min;
                    if(tmp[i] > 32)
                        tmp[i] = 32;
                }
                for(int i = 0; i < LABELS; i++){
                    if(i == 0){
                        if(tmp[1]+16 < tmp[0])
                            tmp[0] = tmp[1] + 16;
                    }else if(i == LABELS-1){
                        if(tmp[LABELS-2]+16 < tmp[LABELS-1])
                            tmp[LABELS-1] = tmp[LABELS-2] + 16;
                    }else{
                        if(tmp[i-1]+16 < tmp[i])
                            tmp[i] = tmp[i-1] + 16;
                        if(tmp[i+1]+16 < tmp[i])
                            tmp[i] = tmp[i+1] + 16;
                    }
                }
                index +=1;
                for(int i = 0; i < LABELS; i++){
                    mrf.array[index].left[i] = tmp[i];
                }
            }
        }
        break;

        case LEFT:
        for(int x=width-1; x >= 1; x--) {
            for(int y=0; y < height; y++) {
                int index = y*width+x;
                for(int i = 0; i < LABELS; i++){
                    tmp[i] = 0;
                    tmp[i] += mrf.data[index][i]; //*weight;
                    tmp[i] += mrf.array[index].right[i];
                    tmp[i] += mrf.array[index].up[i];
                    tmp[i] += mrf.array[index].down[i];
                }
                int min = INT_MAX;
                for(int i = 0; i < LABELS; i++)
                    if(tmp[i] < min)
                        min = tmp[i];
                for(int i = 0; i < LABELS; i++){
                    tmp[i] -= min;
                    if(tmp[i] > 32)
                        tmp[i] = 32;
                }
                for(int i = 0; i < LABELS; i++){
                    if(i == 0){
                        if(tmp[1]+16 < tmp[0])
                            tmp[0] = tmp[1] + 16;
                    }else if(i == LABELS-1){
                        if(tmp[LABELS-2]+16 < tmp[LABELS-1])
                            tmp[LABELS-1] = tmp[LABELS-2] + 16;
                    }else{
                        if(tmp[i-1]+16 < tmp[i])
                            tmp[i] = tmp[i-1] + 16;
                        if(tmp[i+1]+16 < tmp[i])
                            tmp[i] = tmp[i+1] + 16;
                    }
                }
                index -=1;
                for(int i = 0; i < LABELS; i++){
                    mrf.array[index].right[i] = tmp[i];
                }
            }
        }
        break;

        case DOWN:
        for(int y=0; y < height-1; y++) {
            for(int x=0; x < width; x++) {
                int index = y*width+x;
                for(int i = 0; i < LABELS; i++){
                    tmp[i] = 0;
                    tmp[i] += mrf.data[index][i]; //*weight;
                    tmp[i] += mrf.array[index].right[i];
                    tmp[i] += mrf.array[index].up[i];
                    tmp[i] += mrf.array[index].left[i];
                }
                int min = INT_MAX;
                for(int i = 0; i < LABELS; i++)
                    if(tmp[i] < min)
                        min = tmp[i];
                for(int i = 0; i < LABELS; i++){
                    tmp[i] -= min;
                    if(tmp[i] > 32)
                        tmp[i] = 32;
                }
                for(int i = 0; i < LABELS; i++){
                    if(i == 0){
                        if(tmp[1]+16 < tmp[0])
                            tmp[0] = tmp[1] + 16;
                    }else if(i == LABELS-1){
                        if(tmp[LABELS-2]+16 < tmp[LABELS-1])
                            tmp[LABELS-1] = tmp[LABELS-2] + 16;
                    }else{
                        if(tmp[i-1]+16 < tmp[i])
                            tmp[i] = tmp[i-1] + 16;
                        if(tmp[i+1]+16 < tmp[i])
                            tmp[i] = tmp[i+1] + 16;
                    }
                }
                index +=width;
                for(int i = 0; i < LABELS; i++){
                    mrf.array[index].up[i] = tmp[i];
                }
            }
        }
        break;

        case UP:
        for(int y=height-1; y >= 1; y--) {
            for(int x=0; x < width; x++) {
                int index = y*width+x;
                for(int i = 0; i < LABELS; i++){
                    tmp[i] = 0;
                    tmp[i] += mrf.data[index][i]; //*weight;
                    tmp[i] += mrf.array[index].right[i];
                    tmp[i] += mrf.array[index].left[i];
                    tmp[i] += mrf.array[index].down[i];
                }
                int min = INT_MAX;
                for(int i = 0; i < LABELS; i++)
                    if(tmp[i] < min)
                        min = tmp[i];
                for(int i = 0; i < LABELS; i++){
                    tmp[i] -= min;
                    if(tmp[i] > 32)
                        tmp[i] = 32;
                }
                for(int i = 0; i < LABELS; i++){
                    if(i == 0){
                        if(tmp[1]+16 < tmp[0])
                            tmp[0] = tmp[1] + 16;
                    }else if(i == LABELS-1){
                        if(tmp[LABELS-2]+16 < tmp[LABELS-1])
                            tmp[LABELS-1] = tmp[LABELS-2] + 16;
                    }else{
                        if(tmp[i-1]+16 < tmp[i])
                            tmp[i] = tmp[i-1] + 16;
                        if(tmp[i+1]+16 < tmp[i])
                            tmp[i] = tmp[i+1] + 16;
                    }
                }
                index -=width;
                for(int i = 0; i < LABELS; i++){
                    mrf.array[index].down[i] = tmp[i];
                }
            }
        }
        break;

        case DATA:
            assert(0);
        break;
    }
}
TYPE MAP(Field mrf)
{
    // Finds the MAP assignment as well as calculating the energy

    // MAP assignment
    for(size_t i=0; i < mrf.width * mrf.height; i++) {
        TYPE best = MAX_NUM; 
        for(int j=0; j < LABELS; j++) {
            TYPE cost = 0;

            cost += mrf.array[i].left[j];
            cost += mrf.array[i].right[j];
            cost += mrf.array[i].up[j];
            cost += mrf.array[i].down[j];
            cost += mrf.data[i][j] * SCALE;

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
