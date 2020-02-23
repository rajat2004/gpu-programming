#include<stdio.h>
#include<limits.h>
#include<stdlib.h>
#include"cuda.h"

#ifndef min
    #define min(a,b) ((a)<(b) ? (a):(b))
#endif

void print_matrix(int* mat, int rows, int cols) {
    for(int i=0; i<rows; i++) {
        for(int j=0; j<cols; j++) {
            printf("%d ", mat[i*cols + j]);
        }
        printf("\n");
    }
}

// void find_min_and_print_matrix(int* mat, int rows, int cols) {
//     int min_el = INT_MAX;
//     for(int i=0; i<rows; i++) {
//         for(int j=0; j<cols; j++) {
//             printf("%d ", mat[i*cols + j]);
//         }
//         printf("\n");
//     }
// }

void cpu_func(int* mat, int* res, int n, int m, int k=1) {
    int min_el = INT_MAX;
    int last_row = n*(m+1);
    for(int i=0; i<n; i++) {
        int row = i*(m+1);
        for(int j=0; j<m; j++) {
            res[row + m] += mat[row+j];
            res[last_row + j] += mat[row+j];
        }
        min_el = min(min_el, res[row+m]);
    }
    for(int j=0; j<m; j++) {
        min_el = min(min_el, res[last_row+j]);
    }
    res[last_row+m] = min_el;
}


__global__ void sumRandC(int* mat, int n, int m, int k) {
    int threadId1 = blockIdx.x * blockDim.x + threadIdx.x;
    int threadId = threadId1*k;

    // printf("%d\n", threadId);

    int orig_row = threadId / m;
    int orig_col = threadId % m;

    int last_row = n*(m+1);
    int row=orig_row, col=orig_col;

    if (orig_row < n) {
        for(int i=0; i<k; i++) {
            int oc_plus_i = orig_col+i;
            
            col = oc_plus_i%m;
            row = orig_row + (oc_plus_i/m);
            // if (oc_plus_i>=m) {
            //     row = orig_row + (oc_plus_i/m);
            //     // col = oc_plus_i%m;
            // } 
            // else {
            //     col = oc_plus_i;
            // }

            printf("%d %d\n", row, col);

            int val = mat[row*(m+1)+col];
            atomicAdd(&mat[row*(m+1) + m], val);
            atomicAdd(&mat[last_row + col], val);
        }
    }
}

int main() {
    int n,m,k;
    scanf("%d %d %d", &n, &m, &k);
    int *mat, *res, *dmat;
    mat = (int*)calloc((n+1)*(m+1), sizeof(int));
    res = (int*)calloc((n+1)*(m+1), sizeof(int));
    cudaMalloc(&dmat, (n+1)*(m+1)*sizeof(int));

    for(int i=0; i<n; i++) {
        int row = i*(m+1);
        for(int j=0; j<m; j++) {
            scanf("%d", &mat[row+j]);
        }
    }

    // Initialize matrix
    // for(int i=0; i<n; i++) {
    //     for(int j=0; j<m; j++) {
    //         mat[i*(m+1) + j] = rand()%9 + 1;
    //     }
    // }

    // memcpy(res, mat, (n+1)*(m+1)*sizeof(int));
    // cpu_func(mat, res, n, m);
    cudaMemcpy(dmat, mat, (n+1)*(m+1)*sizeof(int), cudaMemcpyHostToDevice);
    int gridDim = ceil((float)(n*m) / (1024*k) );
    printf("%d\n", gridDim);
    sumRandC<<<gridDim,1024>>>(dmat, n, m, k);

    cudaMemcpy(res, dmat, (n+1)*(m+1)*sizeof(int), cudaMemcpyDeviceToHost);

    printf("\n");
    print_matrix(res,n+1,m+1);
    return 0;
}
