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

int cpu_func(int* mat, int* res, int n, int m, int k=1) {
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
    // res[last_row+m] = min_el;
    return min_el;
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

            // printf("%d %d\n", row, col);

            int val = mat[row*(m+1)+col];
            atomicAdd(&mat[row*(m+1) + m], val);
            atomicAdd(&mat[last_row + col], val);
        }
    }
}

// Min value to be added to each element
__device__ int min_el = INT_MAX;

__global__ void findMin(int* mat, int n, int m) {
    int tid = blockIdx.x*blockDim.x + threadIdx.x;
    int val = INT_MAX;

    if(tid < n) {
        // Check in last col of each row
        val = mat[tid*(m+1)+m];
    }
    else if (tid < n+m) {
        // Check in last row
        val = mat[n*(m+1) + (tid-n)];
    }
    else
        return;

    if (min_el > val)
        atomicMin(&min_el, val);

}

__global__ void updateMin(int* mat, int rows, int cols, int k) {
    int tid = blockIdx.x*blockDim.x + threadIdx.x;
    int index = tid*k;

    if (index < rows*cols) {
        for(int i=0; i<k; i++) {
            mat[index+i]+=min_el;
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
    // cudaMalloc(&min_el, sizeof(int));

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
    // printf("%d\n", gridDim);
    sumRandC<<<gridDim, 1024>>>(dmat, n, m, k);

    cudaDeviceSynchronize();

    gridDim = ceil((float)(n+m)/1024);
    findMin<<<gridDim, 1024>>>(dmat, n, m);

    cudaDeviceSynchronize();

    gridDim = ceil((float)((n+1)*(m+1)) / (1024*k) );
    updateMin<<<gridDim, 1024>>>(dmat, n+1, m+1, k);

    cudaMemcpy(res, dmat, (n+1)*(m+1)*sizeof(int), cudaMemcpyDeviceToHost);

    // printf("\n");
    print_matrix(res,n+1,m+1);
    return 0;
}
