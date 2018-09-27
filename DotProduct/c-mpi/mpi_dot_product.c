#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

const int N = 1024;
const double K = 2.0;

void DotProduct(int n,      /* in */
                double k,   /* in */
                double *x,  /* in */
                double *y,  /* in */
                double *z   /* out */) {
    for (int i = 0; i < n; i++) {
        *(z+i) = ( *(x+i) + *(y+i) ) * k;
    }
}

int main(void) {
    double      x[N];
    double      y[N];
    double      z[N];

    double      local_n;
    double      *local_x;
    double      *local_y;
    double      *local_z;

    int         comm_sz;
    int         my_rank;

    MPI_Init(NULL, NULL);
    MPI_Comm_size(MPI_COMM_WORLD, &comm_sz);
    MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);

    if (my_rank == 0) {
        for (int i = 0; i < N; i++) {
            x[i] = i+1;
        }
        for (int j = 0; j < N; j++) {
            y[j] = j+1;
        }
    }

    local_n = N/comm_sz;

    local_x = malloc(sizeof(double) * local_n);
    local_y = malloc(sizeof(double) * local_n);
    local_z = malloc(sizeof(double) * local_n);

    MPI_Scatter(x, local_n, MPI_DOUBLE,
            local_x, local_n, MPI_DOUBLE, 0, MPI_COMM_WORLD);
    MPI_Scatter(y, local_n, MPI_DOUBLE,
            local_y, local_n, MPI_DOUBLE, 0, MPI_COMM_WORLD);

    DotProduct(local_n, K, local_x, local_y, local_z);

    MPI_Gather(local_z, local_n, MPI_DOUBLE,
            z, local_n, MPI_DOUBLE, 0, MPI_COMM_WORLD);

    if (my_rank == 0) {
        for (int m = 0; m < N; m++) {
            printf("%.2lf ", z[m]);
        }
        printf("\n");
    }

    MPI_Finalize();
    return 0;
}

