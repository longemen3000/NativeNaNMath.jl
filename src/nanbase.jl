#This is a port of SkipMissing, but for NaNs

module NaNBase
    const BigNaN = big"NaN"

    @inline nan(::T) where T = nan(T)
    @inline nan(::Type{Float16}) = NaN16
    @inline nan(::Type{Float32}) = NaN32
    @inline nan(::Type{Float64}) = NaN64
    #TODO: define nan for integer types
    @inline nan(::Type{BigFloat}) = BigNaN
    @inline nan(::Type{BigInt}) = BigNaN
    @inline nan(::Type{T}) where T<:Real = zero(T)/zero(T)

struct SkipNaN{T}
    x::T
end

function Base.show(io::IO, s::SkipNaN)
    print(io, "skipnan(")
    show(io, s.x)
    print(io, ')')
end
"""
    skipnan(itr)
Return an iterator over the elements in `itr` skipping NaN values.
The returned object can be indexed using indices of `itr` if the latter is indexable.
Indices corresponding to NaN values are not valid: they are skipped by [`keys`](@ref)
and [`eachindex`](@ref), and a `ErrorException` is thrown when trying to use them.
Use [`collect`](@ref) to obtain an `Array` containing the non-`NaN` values in
`itr`. Note that even if `itr` is a multidimensional array, the result will always
be a `Vector` since it is not possible to remove NaNs while preserving dimensions
of the input.
# Examples
```jldoctest
julia> x = skipnan([1, NaN, 2])
skipnan([1.0, NaN, 2.0])
julia> sum(x)
3
julia> x[1]
1
julia> x[2]
ERROR: the value at index (2,) is NaN
[...]
julia> argmax(x)
3
julia> collect(keys(x))
2-element Vector{Int64}:
 1
 3
julia> collect(skipnan([1, NaN, 2]))
2-element Vector{Float64}:
 1.0
 2.0
julia> collect(skipnan([1 NaN; 2 NaN]))
2-element Vector{Float64}:
 1.0
 2.0
```
"""
skipnan(itr) = SkipNaN(itr)
Base.IteratorSize(::Type{<:SkipNaN}) = Base.SizeUnknown()
Base.IteratorEltype(::Type{SkipNaN{T}}) where {T} = Base.IteratorEltype(T)
Base.eltype(::Type{SkipNaN{T}}) where {T} = eltype(T)

function Base.iterate(itr::SkipNaN, state...)
    y = iterate(itr.x, state...)
    y === nothing && return nothing
    item, state = y
    while isnan(item)
        y = iterate(itr.x, state)
        y === nothing && return nothing
        item, state = y
    end
    item, state
end

Base.IndexStyle(::Type{<:SkipNaN{T}}) where {T} = Base.IndexStyle(T)
Base.eachindex(itr::SkipNaN) =
    Iterators.filter(i -> !isnan(@inbounds(itr.x[i])), eachindex(itr.x))
Base.keys(itr::SkipNaN) =
    Iterators.filter(i -> !isnan(@inbounds(itr.x[i])), keys(itr.x))

Base.@propagate_inbounds function Base.getindex(itr::SkipNaN, I...)
    v = itr.x[I...]
    isnan(v) && throw(Base.ErrorException("the value at index $I is NaN"))
    v
end

#fast shortcut
#if typeof(nan(x)) != typeof(x) then x cannot hold nans 
Base.mapreduce(f, op, itr::SkipNaN{<:AbstractArray}) =
    Base._mapreduce(f, op, IndexStyle(itr.x), typeof(nan(eltype(itr.x))) != eltype(itr.x) ? itr.x : itr)

function Base._mapreduce(f, op, ::Base.IndexLinear, itr::SkipNaN{<:AbstractArray})
    A = itr.x
    _nan = nan(eltype(A))
    ai = _nan
    inds = Base.LinearIndices(A)
    i = first(inds)
    ilast = last(inds)
    for outer i in i:ilast
        @inbounds ai = A[i]
        !isnan(ai) && break
    end
    isnan(ai) && return Base.mapreduce_empty(f, op, eltype(itr))
    a1::eltype(itr) = ai
    i == typemax(typeof(i)) && return Base.mapreduce_first(f, op, a1)
    i += 1
    ai = _nan
    for outer i in i:ilast
        @inbounds ai = A[i]
        !isnan(ai) && break
    end
    isnan(ai) && return Base.mapreduce_first(f, op, a1)
    # We know A contains at least two non-missing entries: the result cannot be nothing
    Base.something(Base.mapreduce_impl(f, op, itr, first(inds), last(inds)))
end

Base._mapreduce(f, op, ::Base.IndexCartesian, itr::SkipNaN) = Base.mapfoldl(f, op, itr)

Base.mapreduce_impl(f, op, A::SkipNaN, ifirst::Integer, ilast::Integer) =
    Base.mapreduce_impl(f, op, A, ifirst, ilast, Base.pairwise_blocksize(f, op))

# Returns nothing when the input contains only missing values, and Some(x) otherwise
@noinline function Base.mapreduce_impl(f, op, itr::SkipNaN{<:AbstractArray},
                                  ifirst::Integer, ilast::Integer, blksize::Int)
    A = itr.x
    if ifirst > ilast
        return nothing
    elseif ifirst == ilast
        @inbounds a1 = A[ifirst]
        if isnan(a1)
            return nothing
        else
            return Some(Base.mapreduce_first(f, op, a1))
        end
    elseif ilast - ifirst < blksize
        # sequential portion
        _nan = nan(eltype(A))
        ai = _nan
        i = ifirst
        for outer i in i:ilast
            @inbounds ai = A[i]
            !isnan(ai) && break
        end
        isnan(ai) && return nothing
        a1 = ai::eltype(itr)
        i == typemax(typeof(i)) && return Some(Base.mapreduce_first(f, op, a1))
        i += 1
        ai = _nan
        for outer i in i:ilast
            @inbounds ai = A[i]
            !isnan(ai) && break
        end
        isnan(ai) && return Some(Base.mapreduce_first(f, op, a1))
        a2 = ai::eltype(itr)
        i == typemax(typeof(i)) && return Some(op(f(a1), f(a2)))
        i += 1
        v = op(f(a1), f(a2))
        @simd for i = i:ilast
            @inbounds ai = A[i]
            if !isnan(ai)
                v = op(v, f(ai))
            end
        end
        return Some(v)
    else
        # pairwise portion
        imid = ifirst + (ilast - ifirst) >> 1
        v1 = Base.mapreduce_impl(f, op, itr, ifirst, imid, blksize)
        v2 = Base.mapreduce_impl(f, op, itr, imid+1, ilast, blksize)
        if v1 === nothing && v2 === nothing
            return nothing
        elseif v1 === nothing
            return v2
        elseif v2 === nothing
            return v1
        else
            return Some(op(something(v1), something(v2)))
        end
    end
end

end


