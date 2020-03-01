#include <stdio.h>
#include <omp.h>
#include <cuda.h>

__global__ void K() {
	printf("in K: %d\n", threadIdx.x);
}
// Compiler as: nvcc -Xcompiler -fopenmp -lgomp omp.cu
int main() {
	omp_set_num_threads(4);
	#pragma omp parallel
	{
		K<<<1, 1>>>();
		cudaDeviceSynchronize();
	}

	return 0;
}
