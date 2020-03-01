#include <cuda.h>
#include <stdio.h>

__global__ void K1() {
	unsigned num = 0;
	unsigned id = blockIdx.x * blockDim.x + threadIdx.x;
	for (unsigned ii = 0; ii < id; ++ii)
		num += ii;
	printf("K1: %d\n", threadIdx.x);
}
__global__ void K2() {
	unsigned num = 0;
	unsigned id = blockIdx.x * blockDim.x + threadIdx.x;
	for (unsigned ii = 0; ii < id; ++ii)
		num += ii;
	__syncthreads();
	printf("K2: %d\n", threadIdx.x);
}
__global__ void K3() {
	printf("\tK3\n");
}
int main() {
	int *ptr;

	cudaStream_t s1, s2, s3;
	cudaStreamCreate(&s1);
	cudaStreamCreate(&s2);
	cudaStreamCreate(&s3);

	K1<<<32, 32, 0, s1>>>();
	cudaHostAlloc(&ptr, sizeof(int), 0);
	K2<<<1, 1024, 0, s2>>>();
	K3<<<1, 32, 0, s3>>>();
	cudaDeviceSynchronize();

	return 0;
}
