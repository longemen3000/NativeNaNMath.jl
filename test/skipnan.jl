@testset "skipnan" begin
    x = skipnan([1, 2, NaN, 4])
    @test eltype(x) === Float64
    @test collect(x) == [1., 2., 4.]
    @test collect(x) isa Vector{Float64}

    x = skipnan([1.  2.; NaN 4.])
    @test eltype(x) === Float64
    @test collect(x) == [1, 2, 4]
    @test collect(x) isa Vector{Float64}

    x = collect(skipnan([NaN]))
    @test eltype(x) === Float64
    @test isempty(collect(x))
    @test collect(x) isa Vector{Float64}


    x = skipnan([NaN, NaN, 1., 2., NaN, 4., NaN, NaN])
    @test eltype(x) === Float64
    @test collect(x) == [1., 2., 4.]
    @test collect(x) isa Vector{Float64}

    x = skipnan(v for v in [NaN, 1, NaN, 2, 4])
    @test eltype(x) === Any
    @test collect(x) == [1., 2., 4.]
    @test collect(x) isa Vector{Float64}

    @testset "indexing" begin
        x = skipnan([1, NaN, 2, NaN, NaN])
        @test collect(eachindex(x)) == collect(keys(x)) == [1, 3]
        @test x[1] === 1
        @test x[3] === 2
        @test_throws MissingException x[2]
        @test_throws BoundsError x[6]
        @test findfirst(==(2), x) == 3
        @test findall(==(2), x) == [3]
        @test argmin(x) == 1
        @test findmin(x) == (1, 1)
        @test argmax(x) == 3
        @test findmax(x) == (2, 3)

        x = skipnan([NaN 2; 1 NaN])
        @test collect(eachindex(x)) == [2, 3]
        @test collect(keys(x)) == [CartesianIndex(2, 1), CartesianIndex(1, 2)]
        @test x[2] === x[2, 1] === 1
        @test x[3] === x[1, 2] === 2
        @test_throws MissingException x[1]
        @test_throws MissingException x[1, 1]
        @test_throws BoundsError x[5]
        @test_throws BoundsError x[3, 1]
        @test findfirst(==(2), x) == CartesianIndex(1, 2)
        @test findall(==(2), x) == [CartesianIndex(1, 2)]
        @test argmin(x) == CartesianIndex(2, 1)
        @test findmin(x) == (1, CartesianIndex(2, 1))
        @test argmax(x) == CartesianIndex(1, 2)
        @test findmax(x) == (2, CartesianIndex(1, 2))

        for x in (skipnan([]), skipnan([NaN, NaN]))
            @test isempty(collect(eachindex(x)))
            @test isempty(collect(keys(x)))
            @test_throws BoundsError x[3]
            @test_throws BoundsError x[3, 1]
            @test findfirst(==(2), x) === nothing
            @test isempty(findall(==(2), x))
            @test_throws "reducing over an empty collection is not allowed" argmin(x)
            @test_throws "reducing over an empty collection is not allowed" findmin(x)
            @test_throws "reducing over an empty collection is not allowed" argmax(x)
            @test_throws "reducing over an empty collection is not allowed" findmax(x)
        end
    end

    @testset "mapreduce" begin
        # Vary size to test splitting blocks with several configurations of missing values
        for T in (Int, Float64),
            A in (rand(T, 10), rand(T, 1000), rand(T, 10000))
            if T === Int
                @test sum(A) === @inferred(sum(skipnan(A))) ===
                    @inferred(reduce(+, skipnan(A))) ===
                    @inferred(mapreduce(identity, +, skipnan(A)))
            else
                @test sum(A) ≈ @inferred(sum(skipnan(A))) ===
                    @inferred(reduce(+, skipnan(A))) ===
                    @inferred(mapreduce(identity, +, skipnan(A)))
            end
            @test mapreduce(cos, *, A) ≈
                @inferred(mapreduce(cos, *, skipnan(A)))

            B = Vector{Float64}(A)
            replace!(x -> rand(Bool) ? x : NaN, B)
            @test sum(collect(skipnan(B))) ≈ @inferred(sum(skipnan(B))) ===
                @inferred(reduce(+, skipnan(B))) ===
                @inferred(mapreduce(identity, +, skipnan(B)))
            
            @test mapreduce(cos, *, collect(skipnan(A))) ≈
                @inferred(mapreduce(cos, *, skipnan(A)))

            # Test block full of missing values
            B[1:length(B)÷2] .= NaN
            @test sum(collect(skipnan(B))) ≈ sum(skipnan(B)) ==
                reduce(+, skipnan(B)) == mapreduce(identity, +, skipnan(B))
            

            @test mapreduce(cos, *, collect(skipnan(A))) ≈ mapreduce(cos, *, skipnan(A))
        end

        # Patterns that exercize code paths for inputs with 1 or 2 non-missing values
        @test sum(skipnan([1., NaN, NaN, NaN])) === 1.
        @test sum(skipnan([NaN, NaN, NaN, 1.])) === 1.
        @test sum(skipnan([1, NaN, NaN, NaN, 2.])) === 3.
        @test sum(skipnan([NaN, NaN, NaN, 1., 2.])) === 3.

        for n in 0:3
            itr = skipnan(Vector{Float64}(fill(NaN, n)))
            @test sum(itr) == reduce(+, itr) == mapreduce(identity, +, itr) === 0
            @test_throws "reducing over an empty collection is not allowed" reduce(x -> x/2, itr)
            @test_throws "reducing over an empty collection is not allowed" mapreduce(x -> x/2, +, itr)
        end
#=
        # issue #35504
        nt = NamedTuple{(:x, :y),Tuple{Union{Missing, Int},Union{Missing, Float64}}}(
            (missing, missing))
        @test sum(skipnan(nt)) === 0

        # issues #38627 and #124
        @testset for len in [1, 2, 15, 16, 1024, 1025]
            v = repeat(Union{Int,Missing}[1], len)
            oa = OffsetArray(v, typemax(Int)-length(v))
            sm = skipnan(oa)
            @test sum(sm) == len

            v = repeat(Union{Int,Missing}[missing], len)
            oa = OffsetArray(v, typemax(Int)-length(v))
            sm = skipnan(oa)
            @test sum(sm) == 0
        end
    end

    @testset "filter" begin
        allmiss = Vector{Union{Int,Missing}}(missing, 10)
        @test isempty(filter(isodd, skipnan(allmiss))::Vector{Int})
        twod1 = [1.0f0 missing; 3.0f0 missing]
        @test filter(x->x > 0, skipnan(twod1))::Vector{Float32} == [1, 3]
        twod2 = [1.0f0 2.0f0; 3.0f0 4.0f0]
        @test filter(x->x > 0, skipnan(twod2)) == reshape(twod2, (4,))
    end
end=#