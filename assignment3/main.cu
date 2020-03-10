#include<stdio.h>
#include<cuda.h>
#include<string.h>
#include<stdlib.h>

void print_matrix(int* mat, int rows, int cols) {
    for(int i=0; i<rows; i++) {
        for(int j=0; j<cols; j++) {
            printf("%d ", mat[i*cols + j]);
        }
        printf("\n");
    }
}


__device__ void update(int *data, int n, int row, int col, int x, int op) {
    if(op==-1)
        atomicSub(&data[row*n+col], x);
    else
        atomicAdd(&data[row*n+col], x);
}

__global__ void runQueries(int *data, int m, int n, int **queries, int q) {

}


int main(int argc, char *argv[]) {
    if (argc < 3) {
        printf("Usage: ./a.out <input-file-name> <output-file-name>\n");
        return 0;
    }
    // printf("Opening file\n");
    // printf("%s\n", argv[0]);
    // printf("%s\n", argv[1]);
    // printf("%s\n", argv[2]);
    FILE *in = fopen(argv[1], "r");
    int m,n;
    fscanf(in, "%d %d", &m, &n);
    // printf("%d, %d\n", m,n);

    int *data, *ddata;
    data = (int*)malloc(m*n*sizeof(int));
    cudaMalloc(&ddata, m*n*sizeof(int));

    for(int i=0; i<m; i++) {
        for(int j=0; j<n; j++) {
            fscanf(in, "%d", &data[i*n+j]);
        }
    }

    // print_matrix(data, m, n);

    int q;
    char s[10];              // Assuming every number is less than 1000000000

    fscanf(in, "%d", &q);

    int* queries[q];

    int* dqueries[q];
    // int** dqueries;
    // cudaMalloc(&dqueries, q*sizeof(int*));

    for(int i=0; i<q; i++) {
        fscanf(in, "%s", s);
        if (strcmp(s, "U")!=0) {
            // First char is not "U", some problem
            printf("Incorrect input, first character in query must be U, exiting!\n");
            return -1;
        }

        fscanf(in, "%s", s);
        int col = atoi(&s[1]);      // Skip first char C

        fscanf(in, "%s", s);
        int x = atoi(s);            // Value to be matched against column

        fscanf(in, "%s", s);
        int p = atoi(s);            // No of update ops

        int len = p*3 + 3;          // +1 for column, +1 for key, +1 for no. of updates

        queries[i] = (int*)malloc(len*sizeof(int));

        // cudaMalloc(&dqueries[i], len*sizeof(int));
        int *dquery;
        cudaMalloc(&dquery, len*sizeof(int));

        queries[i][0] = col;
        queries[i][1] = x;
        queries[i][2] = p;

        for(int j=3; j<len; j+=3) {
            fscanf(in, "%s", s);
            queries[i][j] = atoi(&s[1]);

            fscanf(in, "%s", s);
            queries[i][j+1] = atoi(s);

            fscanf(in, "%s", s);
            queries[i][j+2] = (strcmp(s,"+") ? -1 : 1);     // -1 if -, 1 for +

            // printf("%d %d %d\n", queries[i][j], queries[i][j+1], queries[i][j+2]);
        }

        // cudaMemcpy(dqueries[i], queries[i], len*sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(dquery, queries[i], len*sizeof(int), cudaMemcpyHostToDevice);
        dqueries[i] = dquery;
    }

    for(int i=0; i<q; i++) {
        int len = queries[i][2]*3 + 3;
        // printf("%d\n", len);
        for(int j=0; j<len; j++) {
            printf("%d ", queries[i][j]);
        }
        printf("\n");
    }

    // Copy Database to GPU
    cudaMemcpy(ddata, data, m*n*sizeof(int), cudaMemcpyHostToDevice);

    // Copy array of pointers(pointing to queries) to GPU
    int** dquerieslist;
    cudaMalloc(&dquerieslist, q*sizeof(int*));

    cudaMemcpy(dquerieslist, dqueries, q*sizeof(int*), cudaMemcpyHostToDevice);

    // One query per thread
    int n_blocks = ceil((float)q / 1024);

    runQueries<<<n_blocks, 1024>>>(ddata, m, n, dquerieslist, q);

    fclose(in);
    return 0;
}
