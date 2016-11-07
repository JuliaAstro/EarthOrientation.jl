module EarthOrientation

import Base.Dates: datetime2julian, julian2datetime, Date, today, days
using SmoothingSplines

export EOPData, interpolate

function __init__()
    !isdir(PATH) && update()
    if isold(FILES[1])
        warn("Outdated EOP data. Please call 'EarthOrientation.update()'.")
    end
end

const PATH = abspath(dirname(@__FILE__), "..", "data")

const NAMES = ("IAU1980", "IAU2000")
const FILES = (joinpath(PATH, "finals.csv"), joinpath(PATH, "finals2000A.csv"))
const URLS = ("https://datacenter.iers.org/eop/-/somos/5Rgv/latestXL/7/finals.all/csv",
              "https://datacenter.iers.org/eop/-/somos/5Rgv/latestXL/9/finals2000A.all/csv")

const MJD_EPOCH = 2400000.5
date(mjd) = Date(julian2datetime(mjd + MJD_EPOCH))

type OutOfRangeError <: Base.Exception
    mjd::Float64
    when::String
end
Base.showerror(io::IO, e::OutOfRangeError) = print(io, "No data available ", when, " ", date(mjd))
warn_extrapolation(mjd, when) = warn("No data available $when $(date(mjd)).
                                     Extrapolation is probably imprecise.")

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
        end
    end
    nothing
end

"""
    getdate(data)

Determine the creation date of an IERS table by finding the last which is marked as "final".
"""
function getdate(data)
    idx = findlast(data[:,5] .== "final")
    Date(data[idx,2], data[idx,3], data[idx,4])
end

"""
    isold(file)

Check whether new EOP data should be available, i.e. if the CSV file `file` is older than a week.
"""
function isold(file)
    data, header = readdlm(file, ';', header=true)
    timestamp = getdate(data)
    days(today() - timestamp) > 7
end

type EOPData
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
    δψ::SmoothingSpline{Float64}
    "Error in ecliptic nutation correction."
    δψ_err::SmoothingSpline{Float64}
    "Ecliptic obliquity correction"
    δϵ::SmoothingSpline{Float64}
    "Error in ecliptic obliquity correction"
    δϵ_err::SmoothingSpline{Float64}
    "Celestial pole x-coordinate correction."
    δx::SmoothingSpline{Float64}
    "Error in celestial pole x-coordinate correction."
    δx_err::SmoothingSpline{Float64}
    "Celestial pole y-coordinate correction."
    δy::SmoothingSpline{Float64}
    "Error in celestial pole y-coordinate correction."
    δy_err::SmoothingSpline{Float64}

    EOPData(date, mjd) = new(date, mjd, Dict{Symbol,Float64}())
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
    :δψ => 16,
    :δψ_err => 17,
    :δϵ => 18,
    :δϵ_err => 19,
    :δx => 20,
    :δx_err => 21,
    :δy => 22,
    :δy_err => 23,
)

function EOPData(iau1980::String, iau2000::String)
    data80, header80 = readdlm(iau1980, ';', header=true)
    data00, header00 = readdlm(iau2000, ';', header=true)
    date = getdate(data80)
    mjd = Vector{Float64}(data80[:,1])
    eop = EOPData(date, mjd)
    for field in fieldnames(EOPData)[4:end]
        col = columns[field]
        data = col < 20 ? data80 : data00
        row = findlast(data[:,col] .!= "")
        merge!(eop.lastdate, Dict(field => mjd[row]))
        setfield!(eop, field, fit(SmoothingSpline, mjd[1:row], Vector{Float64}(data[1:row,col]), 0.0))
    end
    return eop
end
EOPData() = EOPData(FILES...)

Base.show(io::IO, eop::EOPData) = print(io, "EOPData($(eop.date))")

function interpolate(eop::EOPData, field::Symbol, jd::Float64; extrapolate=true, warnings=true)
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

function interpolate(eop::EOPData, field::Symbol, dt::DateTime; kwargs...)
    interpolate(eop, field, datetime2julian(dt); kwargs...)
end

for sym in fieldnames(EOPData)[4:end]
    fun = Symbol(:get, sym)
    s = Expr(:quote, sym)
    @eval begin
        function $fun(eop::EOPData, dt::DateTime; kwargs...)
            interpolate(eop, $s, datetime2julian(dt); kwargs...)
        end
        function $fun(eop::EOPData, jd::Float64; kwargs...)
            interpolate(eop, $s, jd; kwargs...)
        end
        export $fun
    end
end

end # module
