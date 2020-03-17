using Documenter
using EarthOrientation

makedocs(
    modules = [EarthOrientation],
    authors = "Helge Eichhorn <git@helgeeichhorn.de>",
    sitename = "EarthOrientation.jl",
    format = Documenter.HTML(),
    pages = [
        "Home" => "index.md",
        "API" => "api.md",
    ],
)

deploydocs(
    repo = "github.com/JuliaAstro/EarthOrientation.jl.git",
    push_preview = true,
)
