export degree_distribution, adjacency_matrix, laplacian_matrix

"""
    adjacency_matrix(edges, n)

Build an n×n adjacency matrix from an edge list.

Edges are treated as undirected: both A[i,j] and A[j,i] are set to 1.
Works with both unweighted edges `(i, j)` and weighted edges `(i, j, w)`;
the weight is ignored — use the raw values if you need a weighted matrix.

Arguments:
    edges: edge list returned by `hvg`, `nvg`, `whvg`, or `wnvg`.
    n::Int: number of nodes (length of the original time series).

Returns:
    Matrix{Int}: symmetric n×n adjacency matrix.

# Example
```julia
x = [1.0, 2.0, 3.0, 1.5]
edges = nvg(x)
A = adjacency_matrix(edges, length(x))
```
"""
function adjacency_matrix(edges, n::Int)

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
    degree_distribution(edges, n)

Compute the degree of every node and return the full degree sequence,
plus a normalised frequency distribution.

The degree of node i is the number of edges incident to it.

Arguments:
    edges: edge list returned by `hvg`, `nvg`, `whvg`, or `wnvg`.
    n::Int: number of nodes (length of the original time series).

Returns:
    degrees::Vector{Int}: degree of each node (length n).
    distribution::Dict{Int,Float64}: maps each observed degree k
        to the fraction of nodes with that degree P(k).

# Example
```julia
x = generate_sine(50)
edges = nvg(x)
degrees, dist = degree_distribution(edges, length(x))
println("Max degree: ", maximum(degrees))
println("P(k): ", sort(collect(dist)))
```
"""
function degree_distribution(edges, n::Int)

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
    laplacian_matrix(edges, n)

Compute the combinatorial Laplacian matrix L = D - A, where D is the
diagonal degree matrix and A is the adjacency matrix.

The Laplacian is symmetric and positive semi-definite. Its eigenvalues
encode structural properties of the graph: the number of zero eigenvalues
equals the number of connected components, and the second-smallest
eigenvalue (the Fiedler value) measures how well-connected the graph is.

Arguments:
    edges: edge list returned by `hvg`, `nvg`, `whvg`, or `wnvg`.
    n::Int: number of nodes (length of the original time series).

Returns:
    Matrix{Int}: symmetric n×n Laplacian matrix.

# Example
```julia
x = generate_sine(20)
edges = nvg(x)
L = laplacian_matrix(edges, length(x))

# compute eigenvalues (requires LinearAlgebra)
using LinearAlgebra
λ = eigvals(Symmetric(float.(L)))
println("Fiedler value: ", λ[2])
```
"""
function laplacian_matrix(edges, n::Int)

    n ≥ 1 || throw(ArgumentError("`n` must be at least 1."))

    A = adjacency_matrix(edges, n)

    # degree matrix — diagonal entries are the node degrees
    D = zeros(Int, n, n)
    for i in 1:n
        D[i, i] = sum(A[i, :])
    end

    return D - A
end
