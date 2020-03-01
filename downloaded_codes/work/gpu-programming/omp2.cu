#include <stdio.h>
#include <omp.h>
#include <cuda.h>

__global__ void K() {
	printf("in K: %d\n", threadIdx.x);
}
// Compiler as: nvcc -Xcompiler -fopenmp -lgomp omp.cu
int main() {
	int sh = 5;
	#pragma omp parallel for
	for (int i = 0; i < 10; ++i)
	{
		K<<<1, 1>>>();
		cudaDeviceSynchronize();
		++sh;
		printf("sh = %d\n", sh);
	}

	return 0;
}
