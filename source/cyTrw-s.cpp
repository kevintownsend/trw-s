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
//#include "bp.h"
using namespace std;


enum DIRECTION {LEFT, RIGHT, UP, DOWN, DATA};

typedef unsigned int TYPE;

#define OVERLAP 16

#define MAX_NUM -1 

const int BP_ITERATIONS = 40;
const int LAMBDA = 16;
const int SMOOTHNESS_TRUNC = 2;
const int BORDER_SZ = 18;


FieldPackage* resizeGraph(Field *mrf, int* hSplits, int* vSplits, Field* newMrf);
void resizeBack(Field *mrf, Field *newMrf);
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
    if(argc == 1)
        InitGraph("vdata_in.txt", mrf);
    else if(argc == 2)
        InitGraph(argv[1],mrf);
    MAP(mrf);
    WriteResultsRaw("first_raw_input",mrf);
    int hSplits, vSplits;
    Field resizedMrf;
    resizeGraph(&mrf, &hSplits, &vSplits, &resizedMrf);
    MAP(resizedMrf);
    WriteResultsRaw("raw_input",resizedMrf);
    Field fields[hSplits*vSplits];
    cout << "split graph" << hSplits << ", " << vSplits << endl;
    splitGraph(resizedMrf, hSplits, vSplits, fields);
    for(int i = 0; i < hSplits*vSplits; i++){
        cout << "field: " << i << endl;
        cout << fields[i].width << ", " << fields[i].height << endl;
    }
    // ------------------------------------------------------
    // FOR THE CONTEST, START IMPLEMENTATION HERE 

//print 8x8 block

    // This loop is where LBP is performed.
    // Runtime measurement starts here
    cout << "starting bps" << endl;
    stealTardis();
    int runs = 40;
    cout << "runs:";
    cin >> runs;
    //#pragma omp parallel for
    for(int h = 0; h < hSplits * vSplits; h++){
        for(int i=0; i < runs; i++) {
            cout << "Iteration: " << i << endl;

            //TODO: print each iteration
            trws(fields[h]);
        }
    }
    returnTardis();
    // Runtime measurement ends here 

    // FOR THE CONTEST, END IMPLEMENTATION HERE 
    // ------------------------------------------------------
    for(int i = 0; i < hSplits * vSplits; i++){
        cerr << "cycle : " << i << endl;
        MAP(fields[i]);
        cerr << "map " << endl;
        sprintf(buffer,"%d",i);
        WriteResultsRaw((string("section") + string(buffer)).c_str(),fields[i]);
    }
    
    mergeGraph(resizedMrf, hSplits, vSplits, fields);

    // Assign labels 
    TYPE energy = MAP(resizedMrf);

    cout <<  "energy = " << energy << endl;

    resizeBack(&mrf, &resizedMrf);
    energy = MAP(mrf);

    cout <<  "energy = " << energy << endl;
    WriteResultsRaw("output_labels_raw.txt", resizedMrf);
    //InitGraph("vdata_in.txt", mrf);
    cout << "runs:";
    cin >> runs;
    stealTardis();
    for(int i = 0; i < runs; i++)
        trws(mrf);
    returnTardis();
    energy = MAP(mrf);
    cout <<  "energy = " << energy << endl;
    cout << "runs:";
    cin >> runs;
    for(int i = 0; i < runs; i++){
        BP(mrf, LEFT, i);
        BP(mrf, RIGHT, i);
        BP(mrf, UP, i);
        BP(mrf, DOWN, i);
    }
    energy = MAP(mrf);
    cout <<  "energy = " << energy << endl;
    cout << "runs:";
    cin >> runs;
    stealTardis();
    for(int i = 0; i < runs; i++)
        trws(mrf);
    returnTardis();
    energy = MAP(mrf);
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

FieldPackage* resizeGraph(Field* mrf, int* hSplits, int* vSplits, Field* destMrf){
    const int overlap = OVERLAP;
    cout << "Resizing graph" << endl;
    cout << mrf->width << endl;
    cout << mrf->height << endl;
    int inWidth = mrf->width;
    int inHeight = mrf->height;
    int tmp = (inWidth - 2 * overlap) / (128 - 2 * overlap);
    if((inWidth - 2 * overlap) / (128 - 2 * overlap))
        tmp++;
    *vSplits = tmp;
    int newWidth = tmp * (128 - 2 * overlap) + 2 * overlap;
    tmp = (inHeight - 2 * overlap) / (128 - 2 * overlap);
    if((inHeight - 2 * overlap) / (128 - 2 * overlap))
        tmp++;
    *hSplits = tmp;
    int newHeight = tmp * (128 - 2 * overlap) + 2 * overlap;
    cout << "New dimensions: " << newWidth << ", " << newHeight << endl;
    int pixelCount = newWidth * newHeight;
    int newSize = sizeof(FieldPackage) + pixelCount*(sizeof(label_t) + sizeof(Node)) + pixelCount;
    FieldPackage* fp = (FieldPackage*)malloc(newSize);
    fp->width = newWidth;
    fp->height = newHeight;
    fp->data = sizeof(FieldPackage);
    fp->array = fp->data + sizeof(label_t) * pixelCount;
    fp->assignment = fp->array + pixelCount * sizeof(Node);
    fp->size = newSize;
    destMrf->width = newWidth;
    destMrf->height = newHeight;
    destMrf->data = (label_t*)((uint8_t*)fp + fp->data);
    destMrf->array = (Node*)((uint8_t*)fp + fp->array);
    destMrf->assignment = (uint8_t*)((uint8_t*)fp + fp->assignment);
    for(int i = 0; i < newHeight; i++){
        for(int j = 0; j < newWidth; j++){
            int newIndex = i * newWidth + j;
            int oldIndex = i * inWidth + j;
            if(i < inHeight && j < inWidth){
                for(int k = 0; k < 16; k++){
                    destMrf->data[newIndex][k] = mrf->data[oldIndex][k];
                    /*
                    destMrf->array[newIndex].left[k] = mrf->data[oldIndex][k];
                    destMrf->array[newIndex].right[k] = mrf->data[oldIndex][k];
                    destMrf->array[newIndex].up[k] = mrf->data[oldIndex][k];
                    destMrf->array[newIndex].down[k] = mrf->data[oldIndex][k];*/
                }
            }else{
                for(int k = 0; k < 16; k++){
                    destMrf->data[newIndex][k] = 0;
                    destMrf->array[newIndex].left[k] = 0;
                    destMrf->array[newIndex].right[k] = 0;
                    destMrf->array[newIndex].up[k] = 0;
                    destMrf->array[newIndex].down[k] = 0;
                }
            }
        }
    }


    //TODO: calculate new size
}
void resizeBack(Field *mrf, Field *newMrf){
    int newHeight = newMrf->height;
    int newWidth = newMrf->width;
    int inHeight = mrf->height;
    int inWidth = mrf->width;
    for(int i = 0; i < newHeight; i++){
        for(int j = 0; j < newWidth; j++){
            int newIndex = i * newWidth + j;
            int oldIndex = i * inWidth + j;
            if(i < inHeight && j < inWidth){
                for(int k = 0; k < 16; k++){
                    mrf->data[oldIndex][k] = newMrf->data[newIndex][k];
                    mrf->array[oldIndex].left[k] = newMrf->array[newIndex].left[k];
                    mrf->array[oldIndex].right[k] = newMrf->array[newIndex].right[k];
                    mrf->array[oldIndex].up[k] = newMrf->array[newIndex].up[k];
                    mrf->array[oldIndex].down[k] = newMrf->array[newIndex].down[k];
                }
            }else{
            }
        }
    }
}

FieldPackage* splitGraph(Field mrf, int hSplits, int vSplits, Field* fields){
    const int overlap = OVERLAP;
    int hCuts[hSplits+1];
    int vCuts[vSplits+1];
    hCuts[0] = overlap;
    hCuts[hSplits] = mrf.height- overlap;
    //fields = (Field*) malloc(sizeof(Field) * hSplits * vSplits);
    for(int i = 1; i < hSplits; i++){
        hCuts[i] = (mrf.height - 2 * overlap) * i / hSplits + overlap;
    }
    vCuts[0] = overlap;
    vCuts[vSplits] = mrf.width- overlap;
    for(int i = 1; i < vSplits; i++){
        vCuts[i] = (mrf.width - 2 * overlap) * i / vSplits + overlap;
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
FieldPackage* splitGraph128x128Blocks(Field mrf, int* hSplits, int* vSplits, Field* fields){
    const int overlap = OVERLAP;
    //TODO:
    /*
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
    */
}
void mergeGraph(Field mrf, int hSplits, int vSplits, Field* fields){
    const int overlap = OVERLAP;
    int hCuts[hSplits+1];
    int vCuts[vSplits+1];
    hCuts[0] = overlap;
    hCuts[hSplits] = mrf.height - overlap;
    //fields = (Field*) malloc(sizeof(Field) * hSplits * vSplits);
    for(int i = 1; i < hSplits; i++){
        hCuts[i] = (mrf.height - 2 * overlap) * i / hSplits + overlap;
    }
    vCuts[0] = overlap;
    vCuts[vSplits] = mrf.width - overlap;
    for(int i = 1; i < vSplits; i++){
        vCuts[i] = (mrf.width - 2 * overlap)  * i / vSplits + overlap;
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
            destLeft = (globalWidth - 2 * overlap) * j / vSplits + overlap;
            destRight = (globalWidth - 2 * overlap) * (j+1) / vSplits + overlap;
            destTop = (globalHeight - 2 * overlap) * i / hSplits + overlap;
            destDown = (globalHeight - 2 * overlap) * (i+1) / hSplits + overlap;
            if(j == 0)
                destLeft = 0;
            if(j == vSplits - 1)
                destRight = globalWidth;
            if(i == 0)
                destTop = 0;
            if(i == hSplits)
                destDown = globalHeight;
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
