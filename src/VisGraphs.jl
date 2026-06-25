module VisGraphs

using Plots
using Plots.Colors: RGB

include("core/hvg.jl")
include("core/nvg.jl")
include("datasets/signals.jl")

export generate_sine, generate_random, generate_noisy_sine
export hvg, plot_hvg, nvg, plot_nvg
export whvg, plot_whvg, wnvg, plot_wnvg

end
