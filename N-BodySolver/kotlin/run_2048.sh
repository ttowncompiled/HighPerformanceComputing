#!/usr/bin/env bash

rm log/job.2048.out
java -jar ./target/n-body-solver-1.0-jar-with-dependencies.jar 2048 60 >> log/job.2048.out
