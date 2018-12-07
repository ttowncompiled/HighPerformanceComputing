TARGET=c_det
EXECS=target
GCC?=gcc

all: ${EXECS}

target: ${TARGET}.c
	${GCC} -g -Wall -o ${TARGET}.exe ${TARGET}.c -lm -lpthread

clean:
	rm ${TARGET}.exe

run:
	./${TARGET}.exe 128 256
