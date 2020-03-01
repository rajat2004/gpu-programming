#include <stdio.h>
#include <cuda.h>

__global__ void hello() {
	int id = blockIdx.x * blockDim.x + threadIdx.x;
	//if (id == 2047)
		printf("my id is %d.\n", id);
}
int main() {
	dim3 block(1024, 1, 1);
	hello<<<2, block>>>();
	cudaDeviceSynchronize();
	return 0;
}
