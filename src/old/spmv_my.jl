using BenchmarkTools 
using LinearAlgebra
using SparseArrays
using MtSpMV

include("MtSpMVBenchmarks.jl")
using .MtSpMVBenchmarks


BenchmarkTools.DEFAULT_PARAMETERS.samples = 1000 # 10000 by default
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1e10 # 5 by default


# Benchmark multithreaded CSR MatVec from MtSpMV.jl
function main(m::Int, n::Int, nnzrow::Int, kernel::String)

    # Get matrix and vectors
    None, None, A_csr, x, y = MtSpMVBenchmarks.rnd_mat_vec(m, n, nnzrow/m)

    # Print median benchmark time
    @mybtime mul!($y, $A_csr, $x)
    print()
    
end


# Run from command line
# ARGS[1]: number of matrix rows
# ARGS[2]: number of matrix columns
# ARGS[3]: number of nonzeros per row (approx.)
# ARGS[4]: kernel (irrelevant, always csr)
main(parse(Int, ARGS[1]), parse(Int, ARGS[2]), parse(Int, ARGS[3]), ARGS[4])

