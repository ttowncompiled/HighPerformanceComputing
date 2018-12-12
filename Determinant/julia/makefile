TARGET=julia_det
NODES=4
MPIRUN?=mpirun
JULIA?=julia

run:
	${MPIRUN} -np ${NODES} ${JULIA} ${TARGET}.jl 128 1
