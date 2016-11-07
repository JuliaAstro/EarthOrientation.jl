module EarthOrientation

import Base.Dates: datetime2julian, julian2datetime, Date, today, days
using SmoothingSplines

export EOParameters, interpolate
export polarmotion, getxp, getxp_err, getyp, getyp_err
export precession_nutation80, getdψ, getdψ_err, getdϵ, getdϵ_err
export precession_nutation00, getdx, getdx_err, getdy, getdy_err
export getΔUT1, getΔUT1_err, getlod, getlod_err

function __init__()
    !isdir(PATH) && update()
    if isold(FILES[1])
        warn("Outdated EOP data. Please call 'EarthOrientation.update()'.")
    end
end

const PATH = abspath(dirname(@__FILE__), "..", "data")

const NAMES = ("IAU 1980", "IAU 2000")
const FILES = (joinpath(PATH, "finals.csv"), joinpath(PATH, "finals2000A.csv"))
const URLS = ("https://datacenter.iers.org/eop/-/somos/5Rgv/latestXL/7/finals.all/csv",
              "https://datacenter.iers.org/eop/-/somos/5Rgv/latestXL/9/finals2000A.all/csv")

const MJD_EPOCH = 2400000.5
date_from_mjd(mjd) = Date(julian2datetime(mjd + MJD_EPOCH))

type OutOfRangeError <: Base.Exception
    mjd::Float64
    when::String
end
Base.showerror(io::IO, err::OutOfRangeError) = print(io, "No data available ", err.when, " ", date_from_mjd(err.mjd), ".")
warn_extrapolation(mjd, when) = warn("No data available $when $(date_from_mjd(mjd)). Extrapolation is probably imprecise.")

"""
    update()

Download weekly EOP data from the IERS servers if newer files are available or
no data has been downloaded previously.
"""
function update()
    !isdir(PATH) && mkdir(PATH)
    dt = now()
    for (name, file, url) in zip(NAMES, FILES, URLS)
        needsupdate = isfile(file) ? isold(file) : true
        if needsupdate
            info("Updating $name EOP data.")
            download(url, file)
        else
            info("$name EOP data is up-to-date.")
        end
    end
    nothing
end

"""
    getdate(data)

Determine the creation date of an IERS table by finding the last entry which is marked as "final".
"""
function getdate(data)
    idx = findlast(data[:,5] .== "final")
    Date(data[idx,2], data[idx,3], data[idx,4])
end

"""
    isold(file)

Check whether new EOP data should be available, i.e. if the CSV `file` is older than a week.
"""
function isold(file)
    data, header = readdlm(file, ';', header=true)
    timestamp = getdate(data)
    days(today() - timestamp) > 7
end

"Contains Earth orientation parameters since 1973-01-01 until "
type EOParameters
    "Creation date of the contained IERS tables."
    date::Date
    "All modified Julian dates covered by this table."
    mjd::Vector{Float64}
    "Contains the last available data point for every table."
    lastdate::Dict{Symbol, Float64}
    "North pole x-coordinate."
    xp::SmoothingSpline{Float64}
    "Error in North pole x-coordinate."
    xp_err::SmoothingSpline{Float64}
    "North pole y-coordinate."
    yp::SmoothingSpline{Float64}
    "Error in North pole y-coordinate."
    yp_err::SmoothingSpline{Float64}
    "Difference between UT1 and UTC."
    ΔUT1::SmoothingSpline{Float64}
    "Error in difference between UT1 and UTC."
    ΔUT1_err::SmoothingSpline{Float64}
    "Excess length of day."
    lod::SmoothingSpline{Float64}
    "Error in excess length of day."
    lod_err::SmoothingSpline{Float64}
    "Ecliptic nutation correction."
    dψ::SmoothingSpline{Float64}
    "Error in ecliptic nutation correction."
    dψ_err::SmoothingSpline{Float64}
    "Ecliptic obliquity correction"
    dϵ::SmoothingSpline{Float64}
    "Error in ecliptic obliquity correction"
    dϵ_err::SmoothingSpline{Float64}
    "Celestial pole x-coordinate correction."
    dx::SmoothingSpline{Float64}
    "Error in celestial pole x-coordinate correction."
    dx_err::SmoothingSpline{Float64}
    "Celestial pole y-coordinate correction."
    dy::SmoothingSpline{Float64}
    "Error in celestial pole y-coordinate correction."
    dy_err::SmoothingSpline{Float64}

    EOParameters(date, mjd) = new(date, mjd, Dict{Symbol,Float64}())
end

columns = Dict(
    :xp => 6,
    :xp_err => 7,
    :yp => 8,
    :yp_err => 9,
    :ΔUT1 => 11,
    :ΔUT1_err => 12,
    :lod => 13,
    :lod_err => 14,
    :dψ => 16,
    :dψ_err => 17,
    :dϵ => 18,
    :dϵ_err => 19,
    :dx => 20,
    :dx_err => 21,
    :dy => 22,
    :dy_err => 23,
)

function EOParameters(iau1980::String, iau2000::String)
    data80, header80 = readdlm(iau1980, ';', header=true)
    data00, header00 = readdlm(iau2000, ';', header=true)
    date = getdate(data80)
    mjd = Vector{Float64}(data80[:,1])
    eop = EOParameters(date, mjd)
    for field in fieldnames(EOParameters)[4:end]
        col = columns[field]
        data = col < 20 ? data80 : data00
        row = findlast(data[:,col] .!= "")
        merge!(eop.lastdate, Dict(field => mjd[row]))
        setfield!(eop, field, fit(SmoothingSpline, mjd[1:row], Vector{Float64}(data[1:row,col]), 0.0))
    end
    return eop
end
EOParameters() = EOParameters(FILES...)

Base.show(io::IO, eop::EOParameters) = print(io, "EOParameters($(eop.date))")

function interpolate(eop::EOParameters, field::Symbol, jd::Float64; extrapolate=true, warnings=true)
    mjd = jd - MJD_EPOCH
    before = mjd < eop.mjd[1]
    after = mjd > eop.lastdate[field]
    if after || before
        when = after ? "after" : "before"
        lim = after ? eop.lastdate[field] : eop.mjd[1]
        if !extrapolate
            throw(OutOfRangeError(lim, when))
        elseif warnings
            warn_extrapolation(lim, when)
        end
    end

    predict(getfield(eop, field), mjd)
end

function interpolate(eop::EOParameters, field::Symbol, dt::DateTime; args...)
    interpolate(eop, field, datetime2julian(dt); args...)
end

################
# Polar motion #
################

"""
    getxp(eop::EOParameters, date; extrapolate=true, warnings=true)

Get the x-coordinate of Earth's north pole w.r.t. the CIO for a certain `date` in arcseconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
getxp(eop, date; args...) = interpolate(eop, :xp, date; args...)

"""
    getxp_err(eop::EOParameters, date; extrapolate=true, warnings=true)

Get the error for the x-coordinate of Earth's north pole w.r.t. the CIO
for a certain `date` in arcseconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
getxp_err(eop, date; args...) = interpolate(eop, :xp_err, date; args...)

"""
    getyp(eop::EOParameters, date; extrapolate=true, warnings=true)

Get the y-coordinate of Earth's north pole w.r.t. the CIO for a certain `date` in arcseconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
getyp(eop, date; args...) = interpolate(eop, :yp, date; args...)

"""
    getyp_err(eop::EOParameters, date; extrapolate=true, warnings=true)

Get the error for the y-coordinate of Earth's north pole w.r.t. the CIO
for a certain `date` in arcseconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
getyp_err(eop, date; args...) = interpolate(eop, :yp_err, date; args...)

"""
    polarmotion(eop::EOParameters, date; extrapolate=true, warnings=true)

Get the coordinates of Earth's north pole w.r.t. the CIO for a certain `date` in arcseconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
polarmotion(eop, date; args...) = (getxp(eop, date; args...), getyp(eop, date; warnings=false, args...))

################
# ΔUT1 and LOD #
################

"""
    getΔUT1(eop::EOParameters, date; extrapolate=true, warnings=true)

Get the difference between UTC and UT1 for a certain `date` in seconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
getΔUT1(eop, date; args...) = interpolate(eop, :ΔUT1, date; args...)

"""
    getΔUT1_err(eop::EOParameters, date; extrapolate=true, warnings=true)

Get the error in the difference between UTC and UT1 for a certain `date` in seconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
getΔUT1_err(eop, date; args...) = interpolate(eop, :ΔUT1_err, date; args...)

"""
    getlod(eop::EOParameters, date; extrapolate=true, warnings=true)

Get the excess length of day for a certain `date` in milliseconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
getlod(eop, date; args...) = interpolate(eop, :lod, date; args...)

"""
    getlod_err(eop::EOParameters, date; extrapolate=true, warnings=true)

Get the error in the excess length of day for a certain `date` in milliseconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
getlod_err(eop, date; args...) = interpolate(eop, :lod_err, date; args...)

#######################################
# IAU 1980 precession/nutation theory #
#######################################

"""
    getdψ(eop::EOParameters, date; extrapolate=true, warnings=true)

Get the ecliptic nutation correction for a certain `date` in milliarcseconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
getdψ(eop, date; args...) = interpolate(eop, :dψ, date; args...)

"""
    getdψ_err(eop::EOParameters, date; extrapolate=true, warnings=true)

Get the error in the ecliptic nutation correction for a certain `date` in milliarcseconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
getdψ_err(eop, date; args...) = interpolate(eop, :dψ_err, date; args...)

"""
    getdϵ(eop::EOParameters, date; extrapolate=true, warnings=true)

Get the ecliptic obliquity correction for a certain `date` in milliarcseconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
getdϵ(eop, date; args...) = interpolate(eop, :dϵ, date; args...)

"""
    getdϵ_err(eop::EOParameters, date; extrapolate=true, warnings=true)

Get the error in the ecliptic obliquity correction for a certain `date` in milliarcseconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
getdϵ_err(eop, date; args...) = interpolate(eop, :dϵ_err, date; args...)

"""
    precession_nutation80(eop::EOParameters, date; extrapolate=true, warnings=true)

Get the ecliptic corrections for a certain `date` in milliarcseconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
precession_nutation80(eop, date; args...) = (getdψ(eop, date; args...), getdϵ(eop, date; warnings=false, args...))

############################################
# IAU 2000/2006 precession/nutation theory #
############################################

"""
    getdx(eop::EOParameters, date; extrapolate=true, warnings=true)

Get the celestial pole x-coordinate correction for a certain `date` in milliarcseconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
getdx(eop, date; args...) = interpolate(eop, :dx, date; args...)

"""
    getdx_err(eop::EOParameters, date; extrapolate=true, warnings=true)

Get the error in celestial pole x-coordinate correction for a certain `date` in milliarcseconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
getdx_err(eop, date; args...) = interpolate(eop, :dx_err, date; args...)

"""
    getdy(eop::EOParameters, date; extrapolate=true, warnings=true)

Get the celestial pole y-coordinate correction for a certain `date` in milliarcseconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
getdy(eop, date; args...) = interpolate(eop, :dy, date; args...)

"""
    getdy_err(eop::EOParameters, date; extrapolate=true, warnings=true)

Get the error in celestial pole y-coordinate correction for a certain `date` in milliarcseconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
getdy_err(eop, date; args...) = interpolate(eop, :dy_err, date; args...)

"""
    precession_nutation00(eop::EOParameters, date; extrapolate=true, warnings=true)

Get the celestial pole coordinate corrections for a certain `date` in milliarcseconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
precession_nutation00(eop, date; args...) = (getdx(eop, date; args...), getdy(eop, date; warnings=false, args...))

end # module
