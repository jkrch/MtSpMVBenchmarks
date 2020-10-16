module MtSpMVBenchmarks

using BenchmarkTools, MtSpMV, SparseArrays, ExtendableSparse, LinearAlgebra, 
    IterativeSolvers, Random, MatrixMarket, Printf 

import BenchmarkTools: prunekwargs, hasevals

export @mybtime, @benchmed

include(joinpath(dirname(@__FILE__), "linsys.jl"))
include(joinpath(dirname(@__FILE__), "output.jl"))

include("bench_constructors.jl")
include("bench_spmv.jl")
include("bench_iterative.jl")
include("bench_all.jl")

end
