#include <stdio.h>
#include <cuda.h>

__global__ void K() {
	int x = threadIdx.x;
	unsigned mask = __match_any_sync(x);
	if (threadIdx.x % 32 == 0) printf("%X\n", mask);
}
int main() {
	K<<<1, 128>>>();
	cudaDeviceSynchronize();

	return 0;
}
