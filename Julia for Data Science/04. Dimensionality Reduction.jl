# Packages we will use throughout this notebook
using UMAP
using Makie
using XLSX
using VegaDatasets
using DataFrames
using MultivariateStats
using RDatasets
using StatsBase
using Statistics
using LinearAlgebra
using Plots
using ScikitLearn
using MLBase
using Distances

C = DataFrame(VegaDatasets.dataset("cars"))

dropmissing!(C)
M = Matrix(C[:,2:7])
names(C)

car_origin = C[:,:Origin]
carmap = labelmap(car_origin) #from MLBase
uniqueids = labelencode(carmap,car_origin)

# center and normalize the data
data = M
data = (data .- mean(data,dims = 1))./ std(data,dims=1)

# each car is now a column, PCA takes features - by - samples matrix
data'

p = fit(PCA,data',maxoutdim=2)

P = projection(p)

P'*(data[1,:]-mean(p))

Yte = MultivariateStats.transform(p, data') #notice that Yte[:,1] is the same as P'*(data[1,:]-mean(p))

# reconstruct testing observations (approximately)
Xr = reconstruct(p, Yte)

norm(Xr-data') # this won't be zero

Plots.scatter(Yte[1,:],Yte[2,:])

Plots.scatter(Yte[1,car_origin.=="USA"],Yte[2,car_origin.=="USA"],color=1,label="USA")
Plots.xlabel!("pca component1")
Plots.ylabel!("pca component2")
Plots.scatter!(Yte[1,car_origin.=="Japan"],Yte[2,car_origin.=="Japan"],color=2,label="Japan")
Plots.scatter!(Yte[1,car_origin.=="Europe"],Yte[2,car_origin.=="Europe"],color=3,label="Europe")

p = fit(PCA,data',maxoutdim=3)
Yte = MultivariateStats.transform(p, data')
scatter3d(Yte[1,:],Yte[2,:],Yte[3,:],color=uniqueids,legend=false)

using GLMakie
scene = Makie.scatter(Yte[1,:],Yte[2,:],Yte[3,:],color=uniqueids)

display(scene)

@sk_import manifold : TSNE
tfn = TSNE(n_components=2) #,perplexity=20.0,early_exaggeration=50)
Y2 = tfn.fit_transform(data);
Plots.scatter(Y2[:,1],Y2[:,2],color=uniqueids,legend=false,size=(400,300),markersize=3)

L = cor(data,data,dims=2)
embedding = umap(L, 2)

Plots.scatter(embedding[1,:],embedding[2,:],color=uniqueids)

L = pairwise(Euclidean(), data, data,dims=1) 
embedding = umap(-L, 2)

Plots.scatter(embedding[1,:],embedding[2,:],color=uniqueids)


