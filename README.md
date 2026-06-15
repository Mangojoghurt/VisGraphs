# VisGraphs

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://Mangojoghurt.github.io/VisGraphs/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://Mangojoghurt.github.io/VisGraphs/dev/)
[![Build Status](https://github.com/Mangojoghurt/VisGraphs/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/Mangojoghurt/VisGraphs/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/Mangojoghurt/VisGraphs/branch/main/graph/badge.svg)](https://codecov.io/gh/Mangojoghurt/VisGraphs)

A Julia package for constructing **visibility graphs** from time series data.
Visibility graphs convert a sequence of numbers into a network where each data point
is a node, and two nodes are connected if they can "see" each other according to a
geometric visibility rule. This allows time series to be analysed using tools from
complex network theory.

> JuML Project — TU Berlin | Group B

---

## What is a Visibility Graph?

Given a time series `x = [x₁, x₂, ..., xₙ]`, imagine each value as a bar standing
on the ground (like a bar chart). Two bars `i` and `j` are **connected** if you can
draw a line between their tops without it being blocked by any bar in between.

This package implements two variants:

- **Natural Visibility Graph (NVG):** two points are connected if the straight
  diagonal line between them clears all intermediate bars.
- **Horizontal Visibility Graph (HVG):** two points are connected if a flat
  horizontal line at the height of the shorter bar clears all intermediate bars.
  This is a stricter rule — HVG always produces fewer or equal edges than NVG.

---

## Installation

### Option 1 — Install directly from the repository (recommended)

Open Julia and run:

```julia
using Pkg
Pkg.add(url="https://github.com/Mangojoghurt/VisGraphs")
```

Or in Pkg mode (press `]` in the Julia REPL):

```
pkg> add https://github.com/Mangojoghurt/VisGraphs
```

### Option 2 — Clone and run locally

```bash
git clone https://github.com/Mangojoghurt/VisGraphs.git
cd VisGraphs
```

Then start Julia in project mode:

```bash
julia --project=.
```

Install all dependencies:

```julia
using Pkg
Pkg.instantiate()
```

---

## Quick Start

```julia
using VisGraphs

# 1. Generate a test signal (sine wave with 20 points)
x = generate_sine(20)

# 2. Compute the Horizontal Visibility Graph
hvg_edges = hvg(x)

# 3. Compute the Natural Visibility Graph
nvg_edges = nvg(x)

# 4. Inspect the edges
println("HVG edges: ", hvg_edges)
println("NVG edges: ", nvg_edges)
println("HVG has $(length(hvg_edges)) edges")
println("NVG has $(length(nvg_edges)) edges")  # NVG always ≥ HVG
```

Each function returns a `Vector{Tuple{Int,Int}}` — a list of index pairs `(i, j)`
representing connected nodes. For example, `(2, 5)` means node 2 and node 5 are
connected by an edge.

---

## API Reference

### Signal Generators

| Function | Description |
|---|---|
| `generate_sine(n=100)` | Sine wave over `[0, 4π]` with `n` points |
| `generate_random(n=100)` | Uniform random values in `[0, 1]` |
| `generate_noisy_sine(n=100, noise=0.2)` | Sine wave with added Gaussian noise |

### Graph Constructors

| Function | Input | Output | Description |
|---|---|---|---|
| `hvg(x)` | `AbstractVector` | `Vector{Tuple{Int,Int}}` | Horizontal Visibility Graph |
| `nvg(x)` | `AbstractVector` | `Vector{Tuple{Int,Int}}` | Natural Visibility Graph |

---

## Running the Examples

Make sure you are inside the project directory with `julia --project=.`, then:

```julia
# Plot HVG NVG on the time series — saves PNG files
include("examples/plot_hvg.jl")

# Save HVG and NVG graph plots to PNG files
include("examples/show_graphs.jl")
```

The PNG files will be saved in your current directory. Open them with any image viewer.

---

## Running the Tests

In Pkg mode (press `]`):

```
pkg> test
```

Expected output:

```
Test Summary:               | Pass  Total
VisGraphs basic functionality |    3      3
```

The tests verify that:
- `hvg(x)` returns a non-empty edge list
- `nvg(x)` returns a non-empty edge list
- NVG and HVG produce different edge sets (NVG is more permissive)

---

## Verifying a Clean Install

To check the package installs correctly in a fresh environment (as a reviewer would):

**Step 1** — Open Julia (anywhere, not inside the project folder):
```
julia
```

**Step 2** — Enter Pkg mode and create a temporary empty environment:
```
pkg> activate --temp
```
The prompt changes to `(jl_XXXX) pkg>` — this is a blank slate with nothing installed.

**Step 3** — Install the package directly from the repository:
```
pkg> add https://git.tu-berlin.de/juml-visgraphs-groupb/visgraphs
```

**Step 4** — Test that it works:
```julia
using VisGraphs
x = generate_sine(10)
hvg(x)
nvg(x)
```

If all four steps complete without errors, the package installs correctly.

---

## Background

Visibility graphs were introduced by Lacasa et al. (2008) as a method to map time
series into complex networks, enabling the use of graph-theoretic tools for time
series analysis. Properties of the resulting graph (degree distribution, clustering
coefficient, etc.) reflect structural properties of the original time series.

**References:**

- [1] L. Lacasa et al., *From time series to complex networks: The visibility graph.*
  PNAS, 2008. https://doi.org/10.1073/pnas.0709247105
- [2] J. F. Donges et al., *Visibility graph analysis of geophysical time series.*
  EPL, 2013. DOI: 10.1209/0295-5075/102/10004
- [3] U. von Luxburg, *A Tutorial on Spectral Clustering.*
  https://arxiv.org/pdf/0711.0189.pdf