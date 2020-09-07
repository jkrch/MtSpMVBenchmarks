using SparseArrays
using MKLSparse
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
    A_csc, None, None, b = linsysfunc(n)
    print(ccall((:openblas_get_num_threads64_, Base.libblas_name), Cint, ()))
    @btime $solver($A_csc, $b)
    print()
end

main(parse(Int, ARGS[1]), ARGS[2])

