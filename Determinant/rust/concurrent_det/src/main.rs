extern crate rand;

use rand::prelude::*;
use rand::rngs::StdRng;
use std::time::SystemTime;

const N: usize = 256;
const SEED: u64 = 256;

fn main() {
    let mut rng = StdRng::seed_from_u64(SEED);

    let mut a: [f64; N*N] = [0.0; N*N];
    for i in 0..N {
        for j in 0..N {
            a[i*N + j] = rng.gen();
        }
    }

    let start = SystemTime::now();

    let mut d: f64 = 1.0;
    for i in 0..N {
        d = d * a[i*N + i];
        for j in (i+1)..N {
            let z: f64 = a[j*N + i] / a[i*N + i];
            for k in (i+1)..N {
                let val = a[j*N + k] - z * a[i*N + k];
                a[j*N + k] = val;
            }
        }
    }

    println!("Determinant = {:e}", d.abs());
    match start.elapsed() {
        Ok(elapsed) => {
            let s = elapsed.as_secs() as f64 + elapsed.subsec_nanos() as f64 * 1e-9;
            println!("Elapsed time = {:e} seconds", s);
        },
        Err(e) => println!("Error: {:?}", e),
    }
}
