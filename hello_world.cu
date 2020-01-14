#include <stdio.h>
#include <cuda.h>

__global__ void dkernel() {
	printf("Hello World from GPU!\n");
}

int main() {
	dkernel<<<1,1>>>();
	cudaDeviceSynchronize();
	return 0;
}