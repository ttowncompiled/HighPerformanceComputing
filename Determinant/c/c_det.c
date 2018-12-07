#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <pthread.h>
#include <time.h>

struct args_struct {
    int i;
    int n;
    double *a_i;
    double *a_j;
};

void* ThreadWork(void* args_) {
    struct args_struct *args = (struct args_struct*) args_;
    int i = args->i;
    int n = args->n;
    double *a_i = args->a_i;
    double *a_j = args->a_j;

    double z = a_j[i] / a_i[i];
    for (int k = i+1; k < n; k++) {
        a_j[k] -= z * a_i[k];
    }

    free(args);
    return NULL;
}

void CalculateLogDeterminantOf(long n, double **a) {
    pthread_t *thread_handles = (pthread_t*) malloc(n*sizeof(pthread_t));
    double log_d = 0.0;
    for (int i = 0; i < n; i++) {
        log_d += log(fabs(a[i][i]));
        struct args_struct *args;
        for (int j = i+1; j < n; j++) {
            args = (struct args_struct*) malloc(sizeof(struct args_struct));
            args->i = i;
            args->n = n;
            args->a_i = a[i];
            args->a_j = a[j];
            pthread_create(&thread_handles[j], NULL, ThreadWork, (void*) args);
        }
        for (int j = i+1; j < n; j++) {
            pthread_join(thread_handles[j], NULL);
        }
    }

    free(thread_handles);
    printf("log(abs(det)) = %e\n", log_d);
}

int main(int argc, char* argv[]) {
    long n = strtol(argv[1], NULL, 10);
    long seed = strtol(argv[2], NULL, 10);

    printf("n=%ld, seed=%ld\n", n, seed);

    double **a = (double**) malloc(n*sizeof(double*));

    srand(seed);
    for (int i = 0; i < n; i++) {
        a[i] = (double*) malloc(n*sizeof(double));
        for (int j = 0; j < n; j++) {
            a[i][j] = ((double) rand()) / ((double) RAND_MAX) - 0.5;
        }
    }

    clock_t start = clock();

    CalculateLogDeterminantOf(n, a);

    clock_t finish = clock();
    printf("Elapsed time = %e seconds\n", (double) (finish - start) / CLOCKS_PER_SEC);
    return 0;
}
