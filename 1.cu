#include <iostream>
#define N 1024

using namespace std;

__global__ void fun(int* arr) {
    int id = threadIdx.x;
    arr[id] = id*id*id;
}

int main() {
    int ha[N], *a;
    cudaMalloc(&a, N*sizeof(N));
    fun<<<1,N>>>(a);
    cudaMemcpy(ha, a, N*sizeof(int), cudaMemcpyDeviceToHost);
    // cudaDeviceSynchronize();
    for(int i=0; i<N; i++) {
        cout << ha[i] << endl;
    }
    return 0;
}