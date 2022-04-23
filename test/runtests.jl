using NativeNaNMath
using NativeNaNMath: skipnan
using Test, Statistics
const randmatrix = rand(2,2)
const randdiag = [rand() 0.;0. rand()]
include("math.jl")
include("skipnan.jl")