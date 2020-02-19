#include<stdio.h>
#include<limits.h>
#include<stdlib.h>
#include"cuda.h"

#ifndef min
    #define min(a,b) ((a)<(b) ? (a):(b))
#endif

void print_matrix(int* mat, int rows, int cols) {
    for(int i=0; i<rows; i++) {
        for(int j=0; j<cols; j++) {
            printf("%d ", mat[i*cols + j]);
        }
        printf("\n");
    }
}

void cpu_func(int* mat, int* res, int n, int m, int k=1) {
    int min_el = INT_MAX;
    int last_row = n*(m+1);
    for(int i=0; i<n; i++) {
        int row = i*(m+1);
        for(int j=0; j<m; j++) {
            res[row + m] += mat[row+j];
            res[last_row + j] += mat[row+j];
        }
        min_el = min(min_el, res[row+m]);
    }
}

int main() {
    int n,m,k;
    scanf("%d %d %d", &n, &m, &k);
    int *mat, *res;
    mat = (int*)calloc((n+1)*(m+1), sizeof(int));
    res = (int*)calloc((n+1)*(m+1), sizeof(int));

    for(int i=0; i<n; i++) {
        int row = i*(m+1);
        for(int j=0; j<m; j++) {
            scanf("%d", &mat[row+j]);
            // res[]
        }
    }

    memcpy(res, mat, (n+1)*(m+1)*sizeof(int));
    cpu_func(mat, res, n, m);

    printf("\n");
    print_matrix(res,n+1,m+1);
    return 0;
}
