# some packages we will use
using LinearAlgebra
using SparseArrays
using Images
using MAT

A = rand(10,10); # created a random matrix of size 10-by-10
Atranspose = A' # matrix transpose
A = A*Atranspose; # matrix multiplication

@show A[11] == A[1,2];

b = rand(10); #created a random vector of size 10
x = A\b; #x is the solutions to the linear system Ax=b
@show norm(A*x-b)
;

@show typeof(A)
@show typeof(b)
@show typeof(rand(1,10))
@show typeof(Atranspose)
;

Matrix{Float64} == Array{Float64,2}

Vector{Float64} == Array{Float64,1}

Atranspose

?adjoint

Atranspose.parent

sizeof(A)

# To actually copy the matrix:
B = copy(Atranspose)

sizeof(B)

?\

luA = lu(A)

norm(luA.L*luA.U - luA.P*A)

qrA = qr(A)

norm(qrA.Q*qrA.R - A)

isposdef(A)

cholA = cholesky(A)

norm(cholA.L*cholA.U - A)

cholA.L

cholA.U

factorize(A)

?factorize

?diagm

# convert(Diagonal{Int64,Array{Int64,1}},diagm([1,2,3]))
Diagonal([1,2,3])

I(3)

using SparseArrays
S = sprand(5,5,2/5)

S.rowval

Matrix(S)

S.colptr

S.m

X1 = load("data/khiam-small.jpg")

@show typeof(X1)
X1[1,1] # this is pixel [1,1]

Xgray = Gray.(X1)

R = map(i->X1[i].r,1:length(X1))
R = Float64.(reshape(R,size(X1)...))

G = map(i->X1[i].g,1:length(X1))
G = Float64.(reshape(G,size(X1)...))

B = map(i->X1[i].b,1:length(X1))
B = Float64.(reshape(B,size(X1)...))
;

Z = zeros(size(R)...) # just a matrix of all zeros of equal size as the image
RGB.(Z,G,Z)

Xgrayvalues = Float64.(Xgray)

SVD_V = svd(Xgrayvalues)

norm(SVD_V.U*diagm(SVD_V.S)*SVD_V.V' - Xgrayvalues)

# use the top 4 singular vectors/values to form a new image
u1 = SVD_V.U[:,1]
v1 = SVD_V.V[:,1]
img1 = SVD_V.S[1]*u1*v1'

i = 2
u1 = SVD_V.U[:,i]
v1 = SVD_V.V[:,i]
img1 += SVD_V.S[i]*u1*v1'

i = 3
u1 = SVD_V.U[:,i]
v1 = SVD_V.V[:,i]
img1 += SVD_V.S[i]*u1*v1'

i = 4
u1 = SVD_V.U[:,i]
v1 = SVD_V.V[:,i]
img1 += SVD_V.S[i]*u1*v1'

Gray.(img1)

i = 1:100
u1 = SVD_V.U[:,i]
v1 = SVD_V.V[:,i]
img1 = u1*spdiagm(0=>SVD_V.S[i])*v1'
Gray.(img1)

norm(Xgrayvalues-img1)

M = matread("data/face_recog_qr.mat")

q = reshape(M["V2"][:,1],192,168)
Gray.(q)

b = q[:]

A = M["V2"][:,2:end]
x = A\b #Ax=b
Gray.(reshape(A*x,192,168))

norm(A*x-b)

qv = q+rand(size(q,1),size(q,2))*0.5
qv = qv./maximum(qv)
Gray.(qv)

b = qv[:];

x = A\b
norm(A*x-b)

Gray.(reshape(A*x,192,168))
