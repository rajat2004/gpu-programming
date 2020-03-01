#include <stdio.h>
#include <cuda.h>

__global__ void alloutputs(int *counter) {
    int oldc = atomicAdd(counter, 1);
    if (*counter == 34) printf("%d\n", oldc);
}
int main() {
     int *counter, hcounter = 0;
    cudaMalloc(&counter, sizeof(int));
    cudaMemcpy(counter, &hcounter, sizeof(int), cudaMemcpyHostToDevice);
    alloutputs<<<1, 34>>>(counter);
    cudaDeviceSynchronize();
    return 0;
}
