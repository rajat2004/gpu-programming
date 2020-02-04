#ifndef _KERNELS_H_
#define _KERNELS_H_

__global__ void per_row_kernel(int *in, int N) {
    long long unsigned row = blockIdx.x * blockDim.x*blockDim.y + threadIdx.y * blockDim.x + threadIdx.x;

    // printf("%d\n", row);
    if (row < N) {
        for(long long unsigned i=0; i<row; i++) {
            in[i*N + row] = in[row*N + i];
            in[row*N + i] = 0;
        }
    }

}

__global__ void per_element_kernel(int *in, int N) {
    
}

__global__ void per_element_kernel_2D(int *in, int N);

#endif

