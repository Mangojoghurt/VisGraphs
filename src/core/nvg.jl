export nvg, plot_nvg, wnvg, plot_wnvg

"""
    nvg(x)

Construct a Natural Visibility Graph (NVG)
from a time series x.

Arguments:
    x::AbstractVector{<:Real}: time series containing finite numeric values.

Returns:
    Vector{Tuple{Int, Int}}: edges of the NVG.
"""
function nvg(x::AbstractVector{<:Real})

    # make sure inputs are long enough to avoid trivial graphs
    length(x) ≥ 2 || throw(ArgumentError("`x` must contain at least two values."))

    # reject non-finite values to ensure visibility comparisons are well-defined
    all(isfinite, x) || throw(ArgumentError("`x` must contain only finite values."))

    n = length(x)
    edges = Tuple{Int,Int}[]

    for i in 1:n-1

        xi = x[i]

        for j in i+1:n

            xj = x[j]

            # precompute denominator for interpolation
            denom = j - i
            visible = true

            for k in i+1:j-1

                # linear interpolation between i and j
                x_interp = xi + (xj - xi) * (k - i) / denom

                if x[k] >= x_interp
                    visible = false
                    break
                end
            end

            if visible
                push!(edges, (i, j))
            end
        end
    end

    return edges
end

"""
    plot_nvg(x)

Compute and visualize the Natural Visibility Graph (NVG)
of a time series `x`.

The time series is plotted, and NVG edges are drawn as
lines between visible points.

Arguments:
    x::AbstractVector{<:Real}: finite-valued time series.

Returns:
    Plots.Plot: time series with NVG edges overlaid.
"""
function plot_nvg(x::AbstractVector{<:Real})

    edges = nvg(x)

    n = length(x)
    t = 1:n

    # plot time series
    plt = plot(t, x, lw=2, label="time series", xlabel="t", ylabel="x(t)", title="Natural Visibility Graph")

    # overlay visibility edges
    for (i, j) in edges
        plot!(plt, [i, j], [x[i], x[j]], color=:gray, alpha=0.5, label=false)
    end

    return plt
end
"""
    wnvg(x)

Construct a Weighted Natural Visibility Graph (WNVG)
from a time series x.

Each edge carries a weight equal to the angle (in radians)
of the line of sight between the two nodes:

    weight(i, j) = atan(x[j] - x[i], j - i)

This follows the definition from Donges et al. (2013).

Arguments:
    x::AbstractVector{<:Real}: time series containing finite numeric values.

Returns:
    Vector{Tuple{Int, Int, Float64}}: weighted edges of the WNVG.
"""
function wnvg(x::AbstractVector{<:Real})

    # make sure inputs are long enough to avoid trivial graphs
    length(x) ≥ 2 || throw(ArgumentError("`x` must contain at least two values."))

    # reject non-finite values to ensure visibility comparisons are well-defined
    all(isfinite, x) || throw(ArgumentError("`x` must contain only finite values."))

    n = length(x)
    edges = Tuple{Int,Int,Float64}[]

    for i in 1:n-1

        xi = x[i]

        for j in i+1:n

            xj = x[j]

            # precompute denominator for interpolation
            denom = j - i
            visible = true

            for k in i+1:j-1

                # linear interpolation between i and j
                x_interp = xi + (xj - xi) * (k - i) / denom

                if x[k] >= x_interp
                    visible = false
                    break
                end
            end

            if visible
                weight = atan(xj - xi, float(denom))
                push!(edges, (i, j, weight))
            end
        end
    end

    return edges
end

"""
    plot_wnvg(x)

Compute and visualize the Weighted Natural Visibility Graph (WNVG)
of a time series `x`.

Edges are coloured by weight (the angle of the line of sight),
from blue (negative / shallow) to red (positive / steep).

Arguments:
    x::AbstractVector{<:Real}: finite-valued time series.

Returns:
    Plots.Plot: time series with WNVG edges overlaid.
"""
function plot_wnvg(x::AbstractVector{<:Real})

    edges = wnvg(x)

    n = length(x)
    t = 1:n

    weights = [w for (_, _, w) in edges]
    wmin, wmax = extrema(weights)
    wrange = wmax - wmin

    plt = plot(t, x, lw=2, label="time series", xlabel="t", ylabel="x(t)",
               title="Weighted Natural Visibility Graph")

    for (i, j, w) in edges
        # normalise weight to [0, 1] for colour mapping
        c = wrange ≈ 0.0 ? 0.5 : (w - wmin) / wrange
        color = RGB(c, 0.0, 1.0 - c)
        plot!(plt, [i, j], [x[i], x[j]], color=color, alpha=0.6, label=false)
    end

    return plt
end
