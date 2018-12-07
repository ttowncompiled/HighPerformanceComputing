#!/usr/bin/env bash

rm log/job.8192.out
./n_body_solver.exe 8192 60 >> log/job.8192.out
