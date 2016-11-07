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
date(mjd) = Date(julian2datetime(mjd + MJD_EPOCH))

type OutOfRangeError <: Base.Exception
    mjd::Float64
    when::String
end
Base.showerror(io::IO, err::OutOfRangeError) = print(io, "No data available ", err.when, " ", date(err.mjd), ".")
warn_extrapolation(mjd, when) = warn("No data available $when $(date(mjd)). Extrapolation is probably imprecise.")

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

getxp(eop, dt; args...) = interpolate(eop, :xp, dt; args...)
getxp_err(eop, dt; args...) = interpolate(eop, :xp_err, dt; args...)
getyp(eop, dt; args...) = interpolate(eop, :yp, dt; args...)
getyp_err(eop, dt; args...) = interpolate(eop, :yp_err, dt; args...)
polarmotion(eop, dt; args...) = (getxp(eop, dt; args...), getyp(eop, dt; warnings=false, args...))

getΔUT1(eop, dt; args...) = interpolate(eop, :ΔUT1, dt; args...)
getΔUT1_err(eop, dt; args...) = interpolate(eop, :ΔUT1_err, dt; args...)
getlod(eop, dt; args...) = interpolate(eop, :lod, dt; args...)
getlod_err(eop, dt; args...) = interpolate(eop, :lod_err, dt; args...)

getdψ(eop, dt; args...) = interpolate(eop, :dψ, dt; args...)
getdψ_err(eop, dt; args...) = interpolate(eop, :dψ_err, dt; args...)
getdϵ(eop, dt; args...) = interpolate(eop, :dϵ, dt; args...)
getdϵ_err(eop, dt; args...) = interpolate(eop, :dϵ_err, dt; args...)
precession_nutation80(eop, dt; args...) = (getdψ(eop, dt; args...), getdϵ(eop, dt; warnings=false, args...))

getdx(eop, dt; args...) = interpolate(eop, :dx, dt; args...)
getdx_err(eop, dt; args...) = interpolate(eop, :dx_err, dt; args...)
getdy(eop, dt; args...) = interpolate(eop, :dy, dt; args...)
getdy_err(eop, dt; args...) = interpolate(eop, :dy_err, dt; args...)
precession_nutation00(eop, dt; args...) = (getdx(eop, dt; args...), getdy(eop, dt; warnings=false, args...))

end # module
