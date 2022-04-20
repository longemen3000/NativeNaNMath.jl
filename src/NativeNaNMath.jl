module NativeNaNMath
using Base: IEEEFloat


 #catch all, works with AD without specific rules

include("nanbase.jl")
using .NaNBase: SkipNaN, nan, skipnan

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

# domain: >= -1 
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
    NativeNaNMath.min(x, y)
Compute the IEEE 754-2008 compliant minimum of `x` and `y`. As of version 1.6 of Julia,
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
Compute the IEEE 754-2008 compliant maximum of `x` and `y`. As of version 1.6 of Julia,
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
