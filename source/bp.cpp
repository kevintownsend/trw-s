#include "bp.h"
#include <assert.h>
#include <limits.h>
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
