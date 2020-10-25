# Plot settings

# Backend
gr()

# Plot size 
font1 = Plots.font("sans-serif", pointsize=12)
font2 = Plots.font("sans-serif", pointsize=8)
default(titlefont=font1)
default(guidefont=font2, tickfont=font2, legendfont=font2, legendfontsize=font2)
default(size=(800,600))
default(dpi=200)