#include <stdio.h>
#include <cuda.h>
#include <string.h>

__global__ void mystrrev(char *str, unsigned lenstr) {
	//if (threadIdx.x < lenstr / 2) {
		char c = str[threadIdx.x];
		str[threadIdx.x] = str[lenstr - threadIdx.x - 1];
		str[lenstr - threadIdx.x - 1] = c;
		printf("%d %c\n", threadIdx.x, c);
	//}
}

int main() {
	char hoststr[100] = "Hello World!";
	char *str;

	unsigned len = strlen(hoststr);
	cudaMalloc(&str, sizeof(char) * (len + 1));
	cudaMemcpy(str, hoststr, sizeof(char) * (len + 1), cudaMemcpyHostToDevice);
	puts(hoststr);
	mystrrev<<<1, len>>>(str, len);
	cudaMemcpy(hoststr, str, sizeof(char) * (len + 1), cudaMemcpyDeviceToHost);
	puts(hoststr);
	return 0;
}
