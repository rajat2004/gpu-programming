#include <stdio.h>
#include <cuda.h>

__device__ int value = 5;
__global__ void child() {
	printf("in child %d\n", value);
}
__device__ void devfun() {
	value = value + 2;
	child<<<1, 2>>>();
}
__global__ void parent() {
	devfun();
	value = 4;
	cudaDeviceSynchronize();
}
int main() {
	parent<<<1, 2>>>();
	cudaDeviceSynchronize();
}



