# NativeNaNMath

[![Build Status](https://github.com/longemen3000/NativeNaNMath.jl/workflows/CI/badge.svg)](https://github.com/longemen3000/NativeNaNMath.jl/actions)
[![codecov](https://codecov.io/gh/longemen3000/NativeNaNMath.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/longemen3000/NativeNaNMath.jl)

Alternative approach to [NaNMath.jl](https://github.com/mlubin/NaNMath.jl), by using the functions available in Julia Base instead of the Libm ones.

It should be (almost) drop-in replacement for NaNMath.jl.

## Mathematic functions:

The following functions are not exported but defined:

- Logarithmic: 
    - `log(x)`,`log1p(x)`,`log2(x)`,`log10(x)`,`log1p(x)`
    - `log(x,base)`
- Trigonometric:
    - `sin(x)`,`cos(x)`,`tan(x)`,`cot(x)`,`sec(x)`,`csc(x)`
    - `sind(x)`,`cosd(x)`,`tand(x)`,`cotd(x)`,`secd(x)`,`cscd(x)`
    - `sinpi(x)`,`cospi(x)`
    - `sincos(x)`,`sincosd(x)`,`sincospi(x)`
    - `asin(x)`,`acos(x)`,`asec(x)`,`acsc(x)`
    - `asind(x)`,`acosd(x)`,`asecd(x)`,`acscd(x)`
- Hyperbolic:
    - `acosh(x)`,`asech(x)`,`atanh(x)`,`acoth(x)`
- `sqrt(x)`
- `pow(x,y)`
- `min(x)`,`max(x)`



## `skipnan`

The package only exports a single function: `skipnan(itr)` that works in the same way that `skipmissing(itr)`:
```julia
x = collect(1.0:10.0)
x[end] = NaN
xn = skipnan(x)
sum(xn) #45
```

## `nan`

The package uses the `nan(::Type{<:Real})` function to obtain an always valid NaN. on types that aren't capable of holding NaNs, (like all integers), it will return a promoted type that can hold NaNs (`Float64` for `Int8`,`Int16`,`Int32`,`Int64`, `BigFloat` for `BigInt`). on Rationals, `nan(Rational{T}) = nan(T)`. This function should satisfy `isnan(nan(T))`

It defaults to `zero(x)/zero(x)`.

## Differences with NaNMath.jl

- instead of providing NaN-compatible `sum`, `maximum`, `minimum`, etc. It provides a nan-skipping iterator. it can reproduce almost all functionality, except some corner cases:
    - `sum(skipnan[NaN])` is `0.0` instead of `NaN`, because `collect(skipnan([NaN])) = Float64[]` and `sum(Float64[]) == 0.0`
    - `median(skipnan([NaN])` is not defined. same reason that with `sum`
Other than that, `skipnan` expands the NaN functionality to any reducing operator.
- `pow(x::Integer,y::Integer)` will always promote to a float type.
- `NativeNaNMath.f(x)` where x is not a `Real` number will always default to `Base.f(x)`. This is useful because automatic differenciation and custom number types can use this package without overloading anything.
