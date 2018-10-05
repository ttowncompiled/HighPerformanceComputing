#include <stdio.h>
#include <mpi.h>

const int N = 1048576;
const double A = 0.0;
const double B = 1000.0;

double f(double x) {
    return 10*x;
}

double Trap(int comm_sz, int my_rank, int n, double a, double b) {
    double h = (b-a)/n;
    int local_n = n/comm_sz;

    double local_a = a + my_rank*local_n*h;
    double local_b = local_a + local_n*h;

    double local_int = (f(local_a) + f(local_b))/2;
    for (int i = 1; i < local_n; i++) {
        double x = local_a + i*h;
        local_int += f(x);
    }
    local_int *= h;

    return local_int;
}

int main(void) {
    double      local_int;
    double      total_int;

    int         comm_sz;
    int         my_rank;

    double      local_start;
    double      local_finish;
    double      local_elapsed;
    double      elapsed;

    MPI_Init(NULL, NULL);
    MPI_Comm_size(MPI_COMM_WORLD, &comm_sz);
    MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);

    local_int = Trap(comm_sz, my_rank, N, A, B);

    MPI_Barrier(MPI_COMM_WORLD);
    local_start = MPI_Wtime();

    MPI_Reduce(&local_int, &total_int, 1, MPI_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD);

    local_finish = MPI_Wtime();
    local_elapsed = local_finish - local_start;

    MPI_Reduce(&local_elapsed, &elapsed, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);

    if (my_rank == 0) {
        printf("With n = %d trapezoids, our estimate\n", N);
        printf("of the integral from %.2f to %.2f = %.15e\n", A, B, total_int);
        printf("Elapsed time = %e seconds\n", elapsed);
    }

    MPI_Finalize();
    return 0;
}

