#!/usr/bin/env bash

rm log/job.2.out
java -jar ./target/n-body-solver-1.0-jar-with-dependencies.jar 2 60 >> log/job.2.out
