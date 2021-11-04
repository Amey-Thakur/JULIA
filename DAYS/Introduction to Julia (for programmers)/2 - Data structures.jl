myfavoriteanimals = ("penguins", "cats", "sugargliders")

myfavoriteanimals[1]

myfavoriteanimals[1] = "otters"

myfavoriteanimals = (bird = "penguins", mammal = "cats", marsupial = "sugargliders")

myfavoriteanimals[1]

myfavoriteanimals.bird

myphonebook = Dict("Jenny" => "867-5309", "Ghostbusters" => "555-2368")

myphonebook["Jenny"]

myphonebook["Kramer"] = "555-FILK"

myphonebook

pop!(myphonebook, "Kramer")

myphonebook

myphonebook[1]

myfriends = ["Ted", "Robyn", "Barney", "Lily", "Marshall"]

fibonacci = [1, 1, 2, 3, 5, 8, 13]

mixture = [1, 1, 2, 3, "Ted", "Robyn"]

myfriends[3]

myfriends[3] = "Baby Bop"

push!(fibonacci, 21)

pop!(fibonacci)

fibonacci

favorites = [["koobideh", "chocolate", "eggs"],["penguins", "cats", "sugargliders"]]

numbers = [[1, 2, 3], [4, 5], [6, 7, 8, 9]]

rand(4, 3)

rand(4, 3, 2)

fibonacci

somenumbers = fibonacci

somenumbers[1] = 404

fibonacci

# First, restore fibonacci
fibonacci[1] = 1
fibonacci

somemorenumbers = copy(fibonacci)

somemorenumbers[1] = 404

fibonacci

a_ray = [1, 2, 3]

push!(a_ray,4)

pop!(a_ray)

@assert a_ray == [1, 2, 3]

flexible_phonebook = Dict("Jenny" => 8675309, "Ghostbusters" => "555-2368")

@assert flexible_phonebook == Dict("Jenny" => 8675309, "Ghostbusters" => "555-2368")

flexible_phonebook["Emergency"] = 911

@assert haskey(flexible_phonebook, "Emergency")

@assert flexible_phonebook["Emergency"] == 911


