module PlotNthreads

# Solves problems with Plots.jl on ssh servers
# (https://github.com/JuliaPlots/Plots.jl/issues/1905#issuecomment-458778817)
ENV["GKSwstype"]="100"

using Plots
using DataFrames
using CSV
using DelimitedFiles
using Suppressor

# Load plot settings
include("plotsettings.jl")


# Get benchmark results from csv file and return as arrays
function get_results(filename::String, pos::Int)

    # Read in csv file as dataframe
    df = DataFrame!(CSV.File(filename, header=true))

    # Select nthreads and time columns
    select!(df, [1, pos+1])

    # Convert columns to arrays
    nthreads = convert(Vector{Int}, df[:, 1])
    seconds = convert(Vector{Float64}, df[:, 2])
    
    nthreads, seconds
end

# Plot nthreads to runtime
function plot_runtime(path::String)

	# Create folders for plots
	if !isdir(joinpath(path, "png"))
		mkdir(joinpath(path, "png"))
	end
	# if !isdir(joinpath(path, "svg"))
	# 	mkdir(joinpath(path, "svg"))
	# end
	# if !isdir(joinpath(path, "tex"))
	# 	mkdir(joinpath(path, "tex"))
	# end
	# if !isdir(joinpath(path, "pdf"))
	# 	mkdir(joinpath(path, "pdf"))
	# end
    
   	# Diffrent linestyles
   	linestyles = [:solid, :dash, :dot, :dashdot, :dashdotdot]

   	# Get plottitle
   	title = readlines(joinpath(path, "info.txt"))[1]
   	subtitle = readlines(joinpath(path, "info.txt"))[2]
   	if !isempty(subtitle)
   		title = string(title, "\n", subtitle)
   	end

   	for (i, bench) in enumerate(["minimum", "median", "mean"])

			# Create plot
			plot(
				title=title,
				xlabel="Number of threads",
				ylabel="Runtime (seconds)",
				size=plotsettings["size"],
				dpi=plotsettings["dpi"],
				titlefont=plotsettings["titlefont"],
				tickfont=plotsettings["tickfont"],
				legendfont=plotsettings["legendfont"],
				legend=plotsettings["legend"]
			)

		# MtSpMV.jl CSR
		result = joinpath(path, "result_par_csr.csv")
		if isfile(result)
		    nthreads, seconds = get_results(result, i)
		    plot!(nthreads, seconds, label="MtSpMV.jl CSR")
		    filename = "1a"
		    savefig(joinpath(path, "png", string(bench, "_", filename, ".png")))
		    # savefig(joinpath(path, "svg", string(bench, "_", filename, ".svg")))
		    # savefig(joinpath(path, "tex", string(bench, "_", filename, ".tex")))
		    # savefig(joinpath(path, "pdf", string(bench, "_", filename, ".pdf")))
		end

		# MKLSparse.jl CSR
		result = joinpath(path, "result_mkl_csr.csv")
		if isfile(result)
		    nthreads, seconds = get_results(result, i)
		    plot!(nthreads, seconds, label="MKLSparse.jl CSR")
		    filename = "2a"
		    savefig(joinpath(path, "png", string(bench, "_", filename, ".png")))
		    # savefig(joinpath(path, "svg", string(bench, "_", filename, ".svg")))
		    # savefig(joinpath(path, "tex", string(bench, "_", filename, ".tex")))
		    # savefig(joinpath(path, "pdf", string(bench, "_", filename, ".pdf")))
		end

		# MKLSparse.jl CSC
		result = joinpath(path, "result_mkl_csc.csv")
		if isfile(result)
		    nthreads, seconds = get_results(result, i)
		    plot!(nthreads, seconds, label="MKLSparse.jl CSC")
		    filename = "2a"
		    savefig(joinpath(path, "png", string(bench, "_", filename, ".png")))
		    # savefig(joinpath(path, "svg", string(bench, "_", filename, ".svg")))
		    # savefig(joinpath(path, "tex", string(bench, "_", filename, ".tex")))
		    # savefig(joinpath(path, "pdf", string(bench, "_", filename, ".pdf")))
		end

		# SparseArrays.jl CSR
		result = joinpath(path, "result_ser_csr.csv")
		if isfile(result)
		    seconds = get_results(result, i)[2]
		    seconds = ones(Int, length(nthreads)) * seconds[1]
		    plot!(nthreads, seconds, label="SparseArrays.jl CSR")
		    filename = "3a"
		    savefig(joinpath(path, "png", string(bench, "_", filename, ".png")))
		    # savefig(joinpath(path, "svg", string(bench, "_", filename, ".svg")))
		    # savefig(joinpath(path, "tex", string(bench, "_", filename, ".tex")))
		    # savefig(joinpath(path, "pdf", string(bench, "_", filename, ".pdf")))
		end

		# SparseArrays.jl CSC
		result = joinpath(path, "result_ser_csc.csv")
		if isfile(result)
		    seconds = get_results(result, i)[2]
		    seconds = ones(Int, length(nthreads)) * seconds[1]
		    plot!(nthreads, seconds, label="SparseArrays.jl CSC")
		    filename = "3a"
		    savefig(joinpath(path, "png", string(bench, "_", filename, ".png")))
		    # savefig(joinpath(path, "svg", string(bench, "_", filename, ".svg")))
		    # savefig(joinpath(path, "tex", string(bench, "_", filename, ".tex")))
		    # savefig(joinpath(path, "pdf", string(bench, "_", filename, ".pdf")))
		end

	end

end

# Helper function for plot_speedup()
# Compute the parallel speedup and add it to the plot
function add_speedup(label::String, csv::String, filename::String, 
					 path::String, linestyle::Symbol, bench::String, ibench::Int,)
	
	# Get serial runtimes
	seconds_ser_csr = get_results(joinpath(path, "result_ser_csr.csv"), ibench)[2][1]
	seconds_ser_csc = get_results(joinpath(path, "result_ser_csc.csv"), ibench)[2][1]
	
	# Compute parallel speedup and add to plot
    if isfile(joinpath(path, csv))
    	
    	# Get parallel runtimes
	    nthreads, seconds = get_results(joinpath(path, csv), ibench)
	    
	    # Compute speedup
	    speedup_csr = zeros(Float64, length(seconds)) 
	    speedup_csc = zeros(Float64, length(seconds)) 
	    for i in 1:length(seconds)
	    	speedup_csr[i] = seconds_ser_csr / seconds[i]
	    	speedup_csc[i] = seconds_ser_csc / seconds[i]
	    end

	    # Add to plot
	    plot!(nthreads, speedup_csr, linestyle=linestyle,
	    	label=string(label, " over SparseArrays.jl CSR"))
	    plot!(nthreads, speedup_csc, linestyle=linestyle,
	    	label=string(label, " over SparseArrays.jl CSC"))

	    # Save plot
	    savefig(joinpath(path, "png", string(bench, "_", filename, ".png")))
	    # savefig(joinpath(path, "svg", string(bench, "_", filename, ".svg")))
	    # savefig(joinpath(path, "tex", string(bench, "_", filename, ".tex")))
	    # savefig(joinpath(path, "pdf", string(bench, "_", filename, ".pdf")))
	end

end

# Plot nthreads to speedup
function plot_speedup(path::String)

	# Create folders for plots
	if !isdir(joinpath(path, "png"))
		mkdir(joinpath(path, "png"))
	end
	# if !isdir(joinpath(path, "svg"))
	# 	mkdir(joinpath(path, "svg"))
	# end
	# if !isdir(joinpath(path, "tex"))
	# 	mkdir(joinpath(path, "tex"))
	# end
	# if !isdir(joinpath(path, "pdf"))
	# 	mkdir(joinpath(path, "pdf"))
	# end

	# Diffrent linestyles
	linestyles = [:solid, :dash, :dot, :dashdot, :dashdotdot]

	# Get plottitle
	title = readlines(joinpath(path, "info.txt"))[1]
	subtitle = readlines(joinpath(path, "info.txt"))[2]
	if !isempty(subtitle)
		title = string(title, "\n", subtitle)
	end

	for (i, bench) in enumerate(["minimum", "median", "mean"])

		# Create plot
		plot(
			title=title,
			xlabel="Number of threads",
			ylabel="Parallel speedup",
			size=plotsettings["size"],
			dpi=plotsettings["dpi"],
			titlefont=plotsettings["titlefont"],
			tickfont=plotsettings["tickfont"],
			legendfont=plotsettings["legendfont"],
			legend=plotsettings["legend"]
		)

	    # MKLSparse.jl CSR
	    add_speedup("MtSpMV.jl CSR",    "result_par_csr.csv", "1b", 
	    	path, linestyles[1], bench, i)
	    add_speedup("MKLSparse.jl CSR", "result_mkl_csr.csv", "2b", 
	    	path, linestyles[3], bench, i)
	    add_speedup("MKLSparse.jl CSC", "result_mkl_csc.csv", "2b", 
	    	path, linestyles[2], bench, i)

	end

end

end # module