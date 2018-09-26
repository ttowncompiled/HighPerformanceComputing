using Distributed

# a distributed greet function
@everywhere function greet(my_rank, comm_sz, comm)
    greeting = "Greetings from process $(my_rank) of $(comm_sz)!"
    put!(comm, greeting)
end

const my_rank = 1                                                   # the rank of the master process
const comm_sz = length(workers())+1                                 # the total number of processes
const comm_world = RemoteChannel(()->Channel{String}(comm_sz))      # the singleton communication channel

greet(my_rank, comm_sz, comm_world)
for rank in workers()
    remote_do(greet, rank, rank, comm_sz, comm_world)
end

for i in 1:comm_sz
    greeting = take!(comm_world)
    println(greeting)
end

