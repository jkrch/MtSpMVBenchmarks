using MtSpMV
using BenchmarkTools
using LinearAlgebra
using IterativeSolvers
using SparseArrays
using ExtendableSparse
using Random
using Suppressor
@suppress using MatrixDepot

include("myrand.jl")
include("utils.jl")
include("parameters.jl")


# Benchmark Sparse matrix-vector product
# Prints median benchmark time
function spmv(transA::Transpose{<:Any,<:SparseMatrixCSC}, x::StridedVector)
	y = zeros(length(x))
    @benchmed mul!($y, $transA, $x)
end


# Benchmark iterative solvers from IterativeSolvers.jl
# Prints median benchmark time
function iter(transA::Transpose{<:Any,<:SparseMatrixCSC}, b::StridedVector, solver::Function)
	@benchmed $solver($transA, $b)
end


# Run benchmark from command line
# TODO: Use ArgParse.jl
function run()

	# Get command line arguments
	format = ARGS[1]
	solver = ARGS[2]
	matrix = ARGS[3]
	if matrix == "sprand"
		m = 	 	parse(Int, ARGS[4])
		n = 	 	parse(Int, ARGS[5])
		nnzrow = 	parse(Int, ARGS[6])
	else
		if length(ARGS) > 3
			n =	 	parse(Int, ARGS[4])
		end
	end

	# Get matrix, rhs, solution
	Random.seed!(1)
	if matrix == "sprand"
		A = sprand(m, n, nnzrow/m)
	elseif matrix == "fem2d"
		A = fem2d(n)
	elseif matrix == "fdm3d"
		A = fdm3d(n)
	else
		if length(ARGS) > 3 
			@suppress A = matrixdepot(matrix, n)
		else
			@suppress A = matrixdepot(matrix)
		end
	end
	transA = transpose(sparse(transpose(A)))
	x = ones(A.n)
	b = A * x

	# Run benchmarks
	if solver == "spmv"
		if format == "info"
			info(A)
		elseif format == "csr"
			spmv(transA, x)
		elseif format == "csc"
			spmv(A, x)
		else
			throw(ArgumentError(matrix))
		end
	else
		# All available iterative solvers
		allsolvers = Dict("cg" => cg, 
		                  "minres" => minres, 
		                  "gmres" => gmres, 
		                  "bicgstabl" => bicgstabl)
		if haskey(allsolvers, solver)
			solverfunc = allsolvers[solver]
			if format == "info"
				info(A, b, solverfunc, matrix)
			elseif format == "csr"
				iter(transA, b, solverfunc)
			elseif format == "csc"
				iter(A, b, solverfunc)
			else
				throw(ArgumentError(matrix))
			end
		else
			throw(ArgumentError(solver))
		end	
	end

end

run()
