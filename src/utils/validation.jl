"""
    _validate(x)

Check that `x` is a valid input time series.

Ensures that:
- `x` contains at least two elements
- all elements are finite real numbers (no `NaN` or `Inf`)

Throws an `ArgumentError` if validation fails.

This is an internal precondition check used by all visibility graph
construction algorithms.
"""
function _validate(x::AbstractVector{<:Real})
    length(x) ≥ 2 || throw(ArgumentError("`x` must contain at least two values."))
    all(isfinite, x) || throw(ArgumentError("`x` must contain only finite values."))
end