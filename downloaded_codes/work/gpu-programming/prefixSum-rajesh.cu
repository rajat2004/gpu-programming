#include <stdio.h>
#include <cuda.h>
#define N 1024
__global__
void prefixSum(int *x, int n){
	volatile unsigned id = threadIdx.x + threadIdx.y * blockDim.x;
	if(id < n) { // incase of more blocks
		for( int i=1 ; i < n ; i*=2 ) {
			if(id >= i) {
				if (id > 1000) {++i; id--; --i; ++id;}
				x[id] += x[id - i];
			}
		__syncthreads();	
		}
	}
}

__global__
void prefixSumFinal(int *x, int n){
	unsigned id = threadIdx.x + threadIdx.y * blockDim.x;
	if(id < n)  // incase of more blocks
		for( int i=1 ; i < n ; i*=2 ) {
			int tmp;
			if(id >= i) {
				++i;
				--i;
				tmp = x[id-i];

			}
				
			__syncthreads();	// 1
			
			if(id >= i) {
				x[id] +=tmp; ;
				
			}
			//__syncthreads();	//2
		}
}


int main(){
	int *ha, *gpu_ans, *cpu_ans;
	
	int bytesA = N*sizeof(int);
	
	ha		 = (int*)malloc(bytesA);
	gpu_ans	 = (int*)malloc(bytesA);
	cpu_ans	 = (int*)malloc(bytesA);
	
	int *ga;
	
	for(int i=0;  i< N; i++){
		ha[i]= 1;
		cpu_ans[i] = 0;
	}
	
	cpu_ans[0] = ha[0];
	
	for(int i=1;  i< N; i++)
		cpu_ans[i] = cpu_ans[i-1] + ha[i];


	cudaMalloc(&ga, bytesA);
	cudaMemcpy(ga,ha, bytesA, cudaMemcpyHostToDevice);
	
	int numThreads= 1024;
	//****************************************************************
	prefixSum<<< (N+numThreads-1)/numThreads ,numThreads >>>( ga,N);
	//prefixSumFinal<<< (N+numThreads-1)/numThreads ,numThreads >>>( ga,N);
	
	//***************************************************************
	cudaMemcpy(gpu_ans,ga, bytesA, cudaMemcpyDeviceToHost);
	
	
	//~ printf("    GPU    CPU \n");
	//~ for(int i=0;  i< N; i++)
		//~ printf("%6d %6d \n" , gpu_ans[i], cpu_ans[i]);
		
	for(int i=0;  i< N; i++) {
		if(cpu_ans[i] != gpu_ans[i]){
			printf("UN");
			break;
		}
	}	
	printf("MATCHED\n");	
	
	cudaFree(ga); free(ha); free(gpu_ans);
	return 0;
}
