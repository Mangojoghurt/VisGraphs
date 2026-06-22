export hvg, plot_hvg

"""
    hvg(x)

Construct a Horizontal Visibility Graph (HVG)
from a time series x.

Arguments:
    x::AbstractVector{<:Real}: time series containing finite numeric values.

Returns:
    Vector{Tuple{Int, Int}}: edges of the HVG.
"""
function hvg(x::AbstractVector{<:Real})

    # make sure inputs are long enough to avoid trivial graphs
    length(x) ≥ 2 || throw(ArgumentError("`x` must contain at least two values."))

    # reject non-finite values to ensure visibility comparisons are well-defined
    all(isfinite, x) || throw(ArgumentError("`x` must contain only finite values."))

    n = length(x)
    edges = Tuple{Int,Int}[]

    for i in 1:n-1

        xi = x[i]

        # keep track of maximum value to achieve O(n²) time complexity
        max_between = typemin(eltype(x))

        for j in i+1:n

            xj = x[j]

            if j > i + 1
                max_between = max(max_between, x[j-1])
            end

            if max_between < min(xi, xj)
                push!(edges, (i, j))
            end
        end
    end

    return edges
end

"""
    plot_hvg(x)

Compute and visualize the Horizontal Visibility Graph (HVG)
of a time series `x`.

The time series is plotted, and HVG edges are drawn as
lines between visible points.

Arguments:
    x::AbstractVector{<:Real}: finite-valued time series.

Returns:
    Plots.Plot: time series with HVG edges overlaid.
"""
function plot_hvg(x::AbstractVector{<:Real})

    edges = hvg(x)

    n = length(x)
    t = 1:n

    # plot time series
    plt = plot(t, x, lw=2, label="time series", xlabel="t", ylabel="x(t)", title="Horizontal Visibility Graph")

    # overlay visibility edges
    for (i, j) in edges
        plot!(plt, [i, j], [x[i], x[j]], color=:gray, alpha=0.5, label=false)
    end

    return plt
end