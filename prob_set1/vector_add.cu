#include<stdio.h>
#include<cuda.h>

void print_arr(int* arr, int size) {
    for(int i=0; i<size; i++)
        print("%d ", arr[i]);
    print("\n");
}


int main() {
    int *vec1, *vec2, *dvec1, *dvec2;
    int N;
    scanf("%d", &N);

    // Two vectors of same size
    cudaMalloc(&dvec1, N*sizeof(int));
    cudaMalloc(&dvec2, N*sizeof(int));

    vec1 = (int*)malloc(N*sizeof(int));
    vec2 = (int*)malloc(N*sizeof(int));
    return 0;
}
