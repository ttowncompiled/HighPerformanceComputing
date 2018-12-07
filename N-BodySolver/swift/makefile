TARGET=n_body_solver
EXECS=target
SWIFTC?=swiftc

all: ${EXECS}

target: ${TARGET}.swift
	${SWIFTC} -o ${TARGET}.exe ${TARGET}.swift

clean:
	rm ${TARGET}.exe

run:
	./${TARGET}.exe 8 60
