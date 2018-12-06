#!/usr/bin/env bash

rm log/job.4096.out
./go_det.exe 4096 256 >> log/job.4096.out
