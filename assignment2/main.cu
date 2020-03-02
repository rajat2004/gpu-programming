#include<stdio.h>
#include<limits.h>
#include<stdlib.h>
#include"cuda.h"


void print_matrix(int* mat, int rows, int cols) {
    for(int i=0; i<rows; i++) {
        for(int j=0; j<cols; j++) {
            printf("%d ", mat[i*cols + j]);
        }
        printf("\n");
    }
}


__global__ void sumRandC(int* mat, int n, int m, int k) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    int index = tid*k;

    // printf("%d\n", index);

    int orig_row = index / m;
    int orig_col = index % m;

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

__global__ void findMin(int* mat, int n, int m, int k) {
    int tid = blockIdx.x*blockDim.x + threadIdx.x;
    int orig_index = tid*k;
    int val = INT_MAX;
    int index = orig_index;
    int thread_min = INT_MAX;

    for (int i=0; i<k; i++) {
        index = orig_index + i;

        if (index < n) {
            // Check in last col of each row
            val = mat[index*(m+1) + m];
        }
        else if (index < n+m) {
            // Check in last row
            val = mat[n*(m+1) + (index-n)];
        }
        else
            return;

        if (thread_min > val)
            thread_min = val;
    }
    atomicMin(&min_el, thread_min);
}

__global__ void updateMin(int* mat, int n, int m, int k) {
    int tid = blockIdx.x*blockDim.x + threadIdx.x;
    int index = tid*k;

    int orig_row = index / m;
    int orig_col = index % m;

    int row=orig_row, col=orig_col;

    if (row < n) {
        for(int i=0; i<k; i++) {
            int oc_plus_i = orig_col+i;
            
            col = oc_plus_i%m;
            row = orig_row + (oc_plus_i/m);

            mat[row*(m+1)+col]+=min_el;
        }
    }

    if(tid==0) {
        mat[n*(m+1)+m] = min_el;
    }
}


int main() {
    int n,m,k;
    scanf("%d %d %d", &n, &m, &k);
    int *mat, *dmat;
    mat = (int*)calloc((n+1)*(m+1), sizeof(int));

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


    cudaMemcpy(dmat, mat, (n+1)*(m+1)*sizeof(int), cudaMemcpyHostToDevice);
    int gridDim = ceil((float)(n*m) / (1024*k) );
    sumRandC<<<gridDim, 1024>>>(dmat, n, m, k);

    cudaDeviceSynchronize();

    gridDim = ceil((float)(n+m)/(1024*k));
    findMin<<<gridDim, 1024>>>(dmat, n, m, k);

    cudaDeviceSynchronize();

    gridDim = ceil((float)(n*m) / (1024*k) );
    updateMin<<<gridDim, 1024>>>(dmat, n, m, k);

    cudaMemcpy(mat, dmat, (n+1)*(m+1)*sizeof(int), cudaMemcpyDeviceToHost);

    print_matrix(mat,n+1,m+1);
    return 0;
}
