TARGET=concurrent_greetings
NODES=4
EXECS=target
RUSTC?=rustc

all: ${EXECS}

target: ${TARGET}.rs
	${RUSTC} -o ${TARGET}.exe ${TARGET}.rs

clean:
	rm ${EXECS}

run:
	./${TARGET}.exe -n ${NODES}

