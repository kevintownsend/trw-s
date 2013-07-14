//TODO: add header information
#include <convey/usr/cny_comp.h>
#include <iostream>

#undef DEBUG

using namespace std;

typedef unsigned long long uint64;

//TODO: replace with new assembly function
extern "C" void cpTalk();

int setupBeliefPropagationPersonality()
{
  // check command line args

  // Get personality signature
  // The "pdk" personality is the PDK sample vadd personality
  cny_image_t        sig2;
  cny_image_t        sig;
  int stat;
  if (cny_get_signature)
    cny_get_signature((char*)"BeliefPropagation", &sig, &sig2, &stat);
  else 
    fprintf(stderr,"ERROR:  cny_get_signature not found\n");

  if (stat) {
    printf("***ERROR: cny_get_signature() Failure: %d\n", stat);
    exit(1);
  }

  // check interleave
  // this example requires binary interleave
  if (cny_cp_interleave() == CNY_MI_3131) {
    printf("ERROR - interleave set to 3131, this personality requires binary interleave\n");
    exit (1);
  }

//TODO: replace with own cp call
    cout << "@user:calling coprocessor" << endl;
    copcall_fmt(sig, cpTalk, "");
    cout << "@user:returned from coprocessor" << endl;

    return 0;
}

//TODO: create implementation

//TODO: move memory
//TODO: call assembly function
//TODO: move memory back
