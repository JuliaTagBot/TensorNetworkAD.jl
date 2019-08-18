# tensor for classical 2-d model
const isingβc = log(1+sqrt(2))/2

"""
    tensorfromclassical(h::Matrix)

given a classical 2-body hamiltonian `h`, return the corresponding tensor
for use in e.g. `trg` for a two-dimensional square-lattice.

# Example
```julia
julia> model_tensor(Ising(),β) ≈ tensorfromclassical([β -β; -β β])

true
```
"""
function tensorfromclassical(ham::Matrix)
    wboltzmann = exp.(ham)
    q = sqrt(wboltzmann)
    ein"ij,ik,il,im -> jklm"(q,q,q,q)
end


"""
    model_tensor(::Ising,β)
return the isingtensor at inverse temperature `β` for a two-dimensional
grid tensor-network.
"""
function model_tensor(::Ising, β::Real)
    a = reshape(Float64[1 0 0 0; 0 0 0 0; 0 0 0 0; 0 0 0 1], 2,2,2,2)
    cβ, sβ = sqrt(cosh(β)), sqrt(sinh(β))
    q = 1/sqrt(2) * [cβ+sβ cβ-sβ; cβ-sβ cβ+sβ]
    ein"abcd,ai,bj,ck,dl -> ijkl"(a,q,q,q,q)
end

"""
    model_tensor(::Ising,β)
return the operator for the magnetisation at inverse temperature `β`
at a site in the two-dimensional ising model on a grid in tensor-network form.
"""
function mag_tensor(::Ising, β)
    a = reshape(Float64[1 0 0 0; 0 0 0 0; 0 0 0 0; 0 0 0 -1] , 2,2,2,2)
    cβ, sβ = sqrt(cosh(β)), sqrt(sinh(β))
    q = 1/sqrt(2) * [cβ+sβ cβ-sβ; cβ-sβ cβ+sβ]
    ein"abcd,ai,bj,ck,dl -> ijkl"(a,q,q,q,q)
end

"""
    magnetisation(Ising(), β, χ)

return the magnetisation of the isingmodel as a function of the inverse
temperature `β` and the environment bonddimension `χ` as calculated with
ctmrg.
"""
function magnetisation(model::MT, β, χ) where {MT <: HamiltonianModel}
    a = model_tensor(model,β)
    m = mag_tensor(model, β)
    rt = SquareCTMRGRuntime(a, Val(:random), χ)
    env, vals = ctmrg(rt; tol=1e-6, maxit=100)
    c, t = env.c, env.t
    ctc  = ein"ia,ajb,bk -> ijk"(c,t,c)
    env  = ein"alc,ckd,bjd,bia -> ijkl"(ctc,t,ctc,t)
    mag  = ein"ijkl,ijkl ->"(env,m)[]
    norm = ein"ijkl,ijkl ->"(env,a)[]

    return abs(mag/norm)
end

"""
    magofβ(β)
return the analytical result for the magnetisation at inverse temperature
`β` for the 2d classical ising model.
"""
magofβ(β) = β > isingβc ? (1-sinh(2*β)^-4)^(1/8) : 0.