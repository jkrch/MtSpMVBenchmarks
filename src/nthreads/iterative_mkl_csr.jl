using SparseArrays
using MKLSparse
using IterativeSolvers
using BenchmarkTools

include("../MtSpMVBenchmarks.jl")


function main(n, linsys)
    if linsys=="fdm2d"
        linsysfunc = BenchmarkIterative.fdm2d
        solver = cg
    elseif linsys=="fdm3d"
        linsysfunc = BenchmarkIterative.fdm3d
        solver = cg
    elseif linsys=="fem2d"
        linsysfunc = BenchmarkIterative.fem2d
        solver = gmres
    end
    A_csc, None, None, b = linsysfunc(n)
    A_csc = transpose(sparse(transpose(A)))
    print(ccall((:openblas_get_num_threads64_, Base.libblas_name), Cint, ()))
    @btime $solver($A_csc, $b)
    print()
end

main(parse(Int, ARGS[1]), ARGS[2])

