"""
    generate_sine(n::Int=100)

Generate a sine wave sampled at `n` evenly spaced points over the interval
``[0, 4π]``.

The returned signal contains one complete sine wave with two periods and is
primarily intended for testing, examples, and benchmarking algorithms that
operate on time series.

# Examples
```jldoctest
julia> length(generate_sine())
100

julia> generate_sine(5)
5-element Vector{Float64}:
  0.0
  1.2246467991473532e-16
 -2.4492935982947064e-16
  3.6739403974420594e-16
 -4.898587196589413e-16
```
"""
function generate_sine(n::Int=100)
    return sin.(range(0, 4π, length=n))
end

"""
    generate_random(n::Int=100)

Generate a random time series of length `n`.

Each sample is drawn independently from a uniform distribution on the interval
``[0, 1)`` using Julia's default random number generator. The resulting series
is useful for testing and benchmarking algorithms on unstructured data.

# Examples
```jldoctest
julia> length(generate_random())
100

julia> all(0 .<= generate_random(10) .< 1)
true
```
"""
function generate_random(n::Int=100)
    return rand(n)
end


"""
    generate_noisy_sine(n::Int=100, noise::Float64=0.2)

Generate a sine wave with additive Gaussian noise.

The underlying signal is sampled at `n` evenly spaced points over the interval
``[0, 4π]``. Independent Gaussian noise with standard deviation `noise` is
added to each sample.

This function is useful for testing the robustness of time-series algorithms
under noisy conditions.

# Examples
```jldoctest
julia> length(generate_noisy_sine())
100

julia> generate_noisy_sine(5, 0.0) == generate_sine(5)
true
```
"""
function generate_noisy_sine(n::Int=100, noise::Float64=0.2)
    return sin.(range(0, 4π, length=n)) .+ noise .* randn(n)
end