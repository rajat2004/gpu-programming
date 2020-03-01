#include <cuda.h>
#include <stdio.h>

__global__ void K() {
	printf("in K\n");
}
int main() {
	K<<<1, 1>>>();
	cudaDeviceSynchronize();

	return 0;
}
