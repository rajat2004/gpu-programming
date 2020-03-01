#include <stdio.h>
#include <cuda.h>

#define N	8
__global__ void exscan() {
	__shared__ unsigned a[N]; //= {4, 3, 9, 3, 5, 7, 3, 2};
	if (threadIdx.x == 0) {
		a[0] = 4; a[1] = 3; a[2] = 9; a[3] = 3;
		a[4] = 5; a[5] = 7; a[6] = 3; a[7] = 2;
	}
	__syncthreads();
	unsigned n = sizeof(a) / sizeof (*a);

	__syncthreads();
	for (int off = 0; off < n; off *= 2) {
		if (threadIdx.x > off) {
			a[threadIdx.x] += a[threadIdx.x - off];
		}
		__syncthreads();
	}
	__syncthreads();
	if (threadIdx.x == 0) {
		for (unsigned ii = 0; ii < n; ++ii)
			printf("%d ", a[ii]);
		printf("\n");
	}
}
int main() {
	//cudaSetDevice(5);
	exscan<<<1, 32>>>();
	cudaThreadSynchronize();
	return 0;
}

