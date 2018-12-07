#!/usr/bin/env bash

rm log/job.512.out
java -jar ./target/n-body-solver-1.0-jar-with-dependencies.jar 512 60 >> log/job.512.out
