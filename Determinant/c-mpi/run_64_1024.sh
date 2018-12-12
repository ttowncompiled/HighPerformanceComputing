#!/usr/bin/env bash

parallel-scp -h ~/machinefile ~/HighPerformanceComputing/Determinant/c-mpi/mpi_det.exe ~/HighPerformanceComputing/Determinant/c-mpi/
rm ~/HighPerformanceComputing/Determinant/c-mpi/log/job.64.1024.out
mpirun -np 64 --hostfile ~/machinefile ~/HighPerformanceComputing/Determinant/c-mpi/mpi_det.exe 1024 1 >> ~/HighPerformanceComputing/Determinant/c-mpi/log/job.64.1024.out
