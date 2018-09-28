TARGET=ConcurrentGreetings
NODES=8
EXECS=target
KOTLINC?=kotlinc
JAVA?=java

all: ${EXECS}

target: ${TARGET}.kt
	${KOTLINC} ${TARGET}.kt -include-runtime -d ${TARGET}.jar

clean:
	rm ${TARGET}.jar

run:
	${JAVA} -jar ${TARGET}.jar -n ${NODES}

