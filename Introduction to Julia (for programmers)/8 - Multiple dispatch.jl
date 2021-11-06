f(x) = x.^2

f(10)

f([1, 2, 3])

foo(x::String, y::String) = println("My inputs x and y are both strings!")

foo("hello", "hi!")

foo(3, 4)

foo(x::Int, y::Int) = println("My inputs x and y are both integers!")

foo(3, 4)

foo("hello", "hi!")

methods(foo)

methods(+)

@which foo(3, 4)

@which 3.0 + 3.0

foo(x::Number, y::Number) = println("My inputs x and y are both numbers!")

foo(3.0, 4.0)

foo(x, y) = println("I accept inputs of any type!")

v = rand(3)
foo(v, v)

foo(x::Bool) = "foo with one boolean!"

foo(true)

@assert foo(true) == "foo with one boolean!"


