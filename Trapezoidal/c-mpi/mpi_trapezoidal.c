#include <stdio.h>      /* For printf               */
#include <mpi.h>        /* For MPI functions, etc   */

const int n = 1024;         /* The total number of traps    */
const double a = 0.0;       /* The left of the interval     */
const double b = 100.0;     /* The right of the interval    */

double f(double x) {
    return 10*x;
}

int main(void) {
    double      h;          /* The length of each trap      */
    int         local_n;    /* The local number of traps    */
    double      local_a;    /* The left of the subinterval  */
    double      local_b;    /* The right of the subinterval */
    double      local_int;  /* A single integral            */
    double      total_int;  /* The final integral           */
    int         comm_sz;    /* Number of processes          */
    int         my_rank;    /* My process rank              */

    MPI_Init(NULL, NULL);
    MPI_Comm_size(MPI_COMM_WORLD, &comm_sz);
    MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);

    h = (b-a)/n;
    local_n = n/comm_sz;

    local_a = a + my_rank*local_n*h;
    local_b = local_a + local_n*h;

    // approximate the local integral using the trapezoidal rule
    double x;
    local_int = (f(local_a) + f(local_b))/2.0;
    for (int i = 1; i < local_n; i++) {
        x = local_a + i*h;
        local_int += f(x);
    }
    local_int *= h;

    if (my_rank != 0) {
        MPI_Send(&local_int, 1, MPI_DOUBLE,
                0, 0, MPI_COMM_WORLD);
    } else {    /* my_rank == 0 */
        total_int = local_int;
        for (int q = 1; q < comm_sz; q++) {
            MPI_Recv(&local_int, 1, MPI_DOUBLE,
                    q, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
            total_int += local_int;
        }
    }

    if (my_rank == 0) {
        printf("With n = %d trapezoids, our estimate\n", n);
        printf("of the integral from %.2f to %.2f = %.15e\n",
                a, b, total_int);
    }

    MPI_Finalize();
    return 0;
}   /* main */

