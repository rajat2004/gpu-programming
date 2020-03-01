#include <cuda.h>
#include <stdio.h>

int main() {
	cudaEvent_t start, stop;

	cudaEventCreate(&start);
	cudaEventCreate(&stop);

	cudaEventRecord(start, 0);
	printf("Hello World\n");
	unsigned sum = 0;
	for (unsigned ii = 0; ii < 100000; ++ii)
		sum += ii;
	cudaEventRecord(stop, 0);

	float elapsedtime;
	cudaEventElapsedTime(&elapsedtime, start, stop);
	printf("time = %f ms\n", elapsedtime);

	return 0;
}
