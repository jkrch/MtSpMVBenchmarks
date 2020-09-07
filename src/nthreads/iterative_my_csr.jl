using MtSpMV
using IterativeSolvers
using BenchmarkTools

include("../MtSpMVBenchmarks.jl")


function main(n, linsys)
    if linsys=="fdm2d"
        linsysfunc = MtSpMVBenchmarks.fdm2d
        solver = cg
    elseif linsys=="fdm3d"
        linsysfunc = MtSpMVBenchmarks.fdm3d
        solver = cg
    elseif linsys=="fem2d"
        linsysfunc = MtSpMVBenchmarks.fem2d
        solver = gmres
    end
    None, A_csr, b, None = linsysfunc(n)
    print(Threads.nthreads())
    @btime $solver($A_csr, $b)
    print()
end

main(parse(Int, ARGS[1]), ARGS[2])

