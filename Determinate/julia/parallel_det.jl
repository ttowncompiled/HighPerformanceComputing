using Distributed
@everywhere using Printf
using Random

const N = 256
const SEED = 256

@everywhere function Determinate(a, n)
    d = 1.0
    for i in 1:n
        d = d * a[i, i]
        for j in (i+1):n
            z = a[j, i] / a[i, i]
            for k in (i+1):n
                a[j, k] = a[j, k] - z * a[i, k]
            end
        end
    end
    d
end

@everywhere function Compact(my_rank, comm_sz, a, n)
    local_det = 0.0
    local_a = Array{Float64}(undef, n-1, n-1)
    for k in my_rank:comm_sz:n
        z = a[1, k]
        for i in 2:n
            for j in 1:(k-1)
                local_a[i-1, j] = a[i, j]
            end
        end
        for i in 2:n
            for j in (k+1):n
                local_a[i-1, j-1] = a[i, j]
            end
        end
        d = Determinate(local_a, n-1)
        local_det = local_det + (z * d * if (k % 2 == 1) 1 else -1 end)
    end
    local_det
end

@everywhere function Work!(comm, my_rank, comm_sz, a, n)
    local_det = Compact(my_rank, comm_sz, a, n)
    put!(comm, local_det)
end

function main()
    comm_sz = length(workers())+1
    my_rank = 1
    comm_world = RemoteChannel(()->Channel{Float64}(N))

    Random.seed!(SEED)
    a = rand(N, N)

    for rank in workers()
        remote_do(Work!, rank, comm_world, rank, comm_sz, a, N)
    end

    det = Compact(my_rank, comm_sz, a, N)
    for _ in 2:comm_sz
        local_det = take!(comm_world)
        det = det + local_det
    end

    det = abs(det)
    @printf "Determinate = %e\n" det

end

main()
