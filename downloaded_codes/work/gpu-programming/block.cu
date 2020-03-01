#include <stdio.h>
#include <cuda.h>
#include <sys/time.h>
#define K 32
#define N 32
__global__ void fun(int *a) {
	int i;
	unsigned nthreads = blockDim.x * gridDim.x;
	unsigned id = blockIdx.x * blockDim.x + threadIdx.x;
	unsigned start = N / nthreads * id;
	for (i = 0; i < N/K; ++i)
		a[start + i] = threadIdx.x * threadIdx.x;
}
double rtclock() {
  struct timezone Tzp;
  struct timeval Tp;
  int stat;
  stat = gettimeofday(&Tp, &Tzp);
  if (stat != 0) printf("Error return from gettimeofday: %d", stat);
  return(Tp.tv_sec + Tp.tv_usec * 1.0e-6);
}

void printtime(const char *str, double starttime, double endtime) {
	printf("%s%3f seconds\n", str, endtime - starttime);
}
int main() {
	int a[N], *da;
	int i;

	cudaMalloc(&da, N * sizeof(int));
	double start = rtclock();
	for (i = 0; i < 1000; ++i) {
		fun<<<K, N>>>(da);
		cudaDeviceSynchronize();
	}
	double end = rtclock();
	printtime("Single block: ", start, end);
	cudaMemcpy(a, da, N * sizeof(int), cudaMemcpyDeviceToHost);
	//for (i = 0; i < N; ++i)
	//	printf("%d\n", a[i]);
	return 0;
}
