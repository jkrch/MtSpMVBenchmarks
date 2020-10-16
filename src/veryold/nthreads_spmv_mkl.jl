using BenchmarkTools
using LinearAlgebra
using SparseArrays
using MKLSparse 

include("MtSpMVBenchmarks.jl")
include("output.jl")


BenchmarkTools.DEFAULT_PARAMETERS.samples = 1000 # 10000 by default
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1e10 # 5 by default


# Print number of threads and btime for mkl csr matvec
function csr(m::Int, n::Int, nnzrow::Int)
    
    # Get matrix and vectors
	None, Trans, None, x, y = MtSpMVBenchmarks.rnd_mat_vec(m, n, nnzrow/m)
		
	# Benchmark mkl csr
	print(ccall((:mkl_get_max_threads, "libmkl_rt"), Int32, ()))
	@mybtime mul!($y, $Trans, $x)
	print()
	
end


# Print number of threads and btime for mkl csc matvec
function csc(m::Int, n::Int, nnzrow::Int)

	# Get matrix and vectors
	A_csc, None, None, x, y = MtSpMVBenchmarks.rnd_mat_vec(m, n, nnzrow/m)
	
	# Benchmark mkl csc
	print(ccall((:mkl_get_max_threads, "libmkl_rt"), Int32, ()))
	@mybtime mul!($y, $A_csc, $x)
	print()
	
end   

    
# Run csr or csc
function run(m::Int, n::Int, nnzrow::Int, kernel::String)

    if kernel == "csr"
        csr(m, n, nnzrow)
    end

    if kernel == "csc"
        csc(m, n, nnzrow)
    end
             
end


# Run from command line
# ARGS[1]: number of matrix rows
# ARGS[2]: number of matrix columns
# ARGS[3]: number of nonzeros per row (approx.)
# ARGS[4]: kernel (csr or csc)
run(parse(Int, ARGS[1]), parse(Int, ARGS[2]), parse(Int, ARGS[3]), ARGS[4])

