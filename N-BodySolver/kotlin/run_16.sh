#!/usr/bin/env bash

rm log/job.16.out
java -jar ./target/n-body-solver-1.0-jar-with-dependencies.jar 16 60 >> log/job.16.out
