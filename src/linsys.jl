# Collection of functions providing different linear systems for iterative 
# solver benchmarks
# 
# Each function returns a CSC matrix, their CSR pendant, a right-hand side 
# vector and the solution vector


function nonsymm(n; seed=1)

end


# Make indefinite (hard to solve) linear system
function symmindef(n; seed=1)
    Random.seed!(seed)
    A_csc = sprand(n, n, 3.0/n) + I
    A_csc = (A_csc + A_csc') / 2
    A_csr = sparsecsr(A_csc)
    x = ones(n)
    b = A_csr * x
    return A_csc, A_csr, b, x
end


# Matrix of the 5-point difference stencil
#   - tridiagonal
#   - spd
function fdm2d(n)
    diag = -4 * ones(n)
    subdiag = ones(n-1)
    A_csc = spdiagm(0 => diag, -1 => subdiag, 1 => subdiag)
    A_csr = sparsecsr(A_csc)
    x = ones(n)
    b = A_csr * x 
    return A_csc, A_csr, b, x
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
    A_ext = ExtendableSparseMatrix(n, n)
    fdrand!(A_ext, nx, ny, nz)
    flush!(A_ext)
    A_csc = A_ext.cscmatrix
    A_csr = sparsecsr(A_csc)
    x = ones(n)
    b = A_csr * x
    return A_csc, A_csr, b, x 
end


# Matrix of a 2D piecewise linear FEM discretization
#   - strictly diagonally dominant (=> invertible)
#   - nnzrow = 4
#   - matrix bandwidth bounded by sqrt(n)
function fem2d(n; seed=1)
    Random.seed!(seed)
    A_ext = ExtendableSparseMatrix(n, n)
    sprand_sdd!(A_ext)
    flush!(A_ext)
    A_csc = A_ext.cscmatrix
    A_csr = sparsecsr(A_csc)
    x = ones(n)
    b = A_csr * x
    return A_csc, A_csr, b, x
end
