#include <stdio.h>
#include <cuda.h>

struct node {
	int data;
	struct node *next;
};

__device__ struct node *head;

__device__ struct node *getNewNode() {
	unsigned id = blockIdx.x * blockDim.x + threadIdx.x;
	struct node *newnode = (struct node *)malloc(sizeof(struct node));
	newnode->data = id;
	newnode->next = NULL;
	return newnode;
}
__global__ void listAdd() {
	struct node *myoldhead, *actualoldhead;
	struct node *newnode = getNewNode();

	do {
		myoldhead = head;
		newnode->next = myoldhead;
		actualoldhead = (struct node *)atomicCAS((unsigned long long *)&head, (unsigned long long)myoldhead, (unsigned long long)newnode);
	} while (actualoldhead != myoldhead);
}
__device__ void listPrint(struct node *ptr) {
	printf("%d ", ptr->data);
}
__global__ void listPrint() {
	int nnodes = 0;
	for (struct node *ptr = head; ptr; ptr = ptr->next, ++nnodes)
		listPrint(ptr);
	printf("\nNumber of nodes = %d\n", nnodes);
}
int main() {
	cudaMemset(&head, 0, sizeof(struct node *));	
	listAdd<<<4, 1024>>>();
	listPrint<<<1, 1>>>();
	cudaDeviceSynchronize();

	return 0;
}
