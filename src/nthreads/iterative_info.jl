using MtSpMV
using IterativeSolvers
using BenchmarkTools

include("../MtSpMVBenchmarks.jl")

function main(n::Int, linsys::String)
    # Choose linear system and solver and print them
    if linsys=="fdm2d"
        linsysfunc = MtSpMVBenchmarks.fdm2d
        solver = cg
        print("CG, 2d FDM, ")
    elseif linsys=="fdm3d"
        linsysfunc = MtSpMVBenchmarks.fdm3d
        solver = cg
        print("CG, 3d FDM, ")
    elseif linsys=="fem2d"
        linsysfunc = MtSpMVBenchmarks.fem2d
        solver = gmres
        print("GMRES, 2d FEM, ")
    end
    # Get linear system and print properties
    None, A_csr, b, None = linsysfunc(n)
    print("n=", A_csr.n) 
    println(", nnz=", length(A_csr.nzval))
    # Solve linear system and print convergence history
    x, hist = solver(A_csr, b, log=true)
    println(hist)
end

main(parse(Int, ARGS[1]), ARGS[2])

