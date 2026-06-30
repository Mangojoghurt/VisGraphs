"""
    adjacency_matrix(edges, n::Integer)

Construct an n×n adjacency matrix from an edge list.

The graph is treated as undirected: each edge `(i, j)` contributes both
`A[i, j] = 1` and `A[j, i] = 1`. If edges are weighted tuples `(i, j, w)`,
the weight `w` is ignored.

This function is intended for edge lists produced by `hvg`, `nvg`, `whvg`,
or `wnvg`.

# Example
```julia
x = [1.0, 2.0, 3.0, 1.5]
edges = nvg(x)
A = adjacency_matrix(edges, length(x))
```
"""
function adjacency_matrix(edges, n::Integer)

    n ≥ 1 || throw(ArgumentError("`n` must be at least 1."))

    A = zeros(Int, n, n)

    for edge in edges
        i, j = edge[1], edge[2]
        (1 ≤ i ≤ n && 1 ≤ j ≤ n) ||
            throw(ArgumentError("Edge ($i, $j) is out of range for n=$n."))
        A[i, j] = 1
        A[j, i] = 1
    end

    return A
end

"""
    degree_distribution(edges, n::Integer)

Compute the degree sequence and degree distribution of a graph.

Returns a vector of node degrees and a normalized dictionary mapping each
degree `k` to its empirical probability `P(k)`.

The degree of a node is defined as the number of incident edges.

# Returns
- `degrees::Vector{Int}`: degree of each node.
- `distribution::Dict{Int, Float64}`: empirical degree distribution.

# Example
```julia
x = generate_sine(50)
edges = nvg(x)

degrees, dist = degree_distribution(edges, length(x))

maximum(degrees)
sort(collect(dist))
```
"""
function degree_distribution(edges, n::Integer)

    n ≥ 1 || throw(ArgumentError("`n` must be at least 1."))

    degrees = zeros(Int, n)

    for edge in edges
        i, j = edge[1], edge[2]
        (1 ≤ i ≤ n && 1 ≤ j ≤ n) ||
            throw(ArgumentError("Edge ($i, $j) is out of range for n=$n."))
        degrees[i] += 1
        degrees[j] += 1
    end

    # normalised frequency distribution P(k)
    distribution = Dict{Int,Float64}()
    for d in degrees
        distribution[d] = get(distribution, d, 0.0) + 1.0 / n
    end

    return degrees, distribution
end

"""
    laplacian_matrix(edges, n::Integer)

Construct the combinatorial graph Laplacian `L = D - A`.

The Laplacian encodes structural properties of the graph. It is symmetric
and positive semidefinite. The number of zero eigenvalues corresponds to
the number of connected components, and the second-smallest eigenvalue
(the Fiedler value) measures graph connectivity.

This function builds the Laplacian using the adjacency matrix derived from
the provided edge list.

# Example
```julia
x = generate_sine(20)
edges = nvg(x)

L = laplacian_matrix(edges, length(x))

using LinearAlgebra
eigvals(Symmetric(float.(L)))
```
"""
function laplacian_matrix(edges, n::Integer)

    n ≥ 1 || throw(ArgumentError("`n` must be at least 1."))

    A = adjacency_matrix(edges, n)

    # degree matrix — diagonal entries are the node degrees
    D = zeros(Int, n, n)
    for i in 1:n
        D[i, i] = sum(A[i, :])
    end

    return D - A
end
