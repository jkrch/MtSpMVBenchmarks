using Random

# Quick solution for saving and loading a csr matrix (sprand_sdd! and fdrand!     
# get slow for larger matrix sizes)
# rowptr, colval, nzval each will be written to an own csv file 
# TODO: Save as single file (e.g. Harwell-Boeing Exchange Format)
function savematrix(n::Int, linsys::String)
    if linsys == "fem2d"
        None, A_csr, None, None = linsys_fem2d(n)
    elseif linsys == "fdm3d"
        None, A_csr, None, None = linsys_fdm3d(n)
    else
        throw(ArgumentError("Use 'fem2d' or 'fdm3d'."))
    end
    writedlm(string("benchmark/matrix/", linsys, "_rowptr.csv"), A_csr.rowptr)
    writedlm(string("benchmark/matrix/", linsys, "_colval.csv"), A_csr.colval)
    writedlm(string("benchmark/matrix/", linsys, "_nzval.csv"), A_csr.nzval)
end

function getmatrix(linsys::String)
    if linsys != "fem2d" && linsys != "fdm3d"
        throw(ArgumentError("Use 'fem2d' or 'fdm3d'."))
    end
    rowptr = readdlm(string("benchmark/matrix/", linsys, "_rowptr.csv"), Int)[:]
    colval = readdlm(string("benchmark/matrix/", linsys, "_colval.csv"), Int)[:]
    nzval = readdlm(string("benchmark/matrix/", linsys, "_nzval.csv"), Float64)[:]
    n = length(rowptr) - 1
    SparseMatrixCSR(n, n, rowptr, colval, nzval)
end


Random.seed!(1)

MTSpMatVecBenchmarks.savematrix(1_000, "fdm3d")

#MTSpMatVecBenchmarks.savematrix(10_000_000, "fem2d")


