TARGET=mpi_det
NODES=1
EXECS=target
MPICC?=mpicc
MPIRUN?=mpirun

all: ${EXECS}

target: ${TARGET}.c
	${MPICC} -g -Wall -o ${TARGET}.exe ${TARGET}.c -lm

clean:
	rm ${TARGET}.exe

run:
	${MPIRUN} -n ${NODES} ${TARGET}.exe

