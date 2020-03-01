#include <stdio.h>
#include <omp.h>
#include <cuda.h>

#define N 12

int sum = 0;
int main() {
	int *a = (int *)malloc(sizeof(int) * N);

	#pragma omp parallel for reduction(+:sum)
	for (int ii = 0; ii < N; ++ii) {
		a[ii] = ii + 1;
		sum += a[ii];
	}

	printf("sum = %d\n", sum);
	return 0;
}
