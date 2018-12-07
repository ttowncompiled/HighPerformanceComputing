#!/usr/bin/env bash

#SBATCH --job-name=mpi_det.c
#SBATCH --error=log/job.%J.err
#SBATCH --output=log/job.%J.out
#SBATCH --ntasks=8
#SBATCH --ntasks-per-node=1
#SBATCH --ntasks-per-core=1
#SBATCH --time=0
#SBATCH --mem-per-cpu=100

module load gcc
module load openmpi

cd ~/HighPerformanceComputing/Determinant/c-mpi/
mpirun ./mpi_det.exe 1024 256
