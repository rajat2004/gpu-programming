CC := nvcc

SRCS := $(wildcard *.cu)
PROGS := $(patsubst %.cu,%,$(SRCS))

all : $(PROGS)

%: %.cu
	$(CC) -o $@ $<

clean :
	rm $(PROGS) 
