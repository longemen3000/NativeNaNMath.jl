module NativeNaNMath
using Base: IEEEFloat

const BigNaN = big"NaN"

@inline nan(::T) where T = nan(T)
@inline nan(::Type{Float16}) = NaN16
@inline nan(::Type{Float32}) = NaN32
@inline nan(::Type{Float64}) = NaN64
#TODO: define nan for integer types
@inline nan(::Type{BigFloat}) = BigNaN
@inline nan(::Type{BigInt}) = BigNaN
@inline nan(::Type{T}) where T<:Real = zero(T)/zero(T) #catch all, works with AD without specific rules

#functions with non-negative domain
for f in (:log,:log2,:log10,
        :sqrt)

    @eval begin
        $f(x) = Base.$f(x)
        function $f(x::Real)
            in_domain = x >= zero(x)
            Base.$f(ifelse(in_domain,x,nan(x)))
        end
    end
end

#two-argument log. TODO: find a better version
log(x,base) = Base.log(x,base)
function log(x::Real,base::Real)
    in_domain = (x >= zero(x)) & (base > zero(base)) 
    Base.log(ifelse(in_domain,x,nan(x)),ifelse(in_domain,base,nan(base)))
end

# comain: >= -1 
log1p(x) = Base.log1p(x)
function log1p(x::Real)
    in_domain = x >= -one(x)
    Base.log1p(ifelse(in_domain,x,nan(x)))
end


#functions with finite domain:
for f in (:sin,:sind,:sinpi,
        :cos,:cosd,:cospi,
        :tan,:tand,
        :sec,:secd,
        :cot,:cotd,
        :csc,:cscd)

    @eval begin
        $f(x) = Base.$f(x)
        function $f(x::Real)
            in_domain = !isinf(x)
            Base.$f(ifelse(in_domain,x,nan(x)))
        end
    end
end

#two calls to nan(x) seems excessive. consider using native BigFloat call instead
for f in (:sincos,:sincosd,:sincospi)
    @eval begin
        $f(x) = Base.$f(x)
        function $f(x::Real)
            in_domain = !isinf(x)
            Base.$f(ifelse(in_domain,x,nan(x)))
        end
    end
end
    
#domain: -1 <= x <= 1
for f in (:asin,:asind,
    :acos,:acosd,
    :atanh)
    @eval begin
        $f(x) = Base.$f(x)
        function $f(x::Real)
            in_domain = abs(x) <= 1
            Base.$f(ifelse(in_domain,x,nan(x)))
        end
    end
end

#domain: -Inf <= x <= -1 || 1 <= x <= Inf
for f in (:asec,:asecd,
        :acsc,:acscd,
        :acoth
    )
    @eval begin
        $f(x) = Base.$f(x)
        function $f(x::Real)
            in_domain = abs(x) >= 1
            Base.$f(ifelse(in_domain,x,nan(x)))
        end
    end
end

#domain: >= 1 
acosh(x) = Base.acosh(x)
function acosh(x::Real)
    in_domain = x >= one(x)
    Base.acosh(ifelse(in_domain,x,nan(x)))
end

#domain: 0 <= x <= 1
asech(x) = Base.asech(x)
function asech(x::Real)
    in_domain = zero(x) <= x <= one(x)  
    Base.asech(ifelse(in_domain,x,nan(x)))
end

# Don't override built-in ^ operator
function pow(x::Real, y::Real)
    z = ifelse(x>=zero(x),x,nan(x))
    return z^y
end

pow(x,y) = x^y

"""
NativeNaNMath.sum(A)
##### Args:
* `A`: An array of floating point numbers
##### Returns:
*    Returns the sum of all elements in the array, ignoring NaN's.
##### Examples:
```julia
using NativeNaNMath
NativeNaNMath.sum([1., 2., NaN]) # result: 3.0
```
"""
function sum(x::AbstractArray{T}) where T<:AbstractFloat
    if length(x) == 0
        result = zero(eltype(x))
    else
        result = convert(eltype(x), NaN)
        for i in x
            if !isnan(i)
                if isnan(result)
                    result = i
                else
                    result += i
                end
            end
        end
    end

    if isnan(result)
        @warn "All elements of the array, passed to \"sum\" are NaN!"
    end
    return result
end

"""
NativeNaNMath.median(A)
##### Args:
* `A`: An array of floating point numbers
##### Returns:
*   Returns the median of all elements in the array, ignoring NaN's.
    Returns NaN for an empty array or array containing NaNs only.
##### Examples:
```jldoctest
julia> using NativeNaNMath
julia> NativeNaNMath.median([1., 2., 3., NaN])
2.
julia> NativeNaNMath.median([1., 2., NaN])
1.5
julia> NativeNaNMath.median([NaN])
NaN
```
"""
median(x::AbstractArray{<:AbstractFloat}) = median(collect(Iterators.flatten(x)))

function median(x::AbstractVector{<:AbstractFloat})

    x = sort(filter(!isnan, x))

    n = length(x)
    if n == 0
        return convert(eltype(x), NaN)
    elseif isodd(n)
        ind = ceil(Int, n/2)
        return x[ind]
    else
        ind = Int(n/2)
        lower = x[ind]
        upper = x[ind+1]
        return (lower + upper) / 2
    end

end

"""
NativeNaNMath.maximum(A)
##### Args:
* `A`: An array of floating point numbers
##### Returns:
*    Returns the maximum of all elements in the array, ignoring NaN's.
##### Examples:
```julia
using NativeNaNMath
NativeNaNMath.maximum([1., 2., NaN]) # result: 2.0
```
"""
function maximum(x::AbstractArray{T}) where T<:AbstractFloat
    result = convert(eltype(x), NaN)
    for i in x
        if !isnan(i)
            if (isnan(result) || i > result)
                result = i
            end
        end
    end
    return result
end

"""
NativeNaNMath.minimum(A)
##### Args:
* `A`: An array of floating point numbers
##### Returns:
*    Returns the minimum of all elements in the array, ignoring NaN's.
##### Examples:
```julia
using NativeNaNMath
NativeNaNMath.minimum([1., 2., NaN]) # result: 1.0
```
"""
function minimum(x::AbstractArray{T}) where T<:AbstractFloat
    result = convert(eltype(x), NaN)
    for i in x
        if !isnan(i)
            if (isnan(result) || i < result)
                result = i
            end
        end
    end
    return result
end

"""
NativeNaNMath.extrema(A)
##### Args:
* `A`: An array of floating point numbers
##### Returns:
*    Returns the minimum and maximum of all elements in the array, ignoring NaN's.
##### Examples:
```julia
using NativeNaNMath
NativeNaNMath.extrema([1., 2., NaN]) # result: 1.0, 2.0
```
"""
function extrema(x::AbstractArray{T}) where T<:AbstractFloat
    resultmin, resultmax = convert(eltype(x), NaN), convert(eltype(x), NaN)
    for i in x
        if !isnan(i)
            if (isnan(resultmin) || i < resultmin)
                resultmin = i
            end
            if (isnan(resultmax) || i > resultmax)
                resultmax = i
            end
        end
    end
    return resultmin, resultmax
end

"""
NativeNaNMath.mean(A)
##### Args:
* `A`: An array of floating point numbers
##### Returns:
*    Returns the arithmetic mean of all elements in the array, ignoring NaN's.
##### Examples:
```julia
using NativeNaNMath
NativeNaNMath.mean([1., 2., NaN]) # result: 1.5
```
"""
function mean(x::AbstractArray{T}) where T<:AbstractFloat
    return mean_count(x)[1]
end

"""
Returns a tuple of the arithmetic mean of all elements in the array, ignoring NaN's,
and the number of non-NaN values in the array.
"""
function mean_count(x::AbstractArray{T}) where T<:AbstractFloat
    z = zero(eltype(x))
    sum = z
    count = 0
    @simd for i in x
        count += ifelse(isnan(i), 0, 1)
        sum += ifelse(isnan(i), z, i)
    end
    result = sum / count
    return (result, count)
end

"""
NativeNaNMath.var(A)
##### Args:
* `A`: A one dimensional array of floating point numbers
##### Returns:
* Returns the sample variance of a vector A. The algorithm will return
  an estimator of the  generative distribution's variance under the
  assumption that each entry of v is an IID drawn from that generative
  distribution. This computation is  equivalent to calculating \\
  sum((v - mean(v)).^2) / (length(v) - 1). NaN values are ignored.
##### Examples:
```julia
using NativeNaNMath
NativeNaNMath.var([1., 2., NaN]) # result: 0.5
```
"""
function var(x::Vector{T}) where T<:AbstractFloat
    mean_val, n = mean_count(x)
    if !isnan(mean_val)
        sum_square = zero(eltype(x))
        for i in x
            if !isnan(i)
                sum_square += (i - mean_val)^2
            end
        end
        return sum_square / (n - one(eltype(x)))
    else
        return mean_val # NaN or NaN32
    end
end

"""
NativeNaNMath.std(A)
##### Args:
* `A`: A one dimensional array of floating point numbers
##### Returns:
* Returns the standard deviation of a vector A. The algorithm will return
  an estimator of the  generative distribution's standard deviation under the
  assumption that each entry of v is an IID drawn from that generative
  distribution. This computation is  equivalent to calculating \\
  sqrt(sum((v - mean(v)).^2) / (length(v) - 1)). NaN values are ignored.
##### Examples:
```julia
using NativeNaNMath
NativeNaNMath.std([1., 2., NaN]) # result: 0.7071067811865476
```
"""
function std(x::Vector{T}) where T<:AbstractFloat
    return sqrt(var(x))
end

"""
    NativeNaNMath.min(x, y)
Compute the IEEE 754-2008 compliant minimum of `x` and `y`. As of version 0.6 of Julia,
`Base.min(x, y)` will return `NaN` if `x` or `y` is `NaN`. `NativeNaNMath.min` favors values over
`NaN`, and will return whichever `x` or `y` is not `NaN` in that case.
## Examples
```julia
julia> NativeNaNMath.min(NaN, 0.0)
0.0
julia> NativeNaNMath.min(1, 2)
1
```
"""
min(x::T, y::T) where {T<:AbstractFloat} = ifelse((y < x) | (signbit(y) > signbit(x)),
                                           ifelse(isnan(y), x, y),
                                           ifelse(isnan(x), y, x))

"""
    NativeNaNMath.max(x, y)
Compute the IEEE 754-2008 compliant maximum of `x` and `y`. As of version 0.6 of Julia,
`Base.max(x, y)` will return `NaN` if `x` or `y` is `NaN`. `NativeNaNMath.max` favors values over
`NaN`, and will return whichever `x` or `y` is not `NaN` in that case.
## Examples
```julia
julia> NativeNaNMath.max(NaN, 0.0)
0.0
julia> NativeNaNMath.max(1, 2)
2
```
"""
max(x::T, y::T) where {T<:AbstractFloat} = ifelse((y > x) | (signbit(y) < signbit(x)),
                                           ifelse(isnan(y), x, y),
                                           ifelse(isnan(x), y, x))

min(x::Real, y::Real) = min(promote(x, y)...)
max(x::Real, y::Real) = max(promote(x, y)...)

function min(x::BigFloat, y::BigFloat)
    isnan(x) && return y
    isnan(y) && return x
    return Base.min(x, y)
end

function max(x::BigFloat, y::BigFloat)
    isnan(x) && return y
    isnan(y) && return x
    return Base.max(x, y)
end

# Integers can't represent NaN
min(x::Integer, y::Integer) = Base.min(x, y)
max(x::Integer, y::Integer) = Base.max(x, y)

min(x::Real) = x
max(x::Real) = x

# Multi-arg versions
for f in (:min, :max)
    @eval ($f)(a, b, c, xs...) = Base.afoldl($f, ($f)(($f)(a, b), c), xs...)
end

end
