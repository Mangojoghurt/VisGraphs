module VisGraphs

include("core/hvg.jl")
include("core/nvg.jl")
include("datasets/signals.jl")

export generate_sine, generate_random, generate_noisy_sine
export hvg, nvg

end