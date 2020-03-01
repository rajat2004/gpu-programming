#include <thrust/functional.h>
#include <thrust/device_vector.h>
#include <thrust/sequence.h>
//#include <thrust/transform_reduce.h>
#include <iostream>

struct mycount {
	int _a;
	mycount(int a):_a(a){}
	__host__ __device__
	int operator()(const int x, const int y) const {
		//printf("x=%d, y=%d\n", x, y);
		return (y == _a ? x + 1 : x);
	}
};
int main() {
	thrust::host_vector<int> vec(10, 0);	
	vec[1] = 5;
	vec[4] = 5;
	vec[9] = 5;
	//thrust::sequence(vec.begin(), vec.end());

	int result = thrust::reduce(vec.begin(), vec.end(), (int)0, mycount(5));
	//int result = thrust::transform_reduce(vec.begin(), vec.end(), (int)0, mycount(5));
	std::cout << result << std::endl;

	return 0;
}
