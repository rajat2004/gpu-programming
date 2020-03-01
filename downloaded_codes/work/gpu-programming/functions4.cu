#include <stdio.h>
#include <cuda.h>

#define N	10

__host__ __device__ void fun(int *arr, int ii) {
	++arr[ii];
}
__global__ void dfun(int *arr) {
	fun(arr, threadIdx.x);
}
__host__ __device__ void print(int *arr, int ii) {
	printf("%d, ", arr[ii]);
}
__global__ void dprint(int *arr) {
	print(arr, threadIdx.x);
}
int main() {
	int arr[N], *darr;

	cudaMalloc(&darr, N * sizeof(int));

	for (unsigned ii = 0; ii < N; ++ii)
		arr[ii] = ii;
	cudaMemcpy(darr, arr, N * sizeof(int), cudaMemcpyHostToDevice);

	for (unsigned ii = 0; ii < N; ++ii)
		fun(arr, ii);
	dfun<<<1, N>>>(darr);
	cudaDeviceSynchronize();

	for (unsigned ii = 0; ii < N; ++ii)
		print(arr, ii);
	printf("\n");
	dprint<<<1, N>>>(darr);
	cudaDeviceSynchronize();
	printf("\n");

	return 0;
}
