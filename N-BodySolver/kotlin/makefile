TARGET=n-body-solver-1.0
EXECS=target
MVN?=mvn
JAVA?=java

all:
	${MVN} package

clean:
	rm -r target/

run:
	${JAVA} -jar ./target/${TARGET}-jar-with-dependencies.jar 12 10
