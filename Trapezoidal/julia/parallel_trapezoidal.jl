using Distributed
@everywhere using Printf

const N = 1024
const A = 0.0
const B = 100.0

@everywhere f(x) = 10*x     #= return =#

@everywhere function Trap(comm_sz, my_rank, n, a, b)
    h = (b-a)/n

    local_n = n/comm_sz
    local_a = a + (my_rank-1)*local_n*h
    local_b = local_a + local_n*h

    local_int = ( f(local_a) + f(local_b) )/2
    for i in 1:(local_n-1)
        x = local_a + i*h
        local_int += f(x)
    end
    local_int *= h      #= return =#
end

@everywhere function Trap!(comm, comm_sz, my_rank, n, a, b)
    local_int = Trap(comm_sz, my_rank, n, a, b)
    put!(comm, local_int)
end

function main()
    comm_sz = length(workers())+1
    my_rank = 1
    comm_world = RemoteChannel(()->Channel{Float64}(comm_sz))

    for rank in workers()
        remote_do(Trap!, rank, comm_world, comm_sz, rank, N, A, B)
    end

    total_int = Trap(comm_sz, my_rank, N, A, B)
    for _ in 2:comm_sz
        local_int = take!(comm_world)
        total_int += local_int
    end

    @printf "With n = %d trapezoids, our estimate\n" N
    @printf "of the integral from %.2f to %.2f = %.15e\n" A B total_int
end

main()

