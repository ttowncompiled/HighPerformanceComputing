#!/usr/bin/env bash

parallel-scp -h ~/machinefile ~/HighPerformanceComputing/Determinant/julia/julia_det.jl ~/HighPerformanceComputing/Determinant/julia/
rm ~/HighPerformanceComputing/Determinant/julia/log/job.8.1024.out
mpirun -np 8 --hostfile ~/machinefile julia ~/HighPerformanceComputing/Determinant/julia/julia_det.jl 1024 1 >> ~/HighPerformanceComputing/Determinant/julia/log/job.8.1024.out
