#include <stdio.h>
#include <cuda.h>

__global__ void K(int *a, int N) {
	#pragma unroll 2
	for (unsigned ii = 0; ii < N; ++ii) {
		a[ii] = ii + 1;
	}
}
int main() {
	int *a, N = 32;
	cudaMalloc(&a, N * sizeof(int));

	K<<<1, N>>>(a, N);
	cudaDeviceSynchronize();

	return 0;
}
