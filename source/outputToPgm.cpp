#include <iostream>
#include <climits>
#include <algorithm>
#include <cstdlib>
using namespace std;

int main(int argc, char* argv[]){
    int height, width;
    if(argc == 3){
        width = atoi(argv[1]);
        height = atoi(argv[2]);
    }else if(argc != 1){
        cerr << "usage: " << argv[0] << " < input > output.pgm" << endl;
        return 1;
    }else{
        height = 288-36;
        width = 384-36;
    }
    cout << "P5" << endl;
    cout << width << " " << height << endl;
    cout << "255" << endl;
    for(int i = 0; i < width*height; i++){
        int tmp;
        cin >> tmp;
        cout.put(tmp*17);
    }
    return 0;
}
