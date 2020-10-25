"""
matrix for a mock finite difference operator for a diffusion
problem with random coefficients on a unit hypercube
=======================

*Input options:*

+ n: number of unknowns in x, y, z direction 
""" 
function fdm3d(n)
    A = ExtendableSparseMatrix(n, n)
    fdrand!(A, n, n, n)
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