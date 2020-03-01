#include <stdio.h>
#include <omp.h>
#include <cuda.h>

#define N 100
__global__ void K(int *a, int start, int end) {
	printf("start = %d, end = %d\n", start, end);
}
int main() {
	int a[N];
	int ii;

	omp_set_num_threads(5);
	#pragma omp parallel
	{
	#pragma omp parallel for
	for (ii = 0; ii < N; ++ii) {
		a[ii] = ii;
	}

	int nthreads = omp_get_num_threads();
	int perthread = N / nthreads;
	int start = perthread * omp_get_thread_num();
	int end = start + perthread;
	K<<<1, 1>>>(a, start, end);
	cudaDeviceSynchronize();
	
	}
	printf("All over.\n");

	return 0;
}
