#include <cuda.h>
#include <stdio.h>

__global__ void K1(int *dst, int nelem) {
	printf("\t%d\n", dst[nelem - 1]);
}
int main() {
	int nbytes = (1 << 30);
	int nelem = nbytes / sizeof(int);
	//int *src = (int *)malloc(nbytes);
	int *src; cudaHostAlloc(&src, nbytes, 0);
	src[nelem - 1] = 523;
	int *dst;
	cudaMalloc(&dst, nbytes);
for (unsigned ii = 0; ii < 100; ++ii) {
	printf("iteration1 %d\n", ii);
	cudaMemcpyAsync(dst, src, nbytes, cudaMemcpyHostToDevice);
	printf("iteration2 %d\n", ii);
	K1<<<1, 1>>>(dst, nelem);
	printf("iteration3 %d\n", ii);
	cudaDeviceSynchronize();
	cudaMemcpy(dst, dst+5, 1, cudaMemcpyDeviceToDevice);
	--src[nelem - 1];
}
	return 0;
}
