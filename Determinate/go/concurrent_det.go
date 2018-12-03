package main

import (
	"fmt"
	"math/rand"
	"sync"
	"time"
)

const N int = 256
const SEED int64 = 256

func ThreadWork(wg *sync.WaitGroup, i int, a_i []float64, a_j []float64) {
	z := a_j[i] / a_i[i]
	for k := i+1; k < N; k++ {
		a_j[k] = a_j[k] - z * a_i[k]
	}
	wg.Done()
}

func main() {
	s := rand.NewSource(SEED)
	r := rand.New(s)

	a := make([][]float64, N)
	for i := 0; i < N; i++ {
		a[i] = make([]float64, N)
		for j := 0; j < N; j++ {
			a[i][j] = r.Float64()
		}
	}

	start := time.Now()

	d := 1.0
	for i := 0; i < N; i++ {
		d = d * a[i][i]
		var wg sync.WaitGroup
		for j := i+1; j < N; j++ {
			wg.Add(1)
			go ThreadWork(&wg, i, a[i], a[j])
		}
		wg.Wait()
	}

	elapsed := time.Since(start)

	fmt.Printf("Determinant = %e\n", d)
	fmt.Printf("Elapsed time = %e seconds\n", elapsed.Seconds())
}
