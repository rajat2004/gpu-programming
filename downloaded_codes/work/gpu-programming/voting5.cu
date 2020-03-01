#include <stdio.h>
#include <cuda.h>

#define N 64

__global__ void init(int *a) {
	a[threadIdx.x] = 1;
}
__global__ void K(int *a) {
	// this forces other threads to return false. Ideally, other threads should be don't care.
	//unsigned mask = __ballot(threadIdx.x % 3 == 0 && a[threadIdx.x] == 0);
	unsigned mask = __ballot(threadIdx.x % 3 == 0 && a[threadIdx.x] == 0 || threadIdx.x % 3 != 0);
	if (threadIdx.x % 32 == 0) {
		printf("%X\n", mask);
	}
}
int main() {
	int *a;
	cudaMalloc(&a, N * sizeof(int));
	init<<<1, N>>>(a);
	K<<<1, N>>>(a);
	cudaDeviceSynchronize();

	return 0;
}
