package main

import (
    "flag"
    "fmt"
)

func Greet(comm_sz int, my_rank int) string {
    return fmt.Sprintf("Greetings from process %d of %d!", my_rank, comm_sz)
}

func GreetAndSend(comm_world chan string, comm_sz int, my_rank int) {
    greeting := Greet(comm_sz, my_rank)
    comm_world <- greeting
}

func main() {
    nthreads := flag.Int("n", 8, "max threads")
    flag.Parse()

    comm_sz := *nthreads
    my_rank := 0

    comm_world := make(chan string)

    for rank := 1; rank < comm_sz; rank++ {
        go GreetAndSend(comm_world, comm_sz, rank)
    }

    greeting := Greet(comm_sz, my_rank)
    fmt.Printf("%s\n", greeting)

    for rank := 1; rank < comm_sz; rank++ {
        greeting = <-comm_world
        fmt.Printf("%s\n", greeting)
    }
}

