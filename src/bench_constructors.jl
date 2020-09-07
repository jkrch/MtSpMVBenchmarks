# Benchmark the constructors for 'SparseMatrixCSR' in sparsematrixcsr.jl
function bench_csr(m, n, d; seed=1, dense=false)
    
    # Print info
    println("Benchmark constructors")
    
    # Create a random example matrix in varying matrix formats
    Random.seed!(seed)
    A_csc = sprand(m, n, d)
    A_csr = sparsecsr(A_csc)
    A_ext = ExtendableSparseMatrix(A_csc)
    
    # Print matrix properties
#    println("m=", m, ", n=", n, ", nnz=", length(A_csc.nzval))
    println("m=$m, n=$n, nnz=$(length(A_csc.nzval))")
     
    # Benchmark sprand 
    @printf("sprand():\t") 
    @btime sprand($m, $n, $d)
    
    # Benchmark SparseMatrixCSC
    @printf("csc->csr:\t") 
    @btime sparsecsr($A_csc)
    @printf("csr->csc:\t")  
    @btime sparse($A_csr)
    
    # Benchmark ExtendableSparseMatrix
    @printf("ext->csr:\t")
    @btime sparsecsr($A_ext)
    @printf("ext->csr:\t")
    @btime ExtendableSparseMatrix($A_csr)
    
    # Benchmark dense matrix
    if dense == true
        A = Matrix(A_csc)
        @printf("dense->csc:\t")  
        @btime sparse($A)
        @printf("dense->csr:\t")  
        @btime sparsecsr($A)  
        @printf("csc->dense:\t")  
        @btime Matrix($A_csc)
        @printf("csr->dense:\t")  
        @btime Matrix($A_csr)
    end
    
end
