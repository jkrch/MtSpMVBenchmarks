# Solves problems with Plots.jl on ssh servers
# (https://github.com/JuliaPlots/Plots.jl/issues/1905#issuecomment-458778817)
ENV["GKSwstype"]="100"

using Plots
using DataFrames
using CSV
using DelimitedFiles


# Get parallel benchmark results from csv file and return as arrays
function get_parallel_results(filename::String)

    # Read in csv file as dataframe
    df = DataFrame!(CSV.File(filename, header=true))

    # Select nthreads and time columns
    select!(df, [1, 3])

    # Convert columns to arrays
    nthreads = convert(Vector{Int}, df[:, 1])
    time = convert(Vector{Float64}, df[:, 2])
    
    nthreads, time
    
end


# Create and save plots for matrix size to time and for matrix size to speedup
function plot_msize(method::String, header::String)

    # Folder path of results
    path = joinpath(dirname(@__FILE__), "msize", method, header)
    
    # File paths of results
    result1_csv = joinpath(path, "result1.csv")
    result2_csv = joinpath(path, "result2.csv")
    result3_csv = joinpath(path, "result3.csv")
    result4_csv = joinpath(path, "result4.csv")
    result5_csv = joinpath(path, "result5.csv")
    results_txt = joinpath(path, "results.txt")
    
    # File paths of plots
    plot1 = joinpath(path, "1a")
    plot2 = joinpath(path, "2a")
    plot3 = joinpath(path, "3a")
    plotA = joinpath(path, "1b")
    plotB = joinpath(path, "2b")
    plotC = joinpath(path, "3b")

    # Plot benchmark time for CSR and CSC MatVec from SparseArrays.jl and for 
    # CSR MatVec from SparseArrays.jl
    nthreads1, time1 = get_parallel_results(result1_csv)
    plot(nthreads1, time1, title="SpMV", dpi=300, label="SparseArrays.jl CSR",
         xlabel="Matrix size", ylabel="Time in seconds")
    nthreads2, time2 = get_parallel_results(result2_csv)
    plot!(nthreads2, time2, label="SparseArrays.jl CSR", linestyle=:dash)
    nthreads3, time3 = get_parallel_results(result3_csv)
    plot!(nthreads3, time3, label="MtSpMV.jl CSR", linestyle=:dot)
    png(plot1) 
    
    # Plot benchmark time for CSR MatVec from MKLSparse.jl
    if isfile(result4_csv)
        nthreads4, time4 = get_parallel_results(result4_csv)
        plot!(nthreads4, time4, label="MKLSparse.jl CSR", linestyle=:dashdotdot) 
        png(plot2)
    end
        
    # Plot benchmark time for CSC MatVec from MKLSparse.jl
    if isfile(result5_csv)
        nthreads5, time5 = get_parallel_results(result5_csv)
        plot!(nthreads5, time5, label="MKLSparse.jl CSC", linestyle=:dashdot)
        png(plot3)     
    end
    
    
#    # Plot nthreads to speedup
#    
#    # Get serial result for csr and csc
#    sertimecsr, sertimecsc = get_serial_results(results_txt)
#    
#    # Compute speedups
#    speedup1 = zeros(length(time1))
#    speedup2 = zeros(length(time1))
#    for i = 1:length(time1)
#        speedup1[i] = sertimecsr / time1[i]
#        speedup2[i] = sertimecsc / time1[i]
#    end
#    
#    # Create plot
#    plot(nthreads1, speedup1, title=title, dpi=300, legend=:topleft, 
#         legendfontsize=6, label="MtSpMV.jl CSR over SparseArrays.jl CSR", 
#         xlabel="Number of threads", ylabel="Parallel speedup")
#    
#    # Add plot     
#    plot!(nthreads1, speedup2, linestyle=:dash, 
#          label="MtSpMV.jl CSR over SparseArrays.jl CSC") 
#         
#    # Save plot
#    png(plotA)

#    # Add mkl csr
#    if isfile(result2_csv)
#    
#        # Compute speedups
#        speedup3 = zeros(length(time2))
#        speedup4 = zeros(length(time2))
#        for i = 1:length(time1)
#            speedup3[i] = sertimecsr / time2[i]
#            speedup4[i] = sertimecsc / time2[i]
#        end
#        
#        # Add to plot
#        plot!(nthreads2, speedup3, linestyle=:dot, 
#              label="MKLSparse.jl CSR over SparseArrays.jl CSR")
#              
#        # Add to plot
#        plot!(nthreads2, speedup4, linestyle=:dashdot, 
#              label="MKLSparse.jl CSR over SparseArrays.jl CSC")   
#        
#        # Save plot
#        png(plotB)
#    end
#        
#    # Add mkl csc
#    if isfile(result3_csv)
#    
#        # Compute speedups
#        speedup5 = zeros(length(time3))
#        for i = 1:length(time1)
#            speedup5[i] = sertimecsc / time3[i]
#        end
#        
#        # Add to plot
#        plot!(nthreads3, speedup5, linestyle=:dashdotdot,
#              label="MKLSparse.jl CSC over SparseArrays.jl CSC", )
#        
#        # Save plot
#        png(plotC)     
#    end

end
                                                 

# Run from command line
# ARGS[1]: method (spmv, cg, gmres, ...)
# ARGS[2]: foldername of the results
plotresults(ARGS[1], ARGS[2])

