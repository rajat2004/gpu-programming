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

void print_matrix_file(FILE* f, int* mat, int rows, int cols) {
    for(int i=0; i<rows; i++) {
        for(int j=0; j<cols; j++) {
            fprintf(f, "%d ", mat[i*cols + j]);
        }
        fprintf(f, "\n");
    }
}


// Run query on the specified row
__device__ void runQuery(int *data, int n, int *query, int row) {
    int n_queries = query[2];
    int len = n_queries*3 + 3;

    for(int i=3; i<len; i+=3) {
        int op = query[i+2];

        if (op == -1)
            atomicSub(&data[row*n+query[i]-1], query[i+1]);
        else
            atomicAdd(&data[row*n+query[i]-1], query[i+1]);
    }
}

__global__ void searchQuery(int* data, int n, int m, int* query, int col, int x) {
    int tid = blockIdx.x*blockDim.x + threadIdx.x;

    if (tid < m) {
        if(data[tid*n + col-1] == x)
            runQuery(data, n, query, tid);
    }
}

__global__ void runQueries(int* data, int m, int n, int** queries, int q) {
    int tid = blockIdx.x*blockDim.x + threadIdx.x;

    if (tid < q) {
        int *query = queries[tid];

        int col = query[0];
        int x = query[1];

        // Search in database
        for(int row=0; row<m; row++) {
            if(data[row*n + col-1] == x)
                runQuery(data, n, query, row);
        }

        // Try kernel in kernel
        // int n_blocks = ceil((float)m / 1024);
        // searchQuery<<<n_blocks, 1024>>>(data, n, m, query, col, x);
    }
}


int main(int argc, char *argv[]) {
    if (argc < 3) {
        printf("Usage: ./a.out <input-file-name> <output-file-name>\n");
        return 0;
    }

    FILE *in = fopen(argv[1], "r");
    if (in == NULL) {
        printf("Error opening input file!\n");
        return -1;
    }

    int m,n;
    fscanf(in, "%d %d", &m, &n);

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
    char s[10];                     // Assuming every number is less than 1000000000

    fscanf(in, "%d", &q);

    int* queries[q];                // Storage on CPU

    int* dqueries[q];               // Storage on GPU

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

        // For copying query to GPU
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

        cudaMemcpy(dquery, queries[i], len*sizeof(int), cudaMemcpyHostToDevice);
        dqueries[i] = dquery;
    }

    // for(int i=0; i<q; i++) {
    //     int len = queries[i][2]*3 + 3;
    //     // printf("%d\n", len);
    //     for(int j=0; j<len; j++) {
    //         printf("%d ", queries[i][j]);
    //     }
    //     printf("\n");
    // }

    // Copy Database to GPU
    cudaMemcpy(ddata, data, m*n*sizeof(int), cudaMemcpyHostToDevice);

    // Copy array of pointers(pointing to queries) to GPU
    int** dquerieslist;
    cudaMalloc(&dquerieslist, q*sizeof(int*));

    cudaMemcpy(dquerieslist, dqueries, q*sizeof(int*), cudaMemcpyHostToDevice);

    // One query per thread
    int n_blocks = ceil((float)q / 1024);
    runQueries<<<n_blocks, 1024>>>(ddata, m, n, dquerieslist, q);

    cudaMemcpy(data, ddata, m*n*sizeof(int), cudaMemcpyDeviceToHost);

    // print_matrix(data, m, n);

    // Output to file
    FILE *out = fopen(argv[2], "w");
    if (out == NULL) {
        printf("Error opening output file!");
        return -1;
    }
    print_matrix_file(out, data, m, n);

    fclose(in);
    fclose(out);

    // Free allocated memory
    free(data);
    cudaFree(ddata);

    for(int i=0; i<q; i++) {
        free(queries[i]);
        cudaFree(dqueries[i]);
    }

    return 0;
}
