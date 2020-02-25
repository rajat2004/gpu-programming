#include<stdio.h>
#include<cuda.h>

__global__ void find_unique_id(int* arr) {
    int bid = (blockIdx.z * gridDim.y * gridDim.x) + (blockIdx.y * gridDim.x) + blockIdx.x;
    int tid = (bid * blockDim.x * blockDim.y * blockDim.z) + (threadIdx.z * blockDim.y * blockDim.x) + (threadIdx.y * blockDim.x) + threadIdx.x;

    arr[tid] = tid;
}

int main() {
    dim3 grid(1,2,3);
    dim3 block(4,5,6);
    int threads = 1*2*3*4*5*6;

    int *arr, *darr;
    arr = (int*)malloc(threads*sizeof(int));
    cudaMalloc(&darr, threads*sizeof(int));

    find_unique_id<<<grid, block>>>(darr);
    cudaDeviceSynchronize();
    cudaMemcpy(arr, darr, threads*sizeof(int), cudaMemcpyDeviceToHost);

    for(int i=0; i<threads; i++) 
        printf("%d\n", arr[i]);
    printf("\n");
    return 0;
}
