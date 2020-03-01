#include <thrust/scan.h>
#include <thrust/functional.h>

/*
	Output: 1 1 1 2 2 2 4 4 4 4
	Explanation:
	init = 		1
	1 max -5 = 	1
	1 max 0  =	1
	1 max 2  =	2
	2 max -3 = 	2
	2 max 2  = 	2
	2 max 4  =	4
	4 max 0  = 	4
	4 max -1 = 	4
	4 max 2  =	4
	NOT performed: 4 max 8 = 8, as this is exclusive scan.
*/
int main() {
	int data[] = {-5, 0, 2, -3, 2, 4, 0, -1, 2, 8};
	int sizedata = sizeof(data) / sizeof(*data);
	thrust::maximum<int> binop;
	thrust::exclusive_scan(data, data + sizedata, data, 1, binop);
	//thrust::inclusive_scan(data, data + sizedata, data, 1, binop);
	// inclusive scan does not need the initial value, hence compile error.
	for (unsigned ii = 0; ii < sizedata; ++ii) {
		std::cout << data[ii] << " ";
	}
	std::cout << std::endl;
	return 0;
}
