using Distributed
using Printf

const n = 1024
const a = 0.0
const b = 100.0

const comm_sz = length(workers())+1
const comm_world = RemoteChannel(()->Channel{Float64}(comm_sz))

@everywhere f(x) = 10*x

@everywhere function Trap(my_rank, comm_sz, comm, n, a, b)
    h = (b-a)/n
    
    local_n = n/comm_sz
    local_a = a + (my_rank-1)*local_n*h
    local_b = local_a + local_n*h
    
    local_int = ( f(local_a) + f(local_b) )/2
    for i in 1:(local_n-1)
        x = local_a + i*h
        local_int += f(x)
    end
    local_int *= h

    put!(comm, local_int)
end

function main()
    my_rank = 1

    Trap(my_rank, comm_sz, comm_world, n, a, b)
    for rank in workers()
        remote_do(Trap, rank, rank, comm_sz, comm_world, n, a, b)
    end

    total_int = 0.0
    for p in 1:comm_sz
        local_int = take!(comm_world)
        total_int += local_int
    end

    @printf "With n = %d trapezoids, our estimate\n" n
    @printf "of the integral from %.2f to %.2f = %.15e\n" a b total_int
end

main()

