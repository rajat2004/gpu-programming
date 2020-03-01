#include <stdio.h>
#include <cuda.h>
__device__ unsigned dfun(unsigned id) {
	printf("%d\n", id);
	if (id > 10 && id < 15) return dfun(id+1);
	else return 0;
}
__global__ void dkernel(unsigned n) {
	dfun(n);
	
}

#define BLOCKSIZE	256
int main(int nn, char *str[]) {
	unsigned N = atoi(str[1]);
    	dkernel<<<1, BLOCKSIZE>>>(N);
	cudaThreadSynchronize();
    	return 0;
}
