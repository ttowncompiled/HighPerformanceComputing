import kotlinx.coroutines.*
import kotlin.math.sqrt
import kotlin.system.measureNanoTime

val DIMS: Int = 2
val G: Double = 6.673e-11

fun Do(n: Int, masses: DoubleArray, s: Array<DoubleArray>, v: Array<DoubleArray>, f: Array<DoubleArray>, steps: Int) {
    for (t in 0..steps) {
        runBlocking {
            for (q in 0 until n) {
                launch {
                    for (d in 0 until DIMS) {
                        f[q][d] = 0.0
                    }
                    for (k in 0 until n) {
                        if (k == q) {
                            continue
                        }
                        var diff: DoubleArray = DoubleArray(DIMS, { 0.0 })
                        var dist: Double = 0.0
                        for (d in 0 until DIMS) {
                            diff[d] = s[k][d] - s[q][d]
                            dist += diff[d]*diff[d]
                        }
                        dist = sqrt(dist)
                        val dist_cubed: Double = dist*dist*dist
                        for (d in 0 until DIMS) {
                            f[q][d] += G*masses[q]*masses[k]/dist_cubed * diff[d]
                        }
                    }
                }
            }
        }
        for (q in 0 until n) {
            for (d in 0 until DIMS) {
                s[q][d] += v[q][d]
                v[q][d] += f[q][d] / masses[q]
            }
        }
    }
    for (q in 0 until n) {
        for (d in 0 until DIMS) {
            print("s[%d][%d] = %e\n".format(q, d, s[q][d]))
        }
        for (d in 0 until DIMS) {
            print("v[%d][%d] = %e\n".format(q, d, v[q][d]))
        }
        print("\n")
    }
}

fun main(args: Array<String>) {
    val n: Int = args[0].toInt()
    val steps: Int = args[1].toInt()

    val mass: Double = 5.0e24
    val gap: Double = 1.0e5
    val speed: Double = 3.0e4

    val masses: DoubleArray = DoubleArray(n, { mass })
    var s: Array<DoubleArray> = Array(n, { DoubleArray(DIMS, { 0.0 }) })
    var v: Array<DoubleArray> = Array(n, { DoubleArray(DIMS, { 0.0 }) })
    var f: Array<DoubleArray> = Array(n, { DoubleArray(DIMS, { 0.0 }) })

    for (q in 0 until n) {
        s[q][0] = q * gap
        for (d in 1 until DIMS) {
            s[q][d] = 0.0
        }
        v[q][0] = 0.0
        for (d in 1 until DIMS) {
            if (q % 2 == 0) {
                v[q][d] = speed
            } else {
                v[q][d] = -speed
            }
        }
        for (d in 0 until DIMS) {
            f[q][d] = 0.0
        }
    }

    val elapsed = measureNanoTime {
        Do(n, masses, s, v, f, steps)
    }

    println("Elapsed time = %e seconds".format(elapsed.toDouble() / 1.0e9))
}