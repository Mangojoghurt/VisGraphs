export nvg

"""
    nvg(x)

Construct a Natural Visibility Graph (NVG)
from a time series x.

Returns:
    edges::Vector{Tuple{Int, Int}}
"""
function nvg(x::AbstractVector)

    n = length(x)
    edges = Vector{Tuple{Int, Int}}()

    for i in 1:n-1
        for j in i+1:n

            xi = x[i]
            xj = x[j]

            visible = true

            # check all intermediate points
            for k in i+1:j-1

                # linear interpolation between i and j
                x_interp = xi + (xj - xi) * (k - i) / (j - i)

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