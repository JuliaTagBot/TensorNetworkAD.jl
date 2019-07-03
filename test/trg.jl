using TensorNetworkAD
using Test
using Zygote
using TensorNetworkAD: isingtensor

@testset "trg" begin
    χ = 5
    niter = 5
    foo = β -> trg(isingtensor(β), χ, niter)
    # the pytorch result with tensorgrad
    # https://github.com/wangleiphy/tensorgrad
    # clone this repo and type
    # $ python 1_ising_TRG/ising.py -chi 5 -Niter 5
    next!(pmobj)
    @test foo(0.4) ≈ 0.8919788686747141
    next!(pmobj)
    @test num_grad(foo, 0.4, δ=1e-6) ≈ Zygote.gradient(foo, 0.4)[1]
end
