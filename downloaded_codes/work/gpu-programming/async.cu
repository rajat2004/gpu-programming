#include <cuda.h>
#include <stdio.h>

__global__ void K1() {
	unsigned sum = 0;
	if (blockIdx.x == 0 && threadIdx.x == 0)
		printf("K1 before\n");
	for (unsigned ii = 0; ii < 1000; ++ii) {
		sum += ii;
	}
	if (blockIdx.x == 0 && threadIdx.x == 0)
		printf("K1 after\n");
}
__global__ void K2() {
	printf("in K2\n");
}
int main() {
	printf("on CPU\n");
	K1<<<10, 32, 0, 0>>>();
	K2<<<1, 1>>>();
	cudaDeviceSynchronize();
	printf("on CPU\n");
	return 0;
}
