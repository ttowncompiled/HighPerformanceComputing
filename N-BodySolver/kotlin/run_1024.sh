#!/usr/bin/env bash

rm log/job.1024.out
java -jar ./target/n-body-solver-1.0-jar-with-dependencies.jar 1024 60 >> log/job.1024.out
