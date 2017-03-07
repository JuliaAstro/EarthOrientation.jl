# EarthOrientation.jl

*Calculate Earth orientation parameters from IERS tables in Julia.*

[![Build Status Unix][travis-image]][travis-link] [![Build Status Windows][av-image]][av-link] [![Coverage][codecov-image]][codecov-link]

## Installation

The package can be installed through Julia's package manager:

```julia
Pkg.clone("https://github.com/helgee/EarthOrientation.jl.git")
# As soon as the package has been published in METADATA.jl use:
# Pkg.add("EarthOrientation")
```

## Quickstart

Fetch the latest [IERS][iers-link] tables:

```julia
using EarthOrientation
EarthOrientation.update()
```

Parse the data files into an `EOParams` object:

```julia
eop = EOParams()
```

By default the files downloaded by `EarthOrientation.update()` will be used.
It is also possible to pass different [finals.all][finals-link] and
[finals2000A.all][2000A-link] files in CSV format.

```julia
eop = EOParams("finals.csv", "finals2000A.csv")
```

Get the current Earth orientation parameters, e.g. for polar motion:

```julia
xp, yp = polarmotion(eop, now()) # arcseconds
```

Or the current difference between UT1 and UTC and the associated prediction error:

```julia
ΔUT1 = getΔUT1(eop, now()) # seconds
ΔUT1_err = getΔUT1_err(eop, now()) # seconds
```

## Documentation

Please refer to the [documentation](https://helgee.github.io/EarthOrientation.jl/latest) for additional
information.

[travis-image]: https://travis-ci.org/helgee/EarthOrientation.jl.svg?branch=master
[travis-link]: https://travis-ci.org/helgee/EarthOrientation.jl
[av-image]: https://ci.appveyor.com/api/projects/status/y66wet5aa819vxwu?svg=true
[av-link]: https://ci.appveyor.com/project/helgee/earthorientation-jl
[codecov-image]: http://codecov.io/github/helgee/EarthOrientation.jl/coverage.svg?branch=master
[codecov-link]: http://codecov.io/github/helgee/EarthOrientation.jl?branch=master
[iers-link]: https://www.iers.org/IERS/EN/DataProducts/EarthOrientationData/eop.html
[finals-link]: https://datacenter.iers.org/eop/-/somos/5Rgv/getMeta/7/finals.all
[2000A-link]: https://datacenter.iers.org/eop/-/somos/5Rgv/getMeta/9/finals2000A.all
