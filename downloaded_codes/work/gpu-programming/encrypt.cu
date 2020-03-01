#include <stdio.h>
#include <cuda.h>
#include <sys/time.h>
#include <stdlib.h>

#define BLOCKSIZE	1024

__device__ char dec(char c) {
	return (c - 1);
}
__device__ char enc(char c) {
	return (c + 1);
}
__global__ void decrypt(char *src, char *target, int n) {
	int id = blockIdx.x * blockDim.x + threadIdx.x;
	if (id < n)
		target[id] = dec(src[id]);
	else if (id == n)
		target[id] = '\0';
}
__global__ void encrypt(char *src, char *target, int n) {
	int id = blockIdx.x * blockDim.x + threadIdx.x;
	if (id < n)
		target[id] = enc(src[id]);
	else if (id == n)
		target[id] = '\0';
}
void init(char *s, int *n) {
	strcpy(s, "Hello World!");
	*n = strlen(s);
}
int main() {
	char *s, *ds;

	int n;
	s = (char *)malloc(20);
	init(s, &n);

	dim3 block(BLOCKSIZE, 1, 1);
	dim3 grid(ceil((float)n/BLOCKSIZE), 1, 1);
	printf("number of blocks = %d\n", ceil((float)n/BLOCKSIZE));


	cudaMalloc(&ds, (n + 1)*sizeof(char));

	cudaMemcpy(ds, s, (n+1)*sizeof(char), cudaMemcpyHostToDevice);
	encrypt<<<grid, block>>>(ds, ds, n);
	cudaDeviceSynchronize();

	cudaMemcpy(s, ds, (n+1)*sizeof(char), cudaMemcpyDeviceToHost);
	puts(s);

	decrypt<<<grid, block>>>(ds, ds, n);
	cudaDeviceSynchronize();

	cudaMemcpy(s, ds, (n+1)*sizeof(char), cudaMemcpyDeviceToHost);
	puts(s);

	printf("\n");
	return 0;
}
