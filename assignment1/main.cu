#include<stdio.h>
#include<cuda.h>
// #include"kernels.h"
#include<stdlib.h>
#include"CS17B042.cu"

#define N 1000

void print_matrix(int* mat, int n) {
    for(int i=0; i<n; i++) {
        for(int j=0; j<n; j++) {
            printf("%d ", mat[i*n + j]);
        }
        printf("\n");
    }
}

int main() {
    int *hmatrix, *matrix;
    cudaMalloc(&matrix, N*N*sizeof(int));
    hmatrix = (int *)malloc(N * N * sizeof(int));

    // Initialize lower triangular matrix
    for(int i=0; i<N; i++) {
        for(int j=0; j<N; j++) {
            if (i>=j)
                hmatrix[i*N + j] = rand()%9 + 1;
            else
                hmatrix[i*N + j] = 0;
        }
    }
    printf("Original matrix:\n");
    print_matrix(hmatrix, N);

    cudaMemcpy(matrix, hmatrix, N*N*sizeof(int), cudaMemcpyHostToDevice);
    per_row_kernel<<<1,N>>>(matrix, N);
    cudaMemcpy(hmatrix, matrix, N*N*sizeof(int), cudaMemcpyDeviceToHost);

    printf("\n\nTransformed matrix:\n");

    print_matrix(hmatrix, N);
    return 0;
}