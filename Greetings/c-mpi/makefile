TARGET=mpi_greeting
NODES=4
EXECS=target
MPICC?=mpicc
MPIRUN?=mpirun

all: ${EXECS}

target: ${TARGET}.c
	${MPICC} -g -Wall -o ${TARGET} ${TARGET}.c

clean:
	rm ${EXECS}

run:
	${MPIRUN} -n ${NODES} ${TARGET}

