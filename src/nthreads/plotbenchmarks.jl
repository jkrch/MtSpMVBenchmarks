module PlotBenchmarks

# Solves problems with Plots.jl on ssh servers
# (https://github.com/JuliaPlots/Plots.jl/issues/1905#issuecomment-458778817)
ENV["GKSwstype"]="100"

using Plots
using DataFrames
using CSV
using DelimitedFiles


# Convert benchmark results from csv file to arrays
# TODO: Handle time unites > seconds
function getarrays(filename::String)

    # Read in csv file as dataframe
    df = DataFrame!(CSV.File(filename, header=false))

#    # Remove last (empty) row
#    delete!(df, length(df[!, 1]))

    # Name needed columns
    rename!(df, [1 => "nthreads", 3 => "btime", 4 => "unit"])

    # Select needed columns
    select!(df, ["nthreads", "btime", "unit"])
    
    # Time unit conversion factors
    convdict = Dict("s" => 1, "ms" => 1e-3, "μs" => 1e-6, "ns" => 1e-9)

    # Dataframe columns to arrays
    nthreads = convert(Vector{Int}, df[:, 1])
    btime = convert(Vector{Float64}, df[:, 2])
    unit = convert(Vector{String}, df[:, 3])

    # Time unit conversion factors
    conv = ("ms" => 1e-3, "μs" => 1e-6, "ns" => 1e-9)

    # Convert all btime entrys to unit of first entry
    for i = 1:length(unit)
        for j = 1:length(conv)
            if unit[i] == conv[j][1]
                btime[i] = btime[i] * conv[j][2] 
            end
        end
        unit[i] = "s"
    end
    
    nthreads, btime, unit
end


# Create and save plots
# TODO: Change strings to booleans
function plotresults(method::String, folder::String, mkl_csr::String, mkl_csc::String)

    # Filepaths
    result1_csv = string(method, "/", folder, "/result1.csv")
    result2_csv = string(method, "/", folder, "/result2.csv")
    result3_csv = string(method, "/", folder, "/result3.csv")
    results_txt = string(method, "/", folder, "/results.txt")
    plot1 = string(method, "/", folder, "/1")
    plot2 = string(method, "/", folder, "/2")
    plot3 = string(method, "/", folder, "/3")

    # Get results for my csr from csv file
    nthreads, btime, unit = getarrays(result1_csv)
    
    # Get plottitle
    title = string(readlines(results_txt)[3], "\n", readlines(results_txt)[4])
    
    # Create plot
    plot(nthreads, btime, title=title, label="MtSpMV.jl CSR", dpi=300, 
         xlabel="nthreads", ylabel=string("time in ", unit[1]))
         
    # Save plot
    png(plot1)

    # Add mkl csr
    if mkl_csr == "true"
        # Get results from csv file
        nthreads, btime, unit = getarrays(result2_csv)
        
        # Add to plot
        plot!(nthreads, btime, label="MKLSparse.jl CSR", linestyle=:dash) 
        
        # Save plot
        png(plot2)
    end
        
    # Add mkl csc
    if mkl_csc == "true"
        # Get results from csv file
        nthreads, btime, unit = getarrays(result3_csv)
        
        # Add to plot
        plot!(nthreads, btime, label="MKLSparse.jl CSC", linestyle=:dot)
        
        # Save plot
        png(plot3)     
    end

end


# Run from command line
# TODO: Use ArgParse.jl for better arguments
plotresults(ARGS[1], ARGS[2], ARGS[3], ARGS[4])


end #module

