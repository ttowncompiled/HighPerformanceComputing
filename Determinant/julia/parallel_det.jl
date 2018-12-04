using Distributed
@everywhere using Printf
using Random

@everywhere const N = 256
@everywhere const SEED = 256

@everywhere function CalculateDeterminantOf(a)
    d = 1.0
    for i in 1:(N-1)
        d = d * a[i, i]
        for j in (i+1):(N-1)
            z = a[j, i] / a[i, i]
            for k in (i+1):(N-1)
                a[j, k] -= (z * a[i, k])
            end
        end
    end
    d
end

@everywhere function CalculateDeterminantOfAfterCompacting(my_rank, comm_sz, a)
    local_det = 0.0
    local_a = Array{Float64}(undef, N-1, N-1)
    for k in my_rank:comm_sz:N
        z = a[1, k]
        for i in 2:N
            for j in 1:(k-1)
                local_a[i-1, j] = a[i, j]
            end
        end
        for i in 2:N
            for j in (k+1):N
                local_a[i-1, j-1] = a[i, j]
            end
        end
        d = CalculateDeterminantOf(local_a)
        local_det += (z * d * (if (k % 2 == 1) 1 else -1 end))
    end
    local_det
end

@everywhere function RemoteCalculateDeterminantOfAfterCompacting(comm, my_rank, comm_sz, a)
    local_det = CalculateDeterminantOfAfterCompacting(my_rank, comm_sz, a)
    put!(comm, local_det)
end

function Do(comm_world, my_rank, comm_sz, a)
    for rank in workers()
        remote_do(RemoteCalculateDeterminantOfAfterCompacting, rank, comm_world, rank, comm_sz, a)
    end

    det = CalculateDeterminantOfAfterCompacting(my_rank, comm_sz, a)
    for _ in 2:comm_sz
        local_det = take!(comm_world)
        det += local_det
    end

    det = abs(det)
    @printf "Determinant = %e\n" det
end

function main()
    comm_sz = length(workers())+1
    my_rank = 1
    comm_world = RemoteChannel(()->Channel{Float64}(N))

    Random.seed!(SEED)
    a = rand(N, N)

    @time Do(comm_world, my_rank, comm_sz, a)
end

main()
