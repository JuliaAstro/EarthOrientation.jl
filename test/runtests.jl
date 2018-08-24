using Test
using EarthOrientation

using Dates: DateTime, Year, datetime2julian, now

import EarthOrientation.OutOfRangeError

const FINALS = joinpath(@__DIR__, "finals.csv")
const FINALS_2000A = joinpath(@__DIR__, "finals2000A.csv")

push!(EOP_DATA, FINALS, FINALS_2000A)

@testset "EarthOrientation" begin
    include("akima.jl")

    @testset "API" begin
        eop = get(EOP_DATA)
        dt = DateTime(2000, 1, 1)
        @test interpolate(eop, :dx, datetime2julian(dt)) ≈ -0.135
        @test interpolate(eop, :dx, dt) ≈ -0.135
        @test getxp(eop, dt) ≈ 0.043301
        @test getxp(dt) ≈ 0.043301
        @test getxp_err(eop, dt) ≈ 0.000092
        @test getxp_err(dt) ≈ 0.000092
        @test getyp(eop, dt) ≈ 0.377879
        @test getyp(dt) ≈ 0.377879
        @test getyp_err(eop, dt) ≈ 0.000099
        @test getyp_err(dt) ≈ 0.000099
        @test all(polarmotion(eop, dt) .≈ (0.043301, 0.377879))
        @test all(polarmotion(dt) .≈ (0.043301, 0.377879))
        @test getΔUT1(eop, dt) ≈ 0.3554784
        @test getΔUT1(dt) ≈ 0.3554784
        @test getΔUT1_err(eop, dt) ≈ 0.0000099
        @test getΔUT1_err(dt) ≈ 0.0000099
        @test getlod(eop, dt) ≈ 0.9333
        @test getlod(dt) ≈ 0.9333
        @test getlod_err(eop, dt) ≈ 0.0076
        @test getlod_err(dt) ≈ 0.0076
        @test getdψ(eop, dt) ≈ -50.607
        @test getdψ(dt) ≈ -50.607
        @test getdψ_err(eop, dt) ≈ 0.791
        @test getdψ_err(dt) ≈ 0.791
        @test getdϵ(eop, dt) ≈ -2.585
        @test getdϵ(dt) ≈ -2.585
        @test getdϵ_err(eop, dt) ≈ 0.298
        @test getdϵ_err(dt) ≈ 0.298
        @test all(precession_nutation80(eop, dt) .≈ (-50.607, -2.585))
        @test all(precession_nutation80(dt) .≈ (-50.607, -2.585))
        @test getdx(eop, dt) ≈ -0.135
        @test getdx(dt) ≈ -0.135
        @test getdx_err(eop, dt) ≈ 0.315
        @test getdx_err(dt) ≈ 0.315
        @test getdy(eop, dt) ≈ -0.204
        @test getdy(dt) ≈ -0.204
        @test getdy_err(eop, dt) ≈ 0.298
        @test getdy_err(dt) ≈ 0.298
        @test all(precession_nutation00(eop, dt) .≈ (-0.135, -0.204))
        @test all(precession_nutation00(dt) .≈ (-0.135, -0.204))
        dt = DateTime(2017, 1, 1, 12)
        # Reference value from Orekit which uses Hermite interpolation
        @test getΔUT1(eop, dt) ≈ 0.5907459506337509 rtol=1e-4
        @test_throws OutOfRangeError getdx(eop, now() + Year(1), extrapolate=false)
        dt = DateTime(1973, 1, 1)
        @test_throws OutOfRangeError getdx(eop, dt, extrapolate=false)
    end
end
