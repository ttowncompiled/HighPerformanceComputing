package main

import (
	"fmt"
	"math"
	"math/rand"
)

const N int = 256
const A_MAX int = 10
const SEED int64 = 256
const FLT_MAX float64 = 3.402823e+38

func main() {
	s := rand.NewSource(SEED)
	r := rand.New(s)
	var a[N][N]float64
	for i := 0; i < N; i++ {
		for j := 0; j < N; j++ {
			a[i][j] = float64(r.Intn(A_MAX)+1)
		}
	}
	d := 1.0
	for i := 0; i < N; i++ {
		d = math.Mod(d * math.Mod(a[i][i], FLT_MAX), FLT_MAX)
		for j := i+1; j < N; j++ {
			z := a[j][i] / a[i][i]
			for k := i+1; k < N; k++ {
				a[j][k] = a[j][k] - z * a[i][k]
			}
		}
	}
	fmt.Printf("Determinant = %e\n", d)
}
