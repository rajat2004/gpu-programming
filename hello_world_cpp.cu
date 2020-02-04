#include <iostream>
using namespace std;

__global__ void dkernel() {
    printf("Hello World from GPU!\n");
}

int main() {
    dkernel<<<1,332>>>();
    cudaDeviceSynchronize();
    return 0;
}