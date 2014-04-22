#if !defined(MRF_H)
    #include "mrf.h"
#endif
#define MRF_H
enum DIRECTION {LEFT, RIGHT, UP, DOWN, DATA};
void BP(Field mrf, DIRECTION direction, int iteration);

