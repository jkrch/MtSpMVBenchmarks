module MtSpMVBenchmarks

using MtSpMV
using SparseArrays
using ExtendableSparse
using LinearAlgebra
using IterativeSolvers
using BenchmarkTools
using Printf
using Random

include("bench_constructors.jl")
#include("parallellinalg_extension.jl")
include("bench_spmv.jl")
include("linsys.jl")
include("bench_iterative.jl")
include("bench_all.jl")

export rnd_mat_vec

end
