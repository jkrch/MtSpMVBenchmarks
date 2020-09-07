# Return a random CSC matrix, their CSR pendant, a random vector and the result 
# for the matrix-vector product   
function rnd_mat_vec(m, n, d; seed=1)
    Random.seed!(seed)
    A_csc = sprand(m, n, d)
    A_csr = sparsecsr(A_csc)
    x = rand(n)
    y = zeros(eltype(A_csc), A_csc.m)
    return A_csc, A_csr, x, y
end


# Compare the builtin serial CSC and CSR (if matrix type is 'Tranpose' and 
# the parent is transpose of the CSC matrix) with the multithreaded and 
# serial CSR matrix-vector product from this package
function bench_builtin(m, n, d)

    # Load matrix and vectors
    println("Benchmark SpMV") 
    A_csc, A_csr, x, y = rnd_mat_vec(m, n, d)
    
    # Print info
    print("m=$m, n=$n, nnz=$(length(A_csc.nzval)), d=$d, ")
    println("nthreads=", Threads.nthreads())
    
    # Benchmark for preallocated result
    println("Preallocated result")
    
    # Builtin serial CSC
    print("Builtin serial CSC:\t")
    @btime mul!($y, $A_csc, $x)
    
    # Builtin serial CSR
    print("Builtin serial CSR:\t")
    Trans = transpose(sparse(transpose(A_csc)))
    @btime mul!($y, $Trans, $x)

    # Multithreaded CSR
    print("Multithreaded CSR:\t")
    @btime mul!($y, $A_csr, $x)
    
    # Benchmark for not preallocated result
    println("No preallocated result")
    
    # Builtin serial CSC
    print("Builtin serial CSC:\t")
    @btime $A_csc * $x
    
    # Builtin serial CSR
    print("Builtin serial CSR:\t")
    Trans = transpose(sparse(transpose(A_csc)))
    @btime $Trans * $x

    # Multithreaded CSR
    print("Multithreaded CSR:\t")
    @btime $A_csr * $x
    
    print()
end


# Used for experiments with mul!
function bench_mulexp(m, n, d)
    
    # Load matrix and vectors
    println("Benchmark SpMV (experimental)") 
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
    println(mul!(y, A_csr, x) == mulexp!(y, A_csr, x))

end
