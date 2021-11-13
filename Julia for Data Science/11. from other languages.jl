using PyCall

math = pyimport("math")
math.sin(math.pi / 4) # returns ≈ 1/√2 = 0.70710678...

python_networkx = pyimport("networkx")

py"""
import numpy
def find_best_fit_python(xvals,yvals):
    meanx = numpy.mean(xvals)
    meany = numpy.mean(yvals)
    stdx = numpy.std(xvals)
    stdy = numpy.std(yvals)
    r = numpy.corrcoef(xvals,yvals)[0][1]
    a = r*stdy/stdx
    b = meany - a*meanx
    return a,b
"""

xvals = repeat(1:0.5:10, inner=2)
yvals = 3 .+ xvals .+ 2 .* rand(length(xvals)) .-1
find_best_fit_python = py"find_best_fit_python"
a,b = find_best_fit_python(xvals,yvals)

using RCall

# we can use the rcall function
r = rcall(:sum, Float64[1.0, 4.0, 6.0])

typeof(r[1])

z = 1
@rput z

r = R"z+z"

r[1]

x = randn(10)

@rimport base as rbase
rbase.sum([1, 2, 3])

@rlibrary boot

R"t.test($x)"

using HypothesisTests
OneSampleTTest(x)

t = ccall(:clock, Int32, ())
