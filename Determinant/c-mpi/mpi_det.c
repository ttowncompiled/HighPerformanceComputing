#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <mpi.h>

const int N = 256;
const long SEED = 256;

double CalculateDeterminantOf(double a[N-1][N-1]) {
    double d = 1.0;
    for (int i = 0; i < N-1; i++) {
        d = d * a[i][i];
        for (int j = i+1; j < N-1; j++) {
            double z = a[j][i] / a[i][i];
            for (int k = i+1; k < N-1; k++) {
                a[j][k] -= (z * a[i][k]);
            }
        }
    }
    return d;
}

double CalculateDeterminantOfAfterCompacting(int my_rank, int comm_sz, double a[N*N]) {
    double local_det = 0.0;
    double local_a[N-1][N-1];

    for (int k = my_rank; k < N; k += comm_sz) {
        double z = a[k];
        for (int i = 1; i < N; i++) {
            for (int j = 0; j < k; j++) {
                local_a[i-1][j] = a[i*N + j];
            }
        }
        for (int i = 1; i < N; i++) {
            for (int j = k+1; j < N; j++) {
                local_a[i-1][j-1] = a[i*N + j];
            }
        }
        double d = CalculateDeterminantOf(local_a);
        local_det += (z * d * (k % 2 == 0 ? 1 : -1));
    }
    return local_det;
}

void Do(int my_rank, int comm_sz, double a[N*N]) {
    double det;
    double local_det;

    if (my_rank == 0) {
        for (int rank = 1; rank < comm_sz; rank++) {
            MPI_Send(a, N*N, MPI_DOUBLE, rank, 0, MPI_COMM_WORLD);
        }
    } else {
        MPI_Recv(a, N*N, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
    }

    local_det = CalculateDeterminantOfAfterCompacting(my_rank, comm_sz, a);

    if (my_rank == 0) {
        det = local_det;
        for (int t = 1; t < comm_sz; t++) {
            MPI_Recv(&local_det, 1, MPI_DOUBLE, t, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
            det += local_det;
        }
        printf("Determinant = %e\n", fabs(det));
    } else {
        MPI_Send(&local_det, 1, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD);
    }
}

int main(void) {
    double      a[N*N];

    int         comm_sz;
    int         my_rank;

    double      start;
    double      finish;

    double      local_elapsed;
    double      elapsed;

    MPI_Init(NULL, NULL);
    MPI_Comm_size(MPI_COMM_WORLD, &comm_sz);
    MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);

    if (my_rank == 0) {
        srand(SEED);
        for (int i = 0; i < N*N; i++) {
            a[i] = ((double) rand()) / ((double) RAND_MAX);
        }
    }

    MPI_Barrier(MPI_COMM_WORLD);
    start = MPI_Wtime();

    Do(my_rank, comm_sz, a);

    finish = MPI_Wtime();
    local_elapsed = finish - start;

    MPI_Reduce(&local_elapsed, &elapsed, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);

    if (my_rank == 0) {
        printf("Elapsed time = %e seconds\n", elapsed);
    }

    MPI_Finalize();
    return 0;
}
