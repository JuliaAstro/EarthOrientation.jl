# Tutorial

Fetch the latest [IERS](https://www.iers.org/IERS/EN/DataProducts/EarthOrientationData/eop.html) tables:

```julia
using EarthOrientation
EarthOrientation.update()
```

Parse the data files into an `EOParameters` object:

```julia
eop = EOParameters()
```

By default the files downloaded by `EarthOrientation.update()` will be used. It is also possible to pass
different [finals.all](https://datacenter.iers.org/eop/-/somos/5Rgv/getMeta/7/finals.all) and
[finals2000A.all](https://datacenter.iers.org/eop/-/somos/5Rgv/getMeta/9/finals2000A.all) files in CSV format.

```julia
eop = EOParameters("finals.csv", "finals2000A.csv")
```

Get the current Earth orientation parameters, e.g. for polar motion:

```julia
xp, yp = polarmotion(eop, now()) # arcseconds
```

Or the current difference between UT1 and UTC and the associated prediction error:

```julia
ΔUT1 = getΔUT1(eop, now()) # seconds
ΔUT1_err = getΔUT1_err(eop, now()) # milliseconds
```
