#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <omp.h>

const long DIMS = 2;
const double G = 6.673e-11;

void Do(long n, double *masses, double **s, double **v, long steps) {
    for (int t = 0; t <= steps; t++) {
        for (int q = 0; q < n; q++) {
            double force_q[DIMS];
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
                    force_q[d] += G*masses[q]*masses[k]/dist_cubed * diff[d];
                }
            }
            for (int d = 0; d < DIMS; d++) {
                s[q][d] += v[q][d];
                v[q][d] += force_q[d] / masses[q];
            }
        }
    }
    for (int q = 0; q < n; q++) {
        printf("s[%d][%d] = %e", q, 0, s[q][0]);
        for (int d = 1; d < DIMS; d++) {
            printf(", s[%d][%d] = %e", q, d, s[q][d]);
        }
        for (int d = 0; d < DIMS; d++) {
            printf(", v[%d][%d] = %e", q, d, v[q][d]);
        }
        printf("\n");
    }
}

int main(int argc, char* argv[]) {
    long n = strtol(argv[1], NULL, 10);
    long steps = strtol(argv[2], NULL, 10);

    double mass = 5.0e24;
    double gap = 1.0e5;
    double speed = 3.0e4;

    double *masses = (double*) malloc(n*sizeof(double));
    double **s = (double**) malloc(n*sizeof(double*));
    double **v = (double**) malloc(n*sizeof(double*));

    for (int q = 0; q < n; q++) {
        masses[q] = mass;
        s[q] = (double*) malloc(DIMS*sizeof(double));
        v[q] = (double*) malloc(DIMS*sizeof(double));
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
    }

    clock_t start = clock();

    Do(n, masses, s, v, steps);

    clock_t finish = clock();
    printf("Elapsed time = %e seconds\n", (double) (finish - start) / CLOCKS_PER_SEC);

    return 0;
}
