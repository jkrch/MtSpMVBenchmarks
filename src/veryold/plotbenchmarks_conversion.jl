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
    df = DataFrame!(CSV.File(filename, header=false))

#    # Remove last (empty) row
#    delete!(df, length(df[!, 1]))

    # Name needed columns
    rename!(df, [1 => "nthreads", 3 => "time", 4 => "unit"])

    # Select needed columns
    select!(df, ["nthreads", "time", "unit"])
    
    # Time unit conversion factors
    convdict = Dict("s" => 1, "ms" => 1e-3, "μs" => 1e-6, "ns" => 1e-9)

    # Dataframe columns to arrays
    nthreads = convert(Vector{Int}, df[:, 1])
    time = convert(Vector{Float64}, df[:, 2])
    unit = convert(Vector{String}, df[:, 3])

    # Time unit conversion factors
    conv = ["ms" => 1e-3, "μs" => 1e-6, "ns" => 1e-9]

    # Convert all time entrys to seconds
    for i = 1:length(time)
        for j = 1:length(conv)
            if unit[i] == conv[j][1]
                time[i] = time[i] * conv[j][2] 
            end
        end
    end
    
    nthreads, time
    
end


# Get serial benchmark results from txt file and return as tuples
function get_serial_results(filename::String)

    # Get lines with serial results
    s = [readlines(filename)[7], readlines(filename)[10]]
    
    # Get times
    first = [4, 4]
    last = [findnext(isequal(' '), s[1], 4) - 1, 
            findnext(isequal(' '), s[2], 4) - 1]
    time = [parse(Float64, s[1][4:last[1]]),
            parse(Float64, s[2][4:last[2]])]
                  
    # Get units
    first = [findnext(isequal(' '), s[1], 4) + 1, 
             findnext(isequal(' '), s[2], 4) + 1]
    last = [findnext(isequal(' '), s[1], first[1]) - 1, 
            findnext(isequal(' '), s[2], first[2]) - 1]             
    unit = [s[1][first[1]:last[1]],
            s[2][first[2]:last[2]]]
            
                  
     # Time unit conversion factors
    conv = ["ms" => 1e-3, "μs" => 1e-6, "ns" => 1e-9]
                  
    # Convert all time entrys to seconds
    for i = 1:length(time)
        for j = 1:length(conv)
            if unit[i] == conv[j][1]
                time[i] = time[i] * conv[j][2] 
            end
        end
    end
                  
    time
    
end


# Create and save plots for nthreads to time and for nthreads to speedup
function plotresults(method::String, header::String, mkl_csr::String, mkl_csc::String)

    # Folder path of results
    folder = string(method, "/", header)
    
    # File paths of results
    result1_csv = string(folder, "/result1.csv")
    result2_csv = string(folder, "/result2.csv")
    result3_csv = string(folder, "/result3.csv")
    results_txt = string(folder, "/results.txt")
    
    # File paths of plots
    plot1 = string(folder, "/1")
    plot2 = string(folder, "/2")
    plot3 = string(folder, "/3")
    plotA = string(folder, "/A")
    plotB = string(folder, "/B")
    plotC = string(folder, "/C")
    
    # Get plottitle
    title = string(readlines(results_txt)[3], "\n", readlines(results_txt)[4])
    
    
    # Plot nthreads to time

    # Get results for my csr from csv file
    nthreads1, time1 = get_parallel_results(result1_csv)
    
    # Create plot
    plot(nthreads1, time1, title=title, dpi=300, label="MtSpMV.jl CSR",
         xlabel="Number of threads", ylabel="Time in seconds")
         
    # Save plot
    png(plot1)

    # Add mkl csr
    if mkl_csr == "true"
    
        # Get results from csv file
        nthreads2, time2 = get_parallel_results(result2_csv)
        
        # Add to plot
        plot!(nthreads2, time2, label="MKLSparse.jl CSR", linestyle=:dash) 
        
        # Save plot
        png(plot2)
    end
        
    # Add mkl csc
    if mkl_csc == "true"
    
        # Get results from csv file
        nthreads3, time3 = get_parallel_results(result3_csv)
        
        # Add to plot
        plot!(nthreads3, time3, label="MKLSparse.jl CSR & MKL.jl", linestyle=:dot)
        
        # Save plot
        png(plot3)     
    end
    
    
    # Plot nthreads to speedup
    
    # Get serial result for csr and csc
    serialtime = get_serial_results(results_txt)
    
    # Compute speedups
    speedup1 = zeros(length(time1))
    speedup2 = zeros(length(time1))
    for i = 1:length(time1)
        speedup1[i] = serialtime[1] / time1[i]
        speedup2[i] = serialtime[2] / time1[i]
    end
    
    # Create plot
    plot(nthreads1, speedup1, title=title, dpi=300, legend=:topleft, 
         legendfontsize=6, label="MtSpMV.jl CSR over SparseArrays.jl CSR", 
         xlabel="Number of threads", ylabel="Parallel speedup")
    
    # Add plot     
    plot!(nthreads1, speedup2, linestyle=:dash, 
          label="MtSpMV.jl CSR over SparseArrays.jl CSC") 
         
    # Save plot
    png(plotA)

    # Add mkl csr
    if mkl_csr == "true"
    
        # Compute speedups
        speedup3 = zeros(length(time2))
        speedup4 = zeros(length(time2))
        for i = 1:length(time1)
            speedup3[i] = serialtime[1] / time2[i]
            speedup4[i] = serialtime[2] / time2[i]
        end
        
        # Add to plot
        plot!(nthreads2, speedup3, linestyle=:dot, 
              label="MKLSparse.jl CSR over SparseArrays.jl CSR")
              
        # Add to plot
        plot!(nthreads2, speedup4, linestyle=:dashdot, 
              label="MKLSparse.jl CSR over SparseArrays.jl CSC")   
        
        # Save plot
        png(plotB)
    end
        
    # Add mkl csc
    if mkl_csc == "true"
    
        # Compute speedups
        speedup5 = zeros(length(time3))
        for i = 1:length(time1)
            speedup5[i] = serialtime[2] / time3[i]
        end
        
        # Add to plot
        plot!(nthreads3, speedup5, linestyle=:dashdotdot,
              label="MKLSparse.jl CSC over SparseArrays.jl CSC", )
        
        # Save plot
        png(plotC)     
    end

end
                                                 

# TODO: Use ArgParse.jl
plotresults(ARGS[1], ARGS[2], ARGS[3], ARGS[4])

