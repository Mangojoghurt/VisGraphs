using VisGraphs
using Test

@testset "VisGraphs basic functionality" begin
    x = generate_sine(10)

    hvg_edges = hvg(x)
    nvg_edges = nvg(x)

    @test length(hvg_edges) > 0
    @test length(nvg_edges) > 0
    @test hvg_edges != nvg_edges
end
