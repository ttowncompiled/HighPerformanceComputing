using Distributed
@everywhere using Printf

@everywhere function Greet(comm_sz, my_rank)
    @sprintf "Greetings from process %d of %d" my_rank comm_sz      #= return =#
end

@everywhere function Greet!(comm, comm_sz, my_rank)
    greeting = Greet(comm_sz, my_rank)
    put!(comm, greeting)
end

function main()
    comm_sz = length(workers())+1
    my_rank = 1
    comm_world = RemoteChannel(()->Channel{String}(comm_sz))

    for rank in workers()
        remote_do(Greet!, rank, comm_world, comm_sz, rank)
    end

    greeting = Greet(comm_sz, my_rank)
    @printf "%s\n" greeting

    for _ in 2:comm_sz
        greeting = take!(comm_world)
        @printf "%s\n" greeting
    end
end

main()

