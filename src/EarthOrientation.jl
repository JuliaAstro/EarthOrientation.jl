module EarthOrientation

using Dates: datetime2julian, julian2datetime, Date, DateTime, today, days
using DelimitedFiles
using OptionalData
using RemoteFiles

export EOParams, EOP_DATA, interpolate
export polarmotion, getxp, getxp_err, getyp, getyp_err
export precession_nutation80, getdψ, getdψ_err, getdϵ, getdϵ_err
export precession_nutation00, getdx, getdx_err, getdy, getdy_err
export getΔUT1, getΔUT1_err, getlod, getlod_err

function __init__()
    if isfile(data)
        eop = EOParams(paths(data, :iau1980, :iau2000)...)
        push!(EOP_DATA, eop)
    end
end

@RemoteFileSet data "IERS Data" begin
    iau1980 = @RemoteFile(
        "https://datacenter.iers.org/eop/-/somos/5Rgv/latestXL/7/finals.all/csv",
        file="finals.csv",
        updates=:thursdays,
    )
    iau2000 = @RemoteFile(
        "https://datacenter.iers.org/eop/-/somos/6Rgv/latestXL/9/finals2000A.all/csv",
        file="finals2000A.csv",
        updates=:thursdays,
    )
end

include("akima.jl")

const MJD_EPOCH = 2400000.5
date_from_mjd(mjd) = Date(julian2datetime(mjd + MJD_EPOCH))

struct OutOfRangeError <: Base.Exception
    mjd::Float64
    when::String
end
Base.showerror(io::IO, err::OutOfRangeError) = print(io, "No data available ",
    err.when, " ", date_from_mjd(err.mjd), ".")
warn_extrapolation(mjd, when) = @warn("No data available $when " *
    "$(date_from_mjd(mjd)). Extrapolation is probably imprecise.")

"""
    update()

Download weekly EOP data from the IERS servers if newer files are available or
no data has been downloaded previously.
"""
function update()
    download(data)
    push!(EOP_DATA, paths(data, :iau1980, :iau2000)...)
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

mutable struct EOParams
    "Creation date of the contained IERS tables."
    date::Date
    "All modified Julian dates covered by this table."
    mjd::Vector{Float64}
    "Contains the last available data point for every table."
    lastdate::Dict{Symbol, Float64}
    "North pole x-coordinate."
    xp::Akima
    "Error in North pole x-coordinate."
    xp_err::Akima
    "North pole y-coordinate."
    yp::Akima
    "Error in North pole y-coordinate."
    yp_err::Akima
    "Difference between UT1 and UTC."
    ΔUT1::Akima
    "Error in difference between UT1 and UTC."
    ΔUT1_err::Akima
    "Excess length of day."
    lod::Akima
    "Error in excess length of day."
    lod_err::Akima
    "Ecliptic nutation correction."
    dψ::Akima
    "Error in ecliptic nutation correction."
    dψ_err::Akima
    "Ecliptic obliquity correction"
    dϵ::Akima
    "Error in ecliptic obliquity correction"
    dϵ_err::Akima
    "Celestial pole x-coordinate correction."
    dx::Akima
    "Error in celestial pole x-coordinate correction."
    dx_err::Akima
    "Celestial pole y-coordinate correction."
    dy::Akima
    "Error in celestial pole y-coordinate correction."
    dy_err::Akima

    EOParams(date, mjd) = new(date, mjd, Dict{Symbol,Float64}())
end

@OptionalData EOP_DATA EOParams "Call 'EarthOrientation.update()' to load it."

const columns = Dict(
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

"""
    EOParams(iau1980file::String, iau2000file::String)

Parse IERS data files into a `EOParams` object.
`iau1980file` and `iau2000file` are the paths to a 'finals.all' and a
'finals2000A.all' CSV file, respectively.
"""
function EOParams(iau1980file::String, iau2000file::String)
    data80, header80 = readdlm(iau1980file, ';', header=true)
    data00, header00 = readdlm(iau2000file, ';', header=true)
    date = getdate(data80)
    mjd = Vector{Float64}(data80[:,1])
    eop = EOParams(date, mjd)
    for field in fieldnames(EOParams)[4:end]
        col = columns[field]
        data = col < 20 ? data80 : data00
        row = findfirst(isempty.(data[:,col])) - 1
        merge!(eop.lastdate, Dict(field => mjd[row]))
        setfield!(eop, field,
                  Akima(mjd[1:row], Vector{Float64}(data[1:row,col])))
    end
    return eop
end

Base.show(io::IO, eop::EOParams) = print(io, "EOParams($(eop.date))")

function interpolate(eop::EOParams, field::Symbol, jd::Float64; extrapolate=true, warnings=true)
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

    interpolate(getfield(eop, field), mjd)
end

function interpolate(eop::EOParams, field::Symbol, dt::DateTime; args...)
    interpolate(eop, field, datetime2julian(dt); args...)
end

################
# Polar motion #
################

"""
    getxp(date; extrapolate=true, warnings=true)

Get the x-coordinate of Earth's north pole w.r.t. the CIO for a certain `date` in arcseconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
getxp(eop, date; args...) = interpolate(eop, :xp, date; args...)
getxp(date; args...) = getxp(get(EOP_DATA), date; args...)

"""
    getxp_err(date; extrapolate=true, warnings=true)

Get the error for the x-coordinate of Earth's north pole w.r.t. the CIO
for a certain `date` in arcseconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
getxp_err(eop, date; args...) = interpolate(eop, :xp_err, date; args...)
getxp_err(date; args...) = getxp_err(get(EOP_DATA), date; args...)

"""
    getyp(date; extrapolate=true, warnings=true)

Get the y-coordinate of Earth's north pole w.r.t. the CIO for a certain `date` in arcseconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
getyp(eop, date; args...) = interpolate(eop, :yp, date; args...)
getyp(date; args...) = getyp(get(EOP_DATA), date; args...)

"""
    getyp_err(date; extrapolate=true, warnings=true)

Get the error for the y-coordinate of Earth's north pole w.r.t. the CIO
for a certain `date` in arcseconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
getyp_err(eop, date; args...) = interpolate(eop, :yp_err, date; args...)
getyp_err(date; args...) = getyp_err(get(EOP_DATA), date; args...)

"""
    polarmotion(date; extrapolate=true, warnings=true)

Get the coordinates of Earth's north pole w.r.t. the CIO for a certain `date` in arcseconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
polarmotion(eop, date; args...) = (getxp(eop, date; args...),
    getyp(eop, date; warnings=false, args...))
polarmotion(date; args...) = (getxp(date; args...),
    getyp(date; warnings=false, args...))

################
# ΔUT1 and LOD #
################

"""
    getΔUT1(date; extrapolate=true, warnings=true)

Get the difference between UTC and UT1 for a certain `date` in seconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
getΔUT1(eop, date; args...) = interpolate(eop, :ΔUT1, date; args...)
getΔUT1(date; args...) = getΔUT1(get(EOP_DATA), date; args...)

"""
    getΔUT1_err(date; extrapolate=true, warnings=true)

Get the error in the difference between UTC and UT1 for a certain `date` in seconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
getΔUT1_err(eop, date; args...) = interpolate(eop, :ΔUT1_err, date; args...)
getΔUT1_err(date; args...) = getΔUT1_err(get(EOP_DATA), date; args...)

"""
    getlod(date; extrapolate=true, warnings=true)

Get the excess length of day for a certain `date` in milliseconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
getlod(eop, date; args...) = interpolate(eop, :lod, date; args...)
getlod(date; args...) = getlod(get(EOP_DATA), date; args...)

"""
    getlod_err(date; extrapolate=true, warnings=true)

Get the error in the excess length of day for a certain `date` in milliseconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
getlod_err(eop, date; args...) = interpolate(eop, :lod_err, date; args...)
getlod_err(date; args...) = getlod_err(get(EOP_DATA), date; args...)

#######################################
# IAU 1980 precession/nutation theory #
#######################################

"""
    getdψ(date; extrapolate=true, warnings=true)

Get the ecliptic nutation correction for a certain `date` in milliarcseconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
getdψ(eop, date; args...) = interpolate(eop, :dψ, date; args...)
getdψ(date; args...) = getdψ(get(EOP_DATA), date; args...)

"""
    getdψ_err(date; extrapolate=true, warnings=true)

Get the error in the ecliptic nutation correction for a certain `date` in milliarcseconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
getdψ_err(eop, date; args...) = interpolate(eop, :dψ_err, date; args...)
getdψ_err(date; args...) = getdψ_err(get(EOP_DATA), date; args...)

"""
    getdϵ(date; extrapolate=true, warnings=true)

Get the ecliptic obliquity correction for a certain `date` in milliarcseconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
getdϵ(eop, date; args...) = interpolate(eop, :dϵ, date; args...)
getdϵ(date; args...) = getdϵ(get(EOP_DATA), date; args...)

"""
    getdϵ_err(date; extrapolate=true, warnings=true)

Get the error in the ecliptic obliquity correction for a certain `date` in milliarcseconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
getdϵ_err(eop, date; args...) = interpolate(eop, :dϵ_err, date; args...)
getdϵ_err(date; args...) = getdϵ_err(get(EOP_DATA), date; args...)

"""
    precession_nutation80(date; extrapolate=true, warnings=true)

Get the ecliptic corrections for a certain `date` in milliarcseconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
precession_nutation80(eop, date; args...) = (getdψ(eop, date; args...),
    getdϵ(eop, date; warnings=false, args...))
precession_nutation80(date; args...) = (getdψ(date; args...),
    getdϵ(date; warnings=false, args...))

############################################
# IAU 2000/2006 precession/nutation theory #
############################################

"""
    getdx(date; extrapolate=true, warnings=true)

Get the celestial pole x-coordinate correction for a certain `date` in milliarcseconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
getdx(eop, date; args...) = interpolate(eop, :dx, date; args...)
getdx(date; args...) = getdx(get(EOP_DATA), date; args...)

"""
    getdx_err(date; extrapolate=true, warnings=true)

Get the error in celestial pole x-coordinate correction for a certain `date` in milliarcseconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
getdx_err(eop, date; args...) = interpolate(eop, :dx_err, date; args...)
getdx_err(date; args...) = getdx_err(get(EOP_DATA), date; args...)

"""
    getdy(date; extrapolate=true, warnings=true)

Get the celestial pole y-coordinate correction for a certain `date` in milliarcseconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
getdy(eop, date; args...) = interpolate(eop, :dy, date; args...)
getdy(date; args...) = getdy(get(EOP_DATA), date; args...)

"""
    getdy_err(date; extrapolate=true, warnings=true)

Get the error in celestial pole y-coordinate correction for a certain `date` in milliarcseconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
getdy_err(eop, date; args...) = interpolate(eop, :dy_err, date; args...)
getdy_err(date; args...) = getdy_err(get(EOP_DATA), date; args...)

"""
    precession_nutation00(date; extrapolate=true, warnings=true)

Get the celestial pole coordinate corrections for a certain `date` in milliarcseconds.

`date` can either be a `DateTime` object or a Julian date represented by a `Float64`.
If `extrapolate` is `false` an exception will be thrown if `date` is beyond the range of
the table contained in `eop`.
If `warnings` is `true` the user will be warned if the result is extrapolated.
"""
precession_nutation00(eop, date; args...) = (getdx(eop, date; args...), getdy(eop, date; warnings=false, args...))
precession_nutation00(date; args...) = (getdx(date; args...), getdy(date; warnings=false, args...))

end # module
