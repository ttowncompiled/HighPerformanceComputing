#!/usr/bin/env bash

parallel-scp -h ~/machinefile ~/HighPerformanceComputing/Determinant/c-mpi/mpi_det.exe ~/HighPerformanceComputing/Determinant/c-mpi/
mpirun -np 16 --hostfile ~/machinefile ~/HighPerformanceComputing/Determinant/c-mpi/mpi_det.exe 4096 1
