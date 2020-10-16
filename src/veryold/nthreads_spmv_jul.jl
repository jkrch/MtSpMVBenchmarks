using BenchmarkTools 
using LinearAlgebra
using SparseArrays
using MtSpMV

include("MtSpMVBenchmarks.jl")
include("output.jl")


BenchmarkTools.DEFAULT_PARAMETERS.samples = 1000 # 10000 by default
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1e10 # 5 by default


# Print title for plot, number of threads and btimes with serial csc and csr matvec
function ser(m::Int, n::Int, nnzrow::Int)
    
    # Print first line of the plot title
    println("Multithreaded SpMV")
    
    # Get matrix and vectors
    A_csc, Trans, None, x, y = MtSpMVBenchmarks.rnd_mat_vec(m, n, nnzrow/m)
    
    # Print properties of the matrix for second line of the plot title
    println("m=", A_csc.m, ", n=", A_csc.n, ", nnz=", length(A_csc.nzval))
    println()
    
    # Benchmark builtin csr
    println("SparseArrays.jl CSR")
    print("1")
    @mybtime mul!($y, $Trans, $x)
    println()
    
    # Benchmark builtin csc
    println("SparseArrays.jl CSC")
    print("1")
    @mybtime mul!($y, $A_csc, $x)
    println()
    
end


# Print number of threads and btime with multithreaded csr matvec
function par(m::Int, n::Int, nnzrow::Int)

    # Get matrix and vectors
    None, None, A_csr, x, y = MtSpMVBenchmarks.rnd_mat_vec(m, n, nnzrow/m)
    
    # Benchmark my csr
    print(Threads.nthreads())
    @mybtime MtSpMV.mul!($y, $A_csr, $x)
    print()
    
end


# Run serial or csr
function run(m::Int, n::Int, nnzrow::Int, kernel::String)

    if kernel == "ser"
        ser(m, n, nnzrow)
    end

    if kernel == "par"
        par(m, n, nnzrow)
    end

end


# Run from command line
# ARGS[1]: number of matrix rows
# ARGS[2]: number of matrix columns
# ARGS[3]: number of nonzeros per row (approx.)
# ARGS[4]: kernel (ser or par)
run(parse(Int, ARGS[1]), parse(Int, ARGS[2]), parse(Int, ARGS[3]), ARGS[4])

