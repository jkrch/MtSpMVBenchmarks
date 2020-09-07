using MtSpMV
using BenchmarkTools 

include("../MtSpMVBenchmarks.jl")

function main(m, n, nnzrow)
    None, A, x, y = MtSpMVBenchmarks.rnd_mat_vec(m, n, nnzrow/m)
    print(Threads.nthreads())
    @btime MtSpMV.mul!($y, $A, $x)
    print()
end

main(parse(Int, ARGS[1]), parse(Int, ARGS[2]), parse(Int, ARGS[3]))

