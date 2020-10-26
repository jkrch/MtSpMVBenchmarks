using BenchmarkTools

import BenchmarkTools: prunekwargs, hasevals

# Adapted from BenchmarkTools.btime() https://github.com/JuliaCI/BenchmarkTools.jl/blob/5f8b7f2880b68e019d8cd65317f275b1b1d1ca03/src/execution.jl#L474
# Returns the *median* (instead of the *minimum* in btime) elapsed time (in 
# seconds instead in pretty time in btime).
# No output about memory and no tuning phase.
macro mybtimes(args...)
    _, params = prunekwargs(args...)
    bench, trial, result = gensym(), gensym(), gensym()
    trialmin = gensym()
    trialmed = gensym()
    trialmean = gensym()
    return esc(quote
        local $bench = $BenchmarkTools.@benchmarkable $(args...)
        $BenchmarkTools.warmup($bench)
        local $trial, $result = $BenchmarkTools.run_result($bench)
        local $trialmin = $BenchmarkTools.minimum($trial)
        local $trialmed = $BenchmarkTools.median($trial)
        local $trialmean = $BenchmarkTools.mean($trial)
        println(" ", $BenchmarkTools.time($trialmin)/1e9,
        		" ", $BenchmarkTools.time($trialmed)/1e9,
        		" ", $BenchmarkTools.time($trialmean)/1e9)
        $result
    end)
end