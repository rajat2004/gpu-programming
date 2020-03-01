#include <stdio.h>
#include <cuda.h>

#define N	100000

__device__ unsigned wlsize;
__device__ int worklist[N];

__global__ void k1() {
	unsigned id = blockIdx.x * blockDim.x + threadIdx.x;
	worklist[atomicInc(&wlsize, N)] = id;
}
__global__ void k2() {
	printf("Number of elements added = %d\n", wlsize);
}
int main() {
	cudaMemset(&wlsize, 0, sizeof(int));	// initialization.
	k1<<<4, 64>>>();
	cudaDeviceSynchronize();
	k2<<<1, 1>>>();
	cudaDeviceSynchronize();

	return 0;
}
