#include <cuda.h>
#include <stdio.h>

__global__ void printk(int *counter) {
	++*counter;
	printf("\t%d\n", *counter);
}
int main() {
	int hcounter = 0, *counter;

	cudaMalloc(&counter, sizeof(int));
	do {
		printf("%d\n", hcounter);
		cudaMemcpy(counter, &hcounter, sizeof(int), cudaMemcpyHostToDevice);
		printk <<<1, 1>>>(counter);
		cudaMemcpy(&hcounter, counter, sizeof(int), cudaMemcpyDeviceToHost);
	} while (++hcounter < 10);
	return 0;
}
