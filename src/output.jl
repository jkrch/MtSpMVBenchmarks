using BenchmarkTools

import BenchmarkTools: prunekwargs, hasevals

# Adapted from BenchmarkTools.btime() https://github.com/JuliaCI/BenchmarkTools.jl/blob/5f8b7f2880b68e019d8cd65317f275b1b1d1ca03/src/execution.jl#L474
# Returns the *median* (instead of the *minimum* in btime) elapsed time (in 
# seconds instead in pretty time in btime).
# No output about memory and no tuning phase.
macro benchmed(args...)
    _, params = prunekwargs(args...)
    bench, trial, result = gensym(), gensym(), gensym()
    trialmed = gensym()
    return esc(quote
        local $bench = $BenchmarkTools.@benchmarkable $(args...)
        $BenchmarkTools.warmup($bench)
        local $trial, $result = $BenchmarkTools.run_result($bench)
        local $trialmed = $BenchmarkTools.median($trial)
        println("  ", $BenchmarkTools.time($trialmed)/1e9)
        $result
    end)
end