#include<stdio.h>
#include<cuda.h>

#define BLOCKSIZE 1024

__global__ void initialize(unsigned* matrix, unsigned N) {
    unsigned id = threadIdx.x * blockDim.y + threadIdx.y;
    matrix[id] = id;
}

__global__ void square_v1(unsigned* matrix, unsigned* result, unsigned N) {
    
}

int main(int nn, char *str[]) {
    unsigned N = atoi(str[1]);
    unsigned *hmatrix, *matrix;

    dim3 block(N, N, 1);

    cudaMalloc(&matrix, N*N*sizeof(unsigned));
    hmatrix = (unsigned*)malloc(N*N*sizeof(unsigned));

    // unsigned nblocks = ceil((float)N/BLOCKSIZE);
    // printf("nblocks = %d\n", nblocks);

    initialize<<<1, block>>>(matrix, N);
    cudaMemcpy(hmatrix, matrix, N*N*sizeof(unsigned), cudaMemcpyDeviceToHost);

    for(int i=0; i<N; i++) {
        for(int j=0; j<N; j++) {
            printf("%4d ", hmatrix[i*N + j]);
        }
        printf("\n");
    }
    return 0;
}
