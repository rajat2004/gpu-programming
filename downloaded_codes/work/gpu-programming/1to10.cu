#include <stdio.h>


__global__ void onetoten() {
	__shared__ unsigned int n;
	n = 0;
	__syncthreads();

	while (n < 10) {
		int oldn = atomicInc(&n, 100);
		if (oldn % 3 == threadIdx.x) {
			printf("%d: %d\n", threadIdx.x, oldn);
		}
	}
}

__global__ void onetoten4() {
	__shared__ unsigned int n;
	n = 0;
	__syncthreads();

	while (n < 10) {
		int oldn = atomicInc(&n, 100);
		if (oldn % 3 == threadIdx.x) {
			printf("%d: %d\n", threadIdx.x, oldn);
		}
	}
}
__device__ volatile int n;
__global__ void onetoten3() {
	n = 0;
	__syncthreads();
	while (n < 10) {
		if (n % 3 == threadIdx.x) {
			printf("%d: %d\n", threadIdx.x, n);
			++n;
		}
	}
}
__global__ void onetoten2() {
	volatile __shared__ int n;
	n = 0;
	__syncthreads();
	while (n < 10) {
		if (n % 3 == threadIdx.x) {
			printf("%d: %d\n", threadIdx.x, n);
			++n;
		}
	}
}
__global__ void onetoten1() {
	__shared__ int n;
	n = 0;
	__syncthreads();
	while (n < 10) {
		if (n % 3 == threadIdx.x) {
			printf("%d: %d\n", threadIdx.x, n);
			++n;
		}
		__syncthreads();
	}
}
__global__ void onetoten0() {
	for (int ii = 0; ii < 10; ++ii) {
		if (ii % 3 == threadIdx.x) {
			printf("%d: %d\n", threadIdx.x, ii);
		}
	}
}
int main() {
	onetoten<<<1, 3>>>();
	cudaDeviceSynchronize();
	return 0;
}
