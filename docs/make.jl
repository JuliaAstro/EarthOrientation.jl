using Documenter
using EarthOrientation
using Documenter.Remotes: GitHub

makedocs(;
    modules = [EarthOrientation],
    authors = "Helge Eichhorn <git@helgeeichhorn.de>",
    repo = GitHub("JuliaAstro/EarthOrientation.jl"),
    sitename = "EarthOrientation.jl",
    format = Documenter.HTML(
        canonical = "https://juliaastro.org/EarthOrientation/stable/",
    ),
    pages = [
        "Home" => "index.md",
        "API" => "api.md",
    ],
    doctest = false,
)

deploydocs(;
    repo = "github.com/JuliaAstro/EarthOrientation.jl.git",
    push_preview = true,
    versions = ["stable" => "v^", "v#.#"], # Restrict to minor releases
)
