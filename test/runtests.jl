using EarthOrientation
import EarthOrientation.OutOfRangeError
using Base.Test

# write your own tests here
@testset "EarthOrientation" begin
    #= @testset "Interpolation" begin =#
    #=     xv = collect(0.0:3.0) =#
    #=     yv = [Nullable(el) for el in 0.0:2.0] =#
    #=     push!(yv, Nullable{Float64}()) =#
    #=     @test interpolate(xv, yv, 1.0) == 1.0 =#
    #=     @test interpolate(xv, yv, 1.5) == 1.5 =#
    #=     @test interpolate(xv, yv, -1.0, warnings=false) == -1.0 =#
    #=     @test interpolate(xv, yv, 3.0, warnings=false) == 3.0 =#
    #=     @test interpolate(xv, yv, 30.0, warnings=false) == 30.0 =#
    #=     @test_throws OutOfRangeError interpolate(xv, yv, -1.0, extrapolate=false) =#
    #=     @test_throws OutOfRangeError interpolate(xv, yv, 3.0, extrapolate=false) =#
    #= end =#
    @testset "API" begin
        eop = EOPData()
        dt = Base.Dates.DateTime(2000, 1, 1)
        @test interpolate(eop, :δx, Base.Dates.datetime2julian(dt)) == -0.135
        @test interpolate(eop, :δx, dt) == -0.135
        @test getxp(eop, dt) == 0.043299
        @test getxp_err(eop, dt) == 0.000092
        @test getyp(eop, dt) == 0.377859
        @test getyp_err(eop, dt) == 0.000099
        @test getΔUT1(eop, dt) == 0.3554755
        @test getΔUT1_err(eop, dt) == 0.0000099
        @test getlod(eop, dt) == 0.9333
        @test getlod_err(eop, dt) == 0.0076
        @test getδψ(eop, dt) == -50.607
        @test getδψ_err(eop, dt) == 0.791
        @test getδϵ(eop, dt) == -2.585
        @test getδϵ_err(eop, dt) == 0.298
        @test getδx(eop, dt) == -0.135
        @test getδx_err(eop, dt) == 0.315
        @test getδy(eop, dt) == -0.204
        @test getδy_err(eop, dt) == 0.298
        dt = Base.Dates.DateTime(2000, 1, 1, 12)
        @test getδx(eop, dt) ≈ -0.005462587721092418
        @test_throws OutOfRangeError getδx(eop, now() + Base.Dates.Year(1), extrapolate=false)
        dt = Base.Dates.DateTime(1973, 1, 1)
        @test_throws OutOfRangeError getδx(eop, dt, extrapolate=false)
    end
end
