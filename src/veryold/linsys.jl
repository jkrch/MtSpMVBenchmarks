# Collection of functions providing different linear systems for spmv iterative 
# solver (and spmv) benchmarks
# 
# Each function returns a SparseMatrixCSC, the matrix as Transpose, the matrix 
# as SparseMatrixCSR, a right-hand side vector and the solution vector


# Return a random CSC matrix, the matrix in Tranpose form, their CSR pendant, 
# a random vector and the result for the matrix-vector product   
function rnd_mat_vec(m, n, d; seed=1)
    Random.seed!(seed)
    A_csc = sprand(m, n, d)
    A_csr = sparsecsr(A_csc)
    Trans = transpose(sparse(transpose(A_csc)))
    x = rand(n)
    y = zeros(eltype(A_csc), A_csc.m)
    return A_csc, Trans, A_csr, x, y
end


# Make indefinite (hard to solve) linear system
function symmindef(n; seed=1)
    Random.seed!(seed)
    A_csc = sprand(n, n, 3.0/n) + I
    A_csc = (A_csc + A_csc') / 2
    Trans = transpose(sparse(transpose(A_csc)))
    A_csr = sparsecsr(A_csc)
    x = ones(n)
    b = A_csr * x
    return A_csc, Trans, A_csr, b, x
end


# Matrix of the 5-point difference stencil
#   - tridiagonal
#   - spd
function fdm2d(n)
    diag = -4 * ones(n)
    subdiag = ones(n-1)
    A_csc = spdiagm(0 => diag, -1 => subdiag, 1 => subdiag)
    Trans = transpose(sparse(transpose(A_csc)))
    A_csr = sparsecsr(A_csc)
    x = ones(n)
    b = A_csr * x 
    return A_csc, Trans, A_csr, b, x
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
    A_csc = ExtendableSparseMatrix(n, n)
    fdrand!(A_csc, nx, ny, nz)
    flush!(A_csc)
    A_csc = A_csc.cscmatrix
    Trans = transpose(sparse(transpose(A_csc)))
    A_csr = sparsecsr(A_csc)
    x = ones(n)
    b = A_csr * x
    return A_csc, Trans, A_csr, b, x 
end


# Matrix of a 2D piecewise linear FEM discretization
#   - strictly diagonally dominant (=> invertible)
#   - nnzrow = 4
#   - matrix bandwidth bounded by sqrt(n)
function fem2d(n; seed=1)
    Random.seed!(seed)
    A_csc = ExtendableSparseMatrix(n, n)
    sprand_sdd!(A_csc)
    flush!(A_csc)
    A_csc = A_csc.cscmatrix
    Trans = transpose(sparse(transpose(A_csc)))
    A_csr = sparsecsr(A_csc)
    x = ones(n)
    b = A_csr * x
    return A_csc, Trans, A_csr, b, x
end



function matrixmarket

end

function suitesparse(matrixname)

end
