#include <stdio.h>
#include "mytime.h"

#define M	1024
#define N	1024
#define P	1024
#define BLOCKSIZE	16

int A[M][N], B[N][P], C[M][P];
int main() {
	int ii, jj, kk, i, j, k;
	double start, end;

	srand(time(NULL));
	for (ii = 0; ii < M; ++ii) {
		for (jj = 0; jj < N; ++jj) {
			A[ii][jj] = rand() % 100;
		}
		for (kk = 0; kk < P; ++kk) {
			A[ii][kk] = 0;
		}
	}
	for (jj = 0; jj < N; ++jj) {
		for (kk = 0; kk < P; ++kk) {
			B[jj][kk] = rand() % 100;
		}
	}
	start = rtclock();
	for (ii = 0; ii < M; ++ii)
		for (jj = 0; jj < N; ++jj)
			for (kk = 0; kk < P; ++kk)
				C[ii][jj] += A[ii][kk] * B[kk][jj];
	end = rtclock();
	printtime("ijk: ", start, end);

	start = rtclock();
	for (ii = 0; ii < M; ++ii)
		for (kk = 0; kk < P; ++kk)
			for (jj = 0; jj < N; ++jj)
				C[ii][jj] += A[ii][kk] * B[kk][jj];
	end = rtclock();
	printtime("ikj: ", start, end);

	start = rtclock();
	for (ii = 0; ii < M; ii += BLOCKSIZE)
	for (kk = 0; kk < P; kk += BLOCKSIZE)
	for (jj = 0; jj < N; jj += BLOCKSIZE)
		for (i = ii; i < ii + BLOCKSIZE; ++i)
		for (k = kk; k < kk + BLOCKSIZE; ++k)
		for (j = jj; j < jj + BLOCKSIZE; ++j)
			C[i][j] += A[i][k] * B[k][j];
	end = rtclock();
	printtime("tiledikj: ", start, end);

}
