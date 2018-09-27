use std::env;
use std::sync::mpsc;
use std::thread;

const N: i32 = 1024;
const A: f64 = 0.0;
const B: f64 = 100.0;

fn f(x: f64) -> f64 {
    10.0*x    // return //
}

#[allow(non_snake_case)]
fn Trap(comm_sz: i32, my_rank: i32, n: i32, a: f64, b: f64) -> f64 {
    let h = (b-a)/(n as f64);
    let local_n = n/comm_sz;

    let local_a = a + ((my_rank*local_n) as f64)*h;
    let local_b = local_a + (local_n as f64)*h;

    let mut local_int = ( f(local_a) + f(local_b))/2.0;
    for i in 1..local_n {
        let x = local_a + (i as f64)*h;
        local_int += f(x);
    }
    local_int *= h;
    local_int      // return //
}

fn main() {
    let args: Vec<String> = env::args().collect();

    let comm_sz = *(&args[2].parse::<i32>().unwrap());
    let my_rank = 0;

    let (comm_world_tx, comm_world_rx) = mpsc::channel();

    for rank in 1..comm_sz {
        let comm_world_tx_clone = mpsc::Sender::clone(&comm_world_tx);
        thread::spawn(move || {
            let local_int = Trap(comm_sz, rank, N, A, B);
            comm_world_tx_clone.send(local_int).unwrap();
        });
    }

    let mut total_int = Trap(comm_sz, my_rank, N, A, B);
    for _ in 1..comm_sz {
        let local_int = comm_world_rx.recv().unwrap();
        total_int += local_int;
    }

    println!("With n = {} trapezoids, our estimate", N);
    println!("of the integral from {:.2} to {:.2} = {:.15e}", A, B, total_int);
}

