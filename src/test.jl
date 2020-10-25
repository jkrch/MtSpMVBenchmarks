using LinearAlgebra
using SparseArrays
using BenchmarkTools
using Pardiso
using IterativeSolvers
using Suppressor
@suppress using MatrixDepot


include("utils.jl")
include("parameters.jl")

# Get command line arguments
println(length(ARGS))
format = ARGS[1]
solver = ARGS[2]
matrix = ARGS[3]
println(matrix)
if matrix == "sprand"
	m = 	 	parse(Int, ARGS[4])
	n = 	 	parse(Int, ARGS[5])
	nnzrow = 	parse(Int, ARGS[6])
elseif matrix == "fdm3d"
	nx = 	 	parse(Int, ARGS[4])
	ny = 	 	parse(Int, ARGS[5])
	nz = 	 	parse(Int, ARGS[6])
	n = nx * ny * nz
else
	if length(ARGS) > 3
		n =	 	parse(Int, ARGS[4])
	end
end

