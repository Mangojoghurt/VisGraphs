"""
    hvg(x)

Construct a Horizontal Visibility Graph (HVG) from a time series `x`.

Two nodes `i < j` are connected if all intermediate values satisfy
the horizontal visibility condition:

    x[k] < min(x[i], x[j])  for all i < k < j

The resulting graph encodes the structure of visibility relationships
in the time series.

The implementation uses a divide-and-conquer algorithm with average
O(N log N) complexity.

Returns a sorted edge list `(i, j)` with `i < j`.
"""
function hvg(x::AbstractVector{<:Real})
    _validate(x)
    edges = Tuple{Int,Int}[]
    # Pre-allocate to minimize dynamic memory resizing (JUML H2 optimization)
    sizehint!(edges, 4 * length(x))
    _hvg_core!(edges, x, 1, length(x))
    return sort!(edges)
end

"""
    whvg(x)

Construct a Weighted Horizontal Visibility Graph (WHVG) from a time series `x`.

Extends the HVG by assigning each edge a geometric weight equal to the
angle of visibility between two connected points:

    w(i, j) = atan(x[j] - x[i], j - i)

The weight encodes both amplitude difference and temporal separation.

Returns a vector of weighted edges `(i, j, w)`.
"""
function whvg(x::AbstractVector{<:Real})
    base  = hvg(x)
    W     = float(eltype(x)) # Respects Float32/Float64 inputs natively
    edges = Tuple{Int,Int,W}[]
    sizehint!(edges, length(base))
    
    @inbounds for (i, j) in base
        weight = atan(W(x[j] - x[i]), W(j - i))
        push!(edges, (i, j, weight))
    end
    return edges
end

"""
    plot_hvg(x)

Plot a time series together with its Horizontal Visibility Graph (HVG).

The time series is shown as a line plot, while edges are drawn as
semi-transparent connections between visible nodes.

Returns a `Plots.Plot` object.
"""
function plot_hvg(x::AbstractVector{<:Real})
    edges = hvg(x)
    plt = plot(1:length(x), x, lw=2, label="time series", xlabel="t", ylabel="x(t)", title="Horizontal Visibility Graph")
    for (i, j) in edges
        plot!(plt, [i, j], [x[i], x[j]]; color=:gray, alpha=0.5, label=false)
    end
    return plt
end

"""
    plot_whvg(x)

Plot a time series together with its Weighted Horizontal Visibility Graph (WHVG).

Edges are colored according to their angular weight, normalized across
all edges.

Returns a `Plots.Plot` object.
"""
function plot_whvg(x::AbstractVector{<:Real})
    edges = whvg(x)
    weights = [w for (_, _, w) in edges]
    wmin, wmax = extrema(weights)
    wrange = wmax - wmin
    plt = plot(1:length(x), x, lw=2, label="time series", xlabel="t", ylabel="x(t)", title="Weighted Horizontal Visibility Graph")
    for (i, j, w) in edges
        c = wrange ≈ 0.0 ? 0.5 : (w - wmin) / wrange
        plot!(plt, [i, j], [x[i], x[j]], color=RGB(c, 0.0, 1.0 - c), alpha=0.6, label=false)
    end
    return plt
end