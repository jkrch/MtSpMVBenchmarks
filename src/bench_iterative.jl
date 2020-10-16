# Compare the builtin sequential CSC matrix-vector product and the multithreaded 
# CSR matrix-vector product from this package for iterative solvers
function linsolv(n, linsysfunc, solver)

    # Load linear system
    A_csc, A_csr, b, x = linsysfunc(n)

    # Print info
    println("n=", A_csc.n, ", nnz=", length(A_csc.nzval),
#            ", tol=", tol, ", maxiter=", maxiter,
            ", nthreads=", Threads.nthreads())
    
    # Print convergence
    x_csc, hist_csc = cg(A_csc, b, log=true)
    println(hist_csc)        
               
    # Benchmark sequential CSC
    @printf("Builtin serial CSC:\t")
    @btime cg($A_csc, $b)
    
    # Benchmark sequential CSC
    @printf("Builtin serial CSR:\t")
    Trans = transpose(sparse(transpose(A_csc)))
    @btime cg($Trans, $b)
    
    # Benchmark multithreaded CSR
    @printf("Multithreaded CSR:\t")
    @btime cg($A_csr, $b)
   
end
    

# Benchmark IterativeSolvers.cg
function btime_cg(n, linsys)

    # Load linear system and solver
    println("Benchmark CG")
    if linsys == "fdm2d"
        println("FDM 2d")
        linsolv(n, fdm2d, cg)
    elseif linsys == "fdm3d"
        println("FDM 3d")
        linsolv(n, fdm3d, cg)
    else
        throw(ArgumentError("No linear system of this name, use 'fdm2d' or 'fdm3d'."))
    end   
    
end


# Benchmark IterativeSolvers.minres
function btime_minres(n, linsys)

    # Load linear system and solver
    println("Benchmark MINRES")
    if linsys == "symmindef"
        println("Symmetric indefinite")
        linsolv(n, symmindef, minres)
    else
        throw(ArgumentError("No linear system of this name, use 'symmindef'."))
    end   
    
end


# Benchmark IterativeSolvers.gmres
function btime_gmres(n, linsys)

    # Load linear system
    println("Benchmark GMRES")
    if linsys == "fem2d"
        println("FEM 2d")
        linsolv(n, fem2d, gmres)
    elseif linsys == "nonsymm"
        println("Nonsymmetric")
        linsolv(n, nonsymm, gmres)
    else
        throw(ArgumentError("No linear system of this name, use 'fem2d' or 'nonsymm'"))
    end
    
end


#TODO: BiCGStab(l)
# Benchmark IterativeSolvers.bicgstabl
function btime_bicgstabl(n, linsys)
    
end
