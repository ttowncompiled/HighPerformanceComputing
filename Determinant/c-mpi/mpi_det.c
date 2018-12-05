#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <mpi.h>

void CalculateLogDeterminantOf(long n, double **a, int *sign_d, double *log_d) {
    (*sign_d) = 1;
    (*log_d) = 0.0;

    double d = 1.0;
    for (int i = 0; i < n; i++) {
        if (a[i][i] < 0) {
            (*sign_d) = (*sign_d) * -1;
        }
        d *= a[i][i];
        for (int j = i+1; j < n; j++) {
            double z = a[j][i] / a[i][i];
            for (int k = i+1; k < n; k++) {
                a[j][k] -= (z * a[i][k]);
            }
        }
        if (i % 16 == 0) {
            (*log_d) = (*log_d) + log2(fabs(d));
            d = 1.0;
        }
    }

    (*log_d) = (*log_d) + log2(fabs(d));
}

void CalculateLogDeterminantOfAfterCompacting(int my_rank, int comm_sz, long n, double *a, int *sign_det, double *log_det) {
    double **local_a;

    local_a = (double**) malloc((n-1)*sizeof(double*));
    for (int i = 0; i < n-1; i++) {
        local_a[i] = (double*) malloc((n-1)*sizeof(double));
    }

    double log_x_0 = -1.0; // negative is invalid
    double log_y_0 = -1.0; // negative is invalid

    double sum_x = 0.0;
    double sum_y = 0.0;

    for (int k = my_rank; k < n; k += comm_sz) {
        double c_k = a[k];

        for (int i = 1; i < n; i++) {
            for (int j = 0; j < k; j++) {
                local_a[i-1][j] = a[i*n + j];
            }
        }
        for (int i = 1; i < n; i++) {
            for (int j = k+1; j < n; j++) {
                local_a[i-1][j-1] = a[i*n + j];
            }
        }

        int sign_d;
        double log_d;
        CalculateLogDeterminantOf(n-1, local_a, &sign_d, &log_d);
        if (c_k < 0) {
            sign_d = sign_d * -1;
        }
        if (k % 2 == 1) {
            sign_d = sign_d * -1;
        }
        log_d = log_d + log2(fabs(c_k));

        if (sign_d > 0) {
            if (log_x_0 < 0) {
                log_x_0 = log_d;
            } else {
                sum_x += pow(2, log_d - log_x_0);
            }
        } else {
            if (log_y_0 < 0) {
                log_y_0 = log_d;
            } else {
                sum_y += pow(2, log_d - log_y_0);
            }
        }
    }

    double log_x = log_x_0 + log2(1 + sum_x);
    double log_y = log_y_0 + log2(1 + sum_y);

    if (log_x > log_y) {
        (*sign_det) = 1;
        (*log_det) = log_x + log2(1 - pow(2, log_y - log_x));
    } else {
        (*sign_det) = -1;
        (*log_det) = log_y + log2(1 - pow(2, log_x - log_y));
    }
}

void Do(int my_rank, int comm_sz, long n, double *a) {
    if (my_rank == 0) {
        for (int rank = 1; rank < comm_sz; rank++) {
            MPI_Send(a, n*n, MPI_DOUBLE, rank, 0, MPI_COMM_WORLD);
        }
    } else {
        a = (double*) malloc(n*n*sizeof(double));
        MPI_Recv(a, n*n, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
    }

    double log_x_0 = -1.0; // negative is invalid
    double log_y_0 = -1.0; // negative is invalid

    double sum_x = 0.0;
    double sum_y = 0.0;

    int sign_det;
    double local_det;
    CalculateLogDeterminantOfAfterCompacting(my_rank, comm_sz, n, a, &sign_det, &local_det);

    if (sign_det > 0) {
        log_x_0 = local_det;
    } else {
        log_y_0 = local_det;
    }

    if (my_rank == 0) {
        double local_pair[2];
        for (int t = 1; t < comm_sz; t++) {
            MPI_Recv(&local_pair, 2, MPI_DOUBLE, t, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
            if (local_pair[0] > 0) {
                if (log_x_0 < 0) {
                    log_x_0 = local_pair[1];
                } else {
                    sum_x += pow(2, local_pair[1] - log_x_0);
                }
            } else {
                if (log_y_0 < 0) {
                    log_y_0 = local_pair[1];
                } else {
                    sum_y += pow(2, local_pair[1] - log_y_0);
                }
            }
        }

        double log_x = log_x_0 + log2(1 + sum_x);
        double log_y = log_y_0 + log2(1 + sum_y);

        double det;
        if (log_x > log_y) {
            det = log_x + log2(1 - pow(2, log_y - log_x));
        } else {
            det = log_y + log2(1 - pow(2, log_x - log_y));
        }

        det = det / log2(exp(1));
        printf("Determinant = %e\n", det);
    } else {
        double local_pair[2] = { sign_det, local_det };
        MPI_Send(&local_pair, 2, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD);
    }
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

    double *a;

    if (my_rank == 0) {
        a = (double*) malloc(n*n*sizeof(double));

        srand(seed);
        for (int i = 0; i < n*n; i++) {
            *(a+i) = ((double) rand()) / ((double) RAND_MAX) - 1.0;
        }
    }

    MPI_Barrier(MPI_COMM_WORLD);
    start = MPI_Wtime();

    Do(my_rank, comm_sz, n, a);

    finish = MPI_Wtime();
    local_elapsed = finish - start;

    MPI_Reduce(&local_elapsed, &elapsed, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);

    if (my_rank == 0) {
        printf("Elapsed time = %e seconds\n", elapsed);
    }

    MPI_Finalize();
    return 0;
}
