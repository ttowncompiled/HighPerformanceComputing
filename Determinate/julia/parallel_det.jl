using Distributed
@everywhere using Printf

@everywhere const FLT_MAX = 3.4028234664e+38

const N = 256
const A_MAX = 10
const SEED = 256

@everywhere function Determinate(a, n)
    d = 1.0
    for i in 1:n
        d = (d * (a[i][i] % FLT_MAX)) % FLT_MAX
        for j in (i+1):n
            z = a[j][i] / a[i][i]
            for k in (i+1):n
                a[j][k] = a[j][k] - z * a[i][k]
            end
        end
    end
    d
end

@everywhere function Compact(my_rank, comm_sz, a, n)
    local_a = Array{Float64}(undef, n-1, n-1)
    local_det = 0.0
    for k in my_rank:n:comm_sz
        z = a[1][k]
        for i in 2:N
            for j in 1:K
                local_a[i-1][j] = a[i][j]
            end
        end
        for i in (k+1):n
            for j in (k+1):n
                local_a[i-1][j-1] = a[i][j]
            end
        end
        d = Determinate(local_a, n-1)
        local_det = (local_det + (z * d * (if (k % 2 == 1) 1 else -1 end)) % FLT_MAX) % FLT_MAX
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
    comm_world = RemoteChannel(()->Channel{Float64}(comm_sz))

    srand(SEED)
    a = rand(1:A_MAX, N, N)

    for rank in wokers()
        remote_do(Work!, rank, comm_world, rank, comm_sz, a, N)
    end

    det = 0
    for _ in 2:comm_sz
        local_det = take!(comm_world)
        det = (det + local_det) % FLT_MAX
    end

    det = abs(det)
    @printf "Determinate = %e\n" det

end
