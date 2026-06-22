module VisGraphs

using Plots

include("core/hvg.jl")
include("core/nvg.jl")
include("datasets/signals.jl")

export generate_sine, generate_random, generate_noisy_sine
export hvg, plot_hvg, nvg, plot_nvg

end