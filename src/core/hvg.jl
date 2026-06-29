export hvg, plot_hvg, whvg, plot_whvg

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
"""
    whvg(x)

Construct a Weighted Horizontal Visibility Graph (WHVG)
from a time series x.

Each edge carries a weight equal to the angle (in radians)
of the line of sight between the two nodes:

    weight(i, j) = atan(x[j] - x[i], j - i)

This follows the definition from Donges et al. (2013).

Arguments:
    x::AbstractVector{<:Real}: time series containing finite numeric values.

Returns:
    Vector{Tuple{Int, Int, Float64}}: weighted edges of the WHVG.
"""
function whvg(x::AbstractVector{<:Real})

    # make sure inputs are long enough to avoid trivial graphs
    length(x) ≥ 2 || throw(ArgumentError("`x` must contain at least two values."))

    # reject non-finite values to ensure visibility comparisons are well-defined
    all(isfinite, x) || throw(ArgumentError("`x` must contain only finite values."))

    n = length(x)
    edges = Tuple{Int,Int,Float64}[]

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
                weight = atan(xj - xi, float(j - i))
                push!(edges, (i, j, weight))
            end
        end
    end

    return edges
end

"""
    plot_whvg(x)

Compute and visualize the Weighted Horizontal Visibility Graph (WHVG)
of a time series `x`.

Edges are coloured by weight (the angle of the line of sight),
from blue (negative / shallow) to red (positive / steep).

Arguments:
    x::AbstractVector{<:Real}: finite-valued time series.

Returns:
    Plots.Plot: time series with WHVG edges overlaid.
"""
function plot_whvg(x::AbstractVector{<:Real})

    edges = whvg(x)

    n = length(x)
    t = 1:n

    weights = [w for (_, _, w) in edges]
    wmin, wmax = extrema(weights)
    wrange = wmax - wmin

    plt = plot(t, x, lw=2, label="time series", xlabel="t", ylabel="x(t)",
               title="Weighted Horizontal Visibility Graph")

    for (i, j, w) in edges
        # normalise weight to [0, 1] for colour mapping
        c = wrange ≈ 0.0 ? 0.5 : (w - wmin) / wrange
        color = RGB(c, 0.0, 1.0 - c)
        plot!(plt, [i, j], [x[i], x[j]], color=color, alpha=0.6, label=false)
    end

    return plt
end
