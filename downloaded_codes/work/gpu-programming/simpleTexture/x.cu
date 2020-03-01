#include <cuda.h>
#include <stdio.h>

texture<float, 2, cudaReadModeElementType> tex;

__global__ void transformKernel(float *output, int width, int height, float theta) {
	unsigned x = blockIdx.x * blockDim.x + threadIdx.x;
	unsigned y = blockIdx.y * blockDim.y + threadIdx.y;

	float u = (float)x - (float)width / 2;
	float v = (float)y - (float)height / 2;
	float tu = (u * cosf(theta) - v * sinf(theta)) / width;
	float tv = (v * cosf(theta) + u * sinf(theta)) / height;

	output[y * width + x] = tex2D(tex, tu + 0.5, tv + 0.5);
}
int main() {
	int width = 5, height = 5;
	unsigned size = width * height * sizeof(float);
	float *hData = (float *)malloc(size);
	for (unsigned ii = 0; ii < width; ++ii)
		for (unsigned jj = 0; jj < height; ++jj)
			hData[ii * height + jj] = ii + jj;
    	cudaChannelFormatDesc channelDesc = cudaCreateChannelDesc(32, 0, 0, 0, cudaChannelFormatKindFloat);
	cudaArray *cuArray;
	cudaMallocArray(&cuArray, &channelDesc, width, height);
	cudaMemcpyToArray(cuArray, 0, 0, hData, size, cudaMemcpyHostToDevice);

	tex.addressMode[0] = cudaAddressModeWrap;
	tex.addressMode[1] = cudaAddressModeWrap;
	tex.filterMode     = cudaFilterModeLinear;
	tex.normalized     = true;
	cudaBindTextureToArray(tex, cuArray, channelDesc);

	float *dData;
	cudaMalloc(&dData, size);
	dim3 block(8, 8, 1);
	dim3 grid(width / block.x, height / block.y, 1);;
	transformKernel<<<grid, block>>>(dData, width, height, 0.6);
	return 0;
}
