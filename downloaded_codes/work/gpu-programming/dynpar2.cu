#include <stdio.h>
#include <cuda.h>

#define K 2

__global__ void Child(int father) {
	printf("%d\n", father + threadIdx.x);
}
__global__ void Parent() {
	if (threadIdx.x % K == 0) {
		Child<<<1, K>>>(threadIdx.x);
		cudaDeviceSynchronize();
		printf("Called childen with starting %d\n", threadIdx.x);
	}
}
int main() {
	Parent<<<1, 10>>>();
	cudaDeviceSynchronize();

	return 0;
}
