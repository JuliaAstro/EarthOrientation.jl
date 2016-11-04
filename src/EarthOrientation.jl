module EarthOrientation

import Base.Dates: datetime2julian, julian2datetime, Date, today, days

export EOPData, interpolate

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
warn_extrapolation(mjd, when) = warn("No data available $when $(date(mjd)). Extrapolation is probably imprecise.")

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

function getdate(data)
    idx = findlast(data[:,5] .== "final")
    Date(data[idx,2], data[idx,3], data[idx,4])
end

function isold(file)
    data, header = readdlm(file, ';', header=true)
    timestamp = getdate(data)
    days(today() - timestamp) > 7
end

type EOPData
    date::Date
    mjd::Vector{Float64}
    xp::Vector{Nullable{Float64}}
    xp_err::Vector{Nullable{Float64}}
    yp::Vector{Nullable{Float64}}
    yp_err::Vector{Nullable{Float64}}
    ΔUT1::Vector{Nullable{Float64}}
    ΔUT1_err::Vector{Nullable{Float64}}
    lod::Vector{Nullable{Float64}}
    lod_err::Vector{Nullable{Float64}}
    δψ::Vector{Nullable{Float64}}
    δψ_err::Vector{Nullable{Float64}}
    δϵ::Vector{Nullable{Float64}}
    δϵ_err::Vector{Nullable{Float64}}
    δx::Vector{Nullable{Float64}}
    δx_err::Vector{Nullable{Float64}}
    δy::Vector{Nullable{Float64}}
    δy_err::Vector{Nullable{Float64}}
    EOPData(date, mjd) = new(date, mjd)
end

function EOPData(iau1980::String, iau2000::String)
    data80, header80 = readdlm(iau1980, ';', header=true)
    data00, header00 = readdlm(iau2000, ';', header=true)
    n = size(data80, 1)
    date = getdate(data80)
    mjd = Vector{Float64}(data80[:,1])
    eop = EOPData(date, mjd)
    for field in fieldnames(EOPData)[3:end]
        setfield!(eop, field, Array(Nullable{Float64}, n))
    end
    ind1 = [collect(6:9); collect(11:14); collect(16:19)]
    ind2 = collect(20:23)
    for i = 1:n
        row = view(data80, i, :)
        for (field, idx) in zip(fieldnames(EOPData)[3:end], ind1)
            getfield(eop, field)[i] = row[idx] == "" ? Nullable{Float64}() : Nullable(row[idx])
        end
        row = view(data00, i, :)
        for (field, idx) in zip(fieldnames(EOPData)[end-3:end], ind2)
            getfield(eop, field)[i] = row[idx] == "" ? Nullable{Float64}() : Nullable(row[idx])
        end
    end
    return eop
end
EOPData() = EOPData(FILES...)

Base.show(io::IO, eop::EOPData) = print(io, "EOPData($(eop.date))")

function interpolate(eop::EOPData, field::Symbol, jd::Float64; extrapolate=true, warnings=true)
    interpolate(eop.mjd, getfield(eop, field), jd - MJD_EPOCH,
                extrapolate=extrapolate, warnings=warnings)
end

function interpolate(eop::EOPData, field::Symbol, dt::DateTime; kwargs...)
    interpolate(eop, field, datetime2julian(dt); kwargs...)
end

function interpolate(xv, yv, x; extrapolate=true, warnings=true)
    idx = findfirst(map(y->isapprox(x, y), xv))
    if idx != 0 && !isnull(yv[idx])
        return get(yv[idx])
    end
    idx = findfirst(x .< xv)
    if idx == 0
        if extrapolate
            warnings && warn_extrapolation(xv[end], "after")
            idx = length(xv)
        else
            throw(OutOfRangeError(x, "after"))
        end
    elseif idx == 1
        if extrapolate
            warnings && warn_extrapolation(xv[1], "before")
            idx = 2
        else
            throw(OutOfRangeError(x, "before"))
        end
    end
    if isnull(yv[idx])
        if extrapolate
            idx = findlast(!isnull.(yv))
            warnings && warn_extrapolation(xv[idx], "after")
        else
            throw(OutOfRangeError(x, "after"))
        end
    end
    x0 = xv[idx-1]
    y1 = get(yv[idx])
    y0 = get(yv[idx-1])
    y = y0 + (y1 - y0) * (x - x0)
end

for sym in fieldnames(EOPData)[3:end]
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
