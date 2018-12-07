#!/usr/bin/env bash

rm log/job.4.out
java -jar ./target/n-body-solver-1.0-jar-with-dependencies.jar 4 60 >> log/job.4.out
