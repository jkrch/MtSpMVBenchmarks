module Julia

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


# Benchmark solver from IterativeSolvers.jl with serial CSR or CSC MatVec from 
# SparseArrays.jl
function bench(linsys::String, n::Int, kernel::String)

    # Get linear system and solver functions
    linsysfunc, solverfunc = getfunc(linsys)
    
    # Get the linear system
    A_csc, Trans, None, b, None = linsysfunc(n)
    
    # Print linear solve properties and convergence time
    if kernel == "prop"
        if linsys=="fdm2d"
            print("CG, 2d FDM, ")
        elseif linsys=="fdm3d"
            print("CG, 3d FDM, ")
        elseif linsys=="fem2d"
            print("GMRES, 2d FEM, ")
        end
        println("n=", A_csc.n, ", nnz=", length(A_csc.nzval))
        x, hist = solverfunc(A_csc, b, log=true)
        println(hist)
    end
    
    # Print median benchmark time for CSR
    if kernel == "csr"
        @mybtime $solverfunc($Trans, $b)
        print()
    end
    
    # Print median benchmark time for CSR
    if kernel == "csc"
        @mybtime $solverfunc($A_csc, $b)
        print()
    end
    
end


# Run from command line
# ARGS[1]: type of linear system
# ARGS[2]: size of linear system
# ARGS[4]: kernel (csr or csc)
main(ARGS[1], parse(Int, ARGS[2]), ARGS[3])

end
