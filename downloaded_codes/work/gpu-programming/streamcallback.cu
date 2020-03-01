#include <stdio.h>
#include <cuda.h>


__global__ void MyKernel() {
	printf("in mykernel\n");
}
void MyCallback(cudaStream_t stream, cudaError_t status, void *data){
    printf("Inside callback %d\n", (long)data);
	MyKernel<<<1, 1>>>();
	cudaDeviceSynchronize();
	cudaError_t err = cudaGetLastError();
	printf("error=%d, %s, %s\n", err, cudaGetErrorName(err), cudaGetErrorString(err));
}
int main() {
cudaStream_t stream[2];
for (long i = 0; i < 2; ++i) {
	cudaStreamCreate(&stream[i]);
    //cudaMemcpyAsync(devPtrIn[i], hostPtr[i], size, cudaMemcpyHostToDevice, stream[i]);
    MyKernel<<<1, 1, 0, stream[i]>>>();
    //cudaMemcpyAsync(hostPtr[i], devPtrOut[i], size, cudaMemcpyDeviceToHost, stream[i]);
    cudaStreamAddCallback(stream[i], MyCallback, (void*)i, 0);
    MyKernel<<<1, 1, 0, stream[i]>>>();
	cudaDeviceSynchronize();
}
}
