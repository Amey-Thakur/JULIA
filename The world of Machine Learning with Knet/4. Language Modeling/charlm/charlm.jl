using Pkg; for p in ("Knet",); haskey(Pkg.installed(),p) || Pkg.add(p); end

using Knet


struct Embed; w; end

Embed(vocab::Int,embed::Int)=Embed(param(embed,vocab))

(e::Embed)(x) = e.w[:,x]

struct Linear; w; b; end

Linear(input::Int, output::Int)=Linear(param(output,input), param0(output))

(l::Linear)(x) = l.w * mat(x,dims=1) .+ l.b

# Let's define a chain of layers
struct Chain
    layers
    Chain(layers...) = new(layers)
end
(c::Chain)(x) = (for l in c.layers; x = l(x); end; x)
(c::Chain)(x,y) = nll(c(x),y)
(c::Chain)(d::Knet.Data) = mean(c(x,y) for (x,y) in d)

CharLM(vocab::Int,input::Int,hidden::Int; o...) =
    Chain(Embed(vocab,input), RNN(input,hidden; h=0,c=0,o...), Linear(hidden,vocab))

# Sample from trained model

function generate(model,chars,n)
    reset!(m::Chain)=(for r in m.layers; r isa RNN && (r.c=r.h=0); end)
    function sample(y)
        p = Array(exp.(y)); r = rand()*sum(p)
        for j=1:length(p); (r -= p[j]) < 0 && return j; end
    end
    x = 1
    reset!(model)
    for i=1:n
        y = model([x])
        x = sample(y)
        print(chars[x])
    end
    println()
end

@info("Loading Shakespeare data")
include(Knet.dir("data","gutenberg.jl"))
trn,tst,shake_chars1 = shakespeare()
shake_text = String(shake_chars1[vcat(trn,tst)])

@info("Loading Shakespeare model")
isfile("shakespeare113.jld2") || download("http://people.csail.mit.edu/deniz/models/tutorial/shakespeare113.jld2","shakespeare113.jld2")
shake_model, shake_chars = Knet.load("shakespeare113.jld2","model","chars")

@info("Reading Julia files")
base = joinpath(Sys.BINDIR, Base.DATAROOTDIR, "julia")
julia_text = ""
for (root,dirs,files) in walkdir(base)
    for f in files
        global julia_text
        f[end-2:end] == ".jl" || continue
        julia_text *= read(joinpath(root,f),String)
    end
    # println((root,length(files),all(f->contains(f,".jl"),files)))
end

@info("Loading Julia model")
isfile("juliacharlm113.jld2") || download("http://people.csail.mit.edu/deniz/models/tutorial/juliacharlm113.jld2","juliacharlm113.jld2")
julia_model, julia_chars = Knet.load("juliacharlm113.jld2","model","chars")


nothing
