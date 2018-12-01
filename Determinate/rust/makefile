TARGET=concurrent_det
NODES=8
EXECS=target
RUSTC?=rustc

all: ${EXECS}

target: ${TARGET}.rs
	${RUSTC} -g -o ${TARGET}.exe ${TARGET}.rs

clean:
	rm ${TARGET}.exe

run:
	./${TARGET}.exe -n ${NODES}
