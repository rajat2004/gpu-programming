#include <stdio.h>
#include <cuda.h>
#define N 10
__global__ void f() {
	printf("%d\n", threadIdx.x);
}
int main() {
	f<<<1, N>>>();
	cudaThreadSynchronize();
	return 0;
}
