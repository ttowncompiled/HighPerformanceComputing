#!/usr/bin/env bash

rm log/job.4096.out
./n_body_solver.exe 4096 60 >> log/job.4096.out
