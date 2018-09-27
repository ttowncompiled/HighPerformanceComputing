use std::env;
use std::sync::mpsc;
use std::thread;

#[allow(non_snake_case)]
fn Greet(comm_sz: i32, my_rank: i32) -> String {
    format!("Greetings from process {} of {}!", my_rank, comm_sz) // return //
}

fn main() {
    let greeting: String;

    let comm_sz: i32;
    let my_rank: i32;

    let args: Vec<String> = env::args().collect();

    comm_sz = *(&args[2].parse::<i32>().unwrap());
    my_rank = 0;
    let (comm_world_tx, comm_world_rx) = mpsc::channel();

    for rank in 1..comm_sz {
        let comm_world_tx_clone = mpsc::Sender::clone(&comm_world_tx);
        thread::spawn(move || {
            let greeting = Greet(comm_sz, rank);
            comm_world_tx_clone.send(greeting).unwrap();
        });
    }

    greeting = Greet(comm_sz, my_rank);
    println!("{}", greeting);

    for _ in 1..comm_sz {
        let greeting = comm_world_rx.recv().unwrap();
        println!("{}", greeting);
    }
}

