use std::env;
use std::sync::mpsc;
use std::thread;

const N: usize = 1024;
const K: f64 = 2.0;

#[allow(non_snake_case)]
fn DotProduct(n: usize,     /* in */
              k: f64,       /* in */
              x: &[f64],    /* in */
              y: &[f64],    /* in */
              z: &mut[f64]  /* out */) {
    for i in 0..n {
        z[i] = (x[i] + y[i]) * k;
    }
}

fn main() {
    let mut x: [f64; N];
    let mut y: [f64; N];
    let mut z: [f64; N];

    let local_n: usize;
    let _local_x: &[f64];
    let _local_y: &[f64];
    let mut local_z: Vec<f64>;

    let comm_sz: i32;
    let _my_rank: i32;

    let args: Vec<String> = env::args().collect();

    comm_sz = *(&args[2].parse::<i32>().unwrap());
    _my_rank = 0;
    let (comm_world_tx, comm_world_rx) = mpsc::channel();

    x = [0.0; N];
    for i in 0..N {
        x[i] = (i as f64) + 1.0;
    }
    y = [0.0; N];
    for j in 0..N {
        y[j] = (j as f64) + 1.0;
    }
    z = [0.0; N];

    local_n = N/(comm_sz as usize);

    for rank in 1..comm_sz {
        let comm_world_tx_clone = mpsc::Sender::clone(&comm_world_tx);
        thread::spawn(move || {
            let local_a = (rank as usize) * local_n;
            let local_b = (local_a as usize) + local_n;
            let local_x = &x[local_a..local_b];
            let local_y = &y[local_a..local_b];

            let mut local_z = vec![0.0; local_n];
            DotProduct(local_n, K, local_x, local_y, &mut local_z);

            comm_world_tx_clone.send((rank, local_z)).unwrap();
        });
    }

    local_z = vec![0.0; local_n];
    DotProduct(local_n, K, &x[0..local_n], &y[0..local_n], &mut local_z);
    for m in 0..local_n {
        z[m] = local_z[m];
    }

    for _ in 1..comm_sz {
        let (rank, local_z) = comm_world_rx.recv().unwrap();
        let local_a = rank*(local_n as i32);
        for m in 0..local_n {
            z[(local_a as usize)+m] = local_z[m];
        }
    }

    for m in 0..N {
        print!("{:.2} ", z[m]);
    }
    print!("\n");
}

