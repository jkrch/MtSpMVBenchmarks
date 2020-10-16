# Solves problems with Plots.jl on ssh servers
# (https://github.com/JuliaPlots/Plots.jl/issues/1905#issuecomment-458778817)
ENV["GKSwstype"]="100"

using Plots
using DataFrames
using CSV
using DelimitedFiles


# Get parallel benchmark results from csv file and return as arrays
function get_csv(filename::String)

    # Read in csv file as dataframe
    df = DataFrame!(CSV.File(filename, header=true))

    # Select nthreads and time columns
    select!(df, [1, 3])

    # Convert columns to arrays
    nthreads = convert(Vector{Int}, df[:, 1])
    time = convert(Vector{Float64}, df[:, 2])
    
    nthreads, time
    
end


# Get serial benchmark results from txt file and return as tuples
function get_txt(filename::String)

    # Get lines with serial results
    s1 = readlines(filename)[8]
    s2 = readlines(filename)[12]
    
    # Get times
    timecsr = parse(Float64, s1[4:length(s1)])
    timecsc = parse(Float64, s2[4:length(s2)])
                     
    timecsr, timecsc
    
end


# Create and save plots for number threads to time and for number of threads to 
# speedup
function plot_nthreads(method::String, folder::String)

    # Folder path of results
    path = joinpath(dirname(@__FILE__), folder)
    
    # File paths of results
    result1_csv = joinpath(path, "result1.csv")
    result2_csv = joinpath(path, "result2.csv")
    result3_csv = joinpath(path, "result3.csv")
    results_txt = joinpath(path, "results.txt")
    
    # File paths of plots
    plot1 = joinpath(path, "1a")
    plot2 = joinpath(path, "2a")
    plot3 = joinpath(path, "3a")
    plotA = joinpath(path, "1b")
    plotB = joinpath(path, "2b")
    plotC = joinpath(path, "3b")
    
    
    # Plot benchmark times
    
    # Get plottitle
    title = string(readlines(results_txt)[3], "\n", readlines(results_txt)[4])

    # MtSpMV.jl CSR
    nthreads1, time1 = get_csv(result1_csv)
    plot(nthreads1, time1, title=title, dpi=300, label="MtSpMV.jl CSR",
         xlabel="Number of threads", ylabel="Time in seconds")
    png(plot1)

    # MKLSparse.jl CSR
    if isfile(result2_csv)
        nthreads2, time2 = get_csv(result2_csv)
        plot!(nthreads2, time2, label="MKLSparse.jl CSR", linestyle=:dash) 
        png(plot2)
    end
    
    # MKLSparse.jl CSC
    if isfile(result3_csv)
        nthreads3, time3 = get_csv(result3_csv)
        plot!(nthreads3, time3, label="MKLSparse.jl CSC", linestyle=:dot)
        png(plot3)     
    end
    
    
    # Plot speedups
    
    # Get serial times
    sertimecsr, sertimecsc = get_txt(results_txt)
    
    # MtSpMV.jl CSR
    speedup1 = zeros(length(time1))
    speedup2 = zeros(length(time1))
    for i = 1:length(time1)
        speedup1[i] = sertimecsr / time1[i]
        speedup2[i] = sertimecsc / time1[i]
    end
    plot(nthreads1, speedup1, title=title, dpi=300, legend=:topleft, 
         legendfontsize=6, label="MtSpMV.jl CSR over SparseArrays.jl CSR", 
         xlabel="Number of threads", ylabel="Parallel speedup") 
    plot!(nthreads1, speedup2, linestyle=:dash, 
          label="MtSpMV.jl CSR over SparseArrays.jl CSC")
    png(plotA)

    # MKLSparse.jl CSR
    if isfile(result2_csv)
        speedup3 = zeros(length(time2))
        speedup4 = zeros(length(time2))
        for i = 1:length(time1)
            speedup3[i] = sertimecsr / time2[i]
            speedup4[i] = sertimecsc / time2[i]
        end
        plot!(nthreads2, speedup3, linestyle=:dot, 
              label="MKLSparse.jl CSR over SparseArrays.jl CSR")
        plot!(nthreads2, speedup4, linestyle=:dashdot, 
              label="MKLSparse.jl CSR over SparseArrays.jl CSC")   
        png(plotB)
    end
        
    # MKLSparse.jl CSC
    if isfile(result3_csv)
        speedup5 = zeros(length(time3))
        for i = 1:length(time1)
            speedup5[i] = sertimecsc / time3[i]
        end
        plot!(nthreads3, speedup5, linestyle=:dashdotdot,
              label="MKLSparse.jl CSC over SparseArrays.jl CSC", )
        png(plotC)     
    end

end


# Create and save plots for matrix size to time and for matrix size to speedup
function plot_msize(method::String, folder::String)

    # Folder path of results
    path = joinpath(dirname(@__FILE__), folder)
    
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
    
    
    # Plot benchmark times

    # MtSpMV.jl CSR and SparseArrays.jl CSR and CSC
    msize1, time1 = get_csv(result1_csv)
    plot(msize1, time1, title="SpMV", dpi=300, label="SparseArrays.jl CSR",
         xlabel="Matrix size", ylabel="Time in seconds")
    msize2, time2 = get_csv(result2_csv)
    plot!(msize2, time2, label="SparseArrays.jl CSR", linestyle=:dash)
    msize3, time3 = get_csv(result3_csv)
    plot!(msize3, time3, label="MtSpMV.jl CSR", linestyle=:dot)
    png(plot1) 
    
    # MKLSparse.jl CSR
    if isfile(result4_csv)
        msize4, time4 = get_csv(result4_csv)
        plot!(msize4, time4, label="MKLSparse.jl CSR", linestyle=:dashdotdot) 
        png(plot2)
    end
        
    # MKLSparse.jl CSC
    if isfile(result5_csv)
        msize5, time5 = get_csv(result5_csv)
        plot!(msize5, time5, label="MKLSparse.jl CSC", linestyle=:dashdot)
        png(plot3)     
    end
    
    
    # Plot speedups
        
    # MtSpMV.jl CSR
    speedup1 = zeros(length(time3))
    speedup2 = zeros(length(time3))
    for i = 1:length(time1)
        speedup1[i] = time1[i] / time3[i]
        speedup2[i] = time2[i] / time3[i]
    end
    plot(msize3, speedup1, title="SpMV", dpi=300, legend=:topleft, 
         legendfontsize=6, label="MtSpMV.jl CSR over SparseArrays.jl CSR", 
         xlabel="Number of threads", ylabel="Parallel speedup") 
    plot!(msize3, speedup2, linestyle=:dash, 
          label="MtSpMV.jl CSR over SparseArrays.jl CSC")
    png(plotA)

    # MKLSparse.jl CSR
    if isfile(result4_csv)
        speedup3 = zeros(length(time4))
        speedup4 = zeros(length(time4))
        for i = 1:length(time1)
            speedup3[i] = time1[i] / time4[i]
            speedup4[i] = time2[i] / time4[i]
        end
        plot!(msize4, speedup3, linestyle=:dot, 
              label="MKLSparse.jl CSR over SparseArrays.jl CSR")
        plot!(msize4, speedup4, linestyle=:dashdot, 
              label="MKLSparse.jl CSR over SparseArrays.jl CSC")   
        png(plotB)
    end
        
    # MKLSparse.jl CSC
    if isfile(result5_csv)
        speedup5 = zeros(length(time5))
        for i = 1:length(time1)
            speedup5[i] = time2[i] / time3[i]
        end
        plot!(msize5, speedup5, linestyle=:dashdotdot,
              label="MKLSparse.jl CSC over SparseArrays.jl CSC", )
        png(plotC)     
    end

end


# Plot nthreads or msize
function main(bench::String, method::String, folder::String)
    if bench == "nthreads"
        plot_nthreads(method, folder)
    elseif bench == "msize"
        plot_msize(method, folder)
    end
end
                                              

# Run from command line
# ARGS[1]: benchmark type (nthreads or msize)
# ARGS[2]: method (spmv, cg, gmres, ...)
# ARGS[3]: foldername of the results
main(ARGS[1], ARGS[2], ARGS[3])

