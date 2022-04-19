using NativeNaNMath
using Test

@testset "log" begin
    @test isnan(NativeNaNMath.log(-10))
    @test isnan(NativeNaNMath.log1p(-100))
end

@testset "pow" begin
    @test isnan(NativeNaNMath.pow(-1.5,2.3))
    @test isnan(NativeNaNMath.pow(-1.5f0,2.3f0))
    @test isnan(NativeNaNMath.pow(-1.5,2.3f0))
    @test isnan(NativeNaNMath.pow(-1.5f0,2.3))
    @test NativeNaNMath.pow(-1,2) isa Float64
    @test NativeNaNMath.pow(-1.5f0,2) isa Float32
    @test NativeNaNMath.pow(-1.5f0,2//1) isa Float32
    @test NativeNaNMath.pow(-1.5f0,2.3f0) isa Float32
    @test NativeNaNMath.pow(-1.5f0,2.3) isa Float64
    @test NativeNaNMath.pow(-1.5,2) isa Float64
    @test NativeNaNMath.pow(-1.5,2//1) isa Float64
    @test NativeNaNMath.pow(-1.5,2.3f0) isa Float64
    @test NativeNaNMath.pow(-1.5,2.3) isa Float64
end

@testset "sqrt" begin
    @test isnan(NativeNaNMath.sqrt(-5))
    @test NativeNaNMath.sqrt(5) == Base.sqrt(5)
end

@testset "reductions" begin
    @test NativeNaNMath.sum([1., 2., NaN]) == 3.0
    @test NativeNaNMath.sum([1. 2.; NaN 1.]) == 4.0
    @test isnan(NativeNaNMath.sum([NaN, NaN]))
    @test NativeNaNMath.sum(Float64[]) == 0.0
    @test NativeNaNMath.sum([1f0, 2f0, NaN32]) === 3.0f0
    @test NativeNaNMath.maximum([1., 2., NaN]) == 2.0
    @test NativeNaNMath.maximum([1. 2.; NaN 1.]) == 2.0
    @test NativeNaNMath.minimum([1., 2., NaN]) == 1.0
    @test NativeNaNMath.minimum([1. 2.; NaN 1.]) == 1.0
    @test NativeNaNMath.extrema([1., 2., NaN]) == (1.0, 2.0)
    @test NativeNaNMath.extrema([2., 1., NaN]) == (1.0, 2.0)
    @test NativeNaNMath.extrema([1. 2.; NaN 1.]) == (1.0, 2.0)
    @test NativeNaNMath.extrema([2. 1.; 1. NaN]) == (1.0, 2.0)
    @test NativeNaNMath.extrema([NaN, -1., NaN]) == (-1.0, -1.0)
end

@testset "statistics" begin
    @test NativeNaNMath.mean([1., 2., NaN]) == 1.5
    @test NativeNaNMath.mean([1. 2.; NaN 3.]) == 2.0
    @test NativeNaNMath.var([1., 2., NaN]) == 0.5
    @test NativeNaNMath.std([1., 2., NaN]) == 0.7071067811865476
    @test NativeNaNMath.median([1.]) == 1.
    @test NativeNaNMath.median([1., NaN]) == 1.
    @test NativeNaNMath.median([NaN, 1., 3.]) == 2.
    @test NativeNaNMath.median([1., 3., 2., NaN]) == 2.
    @test NativeNaNMath.median([NaN, 1, 3]) == 2.
    @test NativeNaNMath.median([1, 2, NaN]) == 1.5
    @test NativeNaNMath.median([1 2; NaN NaN]) == 1.5
    @test NativeNaNMath.median([NaN 2; 1 NaN]) == 1.5
    @test isnan(NativeNaNMath.median(Float64[]))
    @test isnan(NativeNaNMath.median(Float32[]))
    @test isnan(NativeNaNMath.median([NaN]))
end

@testset "min/max" begin
    @test NativeNaNMath.min(1, 2) == 1
    @test NativeNaNMath.min(1.0, 2.0) == 1.0
    @test NativeNaNMath.min(1, 2.0) == 1.0
    @test NativeNaNMath.min(BigFloat(1.0), 2.0) == BigFloat(1.0)
    @test NativeNaNMath.min(BigFloat(1.0), BigFloat(2.0)) == BigFloat(1.0)
    @test NativeNaNMath.min(NaN, 1) == 1.0
    @test NativeNaNMath.min(NaN32, 1) == 1.0f0
    @test isnan(NativeNaNMath.min(NaN, NaN))
    @test isnan(NativeNaNMath.min(NaN))
    @test NativeNaNMath.min(NaN, NaN, 0.0, 1.0) == 0.0
    @test NativeNaNMath.max(1, 2) == 2
    @test NativeNaNMath.max(1.0, 2.0) == 2.0
    @test NativeNaNMath.max(1, 2.0) == 2.0
    @test NativeNaNMath.max(BigFloat(1.0), 2.0) == BigFloat(2.0)
    @test NativeNaNMath.max(BigFloat(1.0), BigFloat(2.0)) == BigFloat(2.0)
    @test NativeNaNMath.max(NaN, 1) == 1.0
    @test NativeNaNMath.max(NaN32, 1) == 1.0f0
    @test isnan(NativeNaNMath.max(NaN, NaN))
    @test isnan(NativeNaNMath.max(NaN))
    @test NativeNaNMath.max(NaN, NaN, 0.0, 1.0) == 1.0
end