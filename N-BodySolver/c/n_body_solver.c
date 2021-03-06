#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <pthread.h>
#include <time.h>

const long DIMS = 2;
const double G = 6.673e-11;

struct arg_struct {
    int q;
    int n;
    double *masses;
    double **s;
    double **f;
};

void* ThreadWork(void* args_) {
    struct arg_struct *args = (struct arg_struct*) args_;
    int q = args->q;
    int n = args->n;
    double *masses = args->masses;
    double **s = args->s;
    double **f = args->f;

    for (int d = 0; d < DIMS; d++) {
        f[q][d] = 0.0;
    }

    for (int k = 0; k < n; k++) {
        if (k == q) {
            continue;
        }
        double diff[DIMS];
        double dist = 0.0;
        for (int d = 0; d < DIMS; d++) {
            diff[d] = s[k][d] - s[q][d];
            dist += diff[d]*diff[d];
        }
        dist = sqrt(dist);
        double dist_cubed = dist*dist*dist;
        for (int d = 0; d < DIMS; d++) {
            f[q][d] += G*masses[q]*masses[k]/dist_cubed * diff[d];
        }
    }

    free(args);
    return NULL;
}

void Do(long n, double *masses, double **s, double **v, double **f, long steps) {
    pthread_t* thread_handles = (pthread_t*) malloc(n*sizeof(pthread_t));
    for (int t = 0; t <= steps; t++) {
        struct arg_struct *args;
        for (int q = 0; q < n; q++) {
            args = malloc(sizeof(struct arg_struct));
            args->q = q;
            args->n = n;
            args->masses = masses;
            args->s = s;
            args->f = f;
            pthread_create(&thread_handles[q], NULL, ThreadWork, (void*) args);
        }
        for (int q = 0; q < n; q++) {
            pthread_join(thread_handles[q], NULL);
        }
        for (int q = 0; q < n; q++) {
            for (int d = 0; d < DIMS; d++) {
                s[q][d] += v[q][d];
                v[q][d] += f[q][d] / masses[q];
            }
        }
    }
    for (int q = 0; q < n; q++) {
        for (int d = 0; d < DIMS; d++) {
            printf("s[%d][%d] = %e\n", q, d, s[q][d]);
        }
        for (int d = 0; d < DIMS; d++) {
            printf("v[%d][%d] = %e\n", q, d, v[q][d]);
        }
        printf("\n");
    }
    free(thread_handles);
}

int main(int argc, char* argv[]) {
    long n = strtol(argv[1], NULL, 10);
    long steps = strtol(argv[2], NULL, 10);

    printf("n=%ld, steps=%ld\n", n, steps);

    double mass = 5.0e24;
    double gap = 1.0e5;
    double speed = 3.0e4;

    double *masses = (double*) malloc(n*sizeof(double));
    double **s = (double**) malloc(n*sizeof(double*));
    double **v = (double**) malloc(n*sizeof(double*));
    double **f = (double**) malloc(n*sizeof(double*));

    for (int q = 0; q < n; q++) {
        masses[q] = mass;
        s[q] = (double*) malloc(DIMS*sizeof(double));
        v[q] = (double*) malloc(DIMS*sizeof(double));
        f[q] = (double*) malloc(DIMS*sizeof(double));
        s[q][0] = q * gap;
        for (int d = 1; d < DIMS; d++) {
            s[q][d] = 0.0;
        }
        v[q][0] = 0.0;
        for (int d = 1; d < DIMS; d++) {
            if (q % 2 == 0) {
                v[q][d] = speed;
            } else {
                v[q][d] = -speed;
            }
        }
        for (int d = 0; d < DIMS; d++) {
            f[q][d] = 0.0;
        }
    }

    clock_t start = clock();

    Do(n, masses, s, v, f, steps);

    clock_t finish = clock();
    printf("Elapsed time = %e seconds\n", (double) (finish - start) / CLOCKS_PER_SEC);

    return 0;
}
