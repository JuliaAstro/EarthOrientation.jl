# Tutorial

*EarthOrientation.jl* downloads, parses, and interpolates weekly-updated tables from the
[IERS](https://www.iers.org/IERS/EN/DataProducts/EarthOrientationData/eop.html) that contain the following
Earth Orientation Parameters (EOP):

* Polar motion:
    * x-coordinate of Earth's north pole: $x_p$
    * y-coordinate of Earth's north pole: $y_p$
* Earth rotation
    * Difference between UT1 and UTC: $\Delta UT1$
    * Excess length of day: $LOD$
* Precession and nutation based on the 1980 IAU conventions
    * Correction to the nutation of the ecliptic: $d\psi$
    * Correction to the obliquity of the ecliptic: $d\epsilon$
* Precession and nutation based on the 2000 IAU conventions
    * Correction to the celestial pole's x-coordinate: $dx$
    * Correction to the celestial pole's y-coordinate: $dy$

These parameters are required for precise transformations between quasi-inertial and rotating terrestrial
reference frames.

## Getting Earth Orientation Data

When the package is imported for the first time the required data will be automatically downloaded from the IERS servers.
After that the data needs to be updated manually like shown below.

```julia
using EarthOrientation
EarthOrientation.update()
```

If the data is older than one week newer EOP data should be available and a warning will be given on import.

## Loading Earth Orientation Data

The downloaded data is parsed into an `EOParams` object:

```julia
eop = EOParams()
```

By default the files downloaded by `EarthOrientation.update()` will be used.
It is also possible to manually pass the required
[finals.all](https://datacenter.iers.org/eop/-/somos/5Rgv/getMeta/7/finals.all) and
[finals2000A.all](https://datacenter.iers.org/eop/-/somos/5Rgv/getMeta/9/finals2000A.all) files in CSV format.

```julia
eop = EOParams("finals.csv", "finals2000A.csv")
```

This is useful if the data should not be managed by *EarthOrientation.jl* but by a different system instead.

## Interpolating Earth Orientation Data

Get the current Earth orientation parameters, e.g. for polar motion:

```julia
xp, yp = polarmotion(eop, now()) # arcseconds
```

Or the current difference between UT1 and UTC and the associated prediction error:

```julia
ΔUT1 = getΔUT1(eop, now()) # seconds
ΔUT1_err = getΔUT1_err(eop, now()) # milliseconds
```
