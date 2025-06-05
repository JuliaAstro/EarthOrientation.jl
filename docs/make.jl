using Documenter
using EarthOrientation

include("pages.jl")
makedocs(
    modules = [EarthOrientation],
    authors = "Helge Eichhorn <git@helgeeichhorn.de>",
    sitename = "EarthOrientation.jl",
    format = Documenter.HTML(
        canonical = "https://juliaastro.org/EarthOrientation/stable",
    ),
    pages = pages,
)

deploydocs(
    repo = "github.com/JuliaAstro/EarthOrientation.jl.git",
    push_preview = true,
    versions = ["stable" => "v^", "v#.#"], # Restrict to minor releases
)
