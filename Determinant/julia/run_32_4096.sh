#!/usr/bin/env bash

parallel-scp -h ~/machinefile ~/HighPerformanceComputing/Determinant/julia/julia_det.jl ~/HighPerformanceComputing/Determinant/julia/
rm ~/HighPerformanceComputing/Determinant/julia/log/job.32.4096.out
mpirun -np 32 --hostfile ~/machinefile julia ~/HighPerformanceComputing/Determinant/julia/julia_det.jl 4096 1 >> ~/HighPerformanceComputing/Determinant/julia/log/job.32.4096.out
