#include <iostream>
#include <vector>
#include <cstdlib>
#include <math.h>

#define BORDER 18
#define ANGLE M_PI*3/4
using namespace std;
int main(int argc, char* argv[]){
    int width, height;
    int label_count;
    cin >> label_count;
    //width = atoi(argv[1]);
    //height = atoi(argv[2]);
    height = 288-36;
    width = 384-36;
    int *inputData = (int*)malloc(height*width*sizeof(int));
    for(int i = 0; i < height; i++)
        for(int j = 0; j < width; j++)
            cin >> inputData[i*width+j];
    int oldHeight = height;
    int oldWidth = width;
    double angle = ANGLE;
    double absAngle = angle;
    if(absAngle < 0)
        absAngle = -absAngle;
    if(absAngle > M_PI/2)
        absAngle = M_PI - absAngle;
    int newHeight = sin(absAngle) * oldWidth + cos(absAngle) * oldHeight + 2 * BORDER;
    int newWidth = cos(absAngle) * oldWidth + sin(absAngle) * oldHeight + 2 * BORDER;
    int* outputData = (int*)malloc(newHeight*newWidth*sizeof(int)); //[newHeight*newWidth];//(label_t*)malloc(newWidth*newHeight*sizeof(label_t));
    for(int i = 0; i < newHeight; i++){
        for(int j = 0; j < newWidth; j++){
            int jTransform = (int)(((double)i - newHeight/2.0)*sin(angle) + ((double)j - newWidth/2.0)*cos(angle) + width/2.0 + 0.5);
            int iTransform = (int)(((double)i - newHeight/2.0)*cos(angle) + ((double)j - newWidth/2.0)*sin(-angle) + height/2.0 + 0.5);
            if(iTransform < 0 || iTransform >= height || jTransform < 0 || jTransform >= width)
                outputData[i*newWidth+j] = -1;
            else
                outputData[i*newWidth+j] = inputData[iTransform*width+jTransform];
        }
    }
    cout << (newWidth - 2 * BORDER) * (newHeight - 2 * BORDER) << endl;
    for(int i = BORDER; i < newHeight - BORDER; i++)
        for(int j = BORDER; j < newWidth - BORDER; j++){
            cout << outputData[i*newWidth + j];
            cout << endl;}
}
