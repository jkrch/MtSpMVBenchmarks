"""
matrix for a mock finite difference operator for a diffusion
problem with random coefficients on a unit hypercube
=======================

*Input options:*

+ nx: number of unknowns in x direction 
+ ny: number of unknowns in y direction 
+ nz: number of unknowns in z direction 
""" 
function fdm3d(nx, ny, nz)
    n = nx*ny*nz
    A = ExtendableSparseMatrix(n, n)
    fdrand!(A, nx, ny, nz)
    flush!(A)
    return  A.cscmatrix
end




"""
matrix of a 2D piecewise linear FEM discretization
=======================

*Input options:*

+ n: size of the matrix
""" 
function fem2d(n)
    A = ExtendableSparseMatrix(n, n)
    sprand_sdd!(A)
    flush!(A)
    return A.cscmatrix
end