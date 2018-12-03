extern crate rand;

use rand::prelude::*;
use rand::rngs::StdRng;
use std::sync::Arc;
use std::thread;
use std::thread::JoinHandle;
use std::time::SystemTime;

const N: usize = 256;
const SEED: u64 = 256;

fn main() {
    let mut rng = StdRng::seed_from_u64(SEED);

    let mut a: Vec<Arc<Vec<f64>>> = Vec::new();
    for _ in 0..N {
        a.push(Arc::new(
            (0..N).map(|_| {
                rng.gen()
            }).collect()
        ));
    }

    let start = SystemTime::now();

    let mut handles: Vec<JoinHandle<_>> = Vec::new();

    let mut d: f64 = 1.0;
    for i in 0..N {
        d = d * a[i][i];
        for j in (i+1)..N {
            let a_i = a[i].clone();
            let a_j = a[j].clone();
            let handle: JoinHandle<_> = thread::spawn(move || {
                match Arc::get_mut(&mut a_j.clone()) {
                    Some(ref mut a_j) => {
                        let z: f64 = a_j[i] / a_i[i];
                        for k in (i+1)..N {
                            let val = a_j[k] - z * a_i[k];
                            a_j[k] = val;
                        }
                    },
                    None => (),
                }
            });
            handles.push(handle);
        }
        while ! handles.is_empty() {
            match handles.pop() {
                Some(handle) => {
                    match handle.join() {
                        Ok(_) => (),
                        Err(e) => println!("Error: {:?}", e),
                    }
                },
                None => (),
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
