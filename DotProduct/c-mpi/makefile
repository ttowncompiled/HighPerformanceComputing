TARGET=mpi_dot_product
NODES=8
EXECS=target
MPICC?=mpicc
MPIRUN?=mpirun

all: ${EXECS}

target: ${TARGET}.c
	${MPICC} -g -Wall -o ${TARGET}.exe ${TARGET}.c

clean:
	rm ${TARGET}.exe

run:
	${MPIRUN} -n ${NODES} ${TARGET}.exe

