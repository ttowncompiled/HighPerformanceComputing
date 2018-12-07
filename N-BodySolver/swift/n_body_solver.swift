import Dispatch
import Foundation

let DIMS: Int = 2
let G: Double = 6.673e-11

func Do(_ n: Int, _ masses: [Double], _ s0: [[Double]], _ v0: [[Double]], _ f0: [[Double]], _ steps: Int) {
    var s = s0
    var v = v0
    let f: UnsafeMutablePointer<Double> = UnsafeMutablePointer<Double>.allocate(capacity: n*DIMS)
    f.initialize(repeating: 0.0, count: n*DIMS)
    for _ in 0...steps {
        let group: DispatchGroup = DispatchGroup()
        for q in 0..<n {
            group.enter()
            DispatchQueue.global(qos: .background).async {
                for d in 0..<DIMS {
                    (f + q*DIMS + d).pointee = 0.0
                }
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
                        (f + q*DIMS + d).pointee += G*masses[q]*masses[k]/dist_cubed * diff[d]
                    }
                }
                group.leave()
            }
        }
        group.wait()
        for q in 0..<n {
            for d in 0..<DIMS {
                s[q][d] += v[q][d]
                v[q][d] += (f + q*DIMS + d).pointee / masses[q]
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
    f.deallocate()
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
    let f: [[Double]] = Array(repeating: Array(repeating: 0.0, count: DIMS), count: n)

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

    Do(n, masses, s, v, f, steps)

    let finish: DispatchTime = DispatchTime.now()
    let elapsed: Double = Double(finish.uptimeNanoseconds - start.uptimeNanoseconds) / 1.0e9
    print(String(format: "Elapsed time = %e seconds", elapsed))
}

main()
