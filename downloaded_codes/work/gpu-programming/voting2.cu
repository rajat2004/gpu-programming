#include <stdio.h>
#include <cuda.h>

__global__ void K() {
	// Original: if (condition) atomicInc(&counter, 1000000);
	unsigned val = __ballot(threadIdx.x < 100);
	// leader.
	unsigned wcount = __popc(val);
	if (threadIdx.x % 32 == 0) printf("%d\n", __popc(val));
}
int main() {
	K<<<5, 128>>>();
	cudaDeviceSynchronize();

	return 0;
}
