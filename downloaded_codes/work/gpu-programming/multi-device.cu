#include <stdio.h>
#include <cuda.h>

__global__ void K1() {
	printf("in K1\n");
}
__global__ void K2() {
	printf("in K2\n");
}
__global__ void K3() {
	printf("in K3\n");
}
__global__ void K4() {
	printf("in K4\n");
}
int main() {
	cudaStream_t s0, s1;
	cudaEvent_t e0, e1;

	cudaSetDevice(0);
	cudaStreamCreate(&s0);
	cudaEventCreate(&e0);

	K1<<<1, 1, 0, s0>>>();
	cudaEventRecord(e0, s0);
	K2<<<1, 1, 0, s0>>>();

	cudaSetDevice(1);
	cudaStreamCreate(&s1);
	cudaEventCreate(&e1);

	K3<<<1, 1, 0, s1>>>();
	cudaStreamWaitEvent(s1, e0, 0);
	K4<<<1, 1, 0, s1>>>();

	cudaDeviceSynchronize();

	cudaSetDevice(0);
	cudaDeviceSynchronize();
	return 0;
}
