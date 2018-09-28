fun Greet(comm_sz: Int, my_rank: Int): String {
    return "Greetings from process ${my_rank} of ${comm_sz}!"
}
fun main(args: Array<String>) {
    var greeting: String

    var comm_sz: Int
    var my_rank: Int

    comm_sz = args[1].toInt()
    my_rank = 0

    greeting = Greet(comm_sz, my_rank)

    println(greeting)
}
