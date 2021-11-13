# Packages we will use throughout this notebook
using Clustering
using VegaLite
using VegaDatasets
using DataFrames
using Statistics
using JSON
using CSV
using Distances

download("https://raw.githubusercontent.com/ageron/handson-ml/master/datasets/housing/housing.csv","newhouses.csv")
houses = CSV.read("newhouses.csv", DataFrame)

names(houses)

cali_shape = JSON.parsefile("data/california-counties.json")
VV = VegaDatasets.VegaJSONDataset(cali_shape,"data/california-counties.json")

@vlplot(width=500, height=300) +
@vlplot(
    mark={
        :geoshape,
        fill=:black,
        stroke=:white
    },
    data={
        values=VV,
        format={
            type=:topojson,
            feature=:cb_2015_california_county_20m
        }
    },
    projection={type=:albersUsa},
)+
@vlplot(
    :circle,
    data=houses,
    projection={type=:albersUsa},
    longitude="longitude:q",
    latitude="latitude:q",
    size={value=12},
    color="median_house_value:q"
                    
)

names(houses)

bucketprice = Int.(div.(houses[!,:median_house_value],50000))
insertcols!(houses,3,:cprice=>bucketprice)

@vlplot(width=500, height=300) +
@vlplot(
    mark={
        :geoshape,
        fill=:black,
        stroke=:white
    },
    data={
        values=VV,
        format={
            type=:topojson,
            feature=:cb_2015_california_county_20m
        }
    },
    projection={type=:albersUsa},
)+
@vlplot(
    :circle,
    data=houses,
    projection={type=:albersUsa},
    longitude="longitude:q",
    latitude="latitude:q",
    size={value=12},
    color="cprice:n"
                    
)

X = houses[!, [:latitude,:longitude]]
C = kmeans(Matrix(X)', 10) 
insertcols!(houses,3,:cluster10=>C.assignments)

@vlplot(width=500, height=300) +
@vlplot(
    mark={
        :geoshape,
        fill=:black,
        stroke=:white
    },
    data={
        values=VV,
        format={
            type=:topojson,
            feature=:cb_2015_california_county_20m
        }
    },
    projection={type=:albersUsa},
)+
@vlplot(
    :circle,
    data=houses,
    projection={type=:albersUsa},
    longitude="longitude:q",
    latitude="latitude:q",
    size={value=12},
    color="cluster10:n"
                    
)

xmatrix = Matrix(X)'
D = pairwise(Euclidean(), xmatrix, xmatrix,dims=2) 

K = kmedoids(D,10)
insertcols!(houses,3,:medoids_clusters=>K.assignments)

@vlplot(width=500, height=300) +
@vlplot(
    mark={
        :geoshape,
        fill=:black,
        stroke=:white
    },
    data={
        values=VV,
        format={
            type=:topojson,
            feature=:cb_2015_california_county_20m
        }
    },
    projection={type=:albersUsa},
)+
@vlplot(
    :circle,
    data=houses,
    projection={type=:albersUsa},
    longitude="longitude:q",
    latitude="latitude:q",
    size={value=12},
    color="medoids_clusters:n"
                    
)

K = hclust(D)
L = cutree(K;k=10)
insertcols!(houses,3,:hclust_clusters=>L)

@vlplot(width=500, height=300) +
@vlplot(
    mark={
        :geoshape,
        fill=:black,
        stroke=:white
    },
    data={
        values=VV,
        format={
            type=:topojson,
            feature=:cb_2015_california_county_20m
        }
    },
    projection={type=:albersUsa},
)+
@vlplot(
    :circle,
    data=houses,
    projection={type=:albersUsa},
    longitude="longitude:q",
    latitude="latitude:q",
    size={value=12},
    color="hclust_clusters:n"
                    
)

?dbscan

using Distances
dclara = pairwise(SqEuclidean(), Matrix(X)',dims=2)
L = dbscan(dclara, 0.05, 10)
@show length(unique(L.assignments))

insertcols!(houses,3,:dbscanclusters3=>L.assignments)

@vlplot(width=500, height=300) +
@vlplot(
    mark={
        :geoshape,
    
        fill=:black,
        stroke=:white
    },
    data={
        values=VV,
        format={
            type=:topojson,
            feature=:cb_2015_california_county_20m
        }
    },
    projection={type=:albersUsa},
)+
@vlplot(
    :circle,
    data=houses,
    projection={type=:albersUsa},
    longitude="longitude:q",
    latitude="latitude:q",
    size={value=12},
    color="dbscanclusters3:n"
                    
)


