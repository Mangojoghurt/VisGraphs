"""
    generate_sine(n::Int=100)

Generate a sine wave time series.

Returns:
    Vector{Float64}: sine wave sampled over [0, 4π].
"""
function generate_sine(n::Int=100)
    return sin.(range(0, 4π, length=n))
end

"""
    generate_random(n::Int=100)

Generate a random time series.

Returns:
    Vector{Float64}: uniformly distributed random values in [0, 1).
"""
function generate_random(n::Int=100)
    return rand(n)
end


"""
    generate_noisy_sine(n::Int=100, noise::Float64=0.2)

Generate a noisy sine wave time series.

The signal is a sine wave over [0, 4π] with added Gaussian noise.

Returns:
    Vector{Float64}: noisy sine wave.
"""
function generate_noisy_sine(n::Int=100, noise::Float64=0.2)
    return sin.(range(0, 4π, length=n)) .+ noise .* randn(n)
end