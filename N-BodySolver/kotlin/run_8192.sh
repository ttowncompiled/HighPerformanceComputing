#!/usr/bin/env bash

rm log/job.8192.out
java -jar ./target/n-body-solver-1.0-jar-with-dependencies.jar 8192 60 >> log/job.8192.out
