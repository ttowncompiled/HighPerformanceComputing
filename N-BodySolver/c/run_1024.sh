#!/usr/bin/env bash

rm log/job.1024.out
./n_body_solver.exe 1024 60 >> log/job.1024.out
