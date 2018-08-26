struct Akima
    n::Int
    x::Vector{Float64}
    y::Vector{Float64}
    b::Vector{Float64}
    c::Vector{Float64}
    d::Vector{Float64}
end

function Akima(x, y)
    n = length(x)
    @assert n == length(y)
    dx = diff(x)
    m = Array{Float64}(undef, n + 3)
    m[3:end-2] = diff(y) ./ dx
    m[2] = 2m[3] - m[4]
    m[1] = 2m[2] - m[3]
    m[end-1] = 2m[end-2] - m[end-3]
    m[end] = 2m[end-1] - m[end-2]

    # if m1 == m2 != m3 == m4, the slope at the breakpoint is not defined.
    # This is the fill value:
    b = 0.5 .* (m[4:end] .+ m[1:end-3])
    # get the denominator of the slope t
    dm = abs.(diff(m))
    f1 = dm[3:n+2]
    f2 = dm[1:n]
    f12 = f1 + f2
    # These are the mask of where the the slope at breakpoint is defined:
    ind = findall(f12 .> 1e-9 * maximum(f12))
    # Set the slope at breakpoint
    b[ind] = (f1[ind] .* m[ind .+ 1] .+
              f2[ind] .* m[ind .+ 2]) ./ f12[ind]
    # calculate the higher order coefficients
    c = (3.0 .* m[3:end-2] .- 2.0 .* b[1:end-1] .- b[2:end]) ./ dx
    d = (b[1:end-1] .+ b[2:end] .- 2.0 .* m[3:end-2]) ./ dx.^2

    Akima(n, x, y, b, c, d)
end

function interpolate(a::Akima, xi)
    idx = searchsortedlast(a.x, xi)
    idx == 0 && return a.y[1]
    idx == a.n && return a.y[end]

    wj = xi - a.x[idx]
    @evalpoly wj a.y[idx] a.b[idx] a.c[idx] a.d[idx]
end
