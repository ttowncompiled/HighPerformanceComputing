#!/usr/bin/env bash

rm log/job.64.out
java -jar ./target/n-body-solver-1.0-jar-with-dependencies.jar 64 60 >> log/job.64.out
