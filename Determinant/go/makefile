TARGET=go_det
EXECS=target
GO?=go

all: ${EXECS}

target: ${TARGET}.go
	${GO} build -o ${TARGET}.exe ${TARGET}.go

clean:
	rm ${TARGET}.exe

run:
	./${TARGET}.exe 128 256
