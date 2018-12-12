#!/usr/bin/env bash

parallel-scp -h ~/machinefile ~/HighPerformanceComputing/Determinant/c-mpi/mpi_det.exe ~/HighPerformanceComputing/Determinant/c-mpi/
rm ~/HighPerformanceComputing/Determinant/c-mpi/log/job.1.4096.out
mpirun -np 1 --hostfile ~/machinefile ~/HighPerformanceComputing/Determinant/c-mpi/mpi_det.exe 4096 1 >> ~/HighPerformanceComputing/Determinant/c-mpi/log/job.1.4096.out
