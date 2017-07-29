# EarthOrientation.jl

*Calculate Earth orientation parameters from IERS tables in Julia.*

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

## Available data

* Polar motion:
    * x-coordinate of Earth's north pole: `getxp`
    * y-coordinate of Earth's north pole: `getyp`
    * both: `polarmotion`
* Earth rotation
    * Difference between UT1 and UTC: `getΔUT1`
    * Excess length of day: `getlod`
* Precession and nutation based on the 1980 IAU conventions
    * Correction to the nutation of the ecliptic: `getdψ`
    * Correction to the obliquity of the ecliptic: `getdϵ`
    * both: `precession_nutation80`
* Precession and nutation based on the 2000 IAU conventions
    * Correction to the celestial pole's x-coordinate: `getdx`
    * Correction to the celestial pole's y-coordinate: `getdy`
    * both: `precession_nutation00`

There is an associated function that returns the prediction error for each data type, e.g. `getxp_err`.

## Manual Data Management

By default the files downloaded by `EarthOrientation.update()` will be used.
It is also possible to pass different [finals.all](https://datacenter.iers.org/eop/-/somos/5Rgv/getMeta/7/finals.all) and
[finals2000A.all](https://datacenter.iers.org/eop/-/somos/5Rgv/getMeta/9/finals2000A.all) files in CSV format.

```julia
using EarthOrientation

push!(EOP_DATA, "finals.csv", "finals2000A.csv")
```
