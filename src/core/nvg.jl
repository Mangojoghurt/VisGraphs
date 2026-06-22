export nvg, plot_nvg

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