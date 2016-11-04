module EarthOrientation

export EOPData

const PATH = abspath(dirname(@__FILE__), "..", "data")

const NAMES = ("IAU1980", "IAU2000")
const FILES = (joinpath(PATH, "finals.csv"), joinpath(PATH, "finals2000A.csv"))
const URLS = ("https://datacenter.iers.org/eop/-/somos/5Rgv/latestXL/7/finals.all/csv",
              "https://datacenter.iers.org/eop/-/somos/5Rgv/latestXL/9/finals2000A.all/csv")

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
    Base.Dates.Date(data[idx,2], data[idx,3], data[idx,4])
end

function isold(file)
    data, header = readdlm(file, ';', header=true)
    timestamp = getdate(data)
    today = Base.Dates.today()
    Base.Dates.days(today - timestamp) > 7
end

type EOPData
    date::Base.Dates.Date
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
    data00, header00 = readdlm(iau1980, ';', header=true)
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
        row = view(data80, n, :)
        for (field, idx) in zip(fieldnames(EOPData)[3:end], ind1)
            getfield(eop, field)[i] = row[idx] == "" ? Nullable{Float64}() : Nullable(row[idx])
        end
        row = view(data00, n, :)
        for (field, idx) in zip(fieldnames(EOPData)[end-3:end], ind2)
            getfield(eop, field)[i] = row[idx] == "" ? Nullable{Float64}() : Nullable(row[idx])
        end
    end
    return eop
end
EOPData() = EOPData(FILES...)

Base.show(io::IO, eop::EOPData) = print(io, "EOPData($(eop.date))")

end # module
