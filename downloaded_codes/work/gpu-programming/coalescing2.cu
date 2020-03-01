#include <stdio.h>
#include <cuda.h>
#include "mytime.h"

#define N 1024
__global__ void dkernel(unsigned *a, unsigned wpt, unsigned chunksize) {
	for (unsigned ii = 0; ii < wpt; ii += chunksize) {
		unsigned start = wpt * blockDim.x * threadIdx.x;
		for (unsigned nn = start; nn < start + chunksize; ++nn) {
			a[nn]++;
		}
	}
}
int main() {
	unsigned *a;
	double start, end;
	int i;

	cudaMalloc(&a, sizeof(unsigned) * N);

	for (i = 1; i < 33; ++i) {
		start = rtclock();
		dkernel<<<1, 32>>>(a, N / 32, i);
		cudaDeviceSynchronize();
		end = rtclock();
		printf("%3d: ", i);
		printtime("", start, end);
	}
    return 0;
}
