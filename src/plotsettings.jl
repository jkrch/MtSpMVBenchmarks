# Plot settings

# Backend
gr()

# 
font1 = Plots.font("sans-serif", pointsize=14)
font2 = Plots.font("sans-serif", pointsize=10)
plotsettings = Dict(
	"size" => (1000,600), 
	"dpi" => 200,
    "titlefont" => font1,
    "tickfont" => font2,
    "legendfont" => font2,
    #"legendfontsize" => 10,
    "legend" => :outertopright
)