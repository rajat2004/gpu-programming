#include <cuda.h>
#include <stdio.h>

__global__ void printk(int *counter) {
	*counter <<= 1;
	printf("\t%d\n", *counter);
}
int main() {
	int hcounter = 1, *counter;

	cudaMalloc(&counter, sizeof(int));
	do {
		printf("%d\n", hcounter);
		cudaMemcpy(counter, &hcounter, sizeof(int), cudaMemcpyHostToDevice);
		printk <<<1, 1>>>(counter);
		cudaMemcpy(&hcounter, counter, sizeof(int), cudaMemcpyDeviceToHost);
		hcounter <<= 1;
	} while (hcounter <= 100);
	return 0;
}
