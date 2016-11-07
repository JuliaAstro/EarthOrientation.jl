using Documenter, EarthOrientation

makedocs(
    format = :html,
    sitename = "EarthOrientation.jl",
    authors = "Helge Eichhorn",
    pages = [
        "Home" => "index.md",
        "Tutorial" => "tutorial.md",
        "API" => "api.md",
        "Internals" => "internals.md",
    ],
)

deploydocs(
    repo = "github.com/helgee/EarthOrientation.jl.git",
    target = "build",
    deps = nothing,
    make = nothing,
)
