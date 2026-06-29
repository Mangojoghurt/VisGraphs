# ── Shared Helper ─────────────────────────────────────────────────────────────

"""
    _argmax_range(x, left, right)

Return the index of the maximum value in `x[left:right]`.
Ties are broken in favor of the leftmost index.
"""
@inline function _argmax_range(x::AbstractVector{<:Real}, left::Int, right::Int)
    idx  = left
    best = @inbounds x[left]
    @inbounds for k in left+1:right
        xk = x[k]
        if xk > best
            best = xk
            idx  = k
        end
    end
    return idx
end

# ── Input Validation ──────────────────────────────────────────────────────────

function _validate(x::AbstractVector{<:Real})
    length(x) ≥ 2 || throw(ArgumentError("`x` must contain at least two values."))
    all(isfinite, x) || throw(ArgumentError("`x` must contain only finite values."))
end

# ── HVG Divide-and-Conquer (Stack-Based) ──────────────────────────────────────

function _hvg_core!(
    edges::Vector{Tuple{Int,Int}},
    x::AbstractVector{<:Real},
    left::Int,
    right::Int,
)
    # Using a stack prevents StackOverflowError on massive time series
    stack = [(left, right)]

    while !isempty(stack)
        l, r = pop!(stack)
        r - l < 1 && continue

        # The subarray maximum x[mid] is always visible to other nodes in the range
        mid = _argmax_range(x, l, r)

        # ── Scan LEFT: connect mid to visible nodes in [l, mid-1] ────────────
        max_seen = typemin(eltype(x))
        @inbounds for i in mid-1:-1:l
            xi = x[i]
            if max_seen < xi
                push!(edges, (i, mid))
            end
            max_seen = max(max_seen, xi) # Update always, no early break
        end

        # ── Scan RIGHT: connect mid to visible nodes in [mid+1, r] ───────────
        max_seen = typemin(eltype(x))
        @inbounds for j in mid+1:r
            xj = x[j]
            if max_seen < xj
                push!(edges, (mid, j))
            end
            max_seen = max(max_seen, xj) # Update always, no early break
        end

        # ── Recurse on independent sub-problems ───────────────────────────────
        if l < mid - 1
            push!(stack, (l, mid - 1))
        end
        if mid + 1 < r
            push!(stack, (mid + 1, r))
        end
    end
end

# ── Public API ────────────────────────────────────────────────────────────────

"""
    hvg(x)

Construct a Horizontal Visibility Graph (HVG) from a time series `x`.
Uses a divide-and-conquer algorithm achieving O(N log N) average runtime.

Arguments:
    x::AbstractVector{<:Real}: time series containing finite numeric values.

Returns:
    Vector{Tuple{Int, Int}}: edges of the HVG.
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
Each edge carries a weight equal to the angle (in radians) of the line of sight.
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

# ── Plotting ──────────────────────────────────────────────────────────────────

function plot_hvg(x::AbstractVector{<:Real})
    edges = hvg(x)
    plt = plot(1:length(x), x, lw=2, label="time series", xlabel="t", ylabel="x(t)", title="Horizontal Visibility Graph")
    for (i, j) in edges
        plot!(plt, [i, j], [x[i], x[j]]; color=:gray, alpha=0.5, label=false)
    end
    return plt
end

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