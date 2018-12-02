extern crate rand;

use rand::prelude::*;
use rand::rngs::StdRng;

const N: usize = 3;
const A_MAX: i32 = 10;
const SEED: u64 = 256;
const FLT_MAX: f64 = 3.402823e+38;

fn main() {
    let mut rng = StdRng::seed_from_u64(SEED);

    let mut a: [f64; N*N] = [0.0; N*N];
    for i in 0..N {
        for j in 0..N {
            a[i*N + j] = (rng.gen_range(0, A_MAX)+1).into();
        }
    }

    let mut d: f64 = 1.0;
    for i in 0..N {
        d = (d * (a[i*N + i] % FLT_MAX)) % FLT_MAX;
        for j in (i+1)..N {
            let z: f64 = a[j*N + i] / a[i*N + i];
            for k in (i+1)..N {
                let val = a[j*N + k] - z * a[i*N + k];
                a[j*N + k] = val;
            }
        }
    }

    println!("Determinant = {:e}", d.abs());
}
