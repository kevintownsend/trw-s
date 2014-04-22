#define FMRF_H
#include <stdint.h>
#define LABELS 16
struct floatEdges{
   // Each vertex has 4 messages from its 
   // right/left/up/down edges and a data cost. 
   float left[LABELS];
   float right[LABELS];
   float up[LABELS];
   float down[LABELS];

};

typedef uint8_t label_t[LABELS];

struct floatField{
    int width, height;
    label_t* data;
    floatEdges* edges;
    uint8_t* assignment;
};
struct FieldPackage{
    int width, height;
    uint64_t data;
    uint64_t edges;
    uint64_t assignment;
    uint64_t size;
};

void InitGraph(const char* vdata_file, floatField &mrf); 
void WriteResults(const char *edata_file, floatField mrf); 
void WriteResultsRaw(const char *edata_file, floatField mrf);
float MAP(floatField mrf);

