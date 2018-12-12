#!/usr/bin/env bash

parallel-scp -h ~/machinefile ~/HighPerformanceComputing/Determinant/c-mpi/mpi_det.exe ~/HighPerformanceComputing/Determinant/c-mpi/
rm ~/HighPerformanceComputing/Determinant/c-mpi/log/job.32.32.out
mpirun -np 32 --hostfile ~/machinefile ~/HighPerformanceComputing/Determinant/c-mpi/mpi_det.exe 32 1 >> ~/HighPerformanceComputing/Determinant/c-mpi/log/job.32.32.out
