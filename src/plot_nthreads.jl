module PlotNthreads

# Solves problems with Plots.jl on ssh servers
# (https://github.com/JuliaPlots/Plots.jl/issues/1905#issuecomment-458778817)
ENV["GKSwstype"]="100"

using Plots
using DataFrames
using CSV
using DelimitedFiles
using Suppressor

include("plotsettings.jl")


# Get benchmark results from csv file and return as arrays
function get_results(filename::String)

    # Read in csv file as dataframe
    df = DataFrame!(CSV.File(filename, header=true))

    # Select nthreads and time columns
    select!(df, [1, 3])

    # Convert columns to arrays
    nthreads = convert(Vector{Int}, df[:, 1])
    seconds = convert(Vector{Float64}, df[:, 2])
    
    nthreads, seconds
end

# Plot nthreads to runtime
function plot_runtime(path::String)
    
   	# Diffrent linestyles
   	linestyles = [:solid, :dash, :dot, :dashdot, :dashdotdot]

   	# Get plottitle
   	title = readlines(joinpath(path, "info.txt"))[1]
   	subtitle = readlines(joinpath(path, "info.txt"))[2]
   	if !isempty(subtitle)
   		title = string(title, "\n", subtitle)
   	end

   	# Create plot
   	plot(title=title,
   		 xlabel="Number of threads",
   		 ylabel="Runtime (seconds)",
   		 legend=:outertopright)
    
    # MtSpMV.jl CSR
    result = joinpath(path, "result_par_csr.csv")
    if isfile(result)
	    nthreads, seconds = get_results(result)
	    plot!(nthreads, seconds, label="MtSpMV.jl CSR")
	    filename = "1a"
	    savefig(joinpath(path, string(filename, ".png")))
	    # savefig(joinpath(path, string(filename, ".svg")))
	    # savefig(joinpath(path, string(filename, ".tex")))
	    # savefig(joinpath(path, string(filename, ".pdf")))
	end

    # MKLSparse.jl CSR
    result = joinpath(path, "result_mkl_csr.csv")
    if isfile(result)
	    nthreads, seconds = get_results(result)
	    plot!(nthreads, seconds, label="MKLSparse.jl CSR")
	    filename = "2a"
	    savefig(joinpath(path, string(filename, ".png")))
	    # savefig(joinpath(path, string(filename, ".svg")))
	    # savefig(joinpath(path, string(filename, ".tex")))
	    # savefig(joinpath(path, string(filename, ".pdf")))
	end

    # MKLSparse.jl CSC
    result = joinpath(path, "result_mkl_csc.csv")
    if isfile(result)
	    nthreads, seconds = get_results(result)
	    plot!(nthreads, seconds, label="MKLSparse.jl CSC")
	    filename = "2a"
	    savefig(joinpath(path, string(filename, ".png")))
	    # savefig(joinpath(path, string(filename, ".svg")))
	    # savefig(joinpath(path, string(filename, ".tex")))
	    # savefig(joinpath(path, string(filename, ".pdf")))
	end

    # SparseArrays.jl CSR
    result = joinpath(path, "result_ser_csr.csv")
    if isfile(result)
	    seconds = get_results(result)[2]
	    seconds = ones(Int, length(nthreads)) * seconds[1]
	    plot!(nthreads, seconds, label="SparseArrays.jl CSR")
	    filename = "3a"
	    savefig(joinpath(path, string(filename, ".png")))
	    # savefig(joinpath(path, string(filename, ".svg")))
	    # savefig(joinpath(path, string(filename, ".tex")))
	    # savefig(joinpath(path, string(filename, ".pdf")))
	end

    # SparseArrays.jl CSC
    result = joinpath(path, "result_ser_csc.csv")
    if isfile(result)
	    seconds = get_results(result)[2]
	    seconds = ones(Int, length(nthreads)) * seconds[1]
	    plot!(nthreads, seconds, label="SparseArrays.jl CSC")
	    filename = "3a"
	    savefig(joinpath(path, string(filename, ".png")))
	    # savefig(joinpath(path, string(filename, ".svg")))
	    # savefig(joinpath(path, string(filename, ".tex")))
	    # savefig(joinpath(path, string(filename, ".pdf")))
	end

end

# # Plot nthreads to speedup
# function plot_speedup(path::String)

# 	# Diffrent linestyles
# 	linestyles = [:solid, :dash, :dot, :dashdot, :dashdotdot]

# 	# Get plottitle
# 	title = readlines(joinpath(path, "info.txt"))[1]
# 	subtitle = readlines(joinpath(path, "info.txt"))[2]
# 	if !isempty(subtitle)
# 		title = string(title, "\n", subtitle)
# 	end

# 	# Create plot
# 	plot(xlabel="Number of threads",
# 		 ylabel="Parallel speedup",
# 		 legend=:outertopright,
# 		 title=title)

# 	# Get serial runtimes
# 	seconds_ser_csr = get_results(joinpath(path, "result_ser_csr.csv"))[2]
# 	seconds_ser_csc = get_results(joinpath(path, "result_ser_csr.csv"))[2]
   
#     # MtSpMV.jl CSR
#     result = joinpath(path, "result_par_csr.csv")
#     if isfile(result)
# 	    nthreads, seconds = get_results(result)
# 	    speedup_csr = 
# 	    speedup_csc
# 	    for ispeedup in speedup
# 	    	ispeedup = seconds_ser_csr

# 	        # end
# 	    plot!(nthreads, seconds, label="MtSpMV.jl CSR")
# 	    filename = "1a"
# 	    savefig(joinpath(path, string(filename, ".png")))
# 	    # savefig(joinpath(path, string(filename, ".svg")))
# 	    # savefig(joinpath(path, string(filename, ".tex")))
# 	    # savefig(joinpath(path, string(filename, ".pdf")))
# 	end



#     result = joinpath(path, "result_ser_csr.csv")
#     if isfile(result)
# 	    speedup = get_results(result)[2]
# 	    speedup = ones(Int, length(nthreads)) * seconds[1]
#     if isfile(result)
# 	    seconds = get_results(result)[2]
# 	    seconds = ones(Int, length(nthreads)) * seconds[1]
# 	    plot!(nthreads, seconds, label="SparseArrays.jl CSR")
# 	    filename = "3a"
# 	    savefig(joinpath(path, string(filename, ".png")))
# 	    # savefig(joinpath(path, string(filename, ".svg")))
# 	    # savefig(joinpath(path, string(filename, ".tex")))
# 	    # savefig(joinpath(path, string(filename, ".pdf")))
# 	end
    
    
#     # Get serial times
#     sertimecsr = get_results(joinpath(path, "result_ser_csr.csv"))
#     sertimecsc = get_results(joinpath(path, "result_ser_csc.csv"))
    
#     # # MtSpMV.jl CSR
#     # speedup1 = zeros(length(time1))
#     # speedup2 = zeros(length(time1))
#     # for i = 1:length(time1)
#     #     speedup1[i] = sertimecsr / time1[i]
#     #     speedup2[i] = sertimecsc / time1[i]
#     # end
#     # plot(nthreads1, speedup1, title=title, dpi=300, legend=:topleft, 
#     #      legendfontsize=6, label="MtSpMV.jl CSR over SparseArrays.jl CSR", 
#     #      xlabel="Number of threads", ylabel="Parallel speedup") 
#     # plot!(nthreads1, speedup2, linestyle=:dash, 
#     #       label="MtSpMV.jl CSR over SparseArrays.jl CSC")
#     # png(plotA)

#     # # MKLSparse.jl CSR
#     # if isfile(result2_csv)
#     #     speedup3 = zeros(length(time2))
#     #     speedup4 = zeros(length(time2))
#     #     for i = 1:length(time1)
#     #         speedup3[i] = sertimecsr / time2[i]
#     #         speedup4[i] = sertimecsc / time2[i]
#     #     end
#     #     plot!(nthreads2, speedup3, linestyle=:dot, 
#     #           label="MKLSparse.jl CSR over SparseArrays.jl CSR")
#     #     plot!(nthreads2, speedup4, linestyle=:dashdot, 
#     #           label="MKLSparse.jl CSR over SparseArrays.jl CSC")   
#     #     png(plotB)
#     # end
        
#     # # MKLSparse.jl CSC
#     # if isfile(result3_csv)
#     #     speedup5 = zeros(length(time3))
#     #     for i = 1:length(time1)
#     #         speedup5[i] = sertimecsc / time3[i]
#     #     end
#     #     plot!(nthreads3, speedup5, linestyle=:dashdotdot,
#     #           label="MKLSparse.jl CSC over SparseArrays.jl CSC", )
#     #     png(plotC)     
#     # end

# end


# Run from command line
# ARGS[1]: path to results
@suppress plot_runtime(ARGS[1])

end # module
