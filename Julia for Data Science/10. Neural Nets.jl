using Flux, Flux.Data.MNIST
using Flux: onehotbatch, argmax, crossentropy, throttle
using Base.Iterators: repeated
using Images

imgs = MNIST.images()
colorview(Gray, imgs[100])

typeof(imgs[3])

myFloat32(X) = Float32.(X)
fpt_imgs = myFloat32.(imgs) 

typeof(fpt_imgs[3])

vectorize(x) = x[:]
vectorized_imgs = vectorize.(fpt_imgs);

typeof(vectorized_imgs)

X = hcat(vectorized_imgs...)
size(X)

onefigure = X[:,3]
t1 = reshape(onefigure,28,28)
colorview(Gray,t1)

labels = MNIST.labels()
labels[1]

Y = onehotbatch(labels, 0:9)

m = Chain(
  Dense(28^2, 32, relu),
  Dense(32, 10),
  softmax)

m(onefigure)

loss(x, y) = Flux.crossentropy(m(x), y)
accuracy(x, y) = mean(argmax(m(x)) .== argmax(y))

datasetx = repeated((X, Y), 200)
C = collect(datasetx);

evalcb = () -> @show(loss(X, Y))

ps = Flux.params(m)

?Flux.train!

opt = ADAM()
Flux.train!(loss, ps, datasetx, opt, cb = throttle(evalcb, 10))

tX = hcat(float.(reshape.(MNIST.images(:test), :))...);
test_image = m(tX[:,1])

argmax(test_image) - 1

t1 = reshape(tX[:,1],28,28)
colorview(Gray, t1)

onefigure = X[:,2]
m(onefigure)

Y[:,2]
