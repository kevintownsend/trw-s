#include <iostream>
#include <climits>
#include "trw-s.h"
#define FRAC 1
using namespace std;
void normalize(label_t &tmp);

void trws(Field mrf){
    int width = mrf.width;
    int height = mrf.height;
    for(int i = 0; i < height; i++){
        for(int j = 0; j < width; j++){
            int index = i*width + j;
            label_t right, down;
            for(int k = 0; k < 16; k++){
                int sum = mrf.data[index][k]*SCALE + mrf.array[index].left[k] + 
                    mrf.array[index].right[k] + mrf.array[index].up[k] + mrf.array[index].down[k];
                //TODO: down message
                int tmp = sum*FRAC - mrf.array[index].down[k]*FRAC;
                if(tmp <0)
                    tmp = 0;
                down[k] = tmp;
                tmp = sum*FRAC - mrf.array[index].right[k]*FRAC;
                if(tmp <0)
                    tmp = 0;
                right[k] = tmp;
                //TODO: right message
            }
            //smoooth
            normalize(down);
            normalize(right);
            int downIndex = index + width;
            int rightIndex = index + 1;
            if(i != height - 1){
                for(int k = 0; k < 16; k++){
                    mrf.array[downIndex].up[k] = down[k];
                }
            }
            if(j != width - 1){
                for(int k = 0; k < 16; k++){
                    mrf.array[rightIndex].left[k] = right[k];
                }
            }

        }
    }
    for(int i = height-1; i >= 0; i--){
        for(int j = width-1; j >= 0; j--){
            int index = i*width + j;
            label_t left, up;
            for(int k = 0; k < 16; k++){
                int sum = mrf.data[index][k]*SCALE + mrf.array[index].right[k] + 
                    mrf.array[index].left[k] + mrf.array[index].down[k] + mrf.array[index].up[k];
                //TODO: up message
                int tmp = sum*FRAC - mrf.array[index].up[k]*FRAC;
                if(tmp <0)
                    tmp = 0;
                up[k] = tmp;
                tmp = sum*FRAC - mrf.array[index].left[k]*FRAC;
                if(tmp <0)
                    tmp = 0;
                left[k] = tmp;

                //TODO: left message
                //cerr << "sum: " << sum << endl;
            }
            //smoooth
            normalize(up);
            normalize(left);
            int upIndex = index - width;
            int leftIndex = index - 1;
            if(i != 0){
                for(int k = 0; k < 16; k++){
                    mrf.array[upIndex].down[k] = up[k];
                }
            }
            if(j != 0){
                for(int k = 0; k < 16; k++){
                    mrf.array[leftIndex].right[k] = left[k];
                }
            }

        }
    }
}

void normalize(label_t &tmp){
                int min = INT_MAX;
                for(int i = 0; i < LABELS; i++)
                    if(tmp[i] < min)
                        min = tmp[i];
                for(int i = 0; i < LABELS; i++){
                    tmp[i] -= min;
                    if(tmp[i] > 32*SCALE)
                        tmp[i] = 32*SCALE;
                }
                for(int i = 0; i < LABELS; i++){
                    if(i == 0){
                        if(tmp[1]+16*SCALE < tmp[0])
                            tmp[0] = tmp[1] + 16*SCALE;
                    }else if(i == LABELS-1){
                        if(tmp[LABELS-2]+16*SCALE < tmp[LABELS-1])
                            tmp[LABELS-1] = tmp[LABELS-2] + 16*SCALE;
                    }else{
                        if(tmp[i-1]+16*SCALE < tmp[i])
                            tmp[i] = tmp[i-1] + 16*SCALE;
                        if(tmp[i+1]+16*SCALE < tmp[i])
                            tmp[i] = tmp[i+1] + 16*SCALE;
                    }
                }
}
