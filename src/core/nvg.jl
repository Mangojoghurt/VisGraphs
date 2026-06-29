# _argmax_range and _validate are defined in hvg.jl (included first in VisGraphs.jl)

# ── NVG Divide-and-Conquer (Stack-Based) ──────────────────────────────────────

function _nvg_core!(
    edges::Vector{Tuple{Int,Int}},
    x::AbstractVector{<:Real},
    left::Int,
    right::Int,
)
    # Statically infer the correct float type to prevent boxing/type-instability (JUML H3)
    F = typeof(float(zero(eltype(x)))) 
    
    stack = [(left, right)]

    while !isempty(stack)
        l, r = pop!(stack)
        r - l < 1 && continue

        mid = _argmax_range(x, l, r)
        xm  = @inbounds x[mid]

        # ── Scan LEFT ─────────────────────────────────────────────────────────
        # Uses cross-multiplication: dy_new * dx_old > dy_old * dx_new
        # Eliminates floating-point division from the hot loop.
        best_dy = typemin(F)
        best_dx = F(1) 

        @inbounds for i in mid-1:-1:l
            dy = F(x[i] - xm)
            dx = F(mid - i)
            if dy * best_dx > best_dy * dx
                push!(edges, (i, mid))
                best_dy = dy
                best_dx = dx
            end
        end

        # ── Scan RIGHT ────────────────────────────────────────────────────────
        best_dy = typemin(F)
        best_dx = F(1)

        @inbounds for j in mid+1:r
            dy = F(x[j] - xm)
            dx = F(j - mid)
            if dy * best_dx > best_dy * dx
                push!(edges, (mid, j))
                best_dy = dy
                best_dx = dx
            end
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
    nvg(x)

Construct a Natural Visibility Graph (NVG) from a time series `x`.
Uses a divide-and-conquer algorithm achieving O(N log N) average runtime.
"""
function nvg(x::AbstractVector{<:Real})
    _validate(x)
    edges = Tuple{Int,Int}[]
    sizehint!(edges, 6 * length(x))
    _nvg_core!(edges, x, 1, length(x))
    return sort!(edges)
end

"""
    wnvg(x)

Construct a Weighted Natural Visibility Graph (WNVG) from a time series `x`.
"""
function wnvg(x::AbstractVector{<:Real})
    base  = nvg(x) 
    W     = float(eltype(x))
    edges = Tuple{Int,Int,W}[]
    sizehint!(edges, length(base))
    
    @inbounds for (i, j) in base
        weight = atan(W(x[j] - x[i]), W(j - i))
        push!(edges, (i, j, weight))
    end
    return edges
end

# ── Plotting ──────────────────────────────────────────────────────────────────

function plot_nvg(x::AbstractVector{<:Real})
    edges = nvg(x)
    plt = plot(1:length(x), x, lw=2, label="time series", xlabel="t", ylabel="x(t)", title="Natural Visibility Graph")
    for (i, j) in edges
        plot!(plt, [i, j], [x[i], x[j]]; color=:gray, alpha=0.5, label=false)
    end
    return plt
end

function plot_wnvg(x::AbstractVector{<:Real})
    edges = wnvg(x)
    weights = [w for (_, _, w) in edges]
    wmin, wmax = extrema(weights)
    wrange = wmax - wmin
    plt = plot(1:length(x), x, lw=2, label="time series", xlabel="t", ylabel="x(t)", title="Weighted Natural Visibility Graph")
    for (i, j, w) in edges
        c = wrange ≈ 0.0 ? 0.5 : (w - wmin) / wrange
        plot!(plt, [i, j], [x[i], x[j]], color=RGB(c, 0.0, 1.0 - c), alpha=0.6, label=false)
    end
    return plt
end