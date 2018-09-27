TARGET=concurrent_greeting
NODES=4
EXECS=target
RUSTC?=rustc

all: ${EXECS}

target: ${TARGET}.rs
	${RUSTC} ${TARGET}.rs

clean:
	rm ${EXECS}

run:
	./${TARGET} -n ${NODES}

