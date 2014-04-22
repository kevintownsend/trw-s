#include <iostream>
#include <vector>
#include <cstdlib>
#include <math.h>

#define BORDER 18
#define ANGLE M_PI*3/4
typedef int label_t[16];

using namespace std;
int main(int argc, char* argv[]){
    int width, height;
    cin >> width >> height;
    label_t *inputData = (label_t*)malloc(height*width*sizeof(label_t));
    for(int i = 0; i < height; i++){
        for(int j = 0; j < width; j++){
            for(int k = 0; k < 16; k++){
                cin >> inputData[i*width+j][k];}}}
    int oldHeight = height - 2 * BORDER;
    int oldWidth = width - 2 * BORDER;
    double angle = ANGLE;
    double absAngle = angle;
    if(absAngle < 0)
        absAngle = -absAngle;
    if(absAngle > M_PI/2)
        absAngle = M_PI - absAngle;
    int newHeight = sin(absAngle) * oldWidth + cos(absAngle) * oldHeight + 2 * BORDER;
    int newWidth = cos(absAngle) * oldWidth + sin(absAngle) * oldHeight + 2 * BORDER;
    label_t* outputData = (label_t*)malloc(newHeight*newWidth*sizeof(label_t)); //[newHeight*newWidth];//(label_t*)malloc(newWidth*newHeight*sizeof(label_t));
    for(int i = 0; i < newHeight; i++){
        for(int j = 0; j < newWidth; j++){
            int jTransform = (int)(((double)i - newHeight/2.0)*sin(angle) + ((double)j - newWidth/2.0)*cos(angle) + width/2.0 + 0.5);
            int iTransform = (int)(((double)i - newHeight/2.0)*cos(angle) + ((double)j - newWidth/2.0)*sin(-angle) + height/2.0 + 0.5);
            for(int k = 0; k < 16; k++){
                if(iTransform < 0 || iTransform >= height || jTransform < 0 || jTransform >= width)
                    outputData[i*newWidth+j][k] = 0;
                else
                    outputData[i*newWidth+j][k] = inputData[iTransform*width+jTransform][k];
            }
        }
    }
    cout << newWidth << " " << newHeight << endl;
    for(int i = 0; i < newHeight; i++)
        for(int j = 0; j < newWidth; j++){
            for(int k = 0; k < 16; k++)
                cout << outputData[i*newWidth + j][k] << " ";
            cout << endl;}
}
