function generate_sine(n::Int=100)
    return sin.(range(0, 4π, length=n))
end

function generate_random(n::Int=100)
    return rand(n)
end

function generate_noisy_sine(n::Int=100, noise::Float64=0.2)
    return sin.(range(0, 4π, length=n)) .+ noise .* randn(n)
end