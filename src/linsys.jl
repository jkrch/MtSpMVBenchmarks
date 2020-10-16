# Collection of functions providing different linear systems for spmv iterative 
# solver (and spmv) benchmarks
# 
# Each function returns a SparseMatrixCSC, the matrix as transApose, the matrix 
# as SparseMatrixCSR, a right-hand side vector and the solution vector


# Return a random CSC matrix, the matrix in Tranpose form, their CSR pendant, 
# a random vector and the result for the matrix-vector product   
function randlinsys(m, n, d; seed=1)
    Random.seed!(seed)
    A = sprand(m, n, d)
    transA = transpose(sparse(transpose(A)))
    x = rand(n)
    b = zeros(eltype(A), A.m)
    return A, transA, b, x
end


# Make indefinite (hard to solve) linear system
function symmindef(n; seed=1)
    Random.seed!(seed)
    A = sprand(n, n, 3.0/n) + I
    A = (A + A') / 2
    transA = transpose(sparse(transpose(A)))
    x = ones(n)
    b = A * x
    return A, transA, b, x
end


# Matrix of the 5-point difference stencil
#   - tridiagonal
#   - spd
function fdm2d(n)
    diag = -4 * ones(n)
    subdiag = ones(n-1)
    A = spdiagm(0 => diag, -1 => subdiag, 1 => subdiag)
    transA = transpose(sparse(transpose(A)))
    x = ones(n)
    b = A * x 
    return A, transA, b, x
end


# FDM data on a unit hypercube
#   - banded
#   - spd
function fdm3d(n; seed=1)
    Random.seed!(seed)
    nx = Int(floor(n ^ (1/3)))
    ny = Int(nx)
    nz = Int(nx)
    n = nx*ny*nz
    A = ExtendableSparseMatrix(n, n)
    fdrand!(A, nx, ny, nz)
    flush!(A)
    A = A.cscmatrix
    transA = transpose(sparse(transpose(A)))
    x = ones(n)
    b = A * x
    return A, transA, b, x 
end


# Matrix of a 2D piecewise linear FEM discretization
#   - strictly diagonally dominant (=> invertible)
#   - nnzrow = 4
#   - matrix bandwidth bounded by sqrt(n)
function fem2d(n; seed=1)
    Random.seed!(seed)
    A = ExtendableSparseMatrix(n, n)
    sprand_sdd!(A)
    flush!(A)
    A = A.cscmatrix
    transA = transpose(sparse(transpose(A)))
    x = ones(n)
    b = A * x
    return A, transA, b, x
end