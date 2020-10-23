# Solves problems with Plots.jl on ssh servers
# (https://github.com/JuliaPlots/Plots.jl/issues/1905#issuecomment-458778817)
ENV["GKSwstype"]="100"

using Plots
using DataFrames
using CSV
using DelimitedFiles
using Glob

include("plotsettings.jl")


# Get benchmark results from csv file and return as arrays
function get_results(path::String)

    # Read in csv file as dataframe
    df = DataFrame!(CSV.File(path, header=true))

    # Select nthreads and time columns
    select!(df, [1, 3])

    # Convert columns to arrays
    matsize = convert(Vector{Int}, df[:, 1])
    seconds = convert(Vector{Float64}, df[:, 2])
    
    matsize, seconds 
end

# Get index of results with s in filename
function result_index(results, s::String)
	index = zeros(Int, 0)
	for (i, result) in enumerate(results)
		if !isnothing(findfirst(s, result))
			append!(index, i)
		end
	end
	index
end

# Add benchmark results to plot
function add_plot(results, index, package::String, path::String)
	if !isempty(index)
		for result in results
			nthreads = result[length(result)-4:length(result)-4]
			label = string(package, ", ", nthreads, " thread(s)")
			matsize, seconds = get_results(result)
			plot!(matsize, seconds, label=label)
		end
	end
end

# Create and save plots for matrix size to time and for matrix size to speedup
function plot_matsize(path::String)
	    
    # File paths of results
    results = glob("result*.csv", path)
    
    # Diffrent linestyles
    linestyles = [:solid, :dash, :dot, :dashdot, :dashdotdot]

    # Create runtime plot
    plot(title="spmv", xlabel="Matrix size", ylabel="Runtime (seconds)") 

    # Add MtSpMV.jl CSR to plot
    label = ("MtSpMV.jl CSR")
    index = result_index(results, "par_csr")
    if !isempty(results[index])
	    add_plot(results[index], index, label, path)
	    png(joinpath(path, "1a"))
	end
    
    # Add MKLSparse.jl CSR to plot
    label = ("MKLSparse.jl CSR")
    index = result_index(results, "mkl_csr")
    if !isempty(results[index])
    	add_plot(results[index], index, label, path)
        png(joinpath(path, "2a"))
    end

    # Add SparseArrays.jl CSC to plot
    label = ("MKLSparse.jl CSC")
    index = result_index(results, "mkl_csc")
    if !isempty(results[index])
    	add_plot(results[index], index, label, path)
        png(joinpath(path, "2a"))
    end

    # Add SparseArrays.jl CSR to plot
    label = ("SparseArrays.jl CSR")
    index = result_index(results, "ser_csr")
    if !isempty(results[index])
    	add_plot(results[index], index, label, path)
        png(joinpath(path, "3a"))
    end

    # Add SparseArrays.jl CSC to plot
    label = ("SparseArrays.jl CSC")
    index = result_index(results, "ser_csc")
    if !isempty(results[index])
    	add_plot(results[index], index, label, path)
        png(joinpath(path, "3a"))
    end
  
    
#     # Plot speedups
        
#     # MtSpMV.jl CSR
#     speedup1 = zeros(length(time3))
#     speedup2 = zeros(length(time3))
#     for i = 1:length(time1)
#         speedup1[i] = time1[i] / time3[i]
#         speedup2[i] = time2[i] / time3[i]
#     end
#     plot(msize3, speedup1, title="SpMV", dpi=300, legend=:topleft, 
#          legendfontsize=6, label="MtSpMV.jl CSR over SparseArrays.jl CSR", 
#          xlabel="Number of threads", ylabel="Parallel speedup") 
#     plot!(msize3, speedup2, linestyle=:dash, 
#           label="MtSpMV.jl CSR over SparseArrays.jl CSC")
#     png(plotA)

#     # MKLSparse.jl CSR
#     if isfile(result4_csv)
#         speedup3 = zeros(length(time4))
#         speedup4 = zeros(length(time4))
#         for i = 1:length(time1)
#             speedup3[i] = time1[i] / time4[i]
#             speedup4[i] = time2[i] / time4[i]
#         end
#         plot!(msize4, speedup3, linestyle=:dot, 
#               label="MKLSparse.jl CSR over SparseArrays.jl CSR")
#         plot!(msize4, speedup4, linestyle=:dashdot, 
#               label="MKLSparse.jl CSR over SparseArrays.jl CSC")   
#         png(plotB)
#     end
        
#     # MKLSparse.jl CSC
#     if isfile(result5_csv)
#         speedup5 = zeros(length(time5))
#         for i = 1:length(time1)
#             speedup5[i] = time2[i] / time3[i]
#         end
#         plot!(msize5, speedup5, linestyle=:dashdotdot,
#               label="MKLSparse.jl CSC over SparseArrays.jl CSC", )
#         png(plotC)     
#     end

end
                                              

# Run from command line
# ARGS[1]: path to results
plot_matsize(ARGS[1])
