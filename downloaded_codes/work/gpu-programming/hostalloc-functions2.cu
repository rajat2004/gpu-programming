#include <cuda.h>
#include <stdio.h>

__device__ int counter;
__host__ __device__ void fun() {
	++counter;
}
__global__ void printk() {
	fun();
	printf("printk (after fun): %d\n", counter);
}
int main() {

	//counter = 0;
	//printf("main: %d\n", counter);

	printk <<<1, 1>>>();
	cudaDeviceSynchronize();

	//fun();
	//printf("main (after fun): %d\n", counter);

	return 0;
}
