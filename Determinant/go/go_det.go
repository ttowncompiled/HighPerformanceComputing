package main

import (
	"fmt"
	"math"
	"math/rand"
	"os"
	"strconv"
	"sync"
	"time"
)

func ThreadWork(wg *sync.WaitGroup, i int, n int, a_i []float64, a_j []float64) {
	var z float64 = a_j[i] / a_i[i]
	for k := i+1; k < n; k++ {
		a_j[k] -= z * a_i[k]
	}
	wg.Done()
}

func CalculateLogDeterminantOf(n int, a [][]float64) {
	var wg sync.WaitGroup
	var log_d float64 = 0.0
	for i := 0; i < n; i++ {
		log_d += math.Log(math.Abs(a[i][i]))
		for j := i+1; j < n; j++ {
			wg.Add(1)
			go ThreadWork(&wg, i, n, a[i], a[j])
		}
		wg.Wait()
	}
	fmt.Printf("log(abs(det)) = %e\n", log_d)
}

func main() {
	var n, seed int
	n, _ = strconv.Atoi(os.Args[1])
	seed, _ = strconv.Atoi(os.Args[2])

	fmt.Printf("n=%d, seed=%d\n", n, seed)

	s := rand.NewSource(int64(seed))
	r := rand.New(s)

	a := make([][]float64, n)
	for i := 0; i < n; i++ {
		a[i] = make([]float64, n)
		for j := 0; j < n; j++ {
			a[i][j] = r.Float64() - 0.5
		}
	}

	start := time.Now()

	CalculateLogDeterminantOf(n, a)

	elapsed := time.Since(start)
	fmt.Printf("Elapsed time = %e seconds\n", elapsed.Seconds())
}
