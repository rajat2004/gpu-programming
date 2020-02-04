#include<iostream>
using namespace std;

string msg = "Hello world";

__global__ void fun() {
    // const char* msg = "Hello world";
    printf("%s\n", msg);
}

int main() {
    fun<<<1,3>>>();
    cudaDeviceSynchronize();
    return 0;
}