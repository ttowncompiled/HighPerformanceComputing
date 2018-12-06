import Dispatch
import Foundation

let DIMS: Int = 2
let G: Double = 6.673e-11

func Do(_ n: Int, _ masses: [Double], _ s: inout [[Double]], _ v: inout [[Double]], _ steps: Int) {
    for _ in 0...steps {
        for q in 0..<n {
            var force_q: [Double] = Array(repeating: 0.0, count: DIMS)
            for k in 0..<n {
                if k == q {
                    continue
                }
                var diff: [Double] = Array(repeating: 0.0, count: DIMS)
                var dist: Double = 0.0
                for d in 0..<DIMS {
                    diff[d] = s[k][d] - s[q][d]
                    dist += diff[d]*diff[d]
                }
                dist = sqrt(dist)
                let dist_cubed: Double = dist*dist*dist
                for d in 0..<DIMS {
                    force_q[d] += G*masses[q]*masses[k]/dist_cubed * diff[d]
                }
            }
            for d in 0..<DIMS {
                s[q][d] += v[q][d]
                v[q][d] += force_q[d] / masses[q]
            }
        }
    }
    for q in 0..<n {
        for d in 0..<DIMS {
            print(String(format: "s[%d][%d] = %e", q, d, s[q][d]))
        }
        for d in 0..<DIMS {
            print(String(format: "v[%d][%d] = %e", q, d, v[q][d]))
        }
        print()
    }
}

func main() {
    let n: Int = Int(CommandLine.arguments[1])!
    let steps: Int = Int(CommandLine.arguments[2])!

    let mass: Double = 5.0e24
    let gap: Double = 1.0e5
    let speed: Double = 3.0e4

    let masses: [Double] = Array(repeating: mass, count: n)
    var s: [[Double]] = Array(repeating: Array(repeating: 0.0, count: DIMS), count: n)
    var v: [[Double]] = Array(repeating: Array(repeating: 0.0, count: DIMS), count: n)

    for q in 0..<n {
        s[q][0] = Double(q) * gap
        for d in 1..<DIMS {
            s[q][d] = 0.0
        }
        v[q][0] = 0.0
        for d in 1..<DIMS {
            if q % 2 == 0 {
                v[q][d] = speed
            } else {
                v[q][d] = -speed
            }
        }
    }

    let start: DispatchTime = DispatchTime.now()

    Do(n, masses, &s, &v, steps)

    let finish: DispatchTime = DispatchTime.now()
    let elapsed: Double = Double(finish.uptimeNanoseconds - start.uptimeNanoseconds) / 1.0e9
    print(String(format: "Elapsed time = %e seconds", elapsed))
}

main()
