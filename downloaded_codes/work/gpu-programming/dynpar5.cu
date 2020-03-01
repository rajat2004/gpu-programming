#include <cuda.h>
#include <stdio.h>

__global__ void Child(int parent) {
	printf("\tparent %d, child %d\n", parent, threadIdx.x + blockIdx.x * blockDim.x);
}
__global__ void Parent() {
	unsigned id = threadIdx.x + blockIdx.x * blockDim.x;
	printf("parent %d\n", id);
	cudaStream_t ss;
	cudaStreamCreateWithFlags(&ss, cudaStreamNonBlocking);
	Child<<<2, 2, 0, ss>>>(id);
	cudaDeviceSynchronize();
}
int main() {
	Parent<<<3, 4>>>();
	cudaDeviceSynchronize();

	return 0;
}
