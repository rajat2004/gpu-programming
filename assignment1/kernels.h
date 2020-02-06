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
    long long unsigned blockId = blockIdx.x + (blockIdx.y * gridDim.x) + (blockIdx.z * gridDim.x * gridDim.y);
    long long unsigned threadId = blockId * blockDim.x + threadIdx.x;

    // printf("ThreadId: %llu\n", threadId);

    int row = threadId / N;
    int col = threadId % N;

    // printf("Row: %d, Col: %d\n", row, col);

    if (row < N && col < N && row < col) {
        // printf("Row: %d, Col: %d\n", row, col);
        int temp = in[row * N + col];
        in[row*N + col] = in[col*N + row];
        in[col*N + row] = temp;
    }
}

__global__ void per_element_kernel_2D(int *in, int N) {
    long long unsigned blockId = blockIdx.x + (blockIdx.y * gridDim.x);
    long long unsigned threadId = (blockId * blockDim.x * blockDim.y) + (threadIdx.y * blockDim.x) + threadIdx.x;

    int row = threadId / N;
    int col = threadId % N;

    // printf("Row: %d, Col: %d\n", row, col);

    if (row < N && col < N && row < col) {
        // printf("Row: %d, Col: %d\n", row, col);
        int temp = in[row * N + col];
        in[row*N + col] = in[col*N + row];
        in[col*N + row] = temp;
    }
}

#endif

