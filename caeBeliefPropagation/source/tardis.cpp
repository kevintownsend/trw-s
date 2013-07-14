#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <ctime>
#include <unistd.h>
#include <time.h>
#include <sys/time.h>
#include "tardis.h"

using namespace std;

typedef struct{
    timeval tv;
    double tim;
    timespec ts;
}tardisTime;

tardisTime timeArr[10];
int timeStops;

int stealTardis(){
    gettimeofday(&(timeArr[0].tv),NULL);
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &(timeArr[0].ts));
    timeStops = 1;
    return 0;
}

int markTime(){
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &(timeArr[timeStops].ts));
    gettimeofday(&(timeArr[timeStops++].tv),NULL);
    return 0;
}

int returnTardis(){
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &(timeArr[timeStops].ts));
    gettimeofday(&(timeArr[timeStops++].tv),NULL);
    for(int i = 0; i < timeStops - 1; i++){
        double t1 = timeArr[i].tv.tv_sec + (timeArr[i].tv.tv_usec/1000000.0);
        double t2 = timeArr[i + 1].tv.tv_sec + (timeArr[i + 1].tv.tv_usec/1000000.0);
        cout << "step " << i + 1 << " time: " << (t2 - t1) << " seconds" << endl;
        t1 = timeArr[i].ts.tv_sec + (timeArr[i].ts.tv_nsec/1000000000.0);
        t2 = timeArr[i + 1].ts.tv_sec + (timeArr[i + 1].ts.tv_nsec/1000000000.0);
        cout << "Process time: " << (t2 - t1) << " seconds" << endl;
    }
    return 0;
}
