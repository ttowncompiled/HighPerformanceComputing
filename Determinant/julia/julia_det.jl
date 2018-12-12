import MPI
using Printf
using Random

function ComputeLogTrace(my_rank::Int64, comm_sz::Int64, n::Int64, local_n::Int64, local_a::Vector{Array{Float64}})
    a_i::Array{Float64} = Array{Float64}(undef, n)
    for i in 1:n
        if (i-1) % comm_sz == my_rank
            for j in 1:n
                a_i[j] = local_a[convert(Int64, ceil(i / comm_sz))][j]
            end
            for rank in 0:(comm_sz-1)
                if rank == my_rank
                    continue
                end
                MPI.Send(a_i, rank, 0, MPI.COMM_WORLD)
            end
        else
            MPI.Recv!(a_i, (i-1) % comm_sz, 0, MPI.COMM_WORLD)
        end
        for j in (i+1):n
            if (j-1) % comm_sz == my_rank
                z::Float64 = local_a[convert(Int64, ceil(j / comm_sz))][i] / a_i[i]
                for k in (i+1):n
                    local_a[convert(Int64, ceil(j / comm_sz))][k] -= z * a_i[k]
                end
            end
        end
    end

    local_det::Float64 = 0.0
    for i in 1:local_n
        local_det += log(abs(local_a[i][(i-1) * comm_sz + my_rank + 1]))
    end

    if my_rank == 0
        det::Float64 = local_det
        recv_det::Array{Float64} = Array{Float64}(undef, 1)
        for rank in 1:(comm_sz-1)
            MPI.Recv!(recv_det, rank, 0, MPI.COMM_WORLD)
            det += recv_det[1]
        end
        @printf "log(abs(det)) = %e\n" det
    else
        MPI.Send(local_det, 0, 0, MPI.COMM_WORLD)
    end
end

function SyncRows(my_rank::Int64, comm_sz::Int64, n::Int64, a::Array{Float64, 2})
    local_n::Int64 = floor(n / comm_sz)
    local_a::Vector{Array{Float64}} = []
    for i in 1:n
        if (i-1) % comm_sz == my_rank
            push!(local_a, a[i, 1:n])
        else
            MPI.Send(a[i, 1:n], (i-1) % comm_sz, 0, MPI.COMM_WORLD)
        end
    end

    ComputeLogTrace(my_rank, comm_sz, n, local_n, local_a)
end

function SyncRowsRemote(my_rank::Int64, comm_sz::Int64, n::Int64)
    local_n::Int64 = floor(n / comm_sz)
    local_a::Vector{Array{Float64}} = []
    for i in 1:local_n
        local_a_i::Array{Float64} = Array{Float64}(undef, n)
        MPI.Recv!(local_a_i, 0, 0, MPI.COMM_WORLD)
        push!(local_a, local_a_i)
    end

    ComputeLogTrace(my_rank, comm_sz, n, local_n, local_a)
end

function main()
    n::Int64 = parse(Int64, ARGS[1])
    seed::Int64 = parse(Int64, ARGS[2])

    MPI.Init()
    comm_sz::Int64 = MPI.Comm_size(MPI.COMM_WORLD)
    my_rank::Int64 = MPI.Comm_rank(MPI.COMM_WORLD)

    @printf "my_rank=%d, comm_sz=%d, n=%d, seed=%d\n" my_rank comm_sz n seed

    MPI.Barrier(MPI.COMM_WORLD)

    if my_rank == 0
        Random.seed!(seed)
        a::Array{Float64, 2} = rand(n, n) .- 0.5
        @time SyncRows(my_rank, comm_sz, n, a)
    else
        SyncRowsRemote(my_rank, comm_sz, n)
    end

    MPI.Barrier(MPI.COMM_WORLD)

    MPI.Finalize()
end

main()
