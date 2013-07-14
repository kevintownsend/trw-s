#include <iostream>
#include <climits>
#include <algorithm>
using namespace std;

int main(int argc, char* argv[]){
    if(argc != 1){
        cerr << "usage: " << argv[0] << " < input > output.pgm" << endl;
        return 1;
    }
    cout << "P5" << endl;
    int height, width;
    cin >> width >> height;
    cout << width << " " << height << endl;
    cout << "255" << endl;
    for(int i = 0; i < width*height; i++){
        int minVal = INT_MAX;
        int minLevel = 0;
        int tmp;
        for(int j = 0; j < 16; j++){
            cin >> tmp;
            if(tmp < minVal){
                minVal = tmp;
                minLevel = j;
            }
        }
        cout.put(minLevel*17);
    }
    return 0;
}
