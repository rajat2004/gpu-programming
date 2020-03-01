#include <stdio.h>
#include <cuda.h>
__device__ volatile int counter = 0;
//Launching kernel with <<< (4,4) , (7,7) >>> gridDim.x =4 gridDim.y =4
__global__ void stencil(int* d_input, int M, int N)
{
// TODO: Your implementation goes here
        int tot_blocks = gridDim.x*gridDim.y; // =16
        int thidx = blockDim.x*blockIdx.x + threadIdx.x;
        int thidy = blockDim.y*blockIdx.y + threadIdx.y;
        int write_this;
        if (thidx>0 && thidy >0 && thidx <N-1 && thidy < M-1)
                write_this = 0.2*(d_input[thidy*N+thidx] + d_input[(thidy+1)*N+thidx] + d_input[(thidy-1)*N+thidx] + d_input[thidy*N+thidx+1] + d_input[thidy*N+thidx-
1]);
        __syncthreads();
        if(threadIdx.x==0 && threadIdx.y==0)
                atomicAdd((int *)&counter,1);
        while(counter<tot_blocks); // Waits here for infinite time.
        if (thidx>0 && thidy >0 && thidx <N-1 && thidy < M-1)
                d_input[thidy*N+thidx] = write_this;
}

int main() {
	int *arr;
	const int M = 16, N = 16;

	cudaMalloc(&arr, M * N * sizeof(int));
	stencil<<<M, N>>>(arr, M, N);
	cudaDeviceSynchronize();
}
