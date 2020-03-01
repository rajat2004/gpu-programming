#include <stdio.h>
#include <cuda.h>

__global__ void K() {
	printf("%d\n", threadIdx.x + threadIdx.y);
}
int main() {
	dim3 block(3, 4);
	K<<<1, block>>>();
	cudaDeviceSynchronize();

	return 0;
}
