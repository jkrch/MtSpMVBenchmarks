# Experimental version of parallel linear algebra kernels

import LinearAlgebra: mul!

# TODO: Transpose
# Multithreaded matrix-vector multiplication for Transpose{<:Any,<:AbstractSparseMatrixCSC}'
function mul!(y::StridedVector, Trans::Transpose{<:Any,<:SparseMatrixCSC}, x::StridedVector, α::Number, β::Number) 
    size(Trans)[2] == length(x) || throw(DimensionMismatch("Trans.n != length(x)"))
    A = Trans.parent  
    nzval = A.nzval
    colval = A.rowval
    rowptr = A.colptr
    Threads.@threads for i = 1:A.n
        y[i] = 0 
        @inbounds for j = rowptr[i]:(rowptr[i+1]-1)
            y[i] += nzval[j] * x[colval[j]]
        end
    end
    y
end 
#*(A::SparseMatrixCSR{TA}, x::StridedVector{Tx}) where {TA, Tx} =
#    (T = promote_op(matprod, TA, Tx); mul!(similar(x, T, A.m), A, x, true, false))


## Experimental version of mul! for tuning
#function mulexp!(y::StridedVector, A::SparseMatrixCSR, x::StridedVector)
#    A.n == length(x) || throw(DimensionMismatch("A.n != length(x)"))
#    nzval = A.nzval
#    colval = A.colval
#    rowptr = A.rowptr
#    @sync for i = 1:A.m 
#        y[i] = 0
#        for j = rowptr[i]:(rowptr[i+1]-1)
#            Threads.@spawn y[i] += nzval[j] * x[colval[j]]
#        end
#    end
#    y
#end 


## Multithreaded matrix-vector product for 'SparseMatrixCSR' using Threads.@spawn

## Subdivision of the loop length into equal parts for spawned methods
#function partition(N::Integer, ntasks::Integer)
#    loop_begin = zeros(Int64, ntasks)
#    loop_end = zeros(Int64, ntasks)
#    for itask = 1:ntasks
#        ltask = Int(floor(N / ntasks))
#        loop_begin[itask] = (itask - 1) * ltask + 1
#        if itask==ntasks # adjust last task length
#            ltask = N - (ltask * (ntasks -1  ))
#        end
#        loop_end[itask] = loop_begin[itask] + ltask - 1
#    end
#    loop_begin, loop_end
#end

#function myspmv(A::SparseMatrixCSR, x::StridedVector, n0::Integer, n1::Integer)
#    y = zeros(eltype(A), A.m)
#    nzval = A.nzval
#    colval = A.colval
#    for i = n0:n1
#        for j = A.rowptr[i]:(A.rowptr[i+1]-1)
#            @inbounds y[i] += nzval[j] * x[colval[j]]
#        end
#    end
#    y
#end

#function spwspmv(A::SparseMatrixCSR, x::StridedVector)
#    ntasks = Threads.nthreads()
#    loop_begin, loop_end = partition(length(x), ntasks)
#    tasks = [Threads.@spawn myspmv(A, x, loop_begin[i], loop_end[i]) for i=1:ntasks]
#    mapreduce(task->fetch(task), +, tasks)
#end
