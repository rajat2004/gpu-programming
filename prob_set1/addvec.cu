#include <stdio.h>
#include <cuda.h>
#include <sys/time.h>
#include <stdlib.h>

#define BLOCKSIZE	1024

__global__ void addvec(int *a, int *b, int *c, int n) {
	int id = blockIdx.x * blockDim.x + threadIdx.x;
	if (id < n)
		c[id] = a[id] + b[id];
}
void init(int *a, int *b, int n) {
	srand(time(NULL));
	for (int ii = 0; ii < n; ++ii) {
		a[ii] = rand() % 100;
		b[ii] = rand() % 100;
	}
}
int main() {
	int *a, *b, *c;
	int *da, *db, *dc;

	int n = 10000;
	dim3 block(BLOCKSIZE, 1, 1);
	dim3 grid(ceil((float)n/BLOCKSIZE), 1, 1);
	printf("number of blocks = %d\n", ceil((float)n/BLOCKSIZE));

	a = (int *)malloc(n*sizeof(int));
	b = (int *)malloc(n*sizeof(int));
	c = (int *)malloc(n*sizeof(int));

	cudaMalloc(&da, n*sizeof(int));
	cudaMalloc(&db, n*sizeof(int));
	cudaMalloc(&dc, n*sizeof(int));

	init(a, b, n);

	cudaMemcpy(da, a, n*sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(db, b, n*sizeof(int), cudaMemcpyHostToDevice);

	addvec<<<grid, block>>>(da, db, dc, n);
	cudaDeviceSynchronize();

	cudaMemcpy(c, dc, n*sizeof(int), cudaMemcpyDeviceToHost);

	for (int ii = 0; ii < n; ++ii) {
		printf("%d ", c[ii]);
	}
	printf("\n");
	return 0;
}
