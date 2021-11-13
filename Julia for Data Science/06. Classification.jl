findaccuracy(predictedvals,groundtruthvals) = sum(predictedvals.==groundtruthvals)/length(groundtruthvals)

using GLMNet
using RDatasets
using MLBase
using Plots
using DecisionTree
using Distances
using NearestNeighbors
using Random
using LinearAlgebra
using DataStructures
using LIBSVM

iris = dataset("datasets", "iris")

X = Matrix(iris[:,1:4])
irislabels = iris[:,5]

X

irislabelsmap = labelmap(irislabels)
y = labelencode(irislabelsmap, irislabels)

function perclass_splits(y,at)
    uids = unique(y)
    keepids = []
    for ui in uids
        curids = findall(y.==ui)
        rowids = randsubseq(curids, at) 
        push!(keepids,rowids...)
    end
    return keepids
end

?randsubseq

trainids = perclass_splits(y,0.7)
testids = setdiff(1:length(y),trainids)

assign_class(predictedvalue) = argmin(abs.(predictedvalue .- [1,2,3]))

path = glmnet(X[trainids,:], y[trainids])
cv = glmnetcv(X[trainids,:], y[trainids])

# choose the best lambda to predict with.
path = glmnet(X[trainids,:], y[trainids])
cv = glmnetcv(X[trainids,:], y[trainids])
mylambda = path.lambda[argmin(cv.meanloss)]

path = glmnet(X[trainids,:], y[trainids],lambda=[mylambda]);

q = X[testids,:];
predictions_lasso = GLMNet.predict(path,q)

predictions_lasso = assign_class.(predictions_lasso)
findaccuracy(predictions_lasso,y[testids])

# choose the best lambda to predict with.
path = glmnet(X[trainids,:], y[trainids],alpha=0);
cv = glmnetcv(X[trainids,:], y[trainids],alpha=0)
mylambda = path.lambda[argmin(cv.meanloss)]
path = glmnet(X[trainids,:], y[trainids],alpha=0,lambda=[mylambda]);
q = X[testids,:];
predictions_ridge = GLMNet.predict(path,q)
predictions_ridge = assign_class.(predictions_ridge)
findaccuracy(predictions_ridge,y[testids])

# choose the best lambda to predict with.
path = glmnet(X[trainids,:], y[trainids],alpha=0.5);
cv = glmnetcv(X[trainids,:], y[trainids],alpha=0.5)
mylambda = path.lambda[argmin(cv.meanloss)]
path = glmnet(X[trainids,:], y[trainids],alpha=0.5,lambda=[mylambda]);
q = X[testids,:];
predictions_EN = GLMNet.predict(path,q)
predictions_EN = assign_class.(predictions_EN)
findaccuracy(predictions_EN,y[testids])

model = DecisionTreeClassifier(max_depth=2)
DecisionTree.fit!(model, X[trainids,:], y[trainids])

q = X[testids,:];
predictions_DT = DecisionTree.predict(model, q)
findaccuracy(predictions_DT,y[testids])

model = RandomForestClassifier(n_trees=20)
DecisionTree.fit!(model, X[trainids,:], y[trainids])

q = X[testids,:];
predictions_RF = DecisionTree.predict(model, q)
findaccuracy(predictions_RF,y[testids])

Xtrain = X[trainids,:]
ytrain = y[trainids]
kdtree = KDTree(Xtrain')

queries = X[testids,:]

idxs, dists = knn(kdtree, queries', 5, true)

c = ytrain[hcat(idxs...)]
possible_labels = map(i->counter(c[:,i]),1:size(c,2))
predictions_NN = map(i->parse(Int,string(string(argmax(possible_labels[i])))),1:size(c,2))
findaccuracy(predictions_NN,y[testids])

Xtrain = X[trainids,:]
ytrain = y[trainids]

model = svmtrain(Xtrain', ytrain)

predictions_SVM, decision_values = svmpredict(model, X[testids,:]')
findaccuracy(predictions_SVM,y[testids])

overall_accuracies = zeros(7)
methods = ["lasso","ridge","EN", "DT", "RF","kNN", "SVM"]
ytest = y[testids]
overall_accuracies[1] = findaccuracy(predictions_lasso,ytest)
overall_accuracies[2] = findaccuracy(predictions_ridge,ytest)
overall_accuracies[3] = findaccuracy(predictions_EN,ytest)
overall_accuracies[4] = findaccuracy(predictions_DT,ytest)
overall_accuracies[5] = findaccuracy(predictions_RF,ytest)
overall_accuracies[6] = findaccuracy(predictions_NN,ytest)
overall_accuracies[7] = findaccuracy(predictions_SVM,ytest)
hcat(methods, overall_accuracies)
