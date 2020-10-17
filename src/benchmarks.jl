# Benchmark serial CSR or CSC MatVec from SparseArrays.jl
module JuliaSerial

using SparseArrays
using LinearAlgebra

include("output.jl")

# Benchmark Sparse matrix-vector product
# Prints median benchmark time
function spmv(transA::Transpose{<:Any,<:SparseMatrixCSC}, x::StridedVector)
	y = zeros(length(x))
    @benchmed mul!($y, $transA, $x)
end
function spmv(A::SparseMatrixCSC, x::StridedVector)
	y = zeros(length(x))
    @benchmed mul!($y, $A, $x)
end

# Benchmark iterative solvers from IterativeSolvers.jl
# Prints median benchmark time
function iter(transA::Transpose{<:Any,<:SparseMatrixCSC}, b::StridedVector, solverfunc)
    @benchmed $solverfunc($transA, $b)
end
function iter(A::SparseMatrixCSC, b::StridedVector, solverfunc)
    @benchmed $solverfunc($A, $b)
end

# Print info for plot title
function info(A::SparseMatrixCSC)
    println("spmv, m=", A.m, ", n=", A.n, ", nnz=", length(A.nzval))
end
function info(A::SparseMatrixCSC, b::StridedVector, solverfunc, linsysfunc)
    println(solverfunc, ", ", linsysfunc, ", n=", A.n, ", nnz=", length(A.nzval))
    x, hist = solverfunc(A, b, log=true)
    println(hist)
end

end # module


# Benchmark multithreaded CSR MatVec from MtSpMV.jl
module JuliaParallel

using SparseArrays
using LinearAlgebra
using MtSpMV

include("output.jl")

# Benchmark Sparse matrix-vector product
# Prints median benchmark time
function spmv(transA::Transpose{<:Any,<:SparseMatrixCSC}, x::StridedVector)
	y = zeros(length(x))
    @benchmed mul!($y, $transA, $x)
end

# Benchmark iterative solvers from IterativeSolvers.jl
# Prints median benchmark time
function iter(transA::Transpose{<:Any,<:SparseMatrixCSC}, b::StridedVector, solverfunc)
    @benchmed $solverfunc($transA, $b)
end

end # module


# Benchmark multithreaded CSR and CSC MatVec from MKLSparse.jl
module IntelParallel

using SparseArrays
using LinearAlgebra
using MKLSparse

include("output.jl")

# Benchmark Sparse matrix-vector product
# Prints median benchmark time
function spmv(transA::Transpose{<:Any,<:SparseMatrixCSC}, x::StridedVector)
	y = zeros(length(x))
    @benchmed mul!($y, $transA, $x)
end
function spmv(A::SparseMatrixCSC, x::StridedVector)
	y = zeros(length(x))
    @benchmed mul!($y, $A, $x)
end

# Benchmark iterative solvers from IterativeSolvers.jl
# Prints median benchmark time
function iter(transA::Transpose{<:Any,<:SparseMatrixCSC}, b::StridedVector, solverfunc)
    @benchmed $solverfunc($transA, $b);
end
function iter(A::SparseMatrixCSC, b::StridedVector, solverfunc)
    @benchmed $solverfunc($A, $b)
end

end # module