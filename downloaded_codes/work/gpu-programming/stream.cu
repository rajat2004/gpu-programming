#include <cuda.h>
#include <stdio.h>

__global__ void K1() {
	unsigned num = 0;
	for (unsigned ii = 0; ii < threadIdx.x; ++ii)
		num += ii;
	printf("K1: %d\n", threadIdx.x);
}
__global__ void K2() {
	printf("K2\n");
}
int main() {
	cudaStream_t s1, s2;
	cudaStreamCreate(&s1);
	cudaStreamCreate(&s2);

	K1<<<1, 1024, 0, s1>>>();
	K2<<<1, 32, 0, s2>>>();
	cudaDeviceSynchronize();

	return 0;
}
