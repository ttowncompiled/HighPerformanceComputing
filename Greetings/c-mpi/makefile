TARGET=mpi_greetings
NODES=4
EXECS=target
MPICC?=mpicc
MPIRUN?=mpirun

all: ${EXECS}

target: ${TARGET}.c
	${MPICC} -g -Wall -o ${TARGET}.exe ${TARGET}.c

clean:
	rm ${EXECS}

run:
	${MPIRUN} -n ${NODES} ${TARGET}.exe

