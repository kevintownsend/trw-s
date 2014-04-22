// ----------------------------------------------------------------------------------------
//    Tool to Evaluate Resulting Depth Labels for MEMOCODE Design Contest 2013
//
//    It reads output_labels.txt and ground_truth_labels.txt files.
//    These files contain depth labels produced by lbp.cpp and
//    the ground truth (reference) depth labels, respectivelly. 
//    The code calculates the number of label mismatches. 
// ----------------------------------------------------------------------------------------

#include <stdio.h>
#include <assert.h>
#include <cmath>
#include <iostream>

using namespace std;

int abs(int a){
    if(a < 0)
        return -a;
    else
        return a;
}

int main() {
    FILE *fp_ref;
    FILE *fp_test;

    int ref_lnum, test_lnum;
    int ref_label, test_label;
    int mismatch_cnt;
    int difference_cnt[16];
    for(int i = 0; i < 16; i++){
        difference_cnt[i] = 0;
    }

    // Open files
    if( ( fp_ref = fopen( "ground_truth_labels.txt", "r" ) ) == NULL ) {
        printf("Can't open file\n"); 
        assert(0);
    } 
    if( ( fp_test = fopen( "output_labels.txt", "r" ) ) == NULL ) {
        printf("Can't open file\n"); 
        assert(0);
    } 
   
    // Read number of labels to compare
    fscanf(fp_ref, "%d", &ref_lnum);
    fscanf(fp_test, "%d", &test_lnum);
    assert(ref_lnum == test_lnum);

    // Count mismatches
    mismatch_cnt=0;
    for(int i=0; i<ref_lnum; i++) {
       fscanf(fp_ref, "%d", &ref_label);
       fscanf(fp_test, "%d", &test_label);
        
       if(abs(ref_label - test_label) > 2) {
          mismatch_cnt++;
       } 
       difference_cnt[abs(ref_label - test_label)]++;
    }

    printf("There are %d mismatch out of %d labels\n", 
           mismatch_cnt, ref_lnum);
    cout << "difference array:" << endl;
    for(int i = 0; i < 16; i++){
        cout << difference_cnt[i] << endl;
    }

    return 0;
}

