#include <cuda.h>
#include <stdio.h>
#include "mytime.h"

#define N 4096
// This program works for ODD value of N as well

void fill_values(int *array, int n) {
	time_t t;
	srand((unsigned) time(&t));
	
    for(int j=0; j<n; j++) {
		//array[j]=j;
		if(j % 2 == 0)  
			array[j] = rand() % 200;  
		else{	
			//array[j] = j - j * rand() % (rand() * 200);  
			array[j] = rand() % 100 + rand() % 100;  	
		}
	}
	
}

void printValues(int *a , int n){

	int sum=0;
	for(int i=0;i <n; i++){
		//printf("%4d", a[i]);
		sum += a[i];
	}
	//printf("\n");
	//printf("SUM: %d\n", sum);
}


__global__ void dk(int *a, int n, int iteration){
	unsigned id = threadIdx.x + blockIdx.x * blockDim.x;
	if(id < n){
		unsigned index = id * (1 << (iteration+1));
		//unsigned index = id * (int)pow(2.0, iteration+1);
		unsigned shift_index = (1 << iteration);
		//unsigned shift_index = (int)pow(2.0, iteration);
		//if( n % 2 == 1 && id == n-1 ){
		//	a[index] = a[index] + a[ index + shift_index ] +a[index + 2 * shift_index ];
			//printf("a[%d] = a[%d] + a[%d] + a[%d] = %d \n",index,index, index + shift_index ,index + 2 * shift_index , a[index]);
		//}
		//else{
			a[index] = a[index] + a[ index + shift_index];
			//printf("a[%d] = a[%d] + a[%d] = %d\n",index, index, index + shift_index , a[index]);
		//}
	}
	//__syncthreads();

}
int main(int argc, char** argv){
	double start, end;
	
	unsigned bytes = sizeof(int) * N;
	//~ unsigned sumbytes = sizeof(int) ;
	
	int *a 	= (int *) malloc (bytes);
	//~ int *sum= (int *) malloc (sumbytes);
	fill_values(a,N); // fills random values
	
	//CPUTimer cputimer;
    //cputimer.Start();
	start = rtclock();
  
	printValues(a,N); // prints and finds cpu sum as well.
	
	//cputimer.Stop();
	end = rtclock();
	printtime("Sequential time: ", start, end);
	//printf("The sequential code ran in %f ms\n", cputimer.Elapsed()*1000);
	
	int  *da;
	//~ int *dsum; // removing it as a[0] stores the final result
	cudaMalloc(&da, bytes);
	//~ cudaMalloc(&dsum, sumbytes);
	
	cudaMemset(da, 0,bytes);
	//~ cudaMemset(dsum, 0,sumbytes);
	
	cudaMemcpy(da,a,bytes, cudaMemcpyHostToDevice);
	
	unsigned numThreads = 1024;
	//GPUTimer gputimer;
    //gputimer.Start();
  	start = rtclock();
	for(int i = N/2, j=0; i > 0; j++,i=i/2)	 {
		dk<<< (ceil((float)i/numThreads)) , numThreads>>>(da, i, j);
		//cudaDeviceSynchronize();
	}
		
	//dk<<< 1, i>>>(da, i, j);
	//~ dk<<< 1, N/2>>>(da, N, dsum, 0);
	//~ dk<<< 1, N/4>>>(da, N, dsum, 1);
	//~ dk<<< 1, N/8>>>(da, N, dsum, 2);
	//~ printValues(a,N);
	
	//gputimer.Stop();
	end = rtclock();
	//printf("The Parallel code ran in %f ms\n", gputimer.Elapsed()*1000);
	printtime("Parallel time: ", start, end);
	
	
	//~ cudaMemcpy(sum,dsum,sumbytes, cudaMemcpyDeviceToHost);
	cudaMemcpy(a,da, bytes, cudaMemcpyDeviceToHost);
	printf("Gpu sum %d\n", a[0]);

	cudaFree(da);
	//~ cudaFree(dsum);
	return 0;
}
