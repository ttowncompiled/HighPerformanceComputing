using Distributed
@everywhere using Printf

const comm_sz = length(workers())+1
const comm_world = RemoteChannel(()->Channel{String}(comm_sz))

@everywhere function Greet(comm, comm_sz, my_rank)
    greeting = @sprintf "Greetings from process %d of %d" my_rank comm_sz
    put!(comm, greeting)
end

function main()
    my_rank = 1

    Greet(comm_world, comm_sz, my_rank)
    for rank in workers()
        remote_do(Greet, rank, comm_world, comm_sz, rank)
    end

    for p in 1:comm_sz
        greeting = take!(comm_world)
        @printf "%s\n" greeting
    end
end

main()

