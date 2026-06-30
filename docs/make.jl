using VisGraphs
using Documenter

DocMeta.setdocmeta!(VisGraphs, :DocTestSetup, :(using VisGraphs); recursive=true)

makedocs(;
    modules=[VisGraphs],
    authors="Jan Wohltmann <jan.wohltmann@campus.tu-berlin.de>",
    sitename="VisGraphs.jl",
    format=Documenter.HTML(;
        canonical="https://Mangojoghurt.github.io/VisGraphs.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Getting Started" => "getting_started.md",
    ],
)

deploydocs(;
    repo="github.com/Mangojoghurt/VisGraphs.jl",
    devbranch="main",
)
