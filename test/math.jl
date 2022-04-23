@testset "nan" begin
    for T in (Int8,Int16,Int32,Int64,Float32,Float64,BigFloat,BigInt,Rational{Int},Rational{BigInt})
        @test isnan(nan(T))
    end
end

@testset "log" begin
    @test isnan(NativeNaNMath.log(-10))
    @test isnan(NativeNaNMath.log1p(-100))
    @test isnan(NativeNaNMath.log2(-100))
    @test isnan(NativeNaNMath.log10(-100))
    @test isnan(NativeNaNMath.log(-10,2))
    @test isnan(NativeNaNMath.log(10,-2))
    @test isnan(NativeNaNMath.log(-2,-2))
    @test NativeNaNMath.log(Complex(2)) == Base.log(Complex(2))
    @test NativeNaNMath.log2(Complex(2)) == Base.log2(Complex(2))
    @test NativeNaNMath.log10(Complex(2)) == Base.log10(Complex(2))
    @test NativeNaNMath.log1p(Complex(2)) == Base.log1p(Complex(2))
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
    @test NativeNaNMath.pow(randdiag,2) == randdiag^2
end

@testset "sqrt" begin
    @test isnan(NativeNaNMath.sqrt(-5))
    @test NativeNaNMath.sqrt(5) == Base.sqrt(5)
end

@testset "finite domain" begin
    @test isnan(NativeNaNMath.sin(Inf))
    @test isnan(NativeNaNMath.sind(Inf))
    @test isnan(NativeNaNMath.sinpi(Inf))
    @test isnan(NativeNaNMath.cos(Inf))
    @test isnan(NativeNaNMath.cosd(Inf))
    @test isnan(NativeNaNMath.cospi(Inf))
    @test isnan(NativeNaNMath.tan(Inf))
    @test isnan(NativeNaNMath.tand(Inf))
    @test isnan(NativeNaNMath.sec(Inf))
    @test isnan(NativeNaNMath.secd(Inf))
    @test isnan(NativeNaNMath.cot(Inf))
    @test isnan(NativeNaNMath.cotd(Inf))
    @test isnan(NativeNaNMath.csc(Inf))
    @test isnan(NativeNaNMath.cscd(Inf))
    
    @test isnan(NativeNaNMath.sin(-Inf))
    @test isnan(NativeNaNMath.sind(-Inf))
    @test isnan(NativeNaNMath.sinpi(-Inf))
    @test isnan(NativeNaNMath.cos(-Inf))
    @test isnan(NativeNaNMath.cosd(-Inf))
    @test isnan(NativeNaNMath.cospi(-Inf))
    @test isnan(NativeNaNMath.tan(-Inf))
    @test isnan(NativeNaNMath.tand(-Inf))
    @test isnan(NativeNaNMath.sec(-Inf))
    @test isnan(NativeNaNMath.secd(-Inf))
    @test isnan(NativeNaNMath.cot(-Inf))
    @test isnan(NativeNaNMath.cotd(-Inf))
    @test isnan(NativeNaNMath.csc(-Inf))
    @test isnan(NativeNaNMath.cscd(-Inf))

    @test !isnan(NativeNaNMath.sin(-2.3))
    @test !isnan(NativeNaNMath.sind(-2.3))
    @test !isnan(NativeNaNMath.sinpi(-2.3))
    @test !isnan(NativeNaNMath.cos(-2.3))
    @test !isnan(NativeNaNMath.cosd(-2.3))
    @test !isnan(NativeNaNMath.cospi(-2.3))
    @test !isnan(NativeNaNMath.tan(-2.3))
    @test !isnan(NativeNaNMath.tand(-2.3))
    @test !isnan(NativeNaNMath.sec(-2.3))
    @test !isnan(NativeNaNMath.secd(-2.3))
    @test !isnan(NativeNaNMath.cot(-2.3))
    @test !isnan(NativeNaNMath.cotd(-2.3))
    @test !isnan(NativeNaNMath.csc(-2.3))
    @test !isnan(NativeNaNMath.cscd(-2.3))

    @test isnan.(NativeNaNMath.sincos(Inf)) |> all
    @test isnan.(NativeNaNMath.sincospi(Inf)) |> all
    @test isnan.(NativeNaNMath.sincosd(Inf)) |> all

    @test isnan.(NativeNaNMath.sincos(-Inf)) |> all
    @test isnan.(NativeNaNMath.sincospi(-Inf)) |> all
    @test isnan.(NativeNaNMath.sincosd(-Inf)) |> all

    @test !all(isnan.(NativeNaNMath.sincos(-2.3)))
    @test !all(isnan.(NativeNaNMath.sincospi(-2.3)))
    @test !all(isnan.(NativeNaNMath.sincosd(-2.3)))

    @test NativeNaNMath.sin(randdiag) == Base.sin(randdiag)
end

@testset "0 <= x <= 1" begin
    @test isnan(NativeNaNMath.asin(2.))
    @test isnan(NativeNaNMath.asind(2.))
    @test isnan(NativeNaNMath.acos(2.))
    @test isnan(NativeNaNMath.acosd(2.))
    @test isnan(NativeNaNMath.atanh(2.))

    @test isnan(NativeNaNMath.asin(-2.))
    @test isnan(NativeNaNMath.asind(-2.))
    @test isnan(NativeNaNMath.acos(-2.))
    @test isnan(NativeNaNMath.acosd(-2.))
    @test isnan(NativeNaNMath.atanh(-2.))

    @test !isnan(NativeNaNMath.asin(0.))
    @test !isnan(NativeNaNMath.asind(0.))
    @test !isnan(NativeNaNMath.acos(0.))
    @test !isnan(NativeNaNMath.acosd(0.))
    @test !isnan(NativeNaNMath.atanh(0.))

    @test !isnan(NativeNaNMath.asin(-1.))
    @test !isnan(NativeNaNMath.asind(-1.))
    @test !isnan(NativeNaNMath.acos(-1.))
    @test !isnan(NativeNaNMath.acosd(-1.))
    @test !isnan(NativeNaNMath.atanh(-1.))

    @test !isnan(NativeNaNMath.asin(1.))
    @test !isnan(NativeNaNMath.asind(1.))
    @test !isnan(NativeNaNMath.acos(1.))
    @test !isnan(NativeNaNMath.acosd(1.))
    @test !isnan(NativeNaNMath.atanh(1.))

    @test NativeNaNMath.asin(randdiag) == Base.asin(randdiag)
end

@testset  "x ∉ (0,1)" begin
    @test isnan(NativeNaNMath.asec(0.))
    @test isnan(NativeNaNMath.asecd(0.))
    @test isnan(NativeNaNMath.acsc(0.))
    @test isnan(NativeNaNMath.acscd(0.))
    @test isnan(NativeNaNMath.acoth(0.))

    @test !isnan(NativeNaNMath.asec(2.))
    @test !isnan(NativeNaNMath.asecd(2.))
    @test !isnan(NativeNaNMath.acsc(2.))
    @test !isnan(NativeNaNMath.acscd(2.))
    @test !isnan(NativeNaNMath.acoth(2.))

    @test !isnan(NativeNaNMath.asec(-2.))
    @test !isnan(NativeNaNMath.asecd(-2.))
    @test !isnan(NativeNaNMath.acsc(-2.))
    @test !isnan(NativeNaNMath.acscd(-2.))
    @test !isnan(NativeNaNMath.acoth(-2.))

    @test NativeNaNMath.asec(randdiag) == Base.asec(randdiag)
end

@testset "other domains" begin
    #acosh: x >= 1
    @test !isnan(NativeNaNMath.acosh(2))
    @test isnan(NativeNaNMath.acosh(0))
    @test NativeNaNMath.acosh(randdiag) == Base.acosh(randdiag)

    #asech: 0 <= x <= 1
    @test !isnan(NativeNaNMath.asech(0.5))
    @test isnan(NativeNaNMath.asech(2))
    @test isnan(NativeNaNMath.asech(-2))
    @test NativeNaNMath.asech(randdiag) == Base.asech(randdiag)
end

@testset "reductions" begin
    @test sum([1., 2., NaN] |> skipnan) == 3.0
    @test sum([1. 2.; NaN 1.] |> skipnan) == 4.0
    @test_broken isnan(sum([NaN, NaN] |> skipnan))
    #collect(skipnan([NaN, NaN])) == Float64[]
    @test sum(Float64[] |> skipnan) == 0.0
    @test sum([1f0, 2f0, NaN32] |> skipnan) === 3.0f0
    @test maximum([1., 2., NaN] |> skipnan) == 2.0
    @test maximum([1. 2.; NaN 1.] |> skipnan) == 2.0
    @test minimum([1., 2., NaN] |> skipnan) == 1.0
    @test minimum([1. 2.; NaN 1.] |> skipnan) == 1.0
    @test extrema([1., 2., NaN] |> skipnan) == (1.0, 2.0)
    @test extrema([2., 1., NaN] |> skipnan) == (1.0, 2.0)
    @test extrema([1. 2.; NaN 1.] |> skipnan) == (1.0, 2.0)
    @test extrema([2. 1.; 1. NaN] |> skipnan) == (1.0, 2.0)
    @test extrema([NaN, -1., NaN] |> skipnan) == (-1.0, -1.0)
end

@testset "statistics" begin
    @test mean([1., 2., NaN] |> skipnan) == 1.5
    @test mean([1. 2.; NaN 3.] |> skipnan) == 2.0
    @test var([1., 2., NaN] |> skipnan) == 0.5
    @test std([1., 2., NaN] |> skipnan) == 0.7071067811865476
    @test median([1.] |> skipnan) == 1.
    @test median([1., NaN] |> skipnan) == 1.
    @test median([NaN, 1., 3.] |> skipnan) == 2.
    @test median([1., 3., 2., NaN] |> skipnan) == 2.
    @test median([NaN, 1, 3] |> skipnan) == 2.
    @test median([1, 2, NaN] |> skipnan) == 1.5
    @test median([1 2; NaN NaN] |> skipnan) == 1.5
    @test median([NaN 2; 1 NaN] |> skipnan) == 1.5
    @test_broken isnan(median(Float64[] |> skipnan)) #empty collection error
    @test_broken isnan(median(Float32[] |> skipnan)) #empty collection error
    @test_broken isnan(median([NaN] |> skipnan)) #empty collection error
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