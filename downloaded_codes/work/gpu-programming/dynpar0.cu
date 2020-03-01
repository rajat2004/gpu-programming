#include <stdio.h>
#include <cuda.h>

__global__ void Child(int father) {
	printf("Parent %d -- Child %d\n", father, threadIdx.x);
}
__global__ void Parent() {
	printf("Parent %d\n", threadIdx.x);
	Child<<<1, 5>>>(threadIdx.x);
}
int main() {
	Parent<<<1, 3>>>();
	cudaDeviceSynchronize();

	return 0;
}
