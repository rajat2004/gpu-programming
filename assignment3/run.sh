#!/bin/bash

var=0
unzip A3_TestCases.zip
for file in ./A3_TestCases/Inputs/*.txt; do
	./a.out $file ./A3_TestCases/Outputs/op${var}.txt
	((var+=1))
done

for i in $(seq $(($var-1)) ); do
	python3 checker.py ./A3_TestCases/Outputs/output${i}.txt ./A3_TestCases/Outputs/op${i}.txt
done
