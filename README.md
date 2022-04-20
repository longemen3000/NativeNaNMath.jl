# NativeNaNMath

[![Build Status](https://github.com/longemen3000/NativeNaNMath.jl/workflows/CI/badge.svg)](https://github.com/longemen3000/NativeNaNMath.jl/actions)

Proof of concept of alternative approach to [NaNMath.jl](https://github.com/mlubin/NaNMath.jl), by using the functions available in Base instead of the Libm ones.

It should be a drop-in replacement for NaNMath.jl.

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
- `min(x)`,`max(x)`,`minmax(x)`

## `skipnan`

The package only sports a single function: `skipnan(itr)` that works in the same way that `skipmissing(itr)`:
```julia
x = collect(1.0:10.0)
x[end] = NaN
xn = skipnan(x)
sum(xn) #45
```
