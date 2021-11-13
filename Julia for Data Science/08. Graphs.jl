using LightGraphs
using MatrixNetworks
using VegaDatasets
using DataFrames
using SparseArrays
using LinearAlgebra
using Plots
using VegaLite

airports = dataset("airports")
flightsairport = dataset("flights-airport")

airports

flightsairportdf = DataFrame(flightsairport)

allairports = vcat(flightsairportdf[!,:origin],flightsairportdf[!,:destination])
uairports = unique(allairports)

# create an airports data frame that has a subset of airports that are only included in the routes dataset
airportsdf = DataFrame(airports)
subsetairports = map(i->findfirst(airportsdf[!, :iata].==uairports[i]),1:length(uairports))
airportsdf_subset = airportsdf[subsetairports,:]

# build the adjacency matrix
ei_ids = findfirst.(isequal.(flightsairportdf[!,:origin]), [uairports])
ej_ids = findfirst.(isequal.(flightsairportdf[!,:destination]), [uairports])
edgeweights = flightsairportdf[!,:count]
;

A = sparse(ei_ids,ej_ids,1,length(uairports),length(uairports))
A = max.(A,A')

spy(A)

issymmetric(A)

L = SimpleGraph(A)

G=SimpleGraph(10) #SimpleGraph(nnodes,nedges) 
add_edge!(G,7,5)#modifies graph in place.
add_edge!(G,3,5)
add_edge!(G,5,2)

cc = scomponents(A)

degrees = sum(A,dims=2)[:]
p1 = plot(sort(degrees,rev=true),ylabel="log degree",legend=false,yaxis=:log)
p2 = plot(sort(degrees,rev=true),ylabel="degree",legend=false)
plot(p1,p2,size=(600,300))

maxdegreeid = argmax(degrees)
uairports[maxdegreeid]

us10m = dataset("us-10m")
@vlplot(width=500, height=300) +
@vlplot(
    mark={
        :geoshape,
        fill=:lightgray,
        stroke=:white
    },
    data={
        values=us10m,
        format={
            type=:topojson,
            feature=:states
        }
    },
    projection={type=:albersUsa},
) +
@vlplot(
    :circle,
    data=airportsdf_subset,
    projection={type=:albersUsa},
    longitude="longitude:q",
    latitude="latitude:q",
    size={value=10},
    color={value=:steelblue}
)+
@vlplot(
    :rule,
    data=flightsairport,
    transform=[
        {filter={field=:origin,equal=:ATL}},
        {
            lookup=:origin,
            from={
                data=airportsdf_subset,
                key=:iata,
                fields=["latitude", "longitude"]
            },
            as=["origin_latitude", "origin_longitude"]
        },
        {
            lookup=:destination,
            from={
                data=airportsdf_subset,
                key=:iata,
                fields=["latitude", "longitude"]
            },
            as=["dest_latitude", "dest_longitude"]
        }
    ],
    projection={type=:albersUsa},
    longitude="origin_longitude:q",
    latitude="origin_latitude:q",
    longitude2="dest_longitude:q",
    latitude2="dest_latitude:q"
)

ATL_paths = dijkstra(A,maxdegreeid)

ATL_paths[1][maxdegreeid]

maximum(ATL_paths[1])

@show stop1 = argmax(ATL_paths[1])
@show uairports[stop1]
;

@show stop2 = ATL_paths[2][stop1]
@show uairports[stop2]
;

@show stop3 = ATL_paths[2][stop2]
@show uairports[stop3]
;

@show stop4 = ATL_paths[2][stop3]
@show uairports[stop4]
;

using VegaLite, VegaDatasets

us10m = dataset("us-10m")
airports = dataset("airports")

@vlplot(width=800, height=500) +
@vlplot(
    mark={
        :geoshape,
        fill="#eee",
        stroke=:white
    },
    data={
        values=us10m,
        format={
            type=:topojson,
            feature=:states
        }
    },
    projection={type=:albersUsa},
) +
@vlplot(
    :circle,
    data=airportsdf_subset,
    projection={type=:albersUsa},
    longitude="longitude:q",
    latitude="latitude:q",
    size={value=5},
    color={value=:gray}
) +
@vlplot(
    :line,
    data={
        values=[
            {airport=:ATL,order=1},
            {airport=:SEA,order=2},
            {airport=:JNU,order=3},
            {airport=:GST,order=4}
        ]
    },
    transform=[{
        lookup=:airport,
        from={
            data=airports,
            key=:iata,
            fields=["latitude","longitude"]
        }
    }],
    projection={type=:albersUsa},
    longitude="longitude:q",
    latitude="latitude:q",
    order={field=:order,type=:ordinal}
)

nodeid = argmin(degrees)
@show uairports[nodeid]
d = dijkstra(A,nodeid)
argmax(d[1]),uairports[argmax(d[1])]

function find_path(d,id)
    shortestpath = zeros(Int,1+Int.(d[1][id]))
    shortestpath[1] = id
    for i = 2:length(shortestpath)
        shortestpath[i] = d[2][shortestpath[i-1]]
    end
    return shortestpath
end
p = find_path(d,123)
uairports[p]

?mst_prim

ti,tj,tv,nverts = mst_prim(A)

df_edges = DataFrame(:ei=>uairports[ti],:ej=>uairports[tj])

@vlplot(width=800, height=500) +
@vlplot(
    mark={
        :geoshape,
        fill="#eee",
        stroke=:white
    },
    data={
        values=us10m,
        format={
            type=:topojson,
            feature=:states
        }
    },
    projection={type=:albersUsa},
) +
@vlplot(
    :circle,
    data=airportsdf_subset,
    projection={type=:albersUsa},
    longitude="longitude:q",
    latitude="latitude:q",
    size={value=20},
    color={value=:gray}
) +
@vlplot(
    :rule,
    data=df_edges, #data=flightsairport,
    transform=[
        {
            lookup=:ei,
            from={
                data=airportsdf_subset,
                key=:iata,
                fields=["latitude", "longitude"]
            },
            as=["originx", "originy"]
        },
        {
            lookup=:ej,
            from={
                data=airportsdf_subset,
                key=:iata,
                fields=["latitude", "longitude"]
            },
            as=["destx", "desty"]
        }
    ],
    projection={type=:albersUsa},
    longitude="originy:q",
    latitude="originx:q",
    longitude2="desty:q",
    latitude2="destx:q"
)

?MatrixNetworks.pagerank

v = MatrixNetworks.pagerank(A,0.85)

sum(v)

insertcols!(airportsdf_subset,7,:pagerank_value=>v)

@vlplot(width=500, height=300) +
@vlplot(
    mark={
        :geoshape,
        fill="#eee",
        stroke=:white
    },
    data={
        values=us10m,
        format={
            type=:topojson,
            feature=:states
        }
    },
    projection={type=:albersUsa},
) +
@vlplot(
    :circle,
    data=airportsdf_subset,
    projection={type=:albersUsa},
    longitude="longitude:q",
    latitude="latitude:q",
    size="pagerank_value:q",
    color={value=:steelblue}
)

?clustercoeffs

cc = clustercoeffs(A)
cc[findall(cc.<=eps())] .= 0
cc

insertcols!(airportsdf_subset,7,:ccvalues=>cc)

@vlplot(width=500, height=300) +
@vlplot(
    mark={
        :geoshape,
        fill="#eee",
        stroke=:white
    },
    data={
        values=us10m,
        format={
            type=:topojson,
            feature=:states
        }
    },
    projection={type=:albersUsa},
) +
@vlplot(
    :circle,
    data=airportsdf_subset,
    projection={type=:albersUsa},
    longitude="longitude:q",
    latitude="latitude:q",
    size="ccvalues:q",
    color={value=:gray}
)
