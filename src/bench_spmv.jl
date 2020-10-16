# Compare the builtin serial CSC and CSR (if matrix type is 'Tranpose' and 
# the parent is transpose of the CSC matrix) with the multithreaded and 
# serial CSR matrix-vector product from this package
function btime_spmv(m, n, d)

    # Load matrix and vectors
    println("Benchmark SpMV") 
    A_csc, Trans, A_csr, x, y = rnd_mat_vec(m, n, d)
    
    # Print info
    print("m=$m, n=$n, nnz=$(length(A_csc.nzval)), d=$d, ")
    println("nthreads=", Threads.nthreads())
    
    # Benchmark for preallocated result
    println("Preallocated result")
    
    # Builtin serial CSC
    println("Builtin serial CSC:\t")
    @btime mul!($y, $A_csc, $x)
    
    # Builtin serial CSR
    println("Builtin serial CSR:\t")
    @btime mul!($y, $Trans, $x)

    # Multithreaded CSR
    println("Multithreaded CSR:\t")
    @btime mul!($y, $A_csr, $x)
    
    # Benchmark for not preallocated result
    println("With result allocation")
    
    # Builtin serial CSC
    println("Builtin serial CSC:\t")
    @btime $A_csc * $x
    
    # Builtin serial CSR
    println("Builtin serial CSR:\t")
    @btime $Trans * $x

    # Multithreaded CSR
    println("Multithreaded CSR:\t")
    @btime $A_csr * $x
    
    print()
end


function benchmark_spmv(m, n, d)

    # Load matrix and vectors
    println("Benchmark SpMV") 
    A_csc, Trans, A_csr, x, y = rnd_mat_vec(m, n, d)
    
    # Print info
    print("m=$m, n=$n, nnz=$(length(A_csc.nzval)), d=$d, ")
    println("nthreads=", Threads.nthreads())
    
    # Benchmark for preallocated result
    println("Preallocated result")
    
    # Builtin serial CSC
    println("Builtin serial CSC:\t")
    @btime mul!($y, $A_csc, $x)
    
    # Builtin serial CSR
    println("Builtin serial CSR:\t")
    @btime mul!($y, $Trans, $x)

    # Multithreaded CSR
    println("Multithreaded CSR:\t")
    @btime mul!($y, $A_csr, $x)
    
    # Benchmark for not preallocated result
    println("No preallocated result")
    
    # Builtin serial CSC
    println("Builtin serial CSC:\t")
    @btime $A_csc * $x
    
    # Builtin serial CSR
    println("Builtin serial CSR:\t")
    @btime $Trans * $x

    # Multithreaded CSR
    println("Multithreaded CSR:\t")
    @btime $A_csr * $x
    
    print()
end


# Used for experiments with mul!
function benchmark_spmv(m, n, d)
    
    # Load matrix and vectors
    println("Benchmark experimental SpMV") 
    A_csc, A_csr, x, y = rnd_mat_vec(m, n, d)
    
    # Print info
    println("m=", m, ", n=", n, ", nnz=", length(A_csc.nzval), ", d=", d, 
            ", nthreads=", Threads.nthreads())
        
    # Benchmark mul! and 
    @printf("mul!(y, A_csr, x):\t")
    @btime mul!($y, $A_csr, $x)
    
    # Benchmark mulexp! and check results
    @printf("mulexp!(y, A_csr, x):\t")
    @btime mulexp!($y, $A_csr, $x)
    println("exp. result is ", mul!(y, A_csr, x) == mulexp!(y, A_csr, x))

end
