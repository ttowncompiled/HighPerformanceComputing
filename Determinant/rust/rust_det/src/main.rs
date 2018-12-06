extern crate rand;

use rand::prelude::*;
use rand::rngs::StdRng;
use std::env;
use std::sync::Arc;
use std::thread;
use std::thread::JoinHandle;
use std::time::SystemTime;

const N: usize = 256;

#[allow(non_snake_case)]
fn CalculateLogDeterminantOf(n: i64, a: Vec<Arc<Vec<f64>>>) {
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
}

fn main() {
    let args: Vec<String> = env::args().collect();
    let n: i64 = *(&args[1].parse::<i64>().unwrap());
    let seed: u64 = *(&args[2].parse::<u64>().unwrap());

    let mut rng: StdRng = StdRng::seed_from_u64(seed);

    let mut a: Vec<Arc<Vec<f64>>> = Vec::new();
    for _ in 0..n {
        a.push(Arc::new(
            (0..n).map(|_| {
                rng.gen::<f64>()
            }).collect()
        ));
    }

    let start = SystemTime::now();

    CalculateLogDeterminantOf(n, a);

    match start.elapsed() {
        Ok(elapsed) => {
            let s = elapsed.as_secs() as f64 + elapsed.subsec_nanos() as f64 * 1e-9;
            println!("Elapsed time = {:e} seconds", s);
        },
        Err(e) => println!("Error: {:?}", e),
    }
}
