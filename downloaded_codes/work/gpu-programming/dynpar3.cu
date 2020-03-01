#include <stdio.h>
#include <cuda.h>

__device__ int value;
__global__ void child() {
	printf("in child %d\n", threadIdx.x);
}
__device__ void dchild() {
	child<<<1, 10>>>();
	cudaDeviceSynchronize();
}
__global__ void parent() {
	dchild();
}
int main() {
	parent<<<1, 2>>>();
	cudaDeviceSynchronize();
}
