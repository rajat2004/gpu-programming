#include<stdio.h>
#include<cuda.h>
#include "kernels.h"

__global__ void per_row_kernel(int *in, int N) {
    int row = threadIdx.x;
    // printf("%d\n", row);
    for(int i=0; i<row; i++) {
        int temp = in[row*N + i];
        in[row*N + i] = in[i*N + row];
        in[i*N + row] = temp;
    }
}
