using Distributed
@everywhere using Printf

const N = 1024
const K = 2.0

@everywhere function DotProduct(x, y, k)
    (x .+ y) .* k   #= return =#
end

@everywhere function DotProduct!(comm, my_rank, x, y, k)
    local_z = DotProduct(x, y, k)
    put!(comm, (my_rank, local_z))
end

function main()
    comm_sz = length(workers())+1
    my_rank = 1

    comm_world = RemoteChannel(()->Channel{Tuple{Int32, Array{Float64}}}(comm_sz))

    x = [ x_i for x_i in 1:N ]
    y = [ y_j for y_j in 1:N ]
    z = [ 0 for z_m in 1:N ]

    local_n = convert(Int32, N/comm_sz)

    for rank in workers()
        local_a = 1 + (rank-1)*local_n
        local_b = local_a + local_n - 1
        local_x = x[local_a:local_b]
        local_y = y[local_a:local_b]
        remote_do(DotProduct!, rank, comm_world, rank, local_x, local_y, K)
    end

    local_z = DotProduct(x[1:local_n], y[1:local_n], K)
    for m in 1:local_n
        z[m] = local_z[m]
    end

    for _ in 2:comm_sz
        rank, local_z = take!(comm_world)
        local_a = (rank-1)*local_n
        for m in 1:local_n
            z[local_a+m] = local_z[m]
        end
    end

    for m in 1:N
        @printf "%.2f " z[m]
    end
    @printf "\n"

end

main()

