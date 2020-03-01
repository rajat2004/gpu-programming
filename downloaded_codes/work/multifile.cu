/* compile as:
	nvcc -c multifile.cu
	g++ multifile-cfunction.c multifile.o -L/usr/local/cuda/lib64/ -lcuda -lcudart

  compiling as below results in linking error not finding cfunction.
	nvcc multifile.cu multifile-cfunction.c
*/
#include <stdio.h>
#include <cuda.h>

__global__ void dkernel(unsigned n) {
	printf("in dkernel %d\n", blockIdx.x * blockDim.x + threadIdx.x);
}
void cfunction();

#define BLOCKSIZE	32
int main() {
	unsigned N = BLOCKSIZE;
    	dkernel<<<1, BLOCKSIZE>>>(N);
	cudaThreadSynchronize();
	cfunction();
    	return 0;
}
