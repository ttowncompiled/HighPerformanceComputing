#!/usr/bin/env bash

rm log/job.128.out
java -jar ./target/n-body-solver-1.0-jar-with-dependencies.jar 128 60 >> log/job.128.out
