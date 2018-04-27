using Documenter, EarthOrientation

makedocs(
    format = :html,
    sitename = "EarthOrientation.jl",
    authors = "Helge Eichhorn",
    pages = [
        "Home" => "index.md",
        "API" => "api.md",
    ],
)

deploydocs(
    julia = "nightly",
    repo = "github.com/JuliaAstro/EarthOrientation.jl.git",
    target = "build",
    deps = nothing,
    make = nothing,
)
