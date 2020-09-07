using SparseArrays
using LinearAlgebra
using MKLSparse 
using BenchmarkTools

include("../MtSpMVBenchmarks.jl")


function main(m::Int, n::Int, nnzrow::Int)
	A, None, x, y = MtSpMVBenchmarks.rnd_mat_vec(m, n, nnzrow/m)
	print(ccall((:openblas_get_num_threads64_, Base.libblas_name), Cint, ()))
	@btime mul!($y, $A, $x)
	print()
end

main(parse(Int, ARGS[1]), parse(Int, ARGS[2]), parse(Int, ARGS[3]))

