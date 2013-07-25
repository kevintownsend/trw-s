#define MRF_H
#include <stdint.h>
#define LABELS 16
struct Node {
   // Each vertex has 4 messages from its 
   // right/left/up/down edges and a data cost. 
   uint8_t left[LABELS];
   uint8_t right[LABELS];
   uint8_t up[LABELS];
   uint8_t down[LABELS];

};

typedef uint8_t label_t[LABELS];

struct Field{
    int width, height;
    label_t* data;
    Node* array;
    uint8_t* assignment;
};

struct FieldPackage{
    int width, height;
    uint64_t data;
    uint64_t array;
    uint64_t assignment;
    uint64_t size;
};

FieldPackage* InitGraph(const char* vdata_file, Field &mrf); 
void WriteResults(const char *edata_file, Field mrf); 
void WriteResultsRaw(const char *edata_file, Field mrf);
unsigned int MAP(Field mrf);

