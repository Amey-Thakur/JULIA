using Pkg
Pkg.add("Example")

using Example

hello("it's me. I was wondering if after all these years you'd like to meet.")

Pkg.add("Colors")

using Colors

palette = distinguishable_colors(100)

rand(palette, 3, 3)

Pkg.add("Primes")

using Primes

@assert @isdefined Primes

primes_list = primes(1000000)

@assert primes_list == primes(1000000)


