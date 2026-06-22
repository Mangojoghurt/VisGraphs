using VisGraphs
using Test

@testset "Signal generators" begin

    s = generate_sine(20)
    r = generate_random(20)
    ns = generate_noisy_sine(20)

    @test length(s) == 20
    @test length(r) == 20
    @test length(ns) == 20

    @test all(isfinite, s)
    @test all(isfinite, r)
    @test all(isfinite, ns)
end

@testset "Basic functionality" begin
    x = generate_sine(10)

    hvg_edges = hvg(x)
    nvg_edges = nvg(x)

    @test length(hvg_edges) > 0
    @test length(nvg_edges) > 0
    @test hvg_edges != nvg_edges
end

@testset "HVG/NVG small examples" begin

    x = [1.0, 2.0, 5.0]

    # HVG
    hvg_edges = hvg(x)
    @test (1,2) in hvg_edges
    @test (2,3) in hvg_edges
    @test (1,3) ∉ hvg_edges

    # NVG
    nvg_edges = nvg(x)
    @test (1,2) in nvg_edges
    @test (2,3) in nvg_edges
    @test (1,3) in nvg_edges
end

@testset "Input validation" begin

    @test_throws ArgumentError hvg([1.0])
    @test_throws ArgumentError nvg([1.0])

    @test_throws ArgumentError hvg([1.0, Inf])
    @test_throws ArgumentError nvg([NaN, 1.0])

    @test_throws MethodError hvg([1.0, missing])
    @test_throws MethodError nvg([missing, 1.0])
end

@testset "Flat signals" begin

    x = fill(1.0, 5)

    vis_graphs = [hvg(x), nvg(x)]

    n = length(x)

    for edges in vis_graphs

        # flat signals should be chain-like
        @test length(edges) == n - 1

        for i in 1:n
            for j in i+1:n

                if j == i + 1
                    # adjacent edges must exist
                    @test (i, j) in edges
                else
                    # non-adjacent edges must NOT exist
                    @test (i, j) ∉ edges
                end
            end
        end
    end
end

@testset "Monotone signals" begin

    inc = collect(1:5)
    dec = collect(5:-1:1)

    expected_chain = [(i, i+1) for i in 1:4]

    for (name, x) in [("increasing", inc), ("decreasing", dec)]

        for (label, f) in [("HVG", hvg), ("NVG", nvg)]

            edges = f(x)

            # monotone signals should be chain-like
            @test length(edges) == length(x) - 1

            # adjacent edges must exist
            for e in expected_chain
                @test e in edges
            end
        end
    end
end

@testset "HVG vs NVG structural difference" begin

    x = [1.0, 3.0, 2.0, 4.0, 7.0]

    h = hvg(x)
    n = nvg(x)

    @test h != n
    @test length(h) < length(n)  # NVG usually denser
end

@testset "Plot functions" begin

    x = [1.0, 2.0, 1.5, 3.0]

    plt1 = plot_hvg(x)
    plt2 = plot_nvg(x)

    # ensure plot objects are returned
    @test plt1 !== nothing
    @test plt2 !== nothing

    # ensure correct type
    @test typeof(plt1) == typeof(plt2)
end