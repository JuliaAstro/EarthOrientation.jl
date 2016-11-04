module EarthOrientation

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
end

function EOPData(iau1980, iau2000)
    data80, header80 = readdlm(iau1980, ';', header=true)
    data00, header00 = readdlm(iau1980, ';', header=true)
    date = getdate(data80)
    mjd = Vector{Float64}(data80[:,1])
    ind1 = (6, 7, 8, 9, 11, 12, 13, 14, 16, 17, 18, 19)
    ind2 = (20, 21, 22, 23)
    for (sym, idx) in zip(fieldnames(EOPData)[2:end], ind1)
        @eval $sym = [el == "" ? Nullable{Float64}() : Nullable(el) for el in $data80[:,$idx]]
    end
    for (sym, idx) in zip(fieldnames(EOPData)[end-3:end], ind2)
        @eval $sym = [el == "" ? Nullable{Float64}() : Nullable(el) for el in $data00[:,$idx]]
    end
    EOPData(date, mjd, xp, xp_err, yp, yp_err, ΔUT1, ΔUT1_err, lod, lod_err,
            δψ, δψ_err, δϵ, δϵ_err, δx, δx_err, δy, δy_err)
end
EOPData() = EOPData(FILES...)

end # module
