#include <stdio.h>
#include <cuda.h>

__global__ void dkernel() {
	printf("Hello World from GPU! %d\n", threadIdx.x);
}

int main() {
	dkernel<<<1,1024>>>();
	cudaDeviceSynchronize();
	return 0;
}