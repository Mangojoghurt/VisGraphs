export hvg

"""
    hvg(x)

Construct a Horizontal Visibility Graph (HVG)
from a time series x.

Returns:
    Vector{Tuple{Int, Int}}: edges of the HVG.
"""
function hvg(x::AbstractVector)

    n = length(x)
    edges = Vector{Tuple{Int, Int}}()

    for i in 1:n-1
        for j in i+1:n

            visible = true

            # check all points in between
            for k in i+1:j-1
                if x[k] >= min(x[i], x[j])
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