use std::env;
use std::sync::mpsc;
use std::thread;

#[allow(non_snake_case)]
fn Greet(comm_sz: i32, my_rank: i32) -> String {
    format!("Greetings from process {} of {}!", my_rank, comm_sz) // return //
}

fn main() {
    let args: Vec<String> = env::args().collect();

    let comm_sz = *(&args[2].parse::<i32>().unwrap());
    let my_rank = 0;

    let (tx, rx) = mpsc::channel();

    for rank in 1..comm_sz {
        let tx_clone = mpsc::Sender::clone(&tx);
        thread::spawn(move || {
            let greeting = Greet(comm_sz, rank);
            tx_clone.send(greeting).unwrap();
        });
    }

    let greeting = Greet(comm_sz, my_rank);
    println!("{}", greeting);

    for _ in 1..comm_sz {
        let greeting = rx.recv().unwrap();
        println!("{}", greeting);
    }
}

