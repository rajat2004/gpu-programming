#include <cuda.h>
#include <stdio.h>

__global__ void printk(int *counter) {
	do {
		while (*counter % 2)
			;
		++*counter;
		//__threadfence_system();
		printf("\t%d\n", *counter);
	} while (*counter < 10);
}
int main() {
	int *counter;

	cudaHostAlloc(&counter, sizeof(int), 0);
	//cudaHostAlloc(&counter, sizeof(int), cudaHostAllocMapped);
	printk <<<1, 1>>>(counter);

	do {
		printf("%d\n", *counter);
		//fflush(stdout);
		while (*counter % 2 == 0)
			;
		++*counter;
		//__threadfence_system();
	} while (*counter < 10);

	cudaFreeHost(counter);
	return 0;
}
