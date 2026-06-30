# VisGraphs

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://Mangojoghurt.github.io/VisGraphs.jl/dev/)
[![Build Status](https://github.com/Mangojoghurt/VisGraphs.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/Mangojoghurt/VisGraphs.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/Mangojoghurt/VisGraphs.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/Mangojoghurt/VisGraphs.jl)

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
Pkg.add(url="https://github.com/Mangojoghurt/VisGraphs.jl")
```

Or in Pkg mode (press `]` in the Julia REPL):

```
pkg> add https://github.com/Mangojoghurt/VisGraphs.jl
```

### Option 2 — Clone and run locally

```bash
git clone https://github.com/Mangojoghurt/VisGraphs.jl.git
cd VisGraphs.jl
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

x = generate_noisy_sine(100, 0.1)
g = hvg(x)
plot_hvg(x)
```

For a more detailed introduction, examples, and API reference, see the
[Getting Started guide](https://Mangojoghurt.github.io/VisGraphs.jl/dev/getting_started/).

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