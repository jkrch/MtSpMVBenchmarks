module My

using BenchmarkTools
using LinearAlgebra
using SparseArrays
using IterativeSolvers
using MtSpMV

include("MtSpMVBenchmarks.jl")
using .MtSpMVBenchmarks


BenchmarkTools.DEFAULT_PARAMETERS.samples = 1000 # 10000 by default
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1e10 # 5 by default


# Return right linsys and solver functions 
function getfunc(linsys::String)
    
    # Choose linear system and solver 
    if linsys=="fdm2d"
        linsysfunc = MtSpMVBenchmarks.fdm2d
        solverfunc = cg
    elseif linsys=="fdm3d"
        linsysfunc = MtSpMVBenchmarks.fdm3d
        solverfunc = cg
    elseif linsys=="fem2d"
        linsysfunc = MtSpMVBenchmarks.fem2d
        solverfunc = gmres
    end
    
    return linsysfunc, solverfunc
    
end


# Benchmark solver from IterativeSolvers.jl with CSR MatVec from MtSpMV.jl
function main(linsys::String, n::Int, kernel::String)
    
    # Get linear system and solver functions
    linsysfunc, solverfunc = getfunc(linsys)
    
    # Get the linear system
    None, None, A_csr, b, None = linsysfunc(n)
    
    # Benchmark my csr
    @mybtime $solverfunc($A_csr, $b)
    print()
    
end


# Run from command line
# ARGS[1]: type of linear system
# ARGS[2]: size of linear system
# ARGS[4]: kernel (csr)
main(ARGS[1], parse(Int, ARGS[2]), ARGS[3])

end
    
