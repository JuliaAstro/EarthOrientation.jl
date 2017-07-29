# EarthOrientation.jl

*Calculate Earth orientation parameters from IERS tables in Julia.*

[![Build Status Unix][travis-image]][travis-link] [![Build Status Windows][av-image]][av-link] [![Coveralls][coveralls-image]][coveralls-link] [![Codecov][codecov-image]][codecov-link] [![Docs Stable][docs-badge-stable]][docs-url-stable] [![Docs Latest][docs-badge-latest]][docs-url-latest]

## Installation

The package can be installed through Julia's package manager:

```julia
Pkg.add("EarthOrientation")
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

## Documentation

Please refer to the [documentation][docs-url-stable] for additional
information.

[travis-image]: https://travis-ci.org/JuliaAstro/EarthOrientation.jl.svg?branch=master
[travis-link]: https://travis-ci.org/JuliaAstro/EarthOrientation.jl
[av-image]: https://ci.appveyor.com/api/projects/status/u9v83v216i8g8tdq?svg=true
[av-link]: https://ci.appveyor.com/project/helgee/earthorientation-jl
[coveralls-image]: https://coveralls.io/repos/github/JuliaAstro/EarthOrientation.jl/badge.svg?branch=master
[coveralls-link]: https://coveralls.io/github/JuliaAstro/EarthOrientation.jl?branch=master
[codecov-image]: http://codecov.io/github/JuliaAstro/EarthOrientation.jl/coverage.svg?branch=master
[codecov-link]: http://codecov.io/github/JuliaAstro/EarthOrientation.jl?branch=master
[iers-link]: https://www.iers.org/IERS/EN/DataProducts/EarthOrientationData/eop.html
[finals-link]: https://datacenter.iers.org/eop/-/somos/5Rgv/getMeta/7/finals.all
[2000A-link]: https://datacenter.iers.org/eop/-/somos/5Rgv/getMeta/9/finals2000A.all
[docs-badge-latest]: https://img.shields.io/badge/docs-latest-blue.svg
[docs-url-latest]: https://juliaastro.github.io/EarthOrientation.jl/latest
[docs-badge-stable]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-url-stable]: https://juliaastro.github.io/EarthOrientation.jl/stable
