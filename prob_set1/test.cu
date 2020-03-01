#include<stdio.h>
#include<cuda.h>
#include<sys/time.h>
#include<stdlib.h>

void print_arr(int* arr, int size) {
    for(int i=0; i<size; i++)
        printf("%d ", arr[i]);
    printf("\n");
}

void init(int *arr, int n) {
    srand(time(NULL));
    for(int i=0; i<n; i++)
        arr[i]=rand()%10;
}

__global__ void add_vec(int *a, int *b, int *c, int n1) {
    int tid = blockIdx.x*blockDim.x + threadIdx.x;
    if(tid<n1)
        c[tid] = a[tid] + b[tid];
}

__global__ void kernel() {
    printf("%d\n", threadIdx.x);
}

int main() {
    int *vec1, *vec2, *res, *dvec1, *dvec2, *dvec3;
    int N;
    // scanf("%d", &N);

    // Vectors of same size
    // cudaMalloc(&dvec1, N*sizeof(int));
    // cudaMalloc(&dvec2, N*sizeof(int));
    // cudaMalloc(&dvec3, N*sizeof(int));

    // vec1 = (int*)malloc(N*sizeof(int));
    // vec2 = (int*)malloc(N*sizeof(int));
    // res = (int*)malloc(N*sizeof(int));

    kernel<<<1, 1025>>>();
    cudaDeviceSynchronize();

    // check for error
    cudaError_t error = cudaGetLastError();
    if(error != cudaSuccess)
    {
      // print the CUDA error message and exit
      printf("CUDA error: %s\n", cudaGetErrorString(error));
      exit(-1);
    }
    return 0;
}
