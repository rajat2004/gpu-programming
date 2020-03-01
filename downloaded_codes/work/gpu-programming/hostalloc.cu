#include <cuda.h>
#include <stdio.h>

__global__ void printk(int *counter) {
	++*counter;
	printf("\t%d\n", *counter);
}
int main() {
	int *counter;

	cudaHostAlloc(&counter, sizeof(int), 0);
	//cudaHostAlloc(&counter, sizeof(int), cudaHostAllocMapped);
	do {
		printf("%d\n", *counter);
		printk <<<1, 1>>>(counter);
		cudaDeviceSynchronize();
		++*counter;
	} while (*counter < 10);

	cudaFreeHost(counter);
	return 0;
}
