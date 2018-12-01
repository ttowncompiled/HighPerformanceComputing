#include <stdio.h>
#include <stdlib.h>
#include <float.h>
#include <math.h>
#include <mpi.h>

const int N = 256;
const int A_MAX = 10;
const long SEED = 256;

void Determinate(double **a, double *det) {
    double d = 1;
    for (int i = 0; i < N; i++) {
        d = fmod(d * fmod(*(*(a+i)+i), FLT_MAX), FLT_MAX);
        for (int j = i+1; j < N; j++) {
            double z = *(*(a+j)+i) / *(*(a+i)+i);
            for (int k = i+1; k < N; k++) {
                *(*(a+j)+k) = *(*(a+j)+k) - z * (*(*(a+i)+k));
            }
        }
    }
    (*det) = fabs(d);
}

int main(void) {
    double      **a;
    double      local_det;
    double      det;

    int         comm_sz;
    int         my_rank;

    double      start;
    double      finish;
    double      local_elapsed;
    double      elapsed;

    MPI_Init(NULL, NULL);
    MPI_Comm_size(MPI_COMM_WORLD, &comm_sz);
    MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);

    srand(SEED);
    a = (double**) malloc(sizeof(double*) * N);
    for (int i = 0; i < N; i++) {
        *(a+i) = (double*) malloc(sizeof(double) * N);
        for (int j = 0; j < N; j++) {
            *(*(a+i)+j) = rand() % A_MAX + 1;
        }
    }

    MPI_Barrier(MPI_COMM_WORLD);
    start = MPI_Wtime();

    Determinate(a, &local_det);
    det = local_det;

    finish = MPI_Wtime();
    local_elapsed = finish - start;

    MPI_Reduce(&local_elapsed, &elapsed, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);

    if (my_rank == 0) {
        printf("Determinate = %e\n", det);
        printf("Elapsed time = %e seconds\n", elapsed);
    }

    MPI_Finalize();
    return 0;
}
