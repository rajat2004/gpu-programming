#include <cuda.h>
#include <stdio.h>

__global__ void K(int *x) {
	*x = 0;
	printf("%d\n", *x);
}
int main() {
	int *x = NULL;
	K<<<2, 10>>>(x);
	cudaDeviceSynchronize();

	return 0;
}
