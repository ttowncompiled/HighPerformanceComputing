#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <mpi.h>

const int N = 256;
const long SEED = 256;

void CalculateLogDeterminantOf(double **a, int *sign_d, double *log_d) {
    (*sign_d) = 1;
    (*log_d) = 0.0;

    double d = 1.0;
    for (int i = 0; i < N-1; i++) {
        if (a[i][i] < 0) {
            (*sign_d) = (*sign_d) * -1;
        }
        d *= a[i][i];
        for (int j = i+1; j < N-1; j++) {
            double z = a[j][i] / a[i][i];
            for (int k = i+1; k < N-1; k++) {
                a[j][k] -= (z * a[i][k]);
            }
        }
        if (i % 16 == 0) {
            (*log_d) = (*log_d) + log10(fabs(d));
            d = 1.0;
        }
    }

    (*log_d) = (*log_d) + log10(fabs(d));
}

void CalculateLogDeterminantOfAfterCompacting(int my_rank, int comm_sz, double *a, int *sign_det, double *log_det) {
    double **local_a;

    local_a = (double**) malloc((N-1)*sizeof(double*));
    for (int i = 0; i < N-1; i++) {
        local_a[i] = (double*) malloc((N-1)*sizeof(double));
    }

    double log_x_0 = -1.0; // negative is invalid
    double log_y_0 = -1.0; // negative is invalid

    double sum_x = 0.0;
    double sum_y = 0.0;

    for (int k = my_rank; k < N; k += comm_sz) {
        double c_k = a[k];
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

        int sign_d;
        double log_d;
        CalculateLogDeterminantOf(local_a, &sign_d, &log_d);
        if (c_k < 0) {
            sign_d = sign_d * -1;
        }
        if (k % 2 == 1) {
            sign_d = sign_d * -1;
        }
        log_d = log_d + log10(fabs(c_k));


        if (sign_d > 0) {
            if (log_x_0 < 0) {
                log_x_0 = log_d;
            } else {
                sum_x += pow(10, log_d - log_x_0);
            }
        } else {
            if (log_y_0 < 0) {
                log_y_0 = log_d;
            } else {
                sum_y += pow(10, log_d - log_y_0);
            }
        }
    }

    double log_x = log_x_0 + log10(1 + sum_x);
    double log_y = log_y_0 + log10(1 + sum_y);

    if (log_x > log_y) {
        (*sign_det) = 1;
        (*log_det) = log_x + log10(1 - pow(10, log_y - log_x));
    } else {
        (*sign_det) = -1;
        (*log_det) = log_y + log10(1 - pow(10, log_x - log_y));
    }
}

void Do(int my_rank, int comm_sz, double *a) {
    if (my_rank == 0) {
        for (int rank = 1; rank < comm_sz; rank++) {
            MPI_Send(a, N*N, MPI_DOUBLE, rank, 0, MPI_COMM_WORLD);
        }
    } else {
        a = (double*) malloc(N*N*sizeof(double));
        MPI_Recv(a, N*N, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
    }

    double log_x_0 = -1.0; // negative is invalid
    double log_y_0 = -1.0; // negative is invalid

    double sum_x = 0.0;
    double sum_y = 0.0;

    int sign_det;
    double local_det;
    CalculateLogDeterminantOfAfterCompacting(my_rank, comm_sz, a, &sign_det, &local_det);

    if (sign_det > 0) {
        if (log_x_0 < 0) {
            log_x_0 = local_det;
        } else {
            sum_x += pow(10, local_det - log_x_0);
        }
    } else {
        if (log_y_0 < 0) {
            log_y_0 = local_det;
        } else {
            sum_y += pow(10, local_det - log_y_0);
        }
    }

    if (my_rank == 0) {
        double local_pair[2];
        for (int t = 1; t < comm_sz; t++) {
            MPI_Recv(&local_pair, 2, MPI_DOUBLE, t, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
            if (local_pair[0] > 0) {
                sum_x += pow(10, local_pair[1] - log_x_0);
            } else {
                sum_y += pow(10, local_pair[1] - log_y_0);
            }
        }

        double log_x = log_x_0 + log10(1 + sum_x);
        double log_y = log_y_0 + log10(1 + sum_y);

        double det;
        if (log_x > log_y) {
            det = log_x + log10(1 - pow(10, log_y - log_x));
        } else {
            det = log_y + log10(1 - pow(10, log_x - log_y));
        }
        printf("Determinant = %e\n", det);
    } else {
        double local_pair[2] = { sign_det, local_det };
        MPI_Send(&local_pair, 2, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD);
    }
}

int main(void) {
    double      *a;

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
        a = (double*) malloc(N*N*sizeof(double));

        srand(SEED);
        for (int i = 0; i < N*N; i++) {
            *(a+i) = ((double) rand()) / ((double) RAND_MAX) - 1.0;
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
