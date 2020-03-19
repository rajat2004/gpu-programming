#include<stdio.h>
#include<cuda.h>

#define N		1024
#define BLOCKSIZE	64

__device__ unsigned binary[N];
__device__ volatile unsigned k2counter;		// try removing volatile: the code may hang.

__global__ void K() {
	unsigned id = blockDim.x * blockIdx.x + threadIdx.x;
	binary[id] = id;
	__syncthreads();
	if (binary[N-1 - id] != N-1 - id)
		printf("Error: There is no global barrier.\n");
}
__global__ void K2init() {
	k2counter = 0;
}
__global__ void K2() {
	unsigned id = blockDim.x * blockIdx.x + threadIdx.x;

	printf("This is before: %d\n", id);

	// global barrier start
	atomicInc((unsigned *)&k2counter, N + 1);

	while (k2counter != N)
		;
	// global barrier end

	printf("This is after the global barrier: %d\n", id);
}
int main() {
	K<<<N / BLOCKSIZE, BLOCKSIZE>>>();

	K2init<<<1, 1>>>();
	K2<<<N / BLOCKSIZE, BLOCKSIZE>>>();
	cudaDeviceSynchronize();

	return 0;
}
