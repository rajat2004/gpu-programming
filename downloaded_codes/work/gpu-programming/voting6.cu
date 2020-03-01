#include <stdio.h>
#include <cuda.h>

__global__ void K() {
	//unsigned val = __ballot(threadIdx.x % 2 == 0);
	if (threadIdx.x % 2 == 0) {
		unsigned val = __ballot(threadIdx.x < 100);
		if (threadIdx.x % 32 == 0) printf("%d\n", __popc(val));
	}
}
int main() {
	K<<<1, 128>>>();
	cudaDeviceSynchronize();

	return 0;
}
