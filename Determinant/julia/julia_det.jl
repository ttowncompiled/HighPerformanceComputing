import MPI
using Printf
using Random

function CalculateLogDeterminantOf(n, a)
    sign_d::Int64 = 1
    log_d::Float64 = 0.0

    d::Float64 = 1.0
    for i in 1:n
        if a[i, i] < 0
            sign_d = sign_d * -1
        end
        d *= a[i, i]
        for j in (i+1):n
            z::Float64 = a[j, i] / a[i, i]
            for k in (i+1):n
                a[j, k] -= (z * a[i, k])
            end
        end
        if i % 16 == 0
            log_d = log_d + log2(abs(d))
            d = 1.0
        end
    end

    sign_d, log_d + log2(abs(d))
end

function CalculateLogDeterminantOfAfterCompacting(my_rank, comm_sz, n, a)
    local_a::Array{Float64, 2} = Array{Float64}(undef, n-1, n-1)

    log_x_0::Float64 = -1.0
    log_y_0::Float64 = -1.0

    sum_x::Float64 = 0.0
    sum_y::Float64 = 0.0

    for k in (my_rank+1):comm_sz:n
        c_k::Float64 = a[k]
        for i in 2:n
            for j in 1:(k-1)
                local_a[i-1, j] = a[(i-1)*n + j]
            end
        end
        for i in 2:n
            for j in (k+1):n
                local_a[i-1, j-1] = a[(i-1)*n + j]
            end
        end

        sign_d::Int64, log_d::Float64 = CalculateLogDeterminantOf(n-1, local_a)
        if c_k < 0
            sign_d = sign_d * -1.0
        end
        if k % 2 == 0
            sign_d = sign_d * -1.0
        end
        log_d = log_d + log2(abs(c_k))

        if sign_d > 0
            if log_x_0 < 0
                log_x_0 = log_d
            else
                sum_x += 2^(log_d - log_x_0)
            end
        else
            if log_y_0 < 0
                log_y_0 = log_d
            else
                sum_y += 2^(log_d - log_y_0)
            end
        end
    end

    log_x::Float64 = log_x_0 + log2(1 + sum_x)
    log_y::Float64 = log_y_0 + log2(1 + sum_y)

    if log_x > log_y
        1, log_x + log2(1 - 2^(log_y - log_x))
    else
        -1, log_y + log2(1 - 2^(log_x - log_y))
    end
end

function Do(my_rank, comm_sz, n, a)
    if my_rank == 0
        for rank in 1:(comm_sz-1)
            MPI.Send(a, rank, 0, MPI.COMM_WORLD)
        end
    else
        MPI.Recv!(a, 0, 0, MPI.COMM_WORLD)
    end

    log_x_0::Float64 = -1.0
    log_y_0::Float64 = -1.0

    sum_x::Float64 = 0.0
    sum_y::Float64 = 0.0

    sign_det::Int64, local_det::Float64 = CalculateLogDeterminantOfAfterCompacting(my_rank, comm_sz, n, a)

    if sign_det > 0
        log_x_0 = local_det
    else
        log_y_0 = local_det
    end

    local_pair::Array{Float64} = Array{Float64}(undef, 2)

    if my_rank == 0
        for rank in 1:(comm_sz-1)
            MPI.Recv!(local_pair, rank, 0, MPI.COMM_WORLD)
            if local_pair[1] > 0
                if log_x_0 < 0
                    log_x_0 = local_pair[2]
                else
                    sum_x += 2^(local_pair[2] - log_x_0)
                end
            else
                if log_y_0 < 0
                    log_y_0 = local_pair[2]
                else
                    sum_y += 2^(local_pair[2] - log_y_0)
                end
            end
        end

        log_x::Float64 = log_x_0 + log2(1 + sum_x)
        log_y::Float64 = log_y_0 + log2(1 + sum_y)

        det::Float64 = if log_x > log_y
                log_x + log2(1 - 2^(log_y - log_x))
            else
                log_y + log2(1 - 2^(log_x - log_y))
            end

        det = det / log2(exp(1))
        @printf "log(abs(det)) = %e\n" det
    else
        local_pair[1] = convert(Float64, sign_det)
        local_pair[2] = local_det
        MPI.Send(local_pair, 0, 0, MPI.COMM_WORLD)
    end
end

function main()
    n::Int64 = parse(Int64, ARGS[1])
    seed::Int64 = parse(Int64, ARGS[2])

    MPI.Init()
    comm_sz::Int64 = MPI.Comm_size(MPI.COMM_WORLD)
    my_rank::Int64 = MPI.Comm_rank(MPI.COMM_WORLD)

    @printf "my_rank=%d, comm_sz=%d, n=%d, seed=%d\n" my_rank comm_sz n seed

    a::Array{Float64} = if my_rank == 0
            Random.seed!(seed)
            rand(n*n) .- 0.5
        else
            Array{Float64}(undef, n*n)
        end

    MPI.Barrier(MPI.COMM_WORLD)

    if my_rank == 0
        @time Do(my_rank, comm_sz, n, a)
    else
        Do(my_rank, comm_sz, n, a)
    end

    MPI.Barrier(MPI.COMM_WORLD)

    MPI.Finalize()
end

main()
