#include <stdio.h>
#include <cuda.h>

__global__ void K() {
	// Original: if (condition) atomicInc(&counter, 1000000);
	//unsigned val = __ballot(condition);
	// leader.
	//unsigned wcount = __popc(val);
	//if (threadIdx.x % 32 == 0) printf("%d\n", __popc(val));
	printf("%d\n", __ffs(0xF0000000));
}
int main() {
	K<<<1, 1>>>();
	cudaDeviceSynchronize();

	return 0;
}
