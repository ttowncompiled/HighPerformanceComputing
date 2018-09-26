#include <stdio.h>      /* for printf               */
#include <stdlib.h>     /* for malloc               */
#include <mpi.h>        /* for mpi functions, etc   */

const int n = 1024;     /* The size of each vector  */
const double k = 2.0;   /* The size of the scalar   */

int main(void) {
    double      *x;         /* The first vector x           */
    double      *y;         /* The second vector y          */
    double      *z;         /* The output vector z          */
    double      local_n;    /* The local block size of n    */
    double      *local_x;   /* The local block of x         */
    double      *local_y;   /* The local block of y         */
    double      *local_z;   /* The local block of z         */
    int         comm_sz;    /* number of processes          */
    int         my_rank;    /* my process rank              */

    MPI_Init(NULL, NULL);
    MPI_Comm_size(MPI_COMM_WORLD, &comm_sz);
    MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);

    if (my_rank == 0) {
        x = malloc(sizeof(double) * n);
        y = malloc(sizeof(double) * n);
        for (int i = 0; i < n; i++) {
            *(x+i) = i+1;
        }
        for (int j = 0; j < n; j++) {
            *(y+j) = j+1;
        }
    }

    local_n = n/comm_sz;

    local_x = malloc(sizeof(double) * local_n);
    local_y = malloc(sizeof(double) * local_n);
    local_z = malloc(sizeof(double) * local_n);

    MPI_Scatter(x, local_n, MPI_DOUBLE,
            local_x, local_n, MPI_DOUBLE, 0, MPI_COMM_WORLD);
    MPI_Scatter(y, local_n, MPI_DOUBLE,
            local_y, local_n, MPI_DOUBLE, 0, MPI_COMM_WORLD);

    for (int m = 0; m < local_n; m++) {
        *(local_z+m) = ( *(local_x+m) + *(local_y+m) )*k;
    }

    if (my_rank == 0) {
        z = malloc(sizeof(double) * n);
    }

    MPI_Gather(local_z, local_n, MPI_DOUBLE,
            z, local_n, MPI_DOUBLE, 0, MPI_COMM_WORLD);

    if (my_rank == 0) {
        for (int p = 0; p < n; p++) {
            printf("%.2lf ", *(z+p));
        }
        printf("\n");
    }

    MPI_Finalize();
    return 0;
}   /* main */

