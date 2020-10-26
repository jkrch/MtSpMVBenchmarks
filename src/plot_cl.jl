using Suppressor

include("plot_nthreads.jl")
include("plot_matsize.jl")

# Run from command line
function main()
	path = ARGS[1]
	bench = ARGS[2]
	if bench == "nthreads"
		@suppress PlotNthreads.plot_runtime(path)
		@suppress PlotNthreads.plot_speedup(path)
	elseif bench == "matsize"
		@suppress PlotMatsize.plot_runtime(path)
	else
		throw(ArgumentError(bench))
	end
end
main()