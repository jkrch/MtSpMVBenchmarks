# Run Benchmarks from command line
module RunBenchmarks

using BenchmarkTools
using LinearAlgebra
using IterativeSolvers
using SparseArrays
using ExtendableSparse
using Random

include("linsys.jl")
include("nthreads_bench.jl")

# Set benchmark parameters
BenchmarkTools.DEFAULT_PARAMETERS.samples = 1000 # 10000 by default
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1e10 # 5 by default


# Return function handle for linear system
function getlinsysfunc(linsysname::String)
    alllinsys = Dict("fdm2d" => fdm2d, 
                     "fdm3d" => fdm3d, 
                     "fem2d" => fem2d)
    alllinsys[linsysname]
end


# Return function handle for solver
function getsolverfunc(solvername::String)
    allsolvers = Dict("cg" => cg, 
                      "minres" => minres, 
                      "gmres" => gmres, 
                      "bicgstabl" => bicgstabl)
    allsolvers[solvername]
end


# Benchmark spmv
function spmv(m::Int,
			  n::Int, 
			  nnzrow::Int,
			  modulename::String, 
			  funcname::String)
	
	# Get random matrix and vector
	A, transA, b, x = randlinsys(m, n, 1/nnzrow)

	# Run benchmark or create plot title
	# TODO: Write better
	if modulename == "ser"
		if funcname == "info"
			JuliaSerial.info(A)
		elseif funcname == "csr"
			JuliaSerial.spmv(transA, x)
		elseif funcname == "csc"
			JuliaSerial.spmv(A, x)
		else
			throw(ArgumentError(funcname))
		end
	elseif modulename == "par"
		if funcname == "csr"
			JuliaParallel.spmv(transA, x)
		else
			throw(ArgumentError(funcname))
		end
	elseif modulename == "mkl"
		if funcname == "csr"
			IntelParallel.spmv(transA, x)
		elseif funcname == "csc"
			IntelParallel.spmv(A, x)
		else
			throw(ArgumentError(funcname))
		end
	else
		throw(ArgumentError(modulename))
	end
	
end


# Benchmark iterative solver
function iter(linsysname::String, 
			  n::Int, 
			  solvername::String, 
			  modulename::String, 
			  funcname::String)
	
	# Get liner system and solver
	solverfunc = getsolverfunc(solvername)
	linsysfunc = getlinsysfunc(linsysname)
	A, transA, b, x = linsysfunc(n)

	# Run benchmark or create plot title
	# TODO: Write better
	if modulename == "ser"
		if funcname == "info"
			JuliaSerial.info(A, b, solverfunc, linsysfunc)
		elseif funcname == "csr"
			JuliaSerial.iter(transA, b, solverfunc)
		elseif funcname == "csc"
			JuliaSerial.iter(A, b, solverfunc)
		else
			throw(ArgumentError(funcname))
		end
	elseif modulename == "par"
		if funcname == "csr"
			JuliaParallel.iter(transA, b, solverfunc)
		else
			throw(ArgumentError(funcname))
		end
	elseif modulename == "mkl"
		if funcname == "csr"
			IntelParallel.iter(transA, b, solverfunc)
		elseif funcname == "csc"
			IntelParallel.iter(A, b, solverfunc)
		else
			throw(ArgumentError(funcname))
		end
	else
		throw(ArgumentError(modulename))
	end

end


# Run benchmark from command line
# TODO: Use ArgParse.jl
function main()

	# Command line arguments
	method = ARGS[1] # "spmv", "iter"
	kernel = ARGS[2] # "ser", "par", "mkl"
	matrix = ARGS[3] # "csr", "csc", "info"
	if method == "spmv"
		m = parse(Int, ARGS[4])
		n = parse(Int, ARGS[5])
		nnzrow = parse(Int, ARGS[6])
	elseif method == "iter"
		linsys = ARGS[4]
		n = parse(Int, ARGS[5])
		solver = ARGS[6]
	end

	# Run benchmark
	if method == "spmv"
		spmv(m, n, nnzrow, kernel, matrix)
	elseif method == "iter"
		iter(linsys, n, solver, kernel, matrix)
	end

end
main()

end # module