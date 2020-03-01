#include <stdio.h>
#include <cuda.h>

#define N	10

__host__ __device__ void fun(int *arr) {
	for (unsigned ii = 0; ii < N; ++ii)
		++arr[ii];
}
__global__ void dfun(int *arr) {
	fun(arr);
}
__host__ __device__ void print(int *arr) {
	for (unsigned ii = 0; ii < N; ++ii)
		printf("%d, ", arr[ii]);

	printf("\n");
}
__global__ void dprint(int *arr) {
	print(arr);
}
int main() {
	int arr[N], *darr;

	cudaMalloc(&darr, N * sizeof(int));

	for (unsigned ii = 0; ii < N; ++ii)
		arr[ii] = ii;
	cudaMemcpy(darr, arr, N * sizeof(int), cudaMemcpyHostToDevice);

	fun(arr);
	dfun<<<1, 1>>>(darr);
	cudaDeviceSynchronize();

	print(arr);
	dprint<<<1, 1>>>(darr);
	cudaDeviceSynchronize();

	return 0;
}
