@testset "Akima" begin
    x = 0.0:10.0
    y = [0.0, 2.0, 1.0, 3.0, 2.0, 6.0, 5.5, 5.5, 2.7, 5.1, 3.0]
    ak = EarthOrientation.Akima(x, y)
    xi = [0.0, 0.5, 1., 1.5, 2.5, 3.5, 4.5, 5.1, 6.5, 7.2, 8.6, 9.9, 10.]
    yi = [0., 1.375, 2., 1.5, 1.953125, 2.484375,
        4.1363636363636366866103344, 5.9803623910336236590978842,
        5.5067291516462386624652936, 5.2031367459745245795943447,
        4.1796554159017080820603951, 3.4110386597938129327189927,
        3.0]
    @testset for i in eachindex(xi, yi)
        @test EarthOrientation.interpolate(ak, xi[i]) ≈ yi[i]
    end
end
