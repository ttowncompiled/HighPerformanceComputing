#!/usr/bin/env bash

rm log/job.256.out
java -jar ./target/n-body-solver-1.0-jar-with-dependencies.jar 256 60 >> log/job.256.out
