extern crate rand;

use rand::prelude::*;
use rand::rngs::StdRng;
use std::env;
use std::sync::Arc;
use std::thread;
use std::thread::JoinHandle;
use std::time::SystemTime;

#[allow(non_snake_case)]
fn ThreadWork(handles: &mut Vec<JoinHandle<()>>, i: usize, n: usize, a_i: Arc<Vec<f64>>, a_j: Arc<Vec<f64>>) {
    let handle: JoinHandle<_> = thread::spawn(move || {
        match Arc::get_mut(&mut a_j.clone()) {
            Some(ref mut a_j) => {
                let z: f64 = a_j[i] / a_i[i];
                for k in (i+1)..n {
                    a_j[k] -= z * a_i[k];
                }
            },
            None => (),
        }
    });
    handles.push(handle);
}

#[allow(non_snake_case)]
fn CalculateLogDeterminantOf(n: usize, a: Vec<Arc<Vec<f64>>>) {
    let mut handles: Vec<JoinHandle<_>> = Vec::new();
    let mut log_d: f64 = 0.0;
    for i in 0..n {
        log_d += a[i][i].abs().log2();
        for j in (i+1)..n {
            ThreadWork(&mut handles, i, n, a[i].clone(), a[j].clone());
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

    println!("log(abs(det)) = {:e}", log_d);
}

fn main() {
    let args: Vec<String> = env::args().collect();
    let n: usize = *(&args[1].parse::<usize>().unwrap());
    let seed: u64 = *(&args[2].parse::<u64>().unwrap());

    let mut rng: StdRng = StdRng::seed_from_u64(seed);

    let mut a: Vec<Arc<Vec<f64>>> = Vec::new();
    for _ in 0..n {
        a.push(Arc::new(
            (0..n).map(|_| {
                rng.gen::<f64>() - 0.5
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
