#include <stdio.h>
#include <omp.h>
#include <cuda.h>

#define N 10

__device__ __host__ void fun(int *a, int ii) {
	a[ii] = ii + 1;
}
__global__ void K(int *a) {
	fun(a, threadIdx.x);
}
int main() {
	int *a;
	cudaHostAlloc(&a, sizeof(int) * N, 0);
	K<<<1, N/2>>>(a);

	#pragma omp parallel for
	for (int ii = N/2; ii < N; ++ii)
		fun(a, ii);
	cudaDeviceSynchronize();

	for (int ii = 0; ii < N; ++ii)
		printf("a[%d] = %d\n", ii, a[ii]);
	return 0;
}
