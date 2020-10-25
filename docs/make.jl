using Documenter
using MtSpMTBenchmarks

makedocs(
    sitename = "MtSpMTBenchmarks",
    format = Documenter.HTML(),
    modules = [MtSpMTBenchmarks]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
