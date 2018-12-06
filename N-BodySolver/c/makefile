TARGET=n_body_solver
EXECS=target
GCC?=gcc

all: ${EXECS}

target: ${TARGET}.c
	${GCC} -g -Wall -fopenmp -o ${TARGET}.exe ${TARGET}.c -lm

clean:
	rm ${TARGET}.exe

run:
	./${TARGET}.exe 12 10
