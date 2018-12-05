TARGET=parallel_det
NODES=3  # 1 less than the total #
JULIA?=julia

run:
	${JULIA} -p ${NODES} ${TARGET}.jl 128 256
