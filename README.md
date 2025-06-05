# EarthOrientation.jl

*Calculate Earth orientation parameters from IERS tables in Julia.*

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaAstro.github.io/EarthOrientation.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaAstro.github.io/EarthOrientation.jl/dev)

[![CI](https://github.com/JuliaAstro/EarthOrientation.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaAstro/EarthOrientation.jl/actions/workflows/CI.yml)
[![Coverage](https://codecov.io/gh/JuliaAstro/EarthOrientation.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaAstro/EarthOrientation.jl)
[![DOI](https://zenodo.org/badge/72871735.svg)](https://zenodo.org/badge/latestdoi/72871735)

## Installation

The package can be installed through Julia's package manager:

```julia
pkg> add EarthOrientation
```

## Quickstart

Fetch the latest [IERS][iers-link] tables:

```julia
using EarthOrientation
EarthOrientation.update()
```

Get the current Earth orientation parameters, e.g. for polar motion:

```julia
xp, yp = polarmotion(now()) # arcseconds
```

Or the current difference between UT1 and UTC and the associated prediction error:

```julia
ΔUT1 = getΔUT1(now()) # seconds
ΔUT1_err = getΔUT1_err(now()) # seconds
```
[iers-link]: https://www.iers.org/IERS/EN/DataProducts/EarthOrientationData/eop.html
