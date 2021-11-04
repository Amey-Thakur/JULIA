function sayhi(name)
    println("Hi $name, it's great to see you!")
end

function f(x)
    x^2
end

sayhi("C-3PO")

f(42)

sayhi2(name) = println("Hi $name, it's great to see you!")

f2(x) = x^2

sayhi2("R2D2")

f2(42)

sayhi3 = name -> println("Hi $name, it's great to see you!")

f3 = x -> x^2

sayhi3("Chewbacca")

f3(42)

sayhi(55595472)

A = rand(3, 3)
A

f(A)

f("hi")

v = rand(3)

# This won't work
f(v)

v = [3, 5, 2]

sort(v)

v

sort!(v)

v

map(f, [1, 2, 3])

x -> x^3

map(x -> x^3, [1, 2, 3])

broadcast(f, [1, 2, 3])

f.([1, 2, 3])

A = [i + 3*j for j in 0:2, i in 1:3]

f(A)

B = f.(A)

A .+ 2 .* f.(A) ./ A

broadcast(x -> x + 2 * f(x) / x, A)

add_one(x) = x+1 

@assert add_one(1) == 2

@assert add_one(11) == 12

A = [i + 3*j for j in 0:2, i in 1:3]

A1 = map(add_one, A)

@assert A1 == [2 3 4; 5 6 7; 8 9 10]

A2 = add_one.(A1)

@assert A2 == [3 4 5; 6 7 8; 9 10 11]
