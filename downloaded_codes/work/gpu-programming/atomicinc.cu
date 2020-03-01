#include <stdio.h>
#include <cuda.h>
#define SIZE 64

#define cudaCheckError() {                                          \
 cudaError_t e=cudaGetLastError();                                 \
 if(e!=cudaSuccess) {                                              \
   printf("Cuda failure %s:%d: '%s'\n",__FILE__,__LINE__,cudaGetErrorString(e)); \
   exit(0); \
 }                                                                 \
}

__global__ void kernel(unsigned int * x){
  atomicInc(&x[0],100);
  __syncthreads();
  printf("hi I'm tid %u - %u\n", threadIdx.x, x[0]);
  
}
int main(){
  //! unsigned int* x;
  //! x = (unsigned int*) malloc(sizeof(unsigned int) * SIZE);
  //! *x=0;
  
  unsigned int* dx;
  cudaMalloc( (void**) &dx, SIZE*sizeof(unsigned int));  cudaCheckError();
  
  //! cudaMemcpy(dx ,x , sizeof(unsigned int)* SIZE , cudaMemcpyHostToDevice); // did not make a difference
  
  kernel<<< 1, SIZE >>>(dx);   
  cudaDeviceSynchronize();  cudaCheckError();
  return 0;
}
