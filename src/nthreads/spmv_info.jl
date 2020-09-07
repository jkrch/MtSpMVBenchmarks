using SparseArrays

include("../MtSpMVBenchmarks.jl")


function main(m::Int, n::Int, nnzrow::Int)
    # Get linear system and print properties
    None, A, x, y = MtSpMVBenchmarks.rnd_mat_vec(m, n, nnzrow/m)
    println("Multithreaded SpMV")
    println("m=", A.m, ", n=", A.n, ", nnz=", length(A.nzval))
end

main(parse(Int, ARGS[1]), parse(Int, ARGS[2]), parse(Int, ARGS[3]))

