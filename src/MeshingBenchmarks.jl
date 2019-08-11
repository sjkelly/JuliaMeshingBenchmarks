module MeshingBenchmarks

using FileIO
using NRRD
using Meshing
using MeshIO
using GeometryTypes
using BenchmarkTools

function benchmark()
    here = dirname(@__FILE__)

    println(pwd())
    ctacardio = load(here*"/../data/CTA-cardio.nrrd")
    q = -100

    samples = 1

    # flip sign on nrrd data
    # TODO Meshing should support this
    for i in eachindex(ctacardio.data)
        ctacardio.data[i] = -ctacardio.data[i]
    end

    # convert axis array to sdf
    # Meshing might want to support this format natively
    ctasdf = SignedDistanceField(HyperRectangle(Vec(0,0,0), Vec(10,10,10)),ctacardio.data)
    println("CTA-cardio.nrrd loaded")

    println("CTA-cardio.nrrd MarchingCubes Float32 runtime")
    mc = @btime HomogenousMesh{Point{3,Float32},Face{3,Int}}($ctasdf, MarchingCubes($q))
    for i in 1:samples-1
        @btime HomogenousMesh{Point{3,Float32},Face{3,Int}}($ctasdf, MarchingCubes($q))
    end

    println("CTA-cardio.nrrd MarchingCubes Float64 runtime")
    @btime HomogenousMesh{Point{3,Float64},Face{3,Int}}($ctasdf, MarchingCubes($q))
    for i in 1:samples-1
        @btime HomogenousMesh{Point{3,Float64},Face{3,Int}}($ctasdf, MarchingCubes($q))
    end

    println("CTA-cardio.nrrd MarchingTetrahedra Float32 runtime")
    mt = @btime HomogenousMesh{Point{3,Float32},Face{3,Int}}($ctasdf, MarchingTetrahedra($q))
    for i in 1:samples-1
        @btime HomogenousMesh{Point{3,Float32},Face{3,Int}}($ctasdf, MarchingTetrahedra($q))
    end

    println("Saving files")
    save("ctacardio_mc.ply", mc)
    save("ctacardio_mt.ply", mt)
end

end # module
