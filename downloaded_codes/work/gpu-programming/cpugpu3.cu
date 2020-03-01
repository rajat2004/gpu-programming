#include <cuda.h>
#include <stdio.h>

// not working.

__global__ void printk(int *counter) {
	do {
		while (*counter % 2)
			;
		++*counter;
		__threadfence_system();
		printf("\t%d\n", *counter);
	} while (*counter < 10);
}
int main() {
	int hcounter = 0, *counter;

	cudaMalloc(&counter, sizeof(int));
	cudaMemcpy(counter, &hcounter, sizeof(int), cudaMemcpyHostToDevice);

	printk <<<1, 1>>>(counter);

	do {
		printf("%d\n", hcounter);
		while (hcounter % 2 == 0) {
			cudaMemcpy(&hcounter, counter, sizeof(int), cudaMemcpyDeviceToHost);
		}
		++hcounter;
		cudaMemcpy(counter, &hcounter, sizeof(int), cudaMemcpyHostToDevice);
	} while (hcounter < 10);
	return 0;
}
