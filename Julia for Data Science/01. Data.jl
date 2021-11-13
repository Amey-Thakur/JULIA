using BenchmarkTools
using DataFrames
using DelimitedFiles
using CSV
using XLSX
using Downloads

P = Downloads.download("https://raw.githubusercontent.com/nassarhuda/easy_data/master/programming_languages.csv",
    "programming_languages.csv")

#=
readdlm(source, 
    delim::AbstractChar, 
    T::Type, 
    eol::AbstractChar; 
    header=false, 
    skipstart=0, 
    skipblanks=true, 
    use_mmap, 
    quotes=true, 
    dims, 
    comments=false, 
    comment_char='#')
=#
P,H = readdlm("programming_languages.csv",',';header=true);

H

# To write to a text file, you can:
writedlm("programminglanguages_dlm.txt", P, '-')

C = CSV.read("programming_languages.csv", DataFrame);

@show typeof(C)
C[1:10,:]
# C.year #[!,:year]

@show typeof(P)
P[1:10,:]

names(C)

names(C)
C.year
C.language
describe(C)

@btime P,H = readdlm("programming_languages.csv",',';header=true);
@btime C = CSV.read("programming_languages.csv", DataFrame);

# To write to a *.csv file using the CSV package
CSV.write("programminglanguages_CSV.csv", DataFrame(P, :auto))

T = XLSX.readdata("data/zillow_data_download_april2020.xlsx", #file name
    "Sale_counts_city", #sheet name
    "A1:F9" #cell range
    )

G = XLSX.readtable("data/zillow_data_download_april2020.xlsx","Sale_counts_city");

G[1]

G[1][1][1:10]

G[2][1:10]

D = DataFrame(G...) # equivalent to DataFrame(G[1],G[2])

foods = ["apple", "cucumber", "tomato", "banana"]
calories = [105,47,22,105]
prices = [0.85,1.6,0.8,0.6,]
dataframe_calories = DataFrame(item=foods,calories=calories)
dataframe_prices = DataFrame(item=foods,price=prices)

DF = innerjoin(dataframe_calories,dataframe_prices,on=:item)

# we can also use the DataFrame constructor on a Matrix
DataFrame(T, :auto)

# if you already have a dataframe: 
# XLSX.writetable("filename.xlsx", collect(DataFrames.eachcol(df)), DataFrames.names(df))
XLSX.writetable("writefile_using_XLSX.xlsx",G[1],G[2])

using JLD
jld_data = JLD.load("data/mytempdata.jld")
save("mywrite.jld", "A", jld_data)

using NPZ
npz_data = npzread("data/mytempdata.npz")
npzwrite("mywrite.npz", npz_data)

using RData
R_data = RData.load("data/mytempdata.rda")
# We'll need RCall to save here. https://github.com/JuliaData/RData.jl/issues/56
using RCall
@rput R_data
R"save(R_data, file=\"mywrite.rda\")"

using MAT
Matlab_data = matread("data/mytempdata.mat")
matwrite("mywrite.mat",Matlab_data)

@show typeof(jld_data)
@show typeof(npz_data)
@show typeof(R_data)
@show typeof(Matlab_data)
;

Matlab_data

P

# Q1: Which year was was a given language invented?
function year_created(P,language::String)
    loc = findfirst(P[:,2] .== language)
    return P[loc,1]
end
year_created(P,"Julia")

year_created(P,"W")

function year_created_handle_error(P,language::String)
    loc = findfirst(P[:,2] .== language)
    !isnothing(loc) && return P[loc,1]
    error("Error: Language not found.")
end
year_created_handle_error(P,"W")

# Q2: How many languages were created in a given year?
function how_many_per_year(P,year::Int64)
    year_count = length(findall(P[:,1].==year))
    return year_count
end
how_many_per_year(P,2011)

P_df = C #DataFrame(year = P[:,1], language = P[:,2]) # or DataFrame(P)

# Even better, since we know the types of each column, we can create the DataFrame as follows:
# P_df = DataFrame(year = Int.(P[:,1]), language = string.(P[:,2]))

# Q1: Which year was was a given language invented?
# it's a little more intuitive and you don't need to remember the column ids
function year_created(P_df,language::String)
    loc = findfirst(P_df.language .== language)
    return P_df.year[loc]
end
year_created(P_df,"Julia")

year_created(P_df,"W")

function year_created_handle_error(P_df,language::String)
    loc = findfirst(P_df.language .== language)
    !isnothing(loc) && return P_df.year[loc]
    error("Error: Language not found.")
end
year_created_handle_error(P_df,"W")

# Q2: How many languages were created in a given year?
function how_many_per_year(P_df,year::Int64)
    year_count = length(findall(P_df.year.==year))
    return year_count
end
how_many_per_year(P_df,2011)

# A quick example to show how to build a dictionary
Dict([("A", 1), ("B", 2),(1,[1,2])])

P_dictionary = Dict{Integer,Vector{String}}()

#P_dictionary[67] = ["julia","programming"]

# this is not going to work.
P_dictionary["julia"] = 7

dict = Dict{Integer,Vector{String}}()
for i = 1:size(P,1)
    year,lang = P[i,:]
    if year in keys(dict)
        dict[year] = push!(dict[year],lang) 
        # note that push! is not our favorite thing to do in Julia, 
        # but we're focusing on correctness rather than speed here
    else
        dict[year] = [lang]
    end
end

# Though a smarter way to do this is:
curyear = P_df.year[1]
P_dictionary[curyear] = [P_df.language[1]]
for (i,nextyear) in enumerate(P_df.year[2:end])
    if nextyear == curyear
        #same key
        P_dictionary[curyear] = push!(P_dictionary[curyear],P_df.language[i+1])
        # note that push! is not our favorite thing to do in Julia, 
        # but we're focusing on correctness rather than speed here
    else
        curyear = nextyear
        P_dictionary[curyear] = [P_df.language[i+1]]
    end
end

length(keys(P_dictionary))

length(unique(P[:,1]))

# Q1: Which year was was a given language invented?
# now instead of looking in one long vector, we will look in many small vectors
function year_created(P_dictionary,language::String)
    keys_vec = collect(keys(P_dictionary))
    lookup = map(keyid -> findfirst(P_dictionary[keyid].==language),keys_vec)
    # now the lookup vector has `nothing` or a numeric value. We want to find the index of the numeric value.
    return keys_vec[findfirst((!isnothing).(lookup))]
end
year_created(P_dictionary,"Julia")

# Q2: How many languages were created in a given year?
how_many_per_year(P_dictionary,year::Int64) = length(P_dictionary[year])
how_many_per_year(P_dictionary,2011)

# assume there were missing values in our dataframe
P[1,1] = missing
P_df = DataFrame(year = P[:,1], language = P[:,2])

dropmissing(P_df)
