#include <stdio.h>
#include <cuda.h>
#include <iostream>

class dreference {
public:
	dreference(int *memloc) {
		this->memloc = memloc;
	}
	int operator ()() {
		return getval();
	}
	int operator = (int newval) {
		//printf("Writing %d at %p\n", newval, memloc);
		cudaMemcpy(memloc, &newval, sizeof(int), cudaMemcpyHostToDevice);
		return newval;	// can return self-reference to allow cascaded =.
	}
	int getval() { 
		int val;
		cudaMemcpy(&val, memloc, sizeof(int), cudaMemcpyDeviceToHost);
		return val; 
	}
private:
	int *memloc;
};

class dvector {
public:
	dvector(unsigned size);
	~dvector();
	dreference operator [](unsigned ii);
	void print();
private:
	int *arr;
	int size;
};

dvector::dvector(unsigned size) {
	cudaMalloc(&arr, size * sizeof(int));
	this->size = size;
	//printf("arr points to %p\n", arr);
}
dvector::~dvector() {
	cudaFree(arr);
	arr = NULL;
}
dreference dvector::operator [](unsigned ii) {
	return dreference(arr + ii);
}
void dvector::print() {
	int aval;
	for (int ii = 0; ii < size; ++ii) {
		cudaMemcpy(&aval, arr + ii, sizeof(int), cudaMemcpyDeviceToHost);
		std::cout << aval << ", ";
	}
	std::cout << std::endl;
}
std::ostream & operator <<(std::ostream &os, dreference dd) {
	return os << dd.getval();
}
int main() {
	dvector dv(10);
	dv[0] = 1;
	dv[1] = 2;
	dv[5] = 2;

	std::cout << dv[0] << ", " << dv[1] << std::endl;
	dv.print();

	return 0;
}
