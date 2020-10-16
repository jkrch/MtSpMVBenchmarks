using BenchmarkTools 
using LinearAlgebra
using SparseArrays

include("MtSpMVBenchmarks.jl")
using .MtSpMVBenchmarks


BenchmarkTools.DEFAULT_PARAMETERS.samples = 1000 # 10000 by default
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1e10 # 5 by default


# Benchmark serial CSR or CSC MatVec from MKLSparse.jl
function main(m::Int, n::Int, nnzrow::Int, kernel::String)

    # Get matrix and vectors
    A_csc, Trans, None, x, y = MtSpMVBenchmarks.rnd_mat_vec(m, n, nnzrow/m)
    
    # Print matrix properties
    if kernel == "prop"
        println("m=", A_csc.m, ", n=", A_csc.n, ", nnz=", length(A_csc.nzval))
    end
    
    # Print median benchmark time for CSR
    if kernel == "csr"
        @mybtime mul!($y, $Trans, $x)
        print()
    end
  
    # Print median benchmark time for CSR
    if kernel == "csc"
        @mybtime mul!($y, $A_csc, $x)
        print()
    end
    
end


# Run from command line
# ARGS[1]: number of matrix rows
# ARGS[2]: number of matrix columns
# ARGS[3]: number of nonzeros per row (approx.)
# ARGS[4]: kernel (csr or csc)
main(parse(Int, ARGS[1]), parse(Int, ARGS[2]), parse(Int, ARGS[3]), ARGS[4])

