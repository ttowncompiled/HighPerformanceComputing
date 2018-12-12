#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <mpi.h>

void ComputeLogTrace(int my_rank, int comm_sz, long n, int local_n, double** local_a) {
    double *a_i = (double*) malloc(n*sizeof(double));
    for (int i = 0; i < n; i++) {
        if (i % comm_sz == my_rank) {
            for (int j = 0; j < n; j++) {
                a_i[j] = local_a[i / comm_sz][j];
            }
            for (int rank = 0; rank < comm_sz; rank++) {
                if (rank == my_rank) {
                    continue;
                }
                MPI_Send(a_i, n, MPI_DOUBLE, rank, 0, MPI_COMM_WORLD);
            }
        } else {
            MPI_Recv(a_i, n, MPI_DOUBLE, i % comm_sz, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        }
        for (int j = i+1; j < n; j++) {
            if (j % comm_sz == my_rank) {
                double *a_j = local_a[j / comm_sz];
                double z = a_j[i] / a_i[i];
                for (int k = i+1; k < n; k++) {
                    a_j[k] -= z * a_i[k];
                }
            }
        }
    }

    double local_det = 0.0;
    for (int i = 0; i < local_n; i++) {
        local_det += log(fabs(local_a[i][i * comm_sz + my_rank]));
    }

    if (my_rank == 0) {
        double det = local_det;
        for (int rank = 1; rank < comm_sz; rank++) {
            MPI_Recv(&local_det, 1, MPI_DOUBLE, rank, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
            det += local_det;
        }
        printf("log(abs(det)) = %e\n", det);
    } else {
        MPI_Send(&local_det, 1, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD);
    }
}

void SyncRows(int my_rank, int comm_sz, long n, double** a) {
    int local_n = n / comm_sz;
    double** local_a = (double**) malloc(local_n*sizeof(double*));

    for (int i = 0; i < n; i++) {
        if (i % comm_sz == my_rank) {
            local_a[i / comm_sz] = a[i];
        } else {
            MPI_Send(a[i], n, MPI_DOUBLE, i % comm_sz, 0, MPI_COMM_WORLD);
        }
    }

    ComputeLogTrace(my_rank, comm_sz, n, local_n, local_a);
}

void SyncRowsRemote(int my_rank, int comm_sz, long n) {
    int local_n = n / comm_sz;
    double** local_a = (double**) malloc(local_n*sizeof(double*));
    for (int i = 0; i < local_n; i++) {
        local_a[i] = (double*) malloc(n*sizeof(double));
        MPI_Recv(local_a[i], n, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
    }

    ComputeLogTrace(my_rank, comm_sz, n, local_n, local_a);
}

int main(int argc, char* argv[]) {
    int         comm_sz;
    int         my_rank;

    double      start;
    double      finish;

    double      local_elapsed;
    double      elapsed;

    long n = strtol(argv[1], NULL, 10);
    long seed = strtol(argv[2], NULL, 10);

    MPI_Init(NULL, NULL);
    MPI_Comm_size(MPI_COMM_WORLD, &comm_sz);
    MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);

    printf("my_rank=%d, comm_sz=%d, n=%ld, seed=%ld\n", my_rank, comm_sz, n, seed);

    double **a;

    if (my_rank == 0) {
        a = (double**) malloc(n*sizeof(double*));

        srand(seed);
        for (int i = 0; i < n; i++) {
            a[i] = (double*) malloc(n*sizeof(double));
            for (int j = 0; j < n; j++) {
                a[i][j] = ((double) rand()) / ((double) RAND_MAX) - 0.5;
            }
        }
    }

    MPI_Barrier(MPI_COMM_WORLD);
    start = MPI_Wtime();

    if (my_rank == 0) {
        SyncRows(my_rank, comm_sz, n, a);
    } else {
        SyncRowsRemote(my_rank, comm_sz, n);
    }

    finish = MPI_Wtime();
    local_elapsed = finish - start;

    MPI_Reduce(&local_elapsed, &elapsed, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);

    if (my_rank == 0) {
        printf("Elapsed time = %e seconds\n", elapsed);
    }

    MPI_Finalize();
    return 0;
}
